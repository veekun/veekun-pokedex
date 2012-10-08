<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">Browse types - veekun</%block>

<section>
    <h1>Type chart</h1>

    <table class="table-pretty">
        <tr class="header">
            <th></th>
          % for type_ in types:
            <th>${lib.type_icon(type_)}</th>
          % endfor
        </tr>
      % for type_ in types:
        <tr>
            <td>${lib.type_icon(type_)}</td>
          % for target_type in types:
            <td>${efficacy_map[type_][target_type]}</td>
          % endfor
        </tr>
      % endfor
    </table>
</section>
