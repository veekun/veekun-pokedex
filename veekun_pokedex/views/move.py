#encoding: utf8
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

@view_config(
    context=t.Move,
    renderer='/move.mako')
def move(context, request):
    move = context

    template_ns = dict(move=move)

    return template_ns
