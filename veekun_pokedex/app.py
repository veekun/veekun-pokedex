# encoding: utf8
from wsgiref.simple_server import make_server

from pyramid.config import Configurator
from sqlalchemy import engine_from_config

import pokedex.db
import pokedex.db.tables as t
from veekun_pokedex.model import session

### Resource stuff

class Root(dict):
    pass

class PokemonIndex(object):
    def __getitem__(self, key):
        # `key` should be a Pokémon identifier
        q = session.query(t.Pokemon) \
            .join(t.Pokemon.species) \
            .filter_by(identifier=key)
        try:
            pokemon = q.one()
            return pokemon
        except Exception as e:
            print e
            raise KeyError



resource_root = Root()
resource_root['pokemon'] = PokemonIndex()


### Event stuff

from pyramid.i18n import get_locale_name, get_localizer, TranslationStringFactory

tsf = TranslationStringFactory('veekun_pokedex')

def inject_globals(event):
    request = event['request']
    event['_'] = lambda *a, **kw: request.localizer.translate(tsf(*a, **kw))

# TODO make this a request subclass instead tbh
def inject_request(event):
    #event.request._LOCALE_ = 'ja'

    locale_name = get_locale_name(event.request)
    q = session.query(t.Language).filter_by(identifier=locale_name)
    try:
        language_row = q.one()
        #session.default_language_id = language_row.id
    except Exception as e:
        print e
        raise

    # TODO is this a circular ref
    event.request.localizer = get_localizer(event.request)


### main

def main(global_config, **settings):
    """Builds and returns a wsgi app."""

    # Connect to ye db
    engine = engine_from_config(settings, 'sqlalchemy.')
    session.configure(bind=engine)

    config = Configurator(settings=settings, root_factory=lambda request: resource_root)

    # i18n gunk
    config.add_subscriber(inject_globals, 'pyramid.events.BeforeRender')
    config.add_subscriber(inject_request, 'pyramid.events.NewRequest')
    config.add_translation_dirs('veekun_pokedex:locale/')

    config.add_route('main', '/')
    config.scan()

    config.add_static_view('images', 'veekun_pokedex:assets/images')

    # PySCSS support
    config.include('pyramid_scss')
    config.add_route('pyscss', '/css/{css_path:[^/]+}.css')
    config.add_view(route_name='pyscss', view='pyramid_scss.controller.get_scss', renderer='scss', request_method='GET')

    return config.make_wsgi_app()
