<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">${region.name} [Region] - veekun</%block>

<section>
    <h1>Places</h1>

    <ul>
      % for location in locations:
        <li><a href="${request.resource_url(location)}">${location.name}</a></li>
      % endfor
    </ul>
</section>
