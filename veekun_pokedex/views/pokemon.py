#encoding: utf8
from collections import defaultdict
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

class CollapsibleVersionTable(object):
    """I represent a table where the columns are versions.  Stick data in
    me, and I'll look for duplicate columns and collapse them.

    I kind of suck!  I wish I sucked less.
    """
    _baked = False

    def __init__(self):
        # version => { key => value }
        self._column_data = {}
        self._uncollapsible = set()
        self._row_order = []
        self._row_index = set()
        self._seen_generations = set()

    def set(self, version, row_key, value):
        # Actually store the value
        column = self._column_data.setdefault(version, {})
        column[row_key] = value

        # Possibly un-collapse columns
        version_group = version.version_group
        generation = version_group.generation

        if version_group in self._column_data:
            if row_key in self._column_data[version_group] and \
                    self._column_data[version_group][row_key] != value:
                self._uncollapsible.add(version_group)
                self._uncollapsible.add(generation)
        else:
            self._column_data[version.version_group] = column

        if generation in self._column_data:
            if row_key in self._column_data[generation] and \
                    self._column_data[generation][row_key] != value:
                self._uncollapsible.add(generation)
        else:
            self._column_data[version.generation] = column

        # Bookkeeping
        self._seen_generations.add(generation)
        if row_key not in self._row_index:
            self._row_order.append(row_key)
            self._row_index.add(row_key)

    def bake(self):
        self._baked = True

        self._columns = []
        for generation in sorted(self._seen_generations, key=operator.attrgetter('id')):
            if generation in self._uncollapsible or any(version_group not in self._column_data for version_group in generation.version_groups):
                for version_group in generation.version_groups:
                    if version_group not in self._column_data:
                        continue

                    if version_group in self._uncollapsible or any(version not in self._column_data for version in version_group.versions):
                        self._columns.extend(version for version in version_group.versions if version in self._column_data)
                    else:
                        self._columns.append(version_group)
            else:
                self._columns.append(generation)


    @property
    def column_headers(self):
        return self._columns

    @property
    def rows(self):
        for row_key in self._row_order:
            class Foo(list): pass
            row = Foo()
            for column in self._columns:
                row.append(self._column_data.get(column, {}).get(row_key))
            row.key = row_key
            yield row


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
    context=t.Pokemon,
    renderer='/pokemon.mako')
def pokemon(context, request):
    pokemon = context

    template_ns = dict(pokemon=pokemon)

    ## Type efficacy
    type_efficacies = defaultdict(lambda: 100)
    for target_type in pokemon.types:
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
    for pokemon_stat in pokemon.stats:
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
    for pokemon_item in pokemon.items:
        item_table.set(pokemon_item.version, pokemon_item.item, pokemon_item.rarity)
    item_table.bake()

    template_ns['wild_held_items'] = item_table

    ## Evolution
    template_ns['evolution_table'] = _build_evolution_table(
        pokemon.species.evolution_chain_id)


    return template_ns
