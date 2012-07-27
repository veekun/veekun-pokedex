#encoding: utf8
from sqlalchemy.orm import joinedload, subqueryload
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

def _build_evolution_table(evolution_chain_id):
    """Convert an evolution chain into a format more amenable to the HTML table
    model.

    Returns a nested list like:

        [
            [None, Eevee, Vaporeon, None]
            [None, None, Jolton, None]
            [None, None, Flareon, None]
            ...
        ]

    Each sublist is a physical row in the resulting table, containing one
    element per evolution stage: baby, basic, stage 1, and stage 2.  The
    individual items are objects...
    """

    # The Pokémon are actually dictionaries with 'pokemon' and 'span' keys,
    # where the span is used as the HTML cell's rowspan -- e.g., Eevee has a
    # total of seven descendents, so it would need to span 7 rows.

    evolution_table = []

    # Prefetch the evolution details
    q = session.query(t.PokemonSpecies) \
        .filter_by(evolution_chain_id=evolution_chain_id) \
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

    # Strategy: build this table going backwards.
    # Find a leaf, build the path going back up to its root.  Remember all
    # of the nodes seen along the way.  Find another leaf not seen so far.
    # Build its path backwards, sticking it to a seen node if one exists.
    # Repeat until there are no unseen nodes.
    seen_nodes = {}
    while True:
        # First, find some unseen nodes
        unseen_leaves = []
        for species in family:
            if species in seen_nodes:
                continue

            children = []
            # A Pokémon is a leaf if it has no evolutionary children, so...
            for possible_child in family:
                if possible_child in seen_nodes:
                    continue
                if possible_child.parent_species == species:
                    children.append(possible_child)
            if len(children) == 0:
                unseen_leaves.append(species)

        # If there are none, we're done!  Bail.
        # Note that it is impossible to have any unseen non-leaves if there
        # are no unseen leaves; every leaf's ancestors become seen when we
        # build a path to it.
        if len(unseen_leaves) == 0:
            break

        unseen_leaves.sort(key=lambda x: x.id)
        leaf = unseen_leaves[0]

        # root, parent_n, ... parent2, parent1, leaf
        current_path = []

        # Finally, go back up the tree to the root
        current_species = leaf
        while current_species:
            # The loop bails just after current_species is no longer the
            # root, so this will give us the root after the loop ends;
            # we need to know if it's a baby to see whether to indent the
            # entire table below
            root_pokemon = current_species

            if current_species in seen_nodes:
                current_node = seen_nodes[current_species]
                # Don't need to repeat this node; the first instance will
                # have a rowspan
                current_path.insert(0, None)
            else:
                current_node = {
                    'species': current_species,
                    'span':    0,
                }
                current_path.insert(0, current_node)
                seen_nodes[current_species] = current_node

            # This node has one more row to span: our current leaf
            current_node['span'] += 1

            current_species = current_species.parent_species

        # We want every path to have four nodes: baby, basic, stage 1 and 2.
        # Every root node is basic, unless it's defined as being a baby.
        # So first, add an empty baby node at the beginning if this is not
        # a baby.
        # We use an empty string to indicate an empty cell, as opposed to a
        # complete lack of cell due to a tall cell from an earlier row.
        if not root_pokemon.is_baby:
            current_path.insert(0, '')
        # Now pad to four if necessary.
        while len(current_path) < 4:
            current_path.append('')

        evolution_table.append(current_path)

    return evolution_table

@view_config(
    context=t.Pokemon,
    renderer='/pokemon.mako')
def pokemon(context, request):
    pokemon = context

    template_ns = dict(pokemon=pokemon)

    template_ns['evolution_table'] = _build_evolution_table(
        pokemon.species.evolution_chain_id)


    return template_ns
