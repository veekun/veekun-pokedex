<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>
<% from veekun_pokedex.lib import formatting %>

## TODO: everywhere there's a species.name needs fixing for forms

<%block name="title">${species.name} [${_(u"Pokémon #{id}").format(id=species.id)}] - veekun</%block>

## XXX surely the name should be a header of some kind?  should this be a header too, instead of nav?
<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="eyeball-crop">${lib.pokemon_sprite(species)}</div>
        <div class="name">${species.name}</div>
    </div>
    ${lib.prev_next(species)}
</nav>
<nav id="breadcrumbs">
    <ol>
        <li><a href="/">veekun</a></li>
        <li><a href="/">${_(u"Pokémon")}</a></li>
        <li>
            <span class="icon-eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/icons/${species.id}.png"></span>
            ${species.name}
        </li>
        <li>
            ludicrously detailed
            <a href="/">flavor</a> or
            <a href="/">locations</a>
        </li>
    </ol>
</nav>
</%block>
## back/forward main navigation block...



<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" async></script>

<section>
    <h1>${_(u"Essentials")}</h1>

    <div class="columns">
        <section class="col4">
            <h2>${_(u"Overview")}</h2>

            <dl class="horizontal">
                XXX forms
                <dt>${_(u"Name")}</dt>
                <dd>${species.name}</dd>
                <dt>Introduced in</dt>
                <dd>${lib.generation_icon(species.generation)}</dd>
                <dt>National Dex</dt>
                <dd># ${species.id}</dd>
                <dt>${_(u"Type")}</dt>
                <dd>
                    % for type_ in pokemon.types:
                    ${lib.type_icon(type_)}
                    % endfor
                </dd>
            </dl>
        </section>

        <div class="col6">
            <section>
                <h2>${_(u"Abilities")}</h2>
                <dl class="horizontal">
                    % for pokemon_ability in pokemon.pokemon_abilities:
                    <dt>
                        % if pokemon_ability.is_hidden:
                        ${_(u"Hidden ability")}
                        % else:
                        ${_(u"Ability {n}").format(n=pokemon_ability.slot)}
                        % endif
                    </dt>
                    <dd>
                        <a href="${request.resource_url(pokemon_ability.ability)}">${pokemon_ability.ability.name}</a> —
                        ${lib.render_markdown(pokemon_ability.ability, 'short_effect')}
                    </dd>
                    % endfor
                </dl>
            </section>
        </div>

        <div class="col2">
            <img src="http://veekun.com/dex/media/pokemon/sugimori/${species.id}.png" style="max-width: 100%; max-height: 16em;">
        </div>
    </div>

    <div class="columns">
        <section class="col6">
            <h2>${_(u'Type')}</h2>
            XXX more stuff here?  like what?  seems barren.
            XXX one nice thing: status effects we're immune to

            <%def name="_type_efficacy_pair(efficacy, efficacy_label, description)">
                <dt>${description} (×${efficacy_label})</dt>
                <dd>
                  % if efficacy in efficacy_types:
                    <ul class="inline">
                      % for type_ in efficacy_types[efficacy]:
                        <li>${lib.type_icon(type_)}</li>
                      % endfor
                    </ul>
                  % else:
                    none
                  % endif
                </dd>
            </%def>

            <dl class="horizontal">
                ${_type_efficacy_pair(0, u'0', _(u'Immune'))}
                % if len(pokemon.types) >= 2:
                    ${_type_efficacy_pair(25, u'¼', _(u'Very resistant'))}
                % endif
                ${_type_efficacy_pair(50, u'½', _(u'Resistant'))}
                ## Don't show normal damage
                ##${_type_efficacy_pair(100, u'1', _(u'Normal'))}
                ${_type_efficacy_pair(200, u'2', _(u'Vulnerable'))}
                % if len(pokemon.types) >= 2:
                    ${_type_efficacy_pair(400, u'4', _(u'Very vulnerable'))}
                % endif
            </dl>
        </section>
        <section class="col6">
            <h2>${_(u"Stats")}</h2>
            <%def name="stats_cell(percentile)">
                <div class="statsbar" title="Better than ${int(percentile * 100 + 0.5)}% of Pokémon">
                    <div class="statsbar-bar" style="width: ${percentile * 100}%; background-color: hsl(${percentile * 330}, 70%, 83%);">
                      % if percentile < 0.01:
                        ${_(u"abhorrent")}
                      % elif percentile < 0.1:
                        ${_(u"terrible")}
                      % elif percentile < 0.3:
                        ${_(u"bad")}
                      % elif percentile > 0.99:
                        ${_(u"incredible")}
                      % elif percentile > 0.9:
                        ${_(u"awesome")}
                      % elif percentile > 0.7:
                        ${_(u"good")}
                      % else:
                        ${_(u"okay")}
                      % endif
                    </div>
                </div>
            </%def>
            <table class="standard-table pokemon-stats">
                <thead>
                    <tr></tr>
                </thead>
                <tbody>
                  % for pokemon_stat in pokemon.stats:
                    <tr>
                        <th>${pokemon_stat.stat.name}</th>
                        <td>${pokemon_stat.base_stat}</td>
                        <td>${stats_cell(stat_percentiles[pokemon_stat.stat])}</td>
                    </tr>
                  % endfor
                </tbody>
                <tfoot>
                    <tr>
                        <th>${_(u'Total')}</th>
                        <td>${stat_total}</td>
                        <td>${stats_cell(stat_percentiles[u'total'])}</td>
                    </tr>
                </tfoot>
            </table>
        </section>
    </div>

    <div class="columns">
        <section class="col6">
            <h2>${_(u"Breeding")}</h2>
            <dl class="horizontal">
                <dt>${_(u"Gender")}</dt>
                <dd>
                    <div class="gender-container">
                        <span class="-male">⅞ male</span>
                        <span class="-female">⅛ female</span>
                        <div class="gender-bar" data-male="7"></div>
                    </div>
                </dd>
                <dt>${_(u"Egg groups")}</dt>
                <dd>
                    ground
                    <br><a href="...">Compatible partners</a>
                </dd>
                <dt>Incubation</dt>
                <dd>
                    extremely slow
                    <br>hatch counter starts at 25
                    <br>hatches after 9180 steps, or 4845 with a speedup
                </dd>
            </dl>
        </section>


        <section class="col6">
            <h2>${_(u"Training")}</h2>
            <dl class="horizontal">
                <dt>${_(u"Effort yield")}</dt>
                <dd>
                    % for pokemon_stat in pokemon.stats:
                    % if pokemon_stat.effort:
                    +${pokemon_stat.effort} ${pokemon_stat.stat.name} <br>
                    % endif
                    % endfor
                </dd>

                <dt>${_(u"EXP yield")}</dt>
                <dd>
                    ${pokemon.base_experience}
                    <div class="microbar"><div class="microbar-bar" style="width: ${pokemon.base_experience * 100. / 255}%;"></div></div>
                [1314 exp at level 100]
                XXX calculator
                </dd>

                <dt>${_(u"Catch rate")}</dt>
                <dd>
                    ${species.capture_rate}
                    <div class="microbar"><div class="microbar-bar" style="width: ${species.capture_rate * 100. / 255}%;"></div></div>
                </dd>

                <dt>${_(u"Initial friendship")}</dt>
                <dd>
                    ${species.base_happiness}
                    <div class="microbar"><div class="microbar-bar" style="width: ${species.base_happiness * 100. / 255}%;"></div></div>
                </dd>

                <dt>${_(u"Growth rate")}</dt>
                <dd>
                    ## XXX japanese names oh no!
                    ${species.growth_rate.identifier} <br>

                    ## Courtesy of magical!  Graphs level² vs exp.
                    <style type="text/css">
                    svg.growth-rate path { stroke: #ccc; stroke-width: 2; }
                    svg.growth-rate path.current { stroke: hsl(216, 60%, 60%); stroke-width: 4; }
                    </style>
                    <%!
                        growth_rate_paths = [
                            ('medium', "M 0,100 150,25"),
                            ('medium-slow', "m 0,100 4,-11.25 c 0,0 1.25,8 14.25,6.75 13,-1.25 131,-75 131,-75"),
                            ('fast', "M 0,100 150,50"),
                            ('slow', "M 0,100 150,0"),
                            ('slow-then-very-fast', "M 150,69 c -86.92,0 -133.27,0 -150,30"),
                            ('fast-then-very-slow', "M 0,100 C 55,95 75,70 113,0"),
                        ]
                    %>
                    <svg version="1.1" class="growth-rate"
                       width="75" height="50"
                       viewBox="0 0 150 100"
                       style="border: 1px solid #909090; border-width: 0 0 1px 1px;">
                      <g stroke-linecap="square" stroke-width="2" fill="none">
                        <g>
                            % for rate_ident, rate_path in growth_rate_paths:
                            <path 
                                % if rate_ident == species.growth_rate.identifier:
                                class="current"
                                % endif
                                d="${rate_path}" />
                            % endfor
                        </g>
                      </g>
                    </svg>
                </dd>
            </dl>
        </section>
    </div>

    <section>
        <h2>${_(u"Wild held items")}</h2>

        <table class="table-pretty" style="width: auto;">
        <col>
        % for column, span in wild_held_items.column_headers:
        <col span="${span}" class="-version">
        % endfor
        <tr class="header">
            <th></th>
            % for column, span in wild_held_items.column_headers:
            <th colspan="${span}">${lib.any_version_icon(column)}</th>
            % endfor
        </tr>
        % for row in wild_held_items.rows:
        <tr>
            <th><a href="${request.resource_url(row.key)}">${lib.item_icon(row.key)} ${row.key.name}</a></th>
            ## TODO not quite right...
            % for rarity, span in row:
            <td colspan="${span}">
                % if rarity is None:
                —
                % else:
                ${rarity}%
                % endif
            </td>
            % endfor
        </tr>
        % endfor
        </table>
    </section>
</section>


## evolution
<section>
    <header>
        <h1 id="evolution">${_(u"Evolution")}</h1>
        <div class="doorhanger">
            <a href="...">Compare this family</a>
            ## XXX: hey, don't show that link if there's only one pokemon...
        </div>
    </header>

    <table class="standard-table pokemon-evolution-chart">
        <thead>
            <tr>
                <th>${_(u'Baby')}</th>
                <th>${_(u'Basic')}</th>
                <th>${_(u'Stage 1')}</th>
                <th>${_(u'Stage 2')}</th>
            </tr>
        </thead>
        <tbody>
            % for row in evolution_table:
            <tr>
              % for cell in row:
              % if cell is None:
                <% pass %>
              % elif cell.is_empty:
                <td class="-empty" rowspan="${cell.rowspan}"></td>
              % else:
                <td rowspan="${cell.rowspan}"
                    % if cell.species == pokemon.species:
                        class="-selected"\
                    % endif
                >
                <div class="td-absolute-wrapper">
                    <div class="-sprite-wrapper">
                        ${lib.pokemon_sprite(cell.species)}
                    </div>
                    <p class="-pokemon">
                      % if cell.species == pokemon.species:
                        ${cell.species.name}
                      % else:
                        <a href="${request.resource_url(cell.species)}">${cell.species.name}</a>
                      % endif
                    </p>
                    <ul class="-method">
                        % for evolution in cell.species.evolutions:
                        <li>${lib.evolution_description(evolution)}</li>
                        % endfor
                        % if cell.species.is_baby and pokemon.species.evolution_chain.baby_trigger_item:
                        <li>
                            ${_(u"Either parent must hold ")} {h.pokedex.item_link(pokemon.species.evolution_chain.baby_trigger_item, include_icon=False, _=_)}
                        </li>
                        % endif
                    </ul>
                </div>
                </td>
              % endif
              % endfor
            </tr>
            % endfor
        </tbody>
    </table>
</section>


## flavor
<section>
    <header>
        <h1>${_(u"Flavor")}</h1>
        <div class="doorhanger">
            <a href="...">Complete flavor for other languages, older games</a>
        </div>
    </header>


    ## XXX anywhere better for this?
        <h2>Pokéathlon</h2>
        <dl class="horizontal">
            <dt>Speed</dt>
            <dd>* * **</dd>
            <dt>Power</dt>
            <dd>* * **</dd>
        </dl>
        Total: 6/10/19

    ## XXX needs more internal ids too
    <div class="columns">
        <section class="col4">
            <h2>Taxonomy</h2>
            <dl class="horizontal">
                <dt>${_(u"Genus")}</dt>
                <dd>${_(u"{genus} Pokémon").format(genus=pokemon.species.genus)}</dd>
                <dt>${_(u"Primary color")}</dt>
                <dd>${pokemon.species.color.name}</dd>
                <dt>${_(u"Cry")}</dt>
                <dd>
                    <audio src="http://veekun.com/dex/media/pokemon/cries/${pokemon.id}.ogg" controls preload="auto" class="cry" style="width: 10em; height: 3em;">
                        <!-- Totally the best fallback -->
                        <a href="http://veekun.com/dex/media/pokemon/cries/${pokemon.id}.ogg">Download</a>
                    </audio>
                    <script>
                        var $cry = $(document.currentScript).parent().find('audio');
                        $cry.after($('<button>').html('▶').click(function() { $cry[0].play(); }));
                        $cry.hide();
                    </script>
                </dd>
                <dt>${_(u"Habitat")}</dt>
                <dd>
                  % if pokemon.species.habitat:
                    ## XXX japanese names
                    ${pokemon.species.habitat.identifier}
                  % else:
                    —
                  % endif
                </dd>
                <dt>${_(u"Footprint")}</dt>
                <dd><img src="http://veekun.com/dex/media/pokemon/footprints/${pokemon.id}.png" class="footprint"></dd>
                <dt>${_(u"Body shape")}</dt>
                <dd>
                    ## XXX japanese awesome names...
                    ${pokemon.species.shape.identifier} <br>
                    <img src="http://veekun.com/dex/media/shapes/${pokemon.species.shape.identifier}.png">
                </dd>
            </dl>
        </section>

        <section class="col4">
        XXX game indices
            <h2>${_(u"Pokédex numbers")}</h2>
            <dl class="horizontal">
                <!-- XXX ugh why is this in this list -->
                <!-- TODO put the uh icons but as tooltip things i guess -->
                % for dex_number in pokemon.species.dex_numbers:
                ## XXX japanese names...
                <dt>${dex_number.pokedex.identifier}</dt>
                <dd>${dex_number.pokedex_number}</dd>
                ## TODO dex_number.pokedex.version_groups
                % endfor
            </dl>
        </section>

        <section class="col4">
            <h2>${_(u"Names")}</h2>
            ${lib.names_list(species.name_map)}
        </section>
    </div>



    <section>
        <h2>${_(u"Flavor text")}</h2>

        ## TODO other languages?
        ## XXX whoops this shows every language we've got lol
        <dl class="horizontal">
        % for flavor_text_row in species.flavor_text:
            ## XXX blah blah better vg icons
            <dt>${lib.any_version_icon(flavor_text_row.version)}</dt>
            <dd>${flavor_text_row.flavor_text}</dd>
        % endfor
        </dl>
    </section>

    <h2>${_(u"Size")}</h2>
    <img src="http://veekun.com/static/pokedex/images/trainer-male.png">

    <h2>${_(u"Appearance")}</h2>
</section>


## locations





## moves
<section>
    <h1>${_(u"Moves")}</h1>

    <table class="table-pretty">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
        <col class="-version">
      % for move_method, move_table in _pokemon_moves_by_method:
        <tbody>
            <tr class="header">
              % for column, span in move_table.column_headers:
                <th colspan="${span}">${lib.any_version_icon(column)}</th>
              % endfor
                <th>${_(u"Move")}</th>
                <th>${_(u"Type")}</th>
                <th>${_(u"Class")}</th>
                <th>${_(u"PP")}</th>
                <th>${_(u"Power")}</th>
                <th>${_(u"Acc")}</th>
                <th>${_(u"Pri")}</th>
                <th>${_(u"Effect")}</th>
            </tr>
            <tr class="subheader">
                <th colspan="99">~~~ ${move_method.identifier} ~~~</th>
            </tr>

            % for row in move_table.rows:
            <tr>
              % for level, span in row:
                <td colspan="${span}">
                    % if level == 0:
                    ✓
                    % elif level is not None:
                    ${level}
                    % endif
                </td>
              % endfor
                <td><a href="${request.resource_url(row.key)}">${row.key.name}</a></td>
                <td>${lib.type_icon(row.key.type)}</td>
                <td><img src="http://veekun.com/dex/media/damage-classes/${row.key.damage_class.identifier}.png" alt="${row.key.damage_class.name}"></td>
                <td>${row.key.pp}</td>
                <td>
                    % if row.key.power:
                    ${row.key.power}
                    % else:
                    —
                    % endif
                </td>
                <td>
                    % if row.key.accuracy:
                    ${row.key.accuracy}%
                    % else:
                    —
                    % endif
                </td>
                <td>
                    % if row.key.priority > 0:
                    ⬆${row.key.priority}
                    % elif row.key.priority < 0:
                    ⬇${row.key.priority}
                    % endif
                </td>
                <td>${lib.render_markdown(row.key, 'short_effect')}</td>
            </tr>
            % endfor
        </tbody>
      % endfor
    </table>
</section>



## links

<section>
    <h1>${_(u"Outside references")}</h1>

    <nav>
        <ul>
            <li>Azure Heights</li>
            <li>Bulbapedia</li>
            <li>Gengar and Haunter's Pokémon Dungeon</li>
            <li>Legendary Pokémon</li>
            <li>PsyPoke</li>
            <li>Serebii.net</li>
            <li>Smogon</li>
        </ul>
    </nav>
</section>


## flavor page

<section>
    <h1>[flavor page] Main game portraits</h1>


    <p><label><input type="checkbox" onclick="$(this).closest('section').find('table').toggleClass('multiplex-male', ! this.checked).toggleClass('multiplex-female', this.checked);"> female</label></p>
    <p><label><input type="checkbox" onclick="$(this).closest('section').find('table').toggleClass('multiplex-normal', ! this.checked).toggleClass('multiplex-shiny', this.checked);"> shiny</label></p>
    <div class="columns">
    <section class="col6">
        <h2>Gold &amp; Silver; Crystal</h2>

        <table class="multiplex-male multiplex-normal" style="width: auto;">
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/gold/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/gold/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/gold/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/gold/back/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/silver/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/silver/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/silver/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/silver/back/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/crystal/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/crystal/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/crystal/animated/25.gif" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/crystal/animated/shiny/25.gif" class="sprite-shiny sprite-male">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/crystal/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/crystal/back/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
            </tr>
        </table>
    </section>
    <section class="col6">
        <h2>Ruby &amp; Sapphire; Emerald; FireRed &amp; LeafGreen</h2>

        <table class="multiplex-male multiplex-normal" style="width: auto;">
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/ruby-sapphire/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/ruby-sapphire/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/ruby-sapphire/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/ruby-sapphire/back/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/emerald/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/emerald/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/emerald/frame2/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/emerald/shiny/frame2/25.png" class="sprite-shiny sprite-male">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/emerald/animated/25.gif" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/emerald/animated/shiny/25.gif" class="sprite-shiny sprite-male">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/firered-leafgreen/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/firered-leafgreen/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/firered-leafgreen/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/firered-leafgreen/back/shiny/25.png" class="sprite-shiny sprite-male">
                    </div>
                </td>
            </tr>
        </table>
    </section>
    </div>

    <div class="columns">
    <section class="col6">
        <h2>Diamond &amp; Pearl, Platinum, Heart Gold &amp; Soul Silver</h2>

        <table class="multiplex-male multiplex-normal" style="width: auto;">
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/frame2/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/shiny/female/frame2/25.png" class="sprite-shiny sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/shiny/frame2/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/female/frame2/25.png" class="sprite-normal sprite-female">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/back/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/back/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/diamond-pearl/back/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/frame2/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/shiny/frame2/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/female/frame2/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/shiny/female/frame2/25.png" class="sprite-shiny sprite-female">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/frame2/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/shiny/female/frame2/25.png" class="sprite-shiny sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/shiny/frame2/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/platinum/back/female/frame2/25.png" class="sprite-normal sprite-female">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/frame2/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/shiny/frame2/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/female/frame2/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/shiny/female/frame2/25.png" class="sprite-shiny sprite-female">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/frame2/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/shiny/female/frame2/25.png" class="sprite-shiny sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/shiny/frame2/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/heartgold-soulsilver/back/female/frame2/25.png" class="sprite-normal sprite-female">
                    </div>
                </td>
            </tr>
        </table>
    </section>
    <section class="col6">
        <h2>Black &amp; White</h2>

        <table class="multiplex-male multiplex-normal" style="width: auto;">
            <tr>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                </td>
                <td>
                    <div class="sprite-multiplexer">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/back/25.png" class="sprite-normal sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/back/shiny/25.png" class="sprite-shiny sprite-male">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/back/female/25.png" class="sprite-normal sprite-female">
                        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/back/shiny/female/25.png" class="sprite-shiny sprite-female">
                    </div>
                </td>
            </tr>
        </table>
    </section>
    </div>
</section>
