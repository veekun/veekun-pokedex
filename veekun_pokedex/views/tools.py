#encoding: utf8
from __future__ import absolute_import

from pyramid.view import view_config


#@view_config(route_name='tools.tournament', renderer='/tools/tournament.mako')
#def tournament(request):
#    return {}


@view_config(route_name='tools.compare', renderer='/tools/compare-pokemon.mako')
def compare(request):
    return {}


@view_config(route_name='tools.pokeballs', renderer='/tools/pokeballs.mako')
def pokeballs(request):
    return {}


@view_config(route_name='tools.stats', renderer='/tools/stat-calculator.mako')
def stats(request):
    return {}
