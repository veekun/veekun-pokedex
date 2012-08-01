#encoding: utf8
"""Helpers for formatting data for human consumption.  Generally used from
templates.
"""
import re

from markupsafe import Markup


def version_initials(name):
    # Ruby → R, HeartGold → HG, Black 2 → B2
    # TODO: how does this play with other languages
    letters = re.findall(r'(\b\w|(?<=[a-z])[A-Z])', name)
    return u''.join(letters)


def evolution_description(evolution, _=lambda x: x):
    # XXX fix this when the pieces are hooked up
    article = lambda x, **kw: x
    item_link = lambda x, **kw: x.name
    pokemon_link = lambda x, **kw: x.name
    """Crafts a human-readable description from a `pokemon_evolution` row
    object.
    """
    chunks = []

    # Trigger
    if evolution.trigger.identifier == u'level-up':
        chunks.append(_(u'Level up'))
    elif evolution.trigger.identifier == u'trade':
        chunks.append(_(u'Trade'))
    elif evolution.trigger.identifier == u'use-item':
        chunks.append(Markup(_(u"Use {article} {item}")).format(
            article=article(evolution.trigger_item.name, _=_),
            item=item_link(evolution.trigger_item, include_icon=False)))
    elif evolution.trigger.identifier == u'shed':
        chunks.append(
            _(u"Evolve {from_pokemon} ({to_pokemon} will consume "
            u"a Poké Ball and appear in a free party slot)").format(
                from_pokemon=evolution.evolved_species.parent_species.name,
                to_pokemon=evolution.evolved_species.name))
    else:
        chunks.append(_(u'Do something'))

    # Conditions
    if evolution.gender:
        chunks.append(_(u"{0}s only").format(evolution.gender))
    if evolution.time_of_day:
        chunks.append(_(u"during the {0}").format(evolution.time_of_day))
    if evolution.minimum_level:
        chunks.append(_(u"starting at level {0}").format(evolution.minimum_level))
    if evolution.location_id:
        # TODO link
        chunks.append(Markup(_(u"around {0}")).format(
            evolution.location.name))
    if evolution.held_item_id:
        chunks.append(Markup(_(u"while holding {article} {item}")).format(
            article=article(evolution.held_item.name),
            item=item_link(evolution.held_item, include_icon=False)))
    if evolution.known_move_id:
        # TODO link
        chunks.append(Markup(_(u"knowing {0}")).format(
            evolution.known_move.name))
    if evolution.minimum_happiness:
        chunks.append(_(u"with at least {0} happiness").format(
            evolution.minimum_happiness))
    if evolution.minimum_beauty:
        chunks.append(_(u"with at least {0} beauty").format(
            evolution.minimum_beauty))
    if evolution.relative_physical_stats is not None:
        if evolution.relative_physical_stats < 0:
            op = _(u'<')
        elif evolution.relative_physical_stats > 0:
            op = _(u'>')
        else:
            op = _(u'=')
        chunks.append(_(u"when Attack {0} Defense").format(op))
    if evolution.party_species_id:
        chunks.append(Markup(_(u"with {0} in the party")).format(
            pokemon_link(evolution.party_species.default_pokemon, include_icon=False)))
    if evolution.trade_species_id:
        chunks.append(Markup(_(u"in exchange for {0}")).format(
            pokemon_link(evolution.trade_species.default_pokemon, include_icon=False)))

    return Markup(u', ').join(chunks)
