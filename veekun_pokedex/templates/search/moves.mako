<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>
<%namespace name="libsearch" file="/search/_lib.mako"/>
<%namespace name="libfmt" module="veekun_pokedex.lib.formatting"/>

<%block name="title">Browse moves - veekun</%block>

<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="name">Browse moves</div>
    </div>
</nav>
</%block>


<%def name="move_panels(moves)">
    <ul class="pokemon-panels">
      % for move in moves:
        <li class="panel-${move.type.identifier}">
            ##<div class="-sprite">
            ##    <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${pokemon.species.id}${'-' + pokemon.default_form.form_identifier if pokemon.default_form and pokemon.default_form.form_identifier else ''}.png">
            ##</div>

            <div class="-header">
                <div class="-name"><a href="${request.resource_url(move)}">${move.name}</a></div>
                <div class="-types">
                ${lib.type_icon(move.type)}
                ##  · score 4
                </div>
            </div>

            <div class="-body">

            <p class="-number">
                #${move.id}
            </p>

            ${libfmt.render_markdown(move.move_effect, 'short_effect', inline=True)}

            <p class="-stats">
                <span class="-statgrp"><var>Power</var> ${move.power}</span>
                <span class="-statgrp"><var>Acc</var> ${move.accuracy}%</span>
                <span class="-statgrp"><var>PP</var> ${move.pp}</span>
                ## TODO +1,-1, color, etc.  put in a shared place plz
                <span class="-statgrp"><var>Pri</var> ${move.priority}</span>
            </p>

<!--
            <hr>

            gender...
            ground (???)
            70 happiness
            extremely slow incubation

            <hr>

            <img src="http://veekun.com/dex/media/items/oran-berry.png">
            <img src="http://veekun.com/dex/media/items/light-ball.png">

            medium

            105 base exp

            190 cap rate

            +2 speed

            <hr>

            mouse pokemon

            yellow

            forest

            <img src="http://veekun.com/dex/media/pokemon/footprints/25.png" width="32" height="32">
            <img src="http://veekun.com/dex/media/shapes/quadruped.png">

            size...
-->
            </div>
        </li>
      % endfor
    </ul>
</%def>

## name
## damage class
## generation
## flags
## same effect as
## +crit
## multihit
## multiturn
## category
## status ailment
## type
## accuracy
## pp ...
## learned by

<section>
    ## XXX action?
    <form method="GET">
        <fieldset>
            <legend>Browse</legend>
            <ul class="inline">
                <li><a href="?browse=generation" class="btn" disabled>By generation</a></li>
                <li><a href="?browse=type" class="btn">By type</a></li>
                <li><a href="?browse=type" class="btn">By type combination</a></li>
                <li><a href="?browse=type" class="btn">By egg group</a></li>
                <li><a href="?browse=type" class="btn">By gender distribution</a></li>
                <li><a href="?browse=type" class="btn">By shape</a></li>
                <li><a href="?browse=type" class="btn">By color</a></li>
                <li><a href="?browse=type" class="btn">By evolution style</a></li>
                ## XXX roughly!  also, by each stat individualls?
                <li><a href="?browse=type" class="btn">By stat total</a></li>
            </ul>
        </fieldset>
        <fieldset>
            <legend>Search</legend>


    <dl class="horizontal">
        <dt>Group by</dt>
        <dd>
            <ul class="inline">
                <li>
                    <label class="browse-pill browse-pill-radio">
                        <input type="radio">
                        <span>Don't group</span>
                    </label>
                </li>
                <!--
                <li>name</li>
                -->
                <li>
                    <label class="browse-pill browse-pill-radio">
                        <input type="radio" checked>
                        <span>Generation</span>
                    </label>
                </li>
                <li>
                    <label class="browse-pill browse-pill-radio">
                        <input type="radio">
                        <span>Type</span>
                    </label>
                </li>
                <!--
                <li>either type</li>
                <li>both types</li>
                <li>egg group</li>
                <li>gender</li>
                <li>stat average, roughly?</li>
                <li>shape</li>
                <li>color</li>
                <li>evolution</li>
                -->
            </ul>
        </dd>
        <dt>Filters</dt>
        <dd>
            <ul class="browse-filters">
                <li>Generation</li>
                <li>Type</li>
                <!--
                <li>name</li>
                <li>ability</li>
                <li>held item</li>
                <li>growth rate</li>
                <li>gender</li>
                <li>egg group</li>
                <li>species</li>
                <li>color</li>
                <li>habitat</li>
                <li>shape</li>
                <li>(type resistance?)</li>
                <li>evolution checkboxes</li>
                <li>generation</li>
                <li>regional pokedex (number)</li>
                <li>stats</li>
                <li>effort</li>
                <li>misc other numbers</li>
                <li>moves</li>
                <li>full search of everything?</li>
                <li>...</li>
                <li>form name</li>
                -->
            </ul>
        </dd>



        <% from veekun_pokedex.api import MoveLocus %>

        <dt>
            <span class="browse-pill">Generation</span>
        </dt>
        <dd>
            <div class="browse-filter-criterion">
                <%libsearch:field_select_one datum="${MoveLocus.generation}" args="generation">
                    ${lib.generation_icon(generation)}
                </%libsearch:field_select_one>
            </div>
        </dd>
        <dt>
            <span class="browse-pill">Type</span>
        </dt>
        <dd>
            <div class="browse-filter-criterion">
                <%libsearch:field_select_one datum="${MoveLocus.type}" args="type_">
                    ${lib.type_icon(type_)}
                </%libsearch:field_select_one>
            </div>
        </dd>
        <dt>
            <span class="browse-pill">Damage class</span>
        </dt>
        <dd>
            <div class="browse-filter-criterion">
                <%libsearch:field_select_one datum="${MoveLocus.damage_class}" args="damage_class">
                    ${damage_class.identifier}
                </%libsearch:field_select_one>
            </div>
        </dd>





        <dt>Sort by</dt>
        <dd>
            <ul>
                <li class="selected">ID</li>
            </ul>
        </dd>
        <!--
        <dt>Options</dt>
        <dd>
            <li>show formless, forms only</li>
            <li>cluster evolutions together somehow in panel mode?</li>
        </dd>
        -->
        <dt>Show</dt>
        <dd>
            <ul>
                <li class="selected">Summary</li>
                <!--
                <li>sprites (of any gen!)  (shiny, etc?)</li>
                <li>icons</li>
                <li>sugimori?</li>
                <li>...</li>
                -->
            </ul>
        </dd>

        <dd><button type="submit">Update</button></dd>
    </dl>


        </fieldset>
    </form>

    <hr>

  % for group in move_groups:
    <details>
        <summary>
            <a href="XXX"><!-- ▾ --> ▸ ${group.name}</a> ×${len(moves[group])}
            <ul class="browse-examples">
                ##% for preview_move in move_previews[group]:
                ##<li><div class="eyeball-crop">${lib.move_sprite(preview_move.species)}</div></li>
                ##% endfor
            </ul>
        </summary>
        % if did_search:

            ${move_panels(moves[group])}
            ##${moves[group]}

        % endif
    </details>
  % endfor
</section>
