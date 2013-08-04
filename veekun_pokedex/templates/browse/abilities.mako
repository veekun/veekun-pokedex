<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>
<%namespace name="libfmt" module="veekun_pokedex.lib.formatting"/>

<%block name="title">Browse abilities - veekun</%block>

<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="name">Abilities</div>
    </div>
</nav>
<nav id="breadcrumbs">
    <ol>
        <li><a href="/">veekun</a></li>
        <li>Abilities</li>
    </ol>
</nav>
</%block>

<section>
    <table class="table-pretty">
        <thead>
            <tr class="header">
                <th>${_(u"Ability")}</th>
                <th>${_(u"Effect")}</th>
            </tr>
        </thead>
        <tbody>
        % for ability in abilities:
            <tr>
                <td>${lib.ability_link(ability)}</td>
                <td>${libfmt.render_markdown(ability, 'short_effect', inline=True)}</td>
            </tr>
        % endfor
        </tbody>
    </table>
</section>
