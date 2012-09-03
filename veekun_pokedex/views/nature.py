#encoding: utf8
from sqlalchemy.orm import contains_eager, joinedload
from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

from veekun_pokedex.resource import NatureIndex


@view_config(
    context=NatureIndex,
    renderer='/browse/natures.mako')
def nature_browse(context, request):
    natures = session.query(t.Nature) \
        .join(t.Nature.names_local) \
        .options(
            contains_eager(t.Nature.names_local),
            joinedload(t.Nature.increased_stat),
            joinedload(t.Nature.decreased_stat),
            joinedload(t.Nature.likes_flavor),
            joinedload(t.Nature.hates_flavor),
        ) \
        .order_by(t.Nature.names_table.name.asc())

    # TODO table is kinda fugly still
    # TODO not sure this page is titled correctly given gene hints
    # TODO old page has sort-by-stat

    stat_hint_table = dict()
    stat_hints = session.query(t.StatHint).options(joinedload(t.StatHint.names_local))
    for stat_hint in stat_hints:
        subdict = stat_hint_table.setdefault(stat_hint.stat, {})
        subdict[stat_hint.gene_mod_5] = stat_hint.message

    return dict(
        natures=natures,
        stat_hints=stat_hint_table,
    )
