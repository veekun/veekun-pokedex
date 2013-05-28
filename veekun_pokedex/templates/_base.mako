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
                <li><img src="http://veekun.com/dex/media/items/poke-doll.png"><a href="abc">Pokémon</a></li>
                <li><img src="http://veekun.com/dex/media/items/tm-normal.png"><a href="abc">Moves</a></li>
                <li><img src="http://veekun.com/dex/media/items/explorer-kit.png"><a href="abc">Abilities</a></li>
                <li><img src="http://veekun.com/dex/media/items/pokeblock-case.png"><a href="abc">Types</a></li>
                <li><img src="http://veekun.com/dex/media/items/old-sea-map.png"><a href="abc">Places</a></li>
                <li><a href="abc">Tools</a></li>
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
