#encoding: utf8
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session
from veekun_pokedex.resource import ItemIndex

@view_config(
    context=ItemIndex,
    renderer='/browse/items.mako')
def item_browse(context, request):
    items = session.query(t.Item)

    template_ns = dict(
        items=items,
    )

    return template_ns

@view_config(
    context=t.Item,
    renderer='/item.mako')
def item(context, request):
    item = context

    template_ns = dict(item=item)

    return template_ns
