#encoding: utf8
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

@view_config(
    context=t.Type,
    renderer='/type.mako')
def type(context, request):
    type_ = context

    template_ns = dict(type_=type_)

    return template_ns
