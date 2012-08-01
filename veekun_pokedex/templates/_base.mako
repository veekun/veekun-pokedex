<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='archetype')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='layout')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='pokedex')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='pokemon')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='mobile')}">
    <title><%block name="title">veekun</%block></title>
</head>
<body>
    <header id="header">
        <div id="logo">
            veekun
        </div>
        <nav id="nav">
            <ul class="menubar">
                <li><a href="abc">veekun</a></li>
                <li><a href="abc">Pokémon</a></li>
                <li><a href="abc">Moves</a></li>
                <li><a href="abc">Abilities</a></li>
                <li><a href="abc">Types</a></li>
                <li><a href="abc">Places</a></li>
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
