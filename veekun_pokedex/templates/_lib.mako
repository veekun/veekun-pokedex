<%! from veekun_pokedex.lib.formatting import version_initials %>

###### STANDARD LINKS

<%def name="item_link(item)">
    <a href="${request.route_url('main')}">${item_icon(item)} ${item.name}</a>
</%def>


###### SPRITES

<%def name="item_icon(item)">
    <img src="http://veekun.com/dex/media/items/${item.identifier}.png">
</%def>

<%def name="pokemon_sprite(species)">
    <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${species.id}.png">
</%def>


###### MISC UI

<%def name="version_icon(version)">\
## Ruby → R, HeartGold → HG, Black 2 → B2
## TODO: how does this play with other languages
<span class="version-${version.identifier}">${version_initials(version.name)}</span>\
</%def>
<%def name="generation_icon(generation)">
<span class="version-gen${generation.id}">${_(u'Gen {n}').format(n=generation.id)}</span>
</%def>

<%def name="any_version_icon(obj)"><%
    from pokedex.db import tables as t

    if isinstance(obj, t.Version):
        context['self'].version_icon(obj)
    elif isinstance(obj, t.VersionGroup):
        for version in obj.versions:
            context['self'].version_icon(version)
    elif isinstance(obj, t.Generation):
        context['self'].generation_icon(obj)
    else:
        raise TypeError("{0} don't look like no kinda version to me".format(obj))

%></%def>

<%def name="evolution_description(evolution)"><%

    from mako.runtime import capture

    # Written in Python cause it's fiddly.

    # XXX fix this when the pieces are hooked up
    article = lambda x, **kw: u"a"
    item_link = lambda x, **kw: x.name
    pokemon_link = lambda x, **kw: x.name
    """Crafts a human-readable description from a `pokemon_evolution` row
    object.
    """
    chunks = []

    w = context.write

    # Trigger
    if evolution.trigger.identifier == u'level-up':
        w(_(u'Level up'))
    elif evolution.trigger.identifier == u'trade':
        w(_(u'Trade'))
    elif evolution.trigger.identifier == u'use-item':
        item_link = capture(context,
            context['self'].item_link, evolution.trigger_item)
        w(_(u"Use {article} {item}").format(
            article=article(evolution.trigger_item.name, _=_),
            item=item_link))
    elif evolution.trigger.identifier == u'shed':
        w(
            _(u"Evolve {from_pokemon} ({to_pokemon} will consume "
            u"a Poké Ball and appear in a free party slot)").format(
                from_pokemon=evolution.evolved_species.parent_species.name,
                to_pokemon=evolution.evolved_species.name))
    else:
        w(_(u'Do something'))

    def w(text):
        context.write(u", ")
        context.write(text)

    # Conditions
    if evolution.gender:
        w(_(u"{0}s only").format(evolution.gender))
    if evolution.time_of_day:
        w(_(u"during the {0}").format(evolution.time_of_day))
    if evolution.minimum_level:
        w(_(u"starting at level {0}").format(evolution.minimum_level))
    if evolution.location_id:
        # TODO link
        w((_(u"around {0}")).format(
            evolution.location.name))
    if evolution.held_item_id:
        w((_(u"while holding {article} {item}")).format(
            article=article(evolution.held_item.name),
            item=item_link(evolution.held_item, include_icon=False)))
    if evolution.known_move_id:
        # TODO link
        w((_(u"knowing {0}")).format(
            evolution.known_move.name))
    if evolution.minimum_happiness:
        w(_(u"with at least {0} happiness").format(
            evolution.minimum_happiness))
    if evolution.minimum_beauty:
        w(_(u"with at least {0} beauty").format(
            evolution.minimum_beauty))
    if evolution.relative_physical_stats is not None:
        if evolution.relative_physical_stats < 0:
            op = _(u'<')
        elif evolution.relative_physical_stats > 0:
            op = _(u'>')
        else:
            op = _(u'=')
        w(_(u"when Attack {0} Defense").format(op))
    if evolution.party_species_id:
        w((_(u"with {0} in the party")).format(
            pokemon_link(evolution.party_species.default_pokemon, include_icon=False)))
    if evolution.trade_species_id:
        w((_(u"in exchange for {0}")).format(
            pokemon_link(evolution.trade_species.default_pokemon, include_icon=False)))
%></%def>
