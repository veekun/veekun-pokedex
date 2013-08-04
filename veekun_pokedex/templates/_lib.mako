<%! from veekun_pokedex.lib.formatting import version_initials %>

################################################################################
## Standard links

<%def name="ability_link(ability)">
    <a href="${request.resource_url(ability)}">${ability.name}</a>
</%def>

<%def name="item_link(item)">
    <a href="${request.resource_url(item)}">${item_icon(item)} ${item.name}</a>
</%def>


################################################################################
## Sprites for Pokémon, items, etc.

<%def name="type_icon(type_)"><img src="http://veekun.com/dex/media/types/en/${type_.identifier}.png" alt="${type_.name}"></%def>

<%def name="item_icon(item)">
    <img src="http://veekun.com/dex/media/items/${item.identifier}.png" class="item-icon">
</%def>

<%def name="pokemon_sprite(species)">
    <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${species.id}.png">
</%def>

<%def name="damage_class_icon(class_)">
    ## XXX i18n
    <img src="http://veekun.com/dex/media/damage-classes/${class_.identifier}.png" title="${class_.name}: ${class_.description}">
</%def>

<%def name="contest_type_icon(type_)">
    ## XXX i18n
    ## XXX should be using name for title+alt
    <img src="http://veekun.com/dex/media/contest-types/en/${type_.identifier}.png" title="${type_.identifier}" alt="${type_.identifier}">
</%def>


################################################################################
## Versions, version groups, and generations

<%def name="version_icon(version)">\
## Ruby → R, HeartGold → HG, Black 2 → B2
## TODO: how does this play with other languages
## XXX switched to identifier because this is completely broken in every language wow.
<span class="version-${version.identifier}">${version_initials(version.identifier)}</span>\
</%def>

<%def name="version_name(version)">\
## TODO broken in other languages
<span class="version-${version.identifier}">${version.name}</span>\
</%def>

<%def name="generation_icon(generation)">${generation_icon_by_id(generation.id)}</%def>

## Use me to get a generation icon without a real Generation object
<%def name="generation_icon_by_id(generation_id)">
<span class="version-gen${generation_id}">Gen ${generation_id}</span>
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


################################################################################
## Large chunks of pages

<%def name="prev_next(obj)">
    <%
        # XXX this should go by name for everything but pokémon.  fuck.  do we have 'order' on all the relevant tables maybe?
        # XXX this should perhaps not live in a template
        from sqlalchemy.orm import object_session
        sess = object_session(obj)
        cls = type(obj)
        prev_obj = sess.query(cls).get(obj.id - 1)
        next_obj = sess.query(cls).get(obj.id + 1)
    %>
    <ol class="prev-next">
      % if prev_obj:
        <li class="prev">
            <a href="${request.resource_url(prev_obj)}">
                <div class="wedge"></div>
                <div class="eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${prev_obj.id}.png"></div>
                <div class="name">${prev_obj.name}</div>
            </a>
        </li>
      % else:
        <li class="prev -empty">
            <div class="wedge"></div>
        </li>
      % endif
      % if next_obj:
        <li class="next">
            <a href="${request.resource_url(next_obj)}">
                <div class="name">${next_obj.name}</div>
                <div class="eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${next_obj.id}.png"></div>
                <div class="wedge"></div>
            </a>
        </li>
      % else:
        <li class="next -empty">
            <div class="wedge"></div>
        </li>
      % endif
    </ol>
</%def>

<%def name="names_list(name_mapping)">
    <dl class="horizontal">
      ## XXX keysort
      % for language, foreign_name in name_mapping.iteritems():
      ## XXX no notion of "game language" yet
      ##% if language != c.game_language and foreign_name:
      % if foreign_name:
        <dt>
            ${language.name}
            <img src="{h.static_uri('spline', "flags/{0}.png".format(language.iso3166))}" alt="">
        </dt>
        <dd>
            ${foreign_name}
          % if language.identifier == 'ja':
            ({h.pokedex.romanize(foreign_name)})</dd>
          % endif
        </dd>
      % endif
      % endfor
    </dl>
</%def>

<%def name="pokemon_table_headers()">
    <th colspan="2">${_(u"Pokémon")}</th>
    <th>${_(u"Type")}</th>
    <th>${_(u"Abilities")}</th>
    <th>${_(u"Gender")}</th>
    <th>${_(u"Egg groups")}</th>
    <th>${_(u"HP")}</th>
    <th>${_(u"Atk")}</th>
    <th>${_(u"Def")}</th>
    <th>${_(u"SpA")}</th>
    <th>${_(u"SpD")}</th>
    <th>${_(u"Spe")}</th>
    <th>${_(u"Total")}</th>
</%def>

<%def name="pokemon_table_row(pokemon)">
    <tr>
        <td><span class="icon-eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/icons/${pokemon.species.id}.png"></span></td>

        <td><a href="${request.resource_url(pokemon)}">${pokemon.name}</a></td>

        <td>
            % for type_ in pokemon.types:
            ${type_icon(type_)}
            % endfor
        </td>

        <td>
            ## XXX style me
            <ul class="cell-list">
                % for ability in pokemon.abilities:
                <li>${ability_link(ability)}</li>
                % endfor
                % if pokemon.hidden_ability:
                <li class="hidden-ability">${ability_link(pokemon.hidden_ability)}</li>
                % endif
            </ul>
        </td>

        <td>
            gender
        </td>

        <td>
            ## XXX share some styling with the ability list
            <ul class="cell-list">
                % for egg_group in pokemon.species.egg_groups:
                <li>${egg_group.name}</li>
                % endfor
            </ul>
        </td>

        % for stat in pokemon.stats:
        <td>${stat.base_stat}</td>
        % endfor

        <td>${sum(stat.base_stat for stat in pokemon.stats)}</td>
    </tr>
</%def>

################################################################################
## Misc UI-y stuff


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
        # TODO japanese names!
        w((_(u"around {0}")).format(
            evolution.location.identifier))
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
