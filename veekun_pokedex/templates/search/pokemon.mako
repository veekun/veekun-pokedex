<%! from veekun_pokedex.resource import PokemonIndex %>

<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>
<%namespace name="libsearch" file="/search/_lib.mako"/>
<%namespace name="libfmt" module="veekun_pokedex.lib.formatting"/>

<%block name="title">Explore Pokémon - veekun</%block>

<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="name">Explore Pokémon</div>
    </div>
</nav>
% if did_search:
<nav id="breadcrumbs">
    <ol>
        <li><a href="${request.path_url}">Explore</a></li>
        ## XXX this could stand to be more specific
        <li>Results</li>
    </ol>
</nav>
% endif
</%block>

################################################################################
## ACTUAL PAGE CONTENTS (all the rest is defs)

% if did_search:
    <section>
        ## XXX this could stand to be more specific
        <h1>Results</h1>
        <p>Found ${len(results)} Pokémon.</p>
        ## TODO: could put so so so much more here
        ## show that for browse as well?
        ## what about forms vs species?
        ## need more something something details here

        ## histogram if grouped ...
        ## allow choosing some at random ...

        % if results.grouped:
            % for group in results.groups:
            <% group_pokemon = results.rows_in_group(group) %>
            <details class="xxx-search-groups">
                <summary>
                    <a href="XXX">${group.name}</a> ×${len(group_pokemon)}
                    <ul class="browse-examples">
                        % for preview_pokemon in results.previews_for_group(group):
                        <li><div class="eyeball-crop">${lib.pokemon_sprite(preview_pokemon.species)}</div></li>
                        % endfor
                    </ul>
                </summary>

                    ##${pokemon_panels(group_pokemon)}

                    ${pokemon_mini_panels(group_pokemon)}

            </details>
            % endfor
        % else:
        ${pokemon_mini_panels(results)}
        % endif
    </section>
% else:
    ${show_browse_options()}
% endif

${search_form()}

## END ACTUAL PAGE CONTENTS
################################################################################

<%def name="show_browse_options()">
<section>
    <h1>Browse</h1>

    <ul class="large-tiles">
        <li class="-fullwidth"><a href="${request.resource_url(PokemonIndex, query=dict(all=u'1'))}">All Pokémon</a></li>
        <li><a href="XXX"><img src="http://veekun.com/dex/media/items/retro-mail.png"> By generation</a></li>
        <li><a href="XXX">By type</a></li>
        <li><a href="XXX">By both types</a></li>
        <li><a href="XXX">By egg group</a></li>
        <li><a href="XXX">By gender</a></li>
        <li><a href="XXX"><img src="http://veekun.com/dex/media/shapes/quadruped.png"> By shape</a></li>
        <li><a href="XXX">By color</a></li>
        <li><a href="XXX">By evolution</a></li>
    </ul>
</section>

<section>
    <h1>Convenient lists of Pokémon</h1>


</section>
</%def>


<%def name="search_form()">
<section>
    <h1>Custom</h1>

    <% from veekun_pokedex.api import PokemonLocus %>
    <div class="columns">
        <section class="col4">
        <details>
            <summary>General</summary>

        </details>
        </section>

        <section class="col4">
        <details class="col4">
            <summary>Type</summary>

            <%libsearch:field_select_several datum="${PokemonLocus.type}" args="type">
                ${lib.type_icon(type)}
            </%libsearch:field_select_several>
        </details>
        </section>

        <section class="col4">
        <details class="col4">
            <summary>Evolution</summary>

            <p>Stage: [ ] baby  [ ] basic  [ ] stage 1  [ ] stage 2</p>

            <p>Position: [ ] first  [ ] middle  [ ] final  [ ] only</p>

            <p>[ ] Has multiple evolutions</p>

            <p>[ ] Has "sibling" evolutions</p>
        </details>
        </section>
    </div>

    <div class="columns">
        <section class="col4">
        <details>
            <summary>Generation</summary>

            <p>First introduced in:</p>
            ## TODO i don't much like that this takes over the <ul> and <li> and whatnot for me
            <%libsearch:field_select_one datum="${PokemonLocus.generation}" args="generation">
                ${lib.generation_icon(generation)}
            </%libsearch:field_select_one>

        </details>
        </section>

        <section class="col4">
        <details class="col4">
            <summary>Regional Pokédex</summary>
            <ul>
                <li>[ ] kanto</li>
            </ul>
        </details>
        </section>

        <section class="col4">
        <details class="col4">
            <summary>Flavor</summary>

            <p>genus</p>
            <p>color</p>
            <p>habitat</p>
            <p>shape</p>
        </details>
        </section>
    </div>

    <dl class="horizontal">
        <dt>Sort by</dt>
        <dd>( ) National ID
            <br>
            [ ] Reverse  (default order is A first, 9 first)
        </dd>

        <dt>Group by</dt>
        <dd>( ) Nothing  ( ) Generation</dd>

        <dt>Show as</dt>
        <dd>
            <ul>
                <li><input type="radio"> Small panels</li>
            </ul>
        </dd>

        <dt>Special options</dt>
        <dd>( ) </dd>

        <dd>
            <button type="submit" class="btn btn-submit">Search</button>
        </dd>
    </dl>
</section>
</%def>

################################################################################

<%def name="pokemon_mini_panels(pokemons)">
<ul class="pokemon-mini-panels">
    % for pokemon in pokemons:
    <li class="panel-${pokemon.types[0].identifier}">
        <a href="${request.resource_url(pokemon)}">
            <div class="-name">${pokemon.species.name}</div>
            ####% if not pokemon.is_default:
            ##% if pokemon.default_form.form_name:
            ##<div class="-subheader">${pokemon.default_form.form_name}</div>
            ##% endif
            <div class="-info">
                #${pokemon.species_id} <br>
                % for type_ in pokemon.types:
                    ${lib.type_icon(type_)}
                % endfor
            </div>
            <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${pokemon.species_id}.png" class="-sprite">
        </a>
    </li>
    % endfor
</ul>
</%def>

<%def name="pokemon_panels(pokemons)">
    <ul class="pokemon-panels">
      % for pokemon in pokemons:
        <%
            if True:
                stage = 'durr'
            elif pokemon.species.is_baby:
                stage = 'baby'
            else:
                stage = 'basic'
                parent = pokemon.species.parent_species
                if parent and not parent.is_baby:
                    stage = 'stage1'
                    grandparent = parent.parent_species
                    if grandparent and not grandparent.is_baby:
                        stage = 'stage2'
        %>
        <li class="panel-${stage} panel-${pokemon.types[0].identifier}">
            <div class="-sprite">
                <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${pokemon.species.id}${'-' + pokemon.default_form.form_identifier if pokemon.default_form and pokemon.default_form.form_identifier else ''}.png">
            </div>

            <div class="-header">
                <div class="-name"><a href="${request.resource_url(pokemon.species)}">${pokemon.species.name}</a></div>
                <div class="-types">
                % for type_ in pokemon.types:
                    ${lib.type_icon(type_)}
                % endfor
                ##  · score 4
                </div>
            </div>
            ##% if not pokemon.is_default:
            % if pokemon.default_form.form_name:
            <div class="-subheader">${pokemon.default_form.form_name}</div>
            % endif

            <div class="-body">

            <p class="-number">
                #${pokemon.species.id}
            </p>

            <p class="-evostage">
                ${stage}
                % if False and not pokemon.species.child_species:
                  (fully evolved)
                % endif
            </p>

            <p class="-abilities">
              % for pokemon_ability in pokemon.pokemon_abilities:
                % if pokemon_ability.is_hidden:
                <em>${pokemon_ability.ability.name}</em>
                % else:
                ${pokemon_ability.ability.name}
                % endif

                % if not loop.last:
                ·
                % endif
              % endfor
            </p>

            ## TODO: regional dex versions?

            <%
                stats = dict((ps.stat.identifier, ps.base_stat) for ps in pokemon.stats)
            %>
            <p class="-stats">
                <span class="-statgrp"><var>HP</var> ${stats['hp']}</span>
                <span class="-statgrp"><var>Phys</var> ${stats['attack']} / ${stats['defense']}</span>
                <span class="-statgrp"><var>Speed</var> ${stats['speed']}</span>
                <span class="-statgrp"><var>Spec</var> ${stats['special-attack']} / ${stats['special-defense']}</span>
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


<%def name="old_stuff_idk()">
<section>
    <h1>Browse</h1>

    ## XXX action?
    <form method="GET">
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
    </form>
</section>

<section>
    <h1>Search</h1>

    ## XXX action?
    <form method="GET">

    <style type="text/css">
        dl.horizontal-big dt {
            font-size: 2em;
            line-height: 1;
            font-weight: bold;
            width: 6em;
        }
        dl.horizontal-big dd {
            min-height: 2em;
        }
    </style>
    <dl class="horizontal">
        <dt>Group by</dt>
        <dd>
            <ul class="inline">
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
        <dt>Filter on</dt>
        <dd>
                <!--
                <li>Generation</li>
                <li>Type</li>
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


            <% from veekun_pokedex.api import PokemonLocus %>

            <div class="browse-filter-criterion">
                <h4>Type</h4>
                <p>
                    <select>
                        <option value="any">Find Pokémon with any of the selected types</option>
                        <option value="all">Find Pokémon that are exactly the selected type combination</option>
                        <option value="only">Find Pokémon whose types are all selected</option>
                    </select>
                </p>
                <%libsearch:field_select_several name="type" values="${[(type_.identifier, type_) for type_ in all_types]}" args="type_">
                    ${lib.type_icon(type_)}
                </%libsearch:field_select_several>
            </div>
            <div class="browse-filter-criterion">
                <h4>Generation</h4>
                <%libsearch:field_select_one datum="${PokemonLocus.generation}" args="generation">
                    ${lib.generation_icon(generation)}
                </%libsearch:field_select_one>
            </div>
        </dd>





        <dt>Sort by</dt>
        <dd>
            <ul>
                <li class="selected">National ID</li>
            </ul>
        </dd>
        <dt>Display as</dt>
        <dd>
            <ul>
                <li class="selected">Summary</li>
                <!--
                <li>sprites (of any gen!)  (shiny, etc?)</li>
                <li>icons</li>
                <li>sugimori?</li>
                -->
                <li>...</li>
            </ul>
        </dd>
        <!--
        <dt>Options</dt>
        <dd>
            <li>show formless, forms only</li>
            <li>cluster evolutions together somehow in panel mode?</li>
        </dd>
        -->

        <dd><button type="submit">Update</button></dd>
    </dl>


    </form>

</section>




<script>
    $('.browse-pill').find('input[type=radio], input[type=checkbox]').on('click', function(evt) {
        $(this).closest('.browse-pill').toggleClass('selected', $(this).prop('checked'));
    })
    .each(function() {
        $(this).closest('.browse-pill').toggleClass('selected', $(this).prop('checked'));
    });
</script>
</%def>
