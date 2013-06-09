<%inherit file="/_base.mako"/>

<header id="home-header">
    <p id="home-title">veekun</p>
    <p id="home-tagline">some kind of pokémon website</p>

    <form id="home-lookup">
        ## XXX why isn't this in the navbar.  should the navbar be on the index at all?
        ## XXX random example placeholder every time
        <p>
            <input type="search">
            <button>Go!</button>
        </p>
    </form>
</header>

<section>
    <h1>Pages</h1>

    <ul class="large-tiles">
        <li><a href="/pokemon"><img src="http://veekun.com/dex/media/items/poke-doll.png"> Pokémon</a></li>
        <li><a href="/moves"><img src="http://veekun.com/dex/media/items/tm-normal.png"> Moves</a></li>
        <li><a href="/types"><img src="http://veekun.com/dex/media/items/pokeblock-case.png"> Types</a></li>
        <li><a href="/abilities"><img src="http://veekun.com/dex/media/items/explorer-kit.png"> Abilities</a></li>
        <li><a href="/items"><img src="http://veekun.com/dex/media/items/potion.png"> Items</a></li>
        <li><a href="/places"><img src="http://veekun.com/dex/media/items/old-sea-map.png"> Places</a></li>
        <li><a href="/natures"><img src="http://veekun.com/dex/media/items/unown-report.png"> Natures</a></li>
    </ul>
</section>

<section>
    <h1>Tools</h1>

    <ul class="large-tiles large-tiles-wider">
        <li><a href="/tools/compare"><img src="http://veekun.com/dex/media/items/silph-scope.png"> Compare Pokémon</a></li>
        <li><a href="/tools/pokeballs"><img src="http://veekun.com/dex/media/items/master-ball.png"> Pokéball performance</a></li>
        <li><a href="/tools/stats"><img src="http://veekun.com/dex/media/items/scanner.png"> Stat calculator</a></li>
        <li><a href="/downloads"><img src="http://veekun.com/dex/media/items/up-grade.png"> Downloads</a></li>
    </ul>
</section>

<section>
    <h1>More</h1>

    <ul class="large-tiles large-tiles-wider">
        <li><a href="http://github.com/veekun"><img src="http://veekun.com/dex/media/items/dubious-disc.png"> Source code</a></li>
        <li><a href="http://me.veekun.com/"><img src="http://veekun.com/dex/media/items/journal.png"> fuzzy notepad</a></li>
    </ul>
</section>
