# encoding: utf8
"""Defines the resource traversal tree for the site.
"""
from pyramid.interfaces import IResourceURL
from sqlalchemy.orm.exc import NoResultFound
from zope.interface import Interface, implements

import pokedex.db.tables as t
from veekun_pokedex.model import session


class PokedexIndex(object):

    def __init__(self, table, joins=()):
        self.table = table
        self.joins = joins

    def __getitem__(self, key):
        # `key` should be a whatever identifier
        # TODO or should it be a name?
        q = session.query(self.table)

        for join in self.joins:
            q = q.join(join)

        q = q.filter_by(identifier=key)

        try:
            return q.one()
        except NoResultFound:
            raise KeyError


# This is the good stuff, which defines the actual resource tree.  Keys are
# initial path components.
resource_root = dict(
    pokemon = PokedexIndex(t.Pokemon, joins=(t.Pokemon.species,)),
    moves = PokedexIndex(t.Move),
    types = PokedexIndex(t.Type),
    items = PokedexIndex(t.Item),
    abilities = PokedexIndex(t.Ability),
)


# Aaaand fix up URL generation

class PokedexURLGenerator(object):
    implements(IResourceURL)

    def __init__(self, resource, request):
        # TODO make this use adapters or whatever
        if isinstance(resource, t.Pokemon):
            prefix = 'pokemon'
        elif isinstance(resource, t.PokemonSpecies):
            prefix = 'pokemon'
        elif isinstance(resource, t.Type):
            prefix = 'types'
        elif isinstance(resource, t.Item):
            prefix = 'items'
        elif isinstance(resource, t.Ability):
            prefix = 'abilities'
        else:
            raise TypeError(repr(resource))

        self.virtual_path = '/' + prefix + '/' + resource.identifier
        self.physical_path = self.virtual_path
