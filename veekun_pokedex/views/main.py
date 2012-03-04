from pyramid.view import view_config

@view_config(
    route_name='main',
    request_method='GET',
    renderer='/index.mako')
def main(request):
    return dict()
