<%!
    from veekun_pokedex.resource import PokemonIndex
    from veekun_pokedex.resource import MoveIndex
    from veekun_pokedex.resource import AbilityIndex
    from veekun_pokedex.resource import TypeIndex
    from veekun_pokedex.resource import PlaceIndex
%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='archetype')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='layout')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='pokedex')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='pokemon')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='index')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='mobile')}">
    <script src="http://code.jquery.com/jquery-1.9.0.js"></script>
    <title><%block name="title">veekun</%block></title>
</head>
<body>
    <header id="header">
        <nav id="nav">
            <div id="logo">
                veekun
            </div>
            <form id="lookup">
                ## XXX random example placeholder every time
                <input type="search">
                <button type="submit">→</button>
            </form>
            <ul class="menubar">
                <li><img src="http://veekun.com/dex/media/items/poke-doll.png"><a href="${request.resource_url(PokemonIndex)}">Pokémon</a></li>
                <li><img src="http://veekun.com/dex/media/items/tm-normal.png"><a href="${request.resource_url(MoveIndex)}">Moves</a></li>
                <li><img src="http://veekun.com/dex/media/items/explorer-kit.png"><a href="${request.resource_url(AbilityIndex)}">Abilities</a></li>
                <li><img src="http://veekun.com/dex/media/items/pokeblock-case.png"><a href="${request.resource_url(TypeIndex)}">Types</a></li>
                <li><img src="http://veekun.com/dex/media/items/old-sea-map.png"><a href="${request.resource_url(PlaceIndex)}">Places</a></li>
                <li><a href="XXX">Tools</a></li>
            </ul>
        </nav>
    </header>
    <%block name="subnav"></%block>
    <section id="body">
        ${next.body()}
    </section>
    <footer id="footer">
        <p>Source code: <a href="https://github.com/veekun/veekun-pokedex.git">the site</a>, <a href="https://github.com/veekun/pokedex.git">the data</a>, <a href="http://git.veekun.com/pokedex-media.git">the images and audio</a></p>
        <p>Need to get in touch?  <a href="irc://irc.veekun.com/veekun">IRC</a></p>
        <p>Many thanks to magical, Zhorken, PurpleKecleon, and uncountable others!</p>
    </footer>
</body>
</html>
