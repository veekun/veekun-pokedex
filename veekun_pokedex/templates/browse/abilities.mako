<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">Browse abilities - veekun</%block>

<section>
    <table class="table-pretty">
      % for ability in abilities:
        <tr>
            <td>${lib.ability_link(ability)}</td>
            <td>${ability.prose_local.short_effect}</td>
        </tr>
      % endfor
    </table>
</section>
