<%! from veekun_pokedex.lib.formatting import version_initials %>
###### STANDARD LINKS


###### SPRITES

<%def name="item_icon(item)">
    <img src="http://veekun.com/dex/media/items/${item.identifier}.png">
</%def>

<%def name="pokemon_sprite(species)">
    <img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${species.id}.png">
</%def>


###### MISC UI

<%def name="version_icon(version)">\
## Ruby → R, HeartGold → HG, Black 2 → B2
## TODO: how does this play with other languages
<span class="version-${version.identifier}">${version_initials(version.name)}</span>\
</%def>
<%def name="generation_icon(generation)">
<span class="version-gen${generation.id}">${_(u'Gen {n}').format(n=generation.id)}</span>
</%def>

<%def name="any_version_icon(obj)"><%
    from pokedex.db import tables as t

    if isinstance(obj, t.Version):
        context['self'].version_icon(obj)
    elif isinstance(obj, t.VersionGroup):
        for version in obj.versions:
            context['self'].version_icon(version)
    elif isinstance(obj, t.Generation):
        context['self'].generation_icon(obj)
    else:
        raise TypeError("{0} don't look like no kinda version to me".format(obj))

%></%def>
