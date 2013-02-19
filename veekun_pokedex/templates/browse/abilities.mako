<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>
<%namespace name="libfmt" module="veekun_pokedex.lib.formatting"/>

<%block name="title">Browse abilities - veekun</%block>

<section>
    <table class="table-pretty">
      % for ability in abilities:
        <tr>
            <td>${lib.ability_link(ability)}</td>
            <td>${libfmt.render_markdown(ability, 'short_effect')}</td>
        </tr>
      % endfor
    </table>
</section>
