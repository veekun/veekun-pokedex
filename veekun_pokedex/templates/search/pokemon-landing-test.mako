<%! from veekun_pokedex.resource import PokemonIndex %>

<%inherit file="/_base.mako" />
<%namespace name="lib" file="/_lib.mako"/>
<%namespace name="libsearch" file="/search/_lib.mako"/>
<%namespace name="libfmt" module="veekun_pokedex.lib.formatting"/>

<%namespace name="libtmp" file="/search/pokemon.mako"/>

<%block name="title">Explore Pokémon - veekun</%block>

<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="name">Explore Pokémon</div>
    </div>
</nav>
</%block>

################################################################################
## ACTUAL PAGE CONTENTS (all the rest is defs)

% if did_search:
    <section>
        <h1>Results</h1>
        <p>Found ${len(all_pokemon)} Pokémon.</p>
        ## TODO: could put so so so much more here

        ${pokemon_mini_panels(all_pokemon)}
    </section>
% else:
    ${show_browse_options()}
% endif

${search_form()}

## END ACTUAL PAGE CONTENTS
################################################################################

<%def name="pokemon_mini_panels(pokemons)">
<ul class="pokemon-mini-panels">
    % for pokemon in pokemons:
    <li class="panel-${pokemon.types[0].identifier}">
        <a href="...">
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


<%def name="show_browse_options()">
<section>
    <h1>Browse</h1>

    <ul class="large-tiles">
        <li class="-fullwidth"><a href="${request.resource_url(PokemonIndex, query=dict(foo='foo'))}">All Pokémon</a></li>
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

    <div class="columns">
        <section class="col4">
        <details hidden>
            <summary>General</summary>

        </details>
        </section>

        <section class="col4">
        <details hidden class="col4">
            <summary>Type</summary>

        </details>
        </section>

        <section class="col4">
        <details hidden class="col4">
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
        <details hidden>
            <summary>Generation</summary>

            <p>First introduced in:</p>
            <ul>
                <li>[ ] gen 1</li>
            </ul>

        </details>
        </section>

        <section class="col4">
        <details hidden class="col4">
            <summary>Regional Pokédex</summary>
            <ul>
                <li>[ ] kanto</li>
            </ul>
        </details>
        </section>

        <section class="col4">
        <details hidden class="col4">
            <summary>Flavor</summary>

            <p>genus</p>
            <p>color</p>
            <p>habitat</p>
            <p>shape</p>
        </details>
        </section>
    </div>

    <style>
        details {
            border: 1px solid #ececec;
        }
        details summary {
            display: block;
            padding: 0.5em;
            background: #f0f0f0;
        }
        details summary:before {
            content: "▸ ";
            content: "▾ ";
        }
        </style>

    <dl class="horizontal">
        <dt>Sort by</dt>
        <dd>( ) National ID
            <br>
            [ ] Reverse  (default order is A first, 9 first)
        </dd>

        <dt>Group by</dt>
        <dd>( ) Nothing  ( ) Generation</dd>

        <dt>Show as</dt>
        <dd>( ) </dd>

        <dt>Special options</dt>
        <dd>( ) </dd>
    </dl>
</section>
</%def>
