#encoding: utf8
from collections import defaultdict

from sqlalchemy.orm import joinedload, subqueryload
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

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

    ## Evolution
    template_ns['evolution_table'] = _build_evolution_table(
        pokemon.species.evolution_chain_id)


    return template_ns
