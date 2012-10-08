#encoding: utf8
from pyramid.view import view_config
from sqlalchemy.orm import contains_eager

import pokedex.db.tables as t
from veekun_pokedex.model import session
from veekun_pokedex.resource import TypeIndex


@view_config(
    context=TypeIndex,
    renderer='/browse/types.mako')
def type_browse(context, request):
    types = (
        session.query(t.Type)
            .join(t.Type.names_local)
            # Force inner join here to strip out e.g. Shadow, which has no
            # efficacy
            .join(t.Type.damage_efficacies)
            .order_by(t.Type.names_table.name)
            .options(
                contains_eager(t.Type.names_local),
                contains_eager(t.Type.damage_efficacies),
            )
            .all()
    )

    efficacy_map = {}
    for attacking_type in types:
        submap = efficacy_map[attacking_type] = {}
        for efficacy in attacking_type.damage_efficacies:
            submap[efficacy.target_type] = efficacy.damage_factor


    template_ns = dict(
        types=types,
        efficacy_map=efficacy_map,
    )

    return template_ns

@view_config(
    context=t.Type,
    renderer='/type.mako')
def type(context, request):
    type_ = context

    template_ns = dict(type_=type_)

    return template_ns
