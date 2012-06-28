from pyramid.view import view_config

import pokedex.db.tables as t

@view_config(
    context=t.Pokemon,
    renderer='/pokemon.mako')
def pokemon(context, request):
    return dict(
        pokemon=context,
    )
