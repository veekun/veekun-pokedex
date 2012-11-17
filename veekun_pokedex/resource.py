# encoding: utf8
"""Defines the resource traversal tree for the site.
"""
from pyramid.interfaces import IResourceURL
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import func
from zope.interface import Interface, implements

import pokedex.db.tables as t
from veekun_pokedex.model import session


# List of supported site languages and localized URLs.  These are needed at
# import time, which is a bad time to be doing gettext translations.
LANGUAGES = dict(
    en = dict(
        pokemon=u'pokemon',
        moves=u'moves',
        types=u'types',
        abilities=u'abilities',
        items=u'items',
        places=u'places',
        natures=u'natures',
    ),
    ja = dict(
        pokemon=u'ポケモン',
        moves=u'わざ',
        types=u'タイプ',
        abilities=u'abilities',
        items=u'items',
        places=u'へん',
        natures=u'natures',
    ),
)


class LanguageIndex(object):
    def __init__(self, request):
        self.request = request

    def __getitem__(self, key):
        if key not in LANGUAGES:
            raise KeyError

        # TODO could cache these in-process...
        language = session.query(t.Language).filter_by(identifier=key).one()
        session.default_language_id = language.id

        # TODO this leaves a request out to dry if it doesn't happen to come
        # through here
        self.request._LOCALE_ = key
        self.request._veekun_language = language
        return localized_resource_root[key]

class PokedexIndex(object):
    table = None

    def __getitem__(self, key):
        # `key` should be a whatever name
        q = session.query(self.table) \
            .join(self.table.names_local) \
            .filter(func.lower(self.table.names_table.name) == key)

        try:
            return q.one()
        except NoResultFound:
            # TODO ought to do a 404 with lookup
            raise KeyError

class PokemonIndex(PokedexIndex):
    table = t.PokemonSpecies

class MoveIndex(PokedexIndex):
    table = t.Move

class TypeIndex(PokedexIndex):
    table = t.Type

class AbilityIndex(PokedexIndex):
    table = t.Ability

class ItemIndex(PokedexIndex):
    table = t.Item

class PlaceIndex(PokedexIndex):
    table = t.Location

class NatureIndex(PokedexIndex):
    table = t.Nature


# This is the good stuff, which defines the actual resource tree.  Keys are
# initial path components.
# Here's the simple templated version.
resource_root = dict(
    pokemon = PokemonIndex(),
    moves = MoveIndex(),
    types = TypeIndex(),
    abilities = AbilityIndex(),
    items = ItemIndex(),
    places = PlaceIndex(),
    natures = NatureIndex(),
)

# And here's the per-language one.
localized_resource_root = dict()
for locale in LANGUAGES.keys():
    localized_resource_root[locale] = dict()
    for key, value in resource_root.iteritems():
        localized_key = LANGUAGES[locale][key]
        localized_resource_root[locale][localized_key] = value




# Aaaand fix up URL generation

class PokedexURLGenerator(object):
    implements(IResourceURL)

    def __init__(self, resource, request):
        # TODO make this use adapters or whatever
        if isinstance(resource, t.Pokemon):
            prefix = 'pokemon'
        elif isinstance(resource, t.PokemonSpecies):
            prefix = 'pokemon'
        elif isinstance(resource, t.Move):
            prefix = 'moves'
        elif isinstance(resource, t.Type):
            prefix = 'types'
        elif isinstance(resource, t.Item):
            prefix = 'items'
        elif isinstance(resource, t.Ability):
            prefix = 'abilities'
        else:
            raise TypeError(repr(resource))

        self.virtual_path = u"/{0}/{1}/{2}".format(
            request._LOCALE_, prefix, resource.name.lower())
        self.physical_path = self.virtual_path
