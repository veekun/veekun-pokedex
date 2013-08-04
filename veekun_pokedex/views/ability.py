#encoding: utf8
from pyramid.view import view_config
from sqlalchemy.orm import contains_eager, eagerload

import pokedex.db.tables as t
from veekun_pokedex.model import session
from veekun_pokedex.resource import AbilityIndex


@view_config(
    context=AbilityIndex,
    renderer='/browse/abilities.mako')
def ability_browse(context, request):
    abilities = (
        session.query(t.Ability)
        .filter_by(is_main_series=True)
        .join(t.Ability.names_local)
        .order_by(t.Ability.names_table.name.asc())
        .options(
            eagerload(t.Ability.prose_local),
            contains_eager(t.Ability.names_local),
        )
    )

    template_ns = dict(
        abilities=abilities,
    )

    return template_ns

@view_config(
    context=t.Ability,
    renderer='/ability.mako')
def ability(context, request):
    ability = context

    template_ns = dict(ability=ability)

    return template_ns
