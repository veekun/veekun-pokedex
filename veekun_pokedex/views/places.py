#encoding: utf8
from __future__ import division

from pyramid.view import view_config
from sqlalchemy.orm import contains_eager, joinedload, subqueryload

import pokedex.db.tables as t
from veekun_pokedex.model import session
from veekun_pokedex.resource import PlaceIndex, RegionIndex


class LevelAccumulator(object):
    def __init__(self):
        self._ranges = [(1, 100, 0)]
        self.total_rarity = 0
        self.total_range = None

    def add_from_encounter(self, encounter):
        self.add(encounter.min_level, encounter.max_level, encounter.slot.rarity)

    def add(self, left, right, rarity):
        self.total_rarity += rarity
        if self.total_range:
            curleft, curright = self.total_range
            self.total_range = min(left, curleft), max(right, curright)
        else:
            self.total_range = left, right

        given_width = right - left + 1
        new_ranges = []

        for range_left, range_right, range_rarity in self._ranges:
            if right < range_left or range_right < left:
                # No overlap
                new_ranges.append((range_left, range_right, range_rarity))
                continue

            range_width = range_right - range_left + 1

            # Two possible places where the two ends of the new range might
            # intersect this one, making for three potential new ranges
            if range_left <= left <= range_right:
                mid1 = left
            else:
                mid1 = range_left

            if range_left <= right <= range_right:
                mid2 = right
            else:
                mid2 = range_right

            for midleft, midright in (
                    (range_left, mid1 - 1),
                    (mid1, mid2),
                    (mid2 + 1, range_right)):

                width = midright - midleft + 1
                if width <= 0:
                    continue

                new_rarity = range_rarity * width / range_width
                if (midleft, midright) == (mid1, mid2):
                    # Add in the requested rarity too
                    new_rarity += rarity * width / given_width

                new_ranges.append((midleft, midright, new_rarity))

            left = range_right + 1

        self._ranges = new_ranges

    def __repr__(self):
        return repr(self._ranges)



def _pokemon_condition_sort_key(item):
    (pokemon, simplest_condition), encounter_collection = item
    if simplest_condition:
        # Conditioned rows are sorted after defaults, by the condition
        return 1, min(cv.id for cv in simplest_condition), pokemon.id
    else:
        # Defaults are sorted first, by rarity (descending)
        return (
            0,
            - sum(e.slot.rarity for e in encounter_collection._encounters),
            pokemon.id)

class EncounterCollection(object):
    """Takes a clusterfuck (that's a technical term) of encounters and attempts
    to smooth them out into a saner form.

    The various `partition_by_*` methods group the encounters by some property
    and yield pairs of `(property, subcollection)`.
    """

    DIMENSIONS = frozenset((
        'area', 'method', 'version', 'pokemon', 'condition_values'))

    def __init__(self, encounters, **kwargs):
        assert set(kwargs.keys()) <= self.DIMENSIONS

        self._encounters = encounters
        self._existing_filters = kwargs


    def partition_by_area(self):
        return self._partition_by(
            'area',
            lambda e: e.location_area,
            lambda area: area.name,
        )

    def partition_by_method(self):
        return self._partition_by(
            'method',
            lambda e: e.slot.method,
            lambda method: method.id,
        )

    def partition_by_version(self):
        return self._partition_by(
            'version',
            lambda e: e.version,
            lambda version: version.id,
        )

    def partition_by_pokemon(self):
        return self._partition_by(
            'pokemon',
            lambda e: e.pokemon,
            lambda pokemon: pokemon.name,
        )

    def partition_by_condition_values(self):
        # Some special handling here.  If e.g. slot 1 contains Rattata during
        # the day, and we have another encounter that puts Rattata in slot 1 in
        # the morning, skip that latter encounter.  (At the moment, this should
        # only apply to time-of-day; all other conditions only have two values,
        # and if they're identical then we only have one row.)

        # Step one: figure out what can appear under default conditions
        default_encounters = set()
        for e in self._encounters:
            if any(not cv.is_default for cv in e.condition_values):
                continue

            default_encounters.add((e.location_area, e.version, e.slot, e.pokemon))

        # Step two: strip out anything that matches the default conditions.
        # (But leave the actual default rows in, of course.)
        filtered_encounters = []
        for e in self._encounters:
            if all(cv.is_default for cv in e.condition_values) or \
                    (e.location_area, e.version, e.slot, e.pokemon) not in default_encounters:
                filtered_encounters.append(e)

        # Then partition as usual.
        return self._partition_by(
            'condition_values',
            lambda e: tuple(cv for cv in e.condition_values if not cv.is_default),
            lambda cvs: len(cvs),
            encounters=filtered_encounters,
        )

    def partition_by_pokemon_condition_values(self):
        # If we have a row with a default condition value, ignore rows with
        # another value for the same condition -- i.e., if we have a row that
        # only applies with the radio OFF, ignore rows that apply with the
        # radio ON, because that's not new or interesting.
        pokemon_conditions_with_defaults = {}
        pokemon_nondefault_conditions = {}
        for e in self._encounters:
            conditions_with_defaults = pokemon_conditions_with_defaults.setdefault(e.pokemon, set())
            for cv in e.condition_values:
                if cv.is_default:
                    conditions_with_defaults.add(cv.condition)

            nondefault_conditions = pokemon_nondefault_conditions.setdefault(e.pokemon, {})
            nondefault_key = tuple(cv for cv in e.condition_values if not cv.is_default)
            nondefault_conditions.setdefault(nondefault_key, []).append(e)

        # Figure out the easiest way (i.e., fewest non-default conditions) to
        # get each Pokémon.  In the case of ties, go with whatever makes them
        # most common.
        partitioned_collections = []
        for pokemon, nondefault_conditions in pokemon_nondefault_conditions.items():
            simplest_condition = min(nondefault_conditions.keys(),
                key=lambda cvs: (len(cvs), [cv.id for cv in cvs]))

            filters = dict(pokemon=pokemon, condition_values=simplest_condition)
            filters.update(self._existing_filters)

            partitioned_collections.append((
                (pokemon, simplest_condition),
                EncounterCollection(
                    nondefault_conditions[simplest_condition], **filters)))

        partitioned_collections.sort(key=_pokemon_condition_sort_key)

        return partitioned_collections

    def _partition_by(self, filter_name, get_key, sort_func, encounters=None):
        assert filter_name not in self._existing_filters

        if encounters is None:
            encounters = self._encounters

        keys = []
        encounter_map = {}
        for encounter in encounters:
            key = get_key(encounter)
            if key not in encounter_map:
                encounter_map[key] = []
                keys.append(key)

            encounter_map[key].append(encounter)

        keys.sort(key=sort_func)

        for key in keys:
            filters = {filter_name: key}
            filters.update(self._existing_filters)
            yield key, EncounterCollection(encounter_map[key], **filters)


    def collect_versions(self):
        versions = set(encounter.version for encounter in self._encounters)
        return list(sorted(versions, key=lambda version: version.id))

    def collect_level_ranges(self):
        assert set(self._existing_filters.keys()) == self.DIMENSIONS

        level_ranges = LevelAccumulator()
        for encounter in self._encounters:
            level_ranges.add_from_encounter(encounter)

        return level_ranges


@view_config(
    context=RegionIndex,
    renderer='/browse/regions.mako')
def region_browse(context, request):
    regions = (
        session.query(t.Region)
            .all()
    )

    template_ns = dict(
        regions=regions,
    )

    return template_ns

@view_config(
    context=PlaceIndex,
    renderer='/region.mako')
def region(context, request):
    region = context.parent_row

    template_ns = dict()
    template_ns['region'] = region

    locations = (
        session.query(t.Location)
            .with_parent(region)
            .join(t.Location.names_local)
            .order_by(t.Location.names_table.name)
            .options(
                contains_eager(t.Location.names_local)
            )
    )
    template_ns['locations'] = locations

    return template_ns

@view_config(
    context=t.Location,
    renderer='/place.mako')
def place(context, request):
    location = context

    template_ns = dict()
    template_ns['location'] = location

    # Eagerload
    (session.query(t.Location)
        .filter_by(id=location.id)
        .options(
            joinedload('areas'),
            subqueryload('areas.encounters'),
            joinedload('areas.encounters.condition_values'),
            joinedload('areas.encounters.condition_values.condition'),
        )
        .all()
    )

    encounters = EncounterCollection([
        encounter
        for area in location.areas
        for encounter in area.encounters
    ])
    template_ns['fudged_encounters'] = encounters

    return template_ns
