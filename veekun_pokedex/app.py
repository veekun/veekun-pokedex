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


def main(global_config, **settings):
    """Builds and returns a wsgi app."""

    # Connect to ye db
    engine = engine_from_config(settings, 'sqlalchemy.')
    session.configure(bind=engine)

    config = Configurator(settings=settings, root_factory=lambda request: resource_root)
    config.add_route('main', '/')
    config.scan()

    # PySCSS support
    config.include('pyramid_scss')
    config.add_route('pyscss', '/css/{css_path:[^/]+}.css')
    config.add_view(route_name='pyscss', view='pyramid_scss.controller.get_scss', renderer='scss', request_method='GET')

    return config.make_wsgi_app()
