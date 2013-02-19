<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>
<%namespace name="libfmt" module="veekun_pokedex.lib.formatting"/>

<%block name="title">Browse items - veekun</%block>

<section>
    <table class="table-pretty">
      % for item in items:
        <tr>
            <td>${lib.item_link(item)}</td>
            <td>${libfmt.render_markdown(item, 'short_effect')}</td>
        </tr>
      % endfor
    </table>
</section>
