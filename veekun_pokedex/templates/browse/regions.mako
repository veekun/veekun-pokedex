<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">Regions - veekun</%block>

<section>
    <h1>Regions</h1>
    ## TODO this needs way more styling!
    ## TODO could be something sweet like the front page, adapt to mobile, etc
    ## TODO also way more...  something else.  data.
    ## TODO also, would be nice to show a brief list of "important" places or pokemon...?

    <ul>
      % for region in regions:
        <li><a href="${request.resource_url(region)}">${region.name}</a></li>
      % endfor
    </ul>
</section>
