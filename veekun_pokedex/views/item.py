#encoding: utf8
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

@view_config(
    context=t.Item,
    renderer='/item.mako')
def item(context, request):
    item = context

    template_ns = dict(item=item)

    return template_ns
