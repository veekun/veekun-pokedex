<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">Browse natures - veekun</%block>

<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="portrait"></div>
        <div class="name">Natures</div>
    </div>
</nav>
</%block>

<section>
    <h1>Natures</h1>

    <table class="table-pretty">
        <thead>
            <tr class="header">
                <th>Nature</th>
                <th>+10%</th>
                <th>−10%</th>
                <th colspan="2">Likes</th>
                <th colspan="2">Hates</th>
            </tr>
        </thead>
        <tbody>
          % for nature in natures:
            <tr>
                <td>${nature.name}</td>
                <td>${nature.increased_stat.name}</td>
                <td>${nature.decreased_stat.name}</td>
                <td>${nature.likes_flavor.flavor}</td>
                <td><img src="http://veekun.com/dex/media/contest-types/en/${nature.likes_flavor.identifier}.png"></td>
                <td>${nature.hates_flavor.flavor}</td>
                <td><img src="http://veekun.com/dex/media/contest-types/en/${nature.hates_flavor.identifier}.png"></td>
            </tr>
          % endfor
        </tbody>
    </table>
</section>

<section>
    <h1>Gene hints</h1>

    <p>Your Pokémon's hint tells you which of its genes is highest, and what the value of that gene is (modulo 5).</p>

    <table class="table-pretty">
        <thead>
            <tr class="header">
                <th></th>
              % for mod5 in range(5):
                <th>${u', '.join(str(n) for n in range(mod5, 32, 5))}</th>
              % endfor
            </tr>
        </thead>
        <tbody>
          % for stat, hints in sorted(stat_hints.items(), key=lambda kv: kv[0].id):
            <tr>
                <td>${stat.name}</td>
              % for mod5 in range(5):
                <td>${hints[mod5]}</td>
              % endfor
            </tr>
          % endfor
        </tbody>
    </table>
</section>
