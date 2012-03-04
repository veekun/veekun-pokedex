from wsgiref.simple_server import make_server

from pyramid.config import Configurator

def main(global_config, **settings):
    """Builds and returns a wsgi app."""

    config = Configurator(settings=settings)
    config.add_route('main', '/')
    config.scan()

    # PySCSS support
    config.include('pyramid_scss')
    config.add_route('pyscss', '/css/{css_path:[^/]+}.css')
    config.add_view(route_name='pyscss', view='pyramid_scss.controller.get_scss', renderer='scss', request_method='GET')

    return config.make_wsgi_app()
