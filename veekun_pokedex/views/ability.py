#encoding: utf8
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

@view_config(
    context=t.Ability,
    renderer='/ability.mako')
def ability(context, request):
    ability = context

    template_ns = dict(ability=ability)

    return template_ns
