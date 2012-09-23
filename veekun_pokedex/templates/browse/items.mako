<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">Browse items - veekun</%block>

<section>
    <table class="table-pretty">
      % for item in items:
        <tr>
            <td>${lib.item_link(item)}</td>
            <td>${item.prose_local.short_effect}</td>
        </tr>
      % endfor
    </table>
</section>
