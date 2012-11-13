#encoding: utf8
from collections import defaultdict

from pyramid.view import view_config

import pokedex.db.tables as t
from veekun_pokedex.model import session

@view_config(
    context=t.Move,
    renderer='/move.mako')
def move(context, request):
    move = context

    template_ns = dict(move=move)

    # TODO this should possibly be shared; it's simple, but used on several
    # kinds of pages
    type_efficacies = defaultdict(lambda: 100)
    for damage_type in (move.type,):
        # We start at 100, and every damage factor is a percentage.  Dividing
        # by 100 with every iteration turns the damage factor into a decimal
        # percentage, without any float nonsense
        for type_efficacy in damage_type.damage_efficacies:
            type_efficacies[type_efficacy.target_type] = (
                type_efficacies[type_efficacy.target_type]
                * type_efficacy.damage_factor // 100)

    # Turn that dict of type => efficacy into a dict of efficacy => types.
    efficacy_types = {}
    for type_, efficacy in type_efficacies.items():
        efficacy_types.setdefault(efficacy, []).append(type_)

    template_ns['efficacy_types'] = efficacy_types

    ### Machine numbers


    return template_ns
