<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>
<% from veekun_pokedex.lib import formatting %>

<%block name="title">${pokemon.name} [Pokemon #${pokemon.id}] - veekun</%block>

## XXX surely the name should be a header of some kind?  should this be a header too, instead of nav?
<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="eyeball-crop">${lib.pokemon_sprite(pokemon.species)}</div>
        <div class="name">${pokemon.name}</div>
    </div>
    <ul class="subsections">
        <li><span class="-selected">main</span></li>
        <li><a href="flavor">flavor</a></li>
        <li><a href="locations">locations</a></li>
    </ul>
    <ol class="prev-next">
        <li class="prev">
        <a href="ditto">
            <div class="wedge"></div>
            <div class="eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${pokemon.id - 1}.png"></div>
            <div class="name">XXX</div>
        </a>
        </li>
        <li class="next">
        <a href="vaporeon">
            <div class="name">XXX</div>
            <div class="eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${pokemon.id + 1}.png"></div>
            <div class="wedge"></div>
        </a>
        </li>
    </ol>
</nav>
<nav id="breadcrumbs">
    <ol>
        <li><a href="/">veekun</a></li>
        <li><a href="/">Pokémon</a></li>
        <li>
            <span class="icon-eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/icons/${pokemon.id}.png"></span>
            ${pokemon.name}
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



## TODO whoops better put this in a lib
<%def name="type_icon(name)"><img src="http://veekun.com/dex/media/types/en/${name}.png" alt="${name}"></%def>



<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" async></script>


<section>
    <h1>${_(u'Essentials')}</h1>

    <!-- nececssary...? -->
    <!--
    <div class="page-portrait">
        <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${pokemon.id}.png">
    </div>
    -->

    <div class="columns">
        <section class="col4">
            <h2>Important stuff</h2>

            <dl class="horizontal">
                XXX forms
                <dt>Name</dt>
                <dd>${pokemon.name}</dd>
                <dt>Introduced in</dt>
                <dd><span class="version-gen1">Gen I</span></dd>
                <dt>National Dex</dt>
                <dd># ${pokemon.id}</dd>
                <dt>Type</dt>
                <dd>
                    % for type in pokemon.types:
                    ${type_icon(type.identifier)}
                    % endfor
                </dd>
            </dl>
        </section>

        <div class="col8">
            <section>
                <h2>Abilities</h2>
                <dl class="horizontal">
                    % for pokemon_ability in pokemon.pokemon_abilities:
                    <dt>
                        % if pokemon_ability.is_dream:
                        [Hidden]
                        % endif
                        Slot ${pokemon_ability.slot}
                    </dt>
                    <dd>
                        <a href="TODO">${pokemon_ability.ability.name}</a> —
                        ## TODO markdown
                        ##${pokemon_ability.ability.short_effect}
                    </dd>
                    % endfor
                </dl>
            </section>
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
                        <li>${type_icon(type_.identifier)}</li>
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
        <% hsl_stuff = u'70%, 83%' %>
            <h2>stats</h2>
            <table class="standard-table pokemon-stats">
                <thead>
                    <tr></tr>
                </thead>
                <tbody>
                    <tr>
                        <th>HP</th>
                        <td>55</td>
                        <td>
                            <div class="statsbar"><div class="statsbar-bar" style="width: 32%; background-color: hsl(${32*360/100}, ${hsl_stuff});">32nd</div></div>
                        </td>
                        <td>283–314</td>
                    </tr>
                    <tr>
                        <th>Attack</th>
                        <td>55</td>
                        <td>
                            <div class="statsbar"><div class="statsbar-bar" style="width: 27%; background-color: hsl(${27*360/100}, ${hsl_stuff});">27th</div></div>
                        </td>
                        <td>283–314</td>
                    </tr>
                    <tr>
                        <th>Defense</th>
                        <td>50</td>
                        <td>
                            <div class="statsbar"><div class="statsbar-bar" style="width: 26%; background-color: hsl(${26*360/100}, ${hsl_stuff});">26th</div></div>
                        </td>
                        <td>283–314</td>
                    </tr>
                    <tr>
                        <th>Special Attack</th>
                        <td>45</td>
                        <td>
                            <div class="statsbar"><div class="statsbar-bar" style="width: 24%; background-color: hsl(${24*360/100}, ${hsl_stuff});">24th</div></div>
                        </td>
                        <td>283–314</td>
                    </tr>
                    <tr>
                        <th>Special Defense</th>
                        <td>65</td>
                        <td>
                            <div class="statsbar"><div class="statsbar-bar" style="width: 49%; background-color: hsl(${49*360/100}, ${hsl_stuff});">49th</div></div>
                        </td>
                        <td>283–314</td>
                    </tr>
                    <tr>
                        <th>Speed</th>
                        <td>55</td>
                        <td>
                            <div class="statsbar"><div class="statsbar-bar" style="width: 37%; background-color: hsl(${37*360/100}, ${hsl_stuff});">37th</div></div>
                        </td>
                        <td>283–314</td>
                    </tr>
                    <tr>
                        <th>Total</th>
                        <td>325</td>
                        <td>
                            <div class="statsbar"><div class="statsbar-bar" style="width: 26%; background-color: hsl(${26*360/100}, ${hsl_stuff});">26th</div></div>
                        </td>
                        <td></td>
                    </tr>
                </tbody>
            </table>
        </section>
    </div>

    <div class="columns">
        <section class="col6">
            <h2>breeding</h2>
            <dl class="horizontal">
                <dt>Gender</dt>
                <dd><div class="gender-bar" data-male="7">⅞ male, ⅛ female</div></dd>
                <dt>Egg groups</dt>
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
            <h2>training</h2>
            <dl class="horizontal">
                <dt>Base EXP</dt>
                <dd>
                    ${pokemon.base_experience}
                    <div class="microbar"><div class="microbar-bar" style="width: ${pokemon.base_experience * 100. / 255}%;"></div></div>
                [1314 exp at level 100]
                XXX calculator
                </dd>

                <dt>Effort</dt>
                <dd>
                    % for pokemon_stat in pokemon.stats:
                    % if pokemon_stat.effort:
                    +${pokemon_stat.effort} ${pokemon_stat.stat.name} <br>
                    % endif
                    % endfor
                </dd>

                <dt>Capture rate</dt>
                <dd>
                    ${pokemon.species.capture_rate}
                    <div class="microbar"><div class="microbar-bar" style="width: ${pokemon.species.capture_rate * 100. / 255}%;"></div></div>
                </dd>

                <dt>Base happiness</dt>
                <dd>
                    ${pokemon.species.base_happiness}
                    <div class="microbar"><div class="microbar-bar" style="width: ${pokemon.species.base_happiness * 100. / 255}%;"></div></div>
                </dd>

                <dt>Growth rate</dt>
                <dd>
                    ${pokemon.species.growth_rate.name} <br>

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
                                % if rate_ident == pokemon.species.growth_rate.identifier:
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
        <h2>${_(u'Wild held items')}</h2>

        <table>
        <tr>
            <th></th>
            % for column in wild_held_items.column_headers:
            ##<th>${lib.version_icon(version)}</th>
            <th>${lib.any_version_icon(column)}</th>
            % endfor
        </tr>
        % for row in wild_held_items.rows:
        <tr>
            <th><a href="${request.route_url('main')}">${lib.item_icon(row.key)} ${row.key.name}</a></th>
            ## TODO not quite right...
            % for rarity in row:
            <td>
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

    <section>
        <h2>i am fucking around with css-only version icons</h2>
        <p><span class="version-red">R</span><span class="version-blue">B</span> // <span class="version-yellow">Y</span></p>
        <p><span class="version-gold">G</span><span class="version-silver">S</span> // <span class="version-crystal">C</span></p>
        <p><span class="version-ruby">R</span><span class="version-sapphire">S</span> // <span class="version-emerald">E</span> + <span class="version-fire-red">FR</span><span class="version-leaf-green">LG</span></p>
        <p><span class="version-diamond">D</span><span class="version-pearl">P</span> // <span class="version-platinum">P</span> + <span class="version-heart-gold">HG</span><span class="version-soul-silver">SS</span></p>
        <p><span class="version-black">B</span><span class="version-white">W</span> // <span class="version-black2">B2</span><span class="version-white2">W2</span></p>
        <p><span class="version-colosseum">C</span> // <span class="version-xd">XD</span></p>
        <hr>
        <p>
            <span class="version-gen1">Gen I</span>
            <span class="version-gen2">Gen II</span>
            <span class="version-gen3">Gen III</span>
            <span class="version-gen4">Gen IV</span>
            <span class="version-gen5">Gen V</span>
        </p>
    </section>
</section>




## evolution
<section>
    <header>
        <h1 id="evolution">${_(u'Evolution')}</h1>
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
                        <a href="/pokemon/XXX">${cell.species.name}</a>
                      % endif
                    </p>
                    <ul class="-method">
                        % for evolution in cell.species.evolutions:
                        <li>${formatting.evolution_description(evolution)}</li>
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
        <h1>Flavor</h1>
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
            <h2>taxonomy</h2>
            <dl class="horizontal">
                <dt>Genus</dt>
                <dd>${pokemon.species.genus} Pokémon</dd>
                <dt>Primary color</dt>
                <dd>${pokemon.species.color.name}</dd>
                <dt>Cry</dt>
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
                <dt>Habitat</dt>
                <dd>${pokemon.species.habitat.name}</dd>
                <dt>Footprint</dt>
                <dd><img src="http://veekun.com/dex/media/pokemon/footprints/${pokemon.id}.png"></dd>
                <dt>Shape</dt>
                <dd><img src="http://veekun.com/dex/media/shapes/${pokemon.species.shape.identifier}.png"> ${pokemon.species.shape.awesome_name}</dd>
            </dl>
        </section>

        <section class="col4">
        XXX game indices
            <h2>pokédex numbers</h2>
            <dl class="horizontal">
                <!-- XXX ugh why is this in this list -->
                <!-- TODO put the uh icons but as tooltip things i guess -->
                % for dex_number in pokemon.species.dex_numbers:
                <dt>${dex_number.pokedex.name}</dt>
                <dd>${dex_number.pokedex_number}</dd>
                ## TODO dex_number.pokedex.version_groups
                % endfor
            </dl>
        </section>

        <section class="col4">
            <h2>names</h2>
            <dl class="horizontal">
                % for language, pokemon_name in pokemon.species.names.iteritems():
                ## TODO care about official?
                <dt>${language.name}</dt>
                <dd>${pokemon_name.name}</dd>
                % endfor
            </dl>
        </section>
    </div>



    <h2>Flavor text</h2>
    <p>DP: A rare Pokémon that adapts to harsh environments by taking on different evolutionary forms.</p>
    <p>P: Because its genetic makeup is irregular, it quickly changes its form due to a variety of causes.</p>
    <p>HG: It has the ability to alter the composition of its body to suit its surrounding environment.</p>
    <p>SS: Its irregularly configured DNA is affected by its surroundings. It evolves if its environment changes.</p>

    <p>BW: Because its genetic makeup is irregular, it quickly changes its form due to a variety of causes.</p>


    <h2>Size</h2>
    <img src="http://veekun.com/static/pokedex/images/trainer-male.png">

    <h2>Appearance</h2>
</section>


## locations





## moves
<section>
    <h1>${_(u'Moves')}</h1>

    <table class="table-pretty">
        <tbody>
            <tr>
                <th>RB</th>
                <th>Y</th>
                <th>GS</th>
                <th>C</th>
                <th>RSE</th>
                <th>DP</th>
                <th>P</th>
                <th>HS</th>
                <th>BW</th>
                <th>Move</th>
                <th>Type</th>
                <th>Class</th>
                <th>PP</th>
                <th>Power</th>
                <th>Acc</th>
                <th>Pri</th>
                <th>Effect</th>
            </tr>
            <tr>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>—</td>
                <td>Tackle</td>
                <td>Normal</td>
                <td>Physical</td>
                <td>35</td>
                <td>50</td>
                <td>100%</td>
                <td></td>
                <td>Inflicts regular damage with no additional effect.</td>
            </tr>
        </tbody>
    </table>
</section>



## links

<section>
    <h1>Outside references</h1>

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
