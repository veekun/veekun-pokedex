from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session


# XXX
import veekun_pokedex.api as a



"""
rhydon
- #112
- named Rhydon
- base stats
    - hp: 105
    - attack: 130
    - defense: 120
    - special-attack: 45
    - special-defense: 45
    - speed: 40
- sprites ?????
- types
    - ground
    - rock
- abilities
    - lightningrod
    - rock head
    - reckless
"""

@view_config(route_name='api-test', renderer='json')
def api_test(context, request):
    print context
    pokemon = session.query(t.Pokemon).join(t.Pokemon.species).filter(t.PokemonSpecies.identifier == 'rhydon').one()

    hardcoded = {
        # TODO specify output language
        'name': dict(en=pokemon.name),

        'base-stats': dict((pokemon_stat.stat.identifier, pokemon_stat.base_stat) for pokemon_stat in pokemon.stats),

        # TODO sprite urls

        # TODO link these?  optionally expand them?  something??
        'types': [type_.identifier for type_ in pokemon.types],

        # TODO what to show here, either?  short effect in output language?
        'abilities': [ability.identifier for ability in pokemon.abilities],

        # TODO damage?
    }

    data = dict()

    locus = a.PokemonLocus(pokemon)
    data['identifier'] = locus.identifier

    data.update(hardcoded)

    return data

@view_config(route_name='api-search-test', renderer='json')
def api_search_test(context, request):
    q = session.query(t.Pokemon)
    q = q.join(t.Pokemon.species)

    name_crit = request.GET.getall('name')
    name_crit = filter(lambda x: x, name_crit)
    if name_crit:
        # TODO ...
        q = q.filter(t.PokemonSpecies.identifier.in_(name_crit))

    q = q.order_by(t.Pokemon.id.asc())


    results = []
    for row in q:
        results.append(dict(identifier=row.species.identifier))

    return results
