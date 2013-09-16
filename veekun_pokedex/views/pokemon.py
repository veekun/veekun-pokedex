#encoding: utf8
from collections import defaultdict
from collections import namedtuple
import operator

from sqlalchemy import func
from sqlalchemy.orm import joinedload, subqueryload
from sqlalchemy.sql.expression import case
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

def _countif(expr):
    """SQL expression: count the number rows in an aggregate for which `expr`
    is true.
    """
    return func.sum(case({expr: 1}, else_=0))


ColumnHeader = namedtuple('ColumnHeader', ['label', 'span', 'key'])


class defaultdictkey(defaultdict):
    """defaultdict subclass that passes the key to the default_factory."""
    def __missing__(self, key):
        if self.default_factory is None:
            raise KeyError(key)

        value = self.default_factory(key)
        self[key] = value
        return value


class CollapsibleVersionGroupColumn(object):
    def __init__(self, group):
        self.group = group
        self.versions = group.versions
        self.possible_key = None
        self.pending_rows = {}
        self.uncollapsible = False

    def consider(self, version, row_key, value):
        # TODO docs blah blah
        if self.possible_key is None:
            self.possible_key = version

        if len(self.versions) == 1:
            # A version group with only one version (e.g., Platinum) can always
            # collapse
            return

        if self.uncollapsible:
            # More data won't change this
            return

        if row_key not in self.pending_rows:
            # First time we've seen this value, and there are at least two
            # versions, so this is definitely pending
            self.pending_rows[row_key] = (value, len(self.versions) - 1)
            return

        existing_value, versions_left = self.pending_rows[row_key]

        if existing_value != value:
            # Conflict; this column group will never collapse
            self.uncollapsible = True
            self.pending_rows.clear()
        elif versions_left <= 1:
            # Last version, and the value matches!  Forget about the pending
            # row
            del self.pending_rows[row_key]
        else:
            # Decrement the version count and continue on
            self.pending_rows[row_key] = value, versions_left - 1

    @property
    def can_collapse(self):
        if self.uncollapsible:
            return False
        elif self.pending_rows:
            return False
        else:
            return True

    @property
    def column_header(self):
       return ColumnHeader(label=self.group, span=len(self.versions), key=self.possible_key)


class CollapsibleVersionTable(object):
    """I represent a table where the columns are versions.  Stick data in
    me, and I'll look for duplicate columns and collapse them.

    I kind of suck!  I wish I sucked less.
    """
    def __init__(self):
        # version => { key => value }
        self._column_data = {}
        self._row_order = []
        self._row_index = set()
        self._seen_generations = set()
        self._seen_versions = set()
        self._column_groups = defaultdictkey(CollapsibleVersionGroupColumn)

    def add_version_datum(self, version, row_key, value):
        # TODO defaulting to None is busted if there's no data -- even better
        # reason to add another level of container imo
        print version, row_key, value
        if value is None:
            raise TypeError("Can't store None; it's already a special value")

        # Actually store the value
        column = self._column_data.setdefault(version, {})
        column[row_key] = value

        # Finally, some bookkeeping
        version_group = version.version_group
        generation = version_group.generation

        # Update collapsibility
        for group in (version_group, generation):
            self._column_groups[group].consider(version, row_key, value)

        self._seen_versions.add(version)
        self._seen_generations.add(generation)
        if row_key not in self._row_index:
            self._row_order.append(row_key)
            self._row_index.add(row_key)

    def add_group_datum(self, version_group, row_key, value):
        # Store for every version, in case this column ends up uncollapsed
        for version in version_group.versions:
            self.add_version_datum(version, row_key, value)

    @property
    def column_headers(self):
        return self._column_headers(self.generations, self._seen_versions)

    def _column_headers(self, generations, seen):
        groups = self._column_groups
        for gen in generations:
            if groups[gen].can_collapse:
                yield groups[gen].column_header
                continue

            for vg in gen.version_groups:
                if groups[vg].can_collapse:
                    yield groups[vg].column_header
                    continue

                for version in vg.versions:
                    if version in seen:
                        yield ColumnHeader(label=version, span=1, key=version)

    @property
    def rows(self):
        return self._rows(self.column_headers)

    def _rows(self, headers):
        headers = list(headers)  # evaluate generators
        for row_key in self._row_order:
            row = []
            for header in headers:
                row.append((
                    self._column_data.get(header.key, {}).get(row_key),
                    header.span))
            yield row_key, row

    @property
    def generations(self):
        return sorted(self._seen_generations, key=operator.attrgetter('id'))

    @property
    def generation_spans(self):
        # TODO this seems reeeeally specific
        for generation in self.generations:
            yield len(set(generation.versions) & self._seen_versions)


class SectionedCollapsibleVersionTable(object):
    def __init__(self):
        self._seen_versions = set()
        self._seen_generations = set()
        self._column_groups = defaultdictkey(CollapsibleVersionGroupColumn)
        self._section_tables = dict()
        self.sections = []

    def _table_for_section(self, section):
        if section not in self._section_tables:
            self._section_tables[section] = CollapsibleVersionTable()
            self.sections.append(section)

        return self._section_tables[section]

    def add_version_datum(self, section, version, row_key, value):
        table = self._table_for_section(section)
        table.add_version_datum(version, row_key, value)

        self._seen_versions.add(version)
        self._seen_generations.add(version.generation)

        # Update collapsibility for the entire table
        version_group = version.version_group
        generation = version_group.generation
        for group in (version_group, generation):
            self._column_groups[group].consider(version, row_key, value)

    def add_group_datum(self, section, version_group, row_key, value):
        for version in version_group.versions:
            self.add_version_datum(section, version, row_key, value)

    def sort_sections(self, key):
        self.sections.sort(key=key)

    @property
    def generations(self):
        return sorted(self._seen_generations, key=operator.attrgetter('id'))

    @property
    def generation_spans(self):
        # TODO this seems reeeeally specific
        for generation in self.generations:
            yield len(set(generation.versions) & self._seen_versions)

    def column_headers_for(self, section):
        table = self._section_tables[section]
        return table._column_headers(self.generations, self._seen_versions)

    def rows_for(self, section):
        table = self._section_tables[section]
        return table._rows(self.column_headers_for(section))



class EvolutionTableCell(object):
    def __init__(self, species):
        self.species = species
        self.rowspan = 1

    @property
    def is_empty(self):
        return self.species is None

def _build_evolution_table(evolution_chain_id):
    """Convert an evolution chain into a format more amenable to the HTML table
    model.

    Returns a nested list like:

        [
            [empty, Eevee, Vaporeon, None]
            [None, None, Jolton, None]
            [None, None, Flareon, None]
            ...
        ]

    Each sublist is a physical row in the resulting table, containing one
    element per evolution stage: baby, basic, stage 1, and stage 2.  The
    individual items are simple `EvolutionTableCell` objects: None is a cell
    that should be skipped entirely (due to rowspans) and "empty" is a cell
    object whose `is_empty` is true.
    """

    # Prefetch the evolution details
    q = session.query(t.PokemonSpecies) \
        .filter_by(evolution_chain_id=evolution_chain_id) \
        .order_by(t.PokemonSpecies.id.asc()) \
        .options(
            subqueryload('evolutions'),
            joinedload('evolutions.trigger'),
            joinedload('evolutions.trigger_item'),
            joinedload('evolutions.held_item'),
            joinedload('evolutions.location'),
            joinedload('evolutions.known_move'),
            joinedload('evolutions.party_species'),
            joinedload('parent_species'),
            joinedload('default_form'),
        )
    family = q.all()

    # Strategy: Build a row for each final-form Pokémon.  Intermediate species
    # will naturally get included.
    # We need to replace repeated cells in the same column with None and fix
    # rowspans.  Cute trick: build the table backwards, and propagate rowspans
    # upwards through the table as it's built.
    evolution_table = []

    all_parent_species = set(species.parent_species for species in family)
    final_species = [
        species for species in family
        if species not in all_parent_species
    ]
    final_species.reverse()

    for species in final_species:
        row = []
        while species:
            row.insert(0, EvolutionTableCell(species))
            species = species.parent_species

        # The last cell in the row is now either a basic or baby.  Insert a
        # blank cell (with species of None) for baby if necessary
        if not row[0].species.is_baby:
            row.insert(0, EvolutionTableCell(None))

        # Pad to four columns
        while len(row) < 4:
            row.append(EvolutionTableCell(None))

        # Compare to the previous row (which is actually the next row).  If
        # anything's repeated, absorb its rowspan and replace it with None.
        if evolution_table:
            for i, (cell, next_cell) in enumerate(zip(row, evolution_table[-1])):
                if cell.species == next_cell.species:
                    cell.rowspan += next_cell.rowspan
                    evolution_table[-1][i] = None

        evolution_table.append(row)

    evolution_table.reverse()
    return evolution_table

@view_config(
    context=t.PokemonSpecies,
    renderer='/pokemon.mako')
def pokemon(context, request):
    species = context
    default_pokemon = species.default_pokemon

    # TODO this pokemon is actually a species!!  deal with forms!!!
    template_ns = dict(
        species=species,
        pokemon=default_pokemon,
    )

    # Preload a bunch of stuff we'll always need
    # TODO share this?
    for preload_enum_table in (t.Generation, t.VersionGroup, t.Version):
        session.query(preload_enum_table).all()

    ## Type efficacy
    type_efficacies = defaultdict(lambda: 100)
    for target_type in default_pokemon.types:
        # We start at 100, and every damage factor is a percentage.  Dividing
        # by 100 with every iteration turns the damage factor into a decimal
        # percentage, without any float nonsense
        for type_efficacy in target_type.target_efficacies:
            type_efficacies[type_efficacy.damage_type] = (
                type_efficacies[type_efficacy.damage_type]
                * type_efficacy.damage_factor // 100)

    # Turn that dict of type => efficacy into a dict of efficacy => types.
    efficacy_types = {}
    for type_, efficacy in type_efficacies.items():
        efficacy_types.setdefault(efficacy, []).append(type_)

    template_ns['efficacy_types'] = efficacy_types

    ### Stats
    # This takes a lot of queries  :(
    stat_total = 0
    stat_percentiles = {}
    for pokemon_stat in default_pokemon.stats:
        stat_total += pokemon_stat.base_stat

        less = _countif(t.PokemonStat.base_stat < pokemon_stat.base_stat)
        equal = _countif(t.PokemonStat.base_stat == pokemon_stat.base_stat)
        total = func.count(t.PokemonStat.base_stat)
        q = session.query((less + equal / 2.) / total) \
            .filter_by(stat=pokemon_stat.stat)

        percentile, = q.one()

        # pg gives us fixed-point, which sqla turns into Decimal
        stat_percentiles[pokemon_stat.stat] = float(percentile)

    # Percentile for the total
    # Need to make a derived table that maps pokemon_id to total_stats
    stat_total_subq = session.query(
            t.PokemonStat.pokemon_id,
            func.sum(t.PokemonStat.base_stat).label('stat_total'),
        ) \
        .group_by(t.PokemonStat.pokemon_id) \
        .subquery()

    less = _countif(stat_total_subq.c.stat_total < stat_total)
    equal = _countif(stat_total_subq.c.stat_total == stat_total)
    total = func.count(stat_total_subq.c.stat_total)
    q = session.query((less + equal / 2.) / total)

    percentile, = q.one()
    stat_percentiles['total'] = float(percentile)

    template_ns['stat_percentiles'] = stat_percentiles
    template_ns['stat_total'] = stat_total

    ## Wild held items
    # To date (as of B/W 2), no Pokémon has ever held more than three different
    # items in its history.  So it makes sense to show wild items as a little
    # table like the move table.
    item_table = CollapsibleVersionTable()
    for pokemon_item in default_pokemon.items:
        item_table.add_version_datum(pokemon_item.version, pokemon_item.item, pokemon_item.rarity)

    template_ns['wild_held_items'] = item_table

    ## Evolution
    template_ns['evolution_table'] = _build_evolution_table(
        species.evolution_chain_id)

    ## Moves
    # XXX yeah this is bad
    q = session.query(t.PokemonMove) \
        .with_parent(default_pokemon) \
        .order_by(
            t.PokemonMove.level.asc(),
            # t.Machine.machine_number.asc(),
            t.PokemonMove.order.asc(),
            t.PokemonMove.version_group_id.asc(),
        )

    moves_table = SectionedCollapsibleVersionTable()
    for pokemove in q:
        moves_table.add_group_datum(
            pokemove.method, pokemove.version_group, pokemove.move, pokemove.level)

    _method_order = [u'level-up', 'egg', u'tutor', u'stadium-surfing-pikachu', u'machine']
    moves_table.sort_sections(lambda method: _method_order.index(method.identifier))
    template_ns['moves'] = moves_table

    return template_ns
