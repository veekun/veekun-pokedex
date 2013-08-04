<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">${ability.name} [Ability] - veekun</%block>

<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="name">${ability.name}</div>
    </div>
</nav>
<nav id="breadcrumbs">
    <ol>
        <li><a href="/">veekun</a></li>
        <li><a href="/">${_(u"Abilities")}</a></li>
        <li>${ability.name}</li>
    </ol>
</nav>
</%block>

<section>
    <h1>${_(u"Essentials")}</h1>

    <h2>${_(u"Summary")}</h2>
    ${ability.short_effect}
</section>

<section>
    <h1>${_(u"Effect")}</h1>
    ${ability.effect}
</section>

<section>
    <h1>${_(u"Flavor")}</h1>
    <h2>${_(u"Flavor text")}</h2>

    ## XXX Collapsing
    <dl class="horizontal">
    % for flavor_text_row in ability.flavor_text:
        <dt>${lib.any_version_icon(flavor_text_row.version_group)}</dt>
        <dd>${flavor_text_row.flavor_text}</dd>
    % endfor
    </dl>

    <h2>${_(u"Names")}</h2>
    ${lib.names_list(ability.name_map)}
</section>

<section>
    <h1>${_(u"Pokémon")}</h1>
    <table class="table-pretty">
        % for method, pokemon in [('normal', ability.pokemon), ('hidden', ability.hidden_pokemon)]:  ## XXX
        % if pokemon:
        <tbody>
            <tr class="header">
                ${lib.pokemon_table_headers()}
            </tr>

            <tr class="subheader">
                <th colspan="12">~~~ ${method} ~~~</th>
            </tr>

            % for p in pokemon:
            ${lib.pokemon_table_row(p)}
            % endfor
        </tbody>
        % endif
        % endfor
    </table>
</section>
