# encoding: utf8
from pyramid.config import Configurator
from sqlalchemy import engine_from_config

from veekun_pokedex.model import session
from veekun_pokedex.resource import LanguageIndex, PokedexURLGenerator

### Event stuff

from pyramid.i18n import get_localizer, TranslationStringFactory

tsf = TranslationStringFactory('veekun_pokedex')

def inject_globals(event):
    request = event['request']
    event['_'] = lambda *a, **kw: get_localizer(request).translate(tsf(*a, **kw))

def inject_request(event):
    request = event.request

    from pokedex.db.markdown import PokedexLinkExtension
    class VeekunExtension(PokedexLinkExtension):
        def object_url(self, category, obj):
            # XXX this probably does not need to be a closure-class
            return request.resource_url(obj)

    # XXX this spews warnings; may or may not be a problem
    session.configure(markdown_extension_class=VeekunExtension)


### main

def main(global_config, **settings):
    """Builds and returns a wsgi app."""

    # Connect to ye db
    engine = engine_from_config(settings, 'sqlalchemy.')
    session.configure(bind=engine)

    config = Configurator(settings=settings, root_factory=LanguageIndex)
    config.add_resource_url_adapter(PokedexURLGenerator)

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

    # Fucking around
    config.add_route('api-test', '/pokemon/eevee.json')
    config.add_route('api-search-test', '/api/pokemon/search')
    config.add_route('move-search', '/en/moves')

    config.add_route('tools.tournament', '/tools/tournament')
    config.add_route('tools.compare', '/tools/compare')
    config.add_route('tools.pokeballs', '/tools/pokeballs')
    config.add_route('tools.stats', '/tools/stats')

    return config.make_wsgi_app()
