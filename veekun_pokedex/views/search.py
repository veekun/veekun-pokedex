from sqlalchemy.orm import contains_eager, joinedload, subqueryload
from pyramid.httpexceptions import HTTPNotFound
from pyramid.view import view_config

import pokedex.db.tables as t
import veekun_pokedex.api as api
from veekun_pokedex.model import session
from veekun_pokedex.resource import PokemonIndex


@view_config(
    context=PokemonIndex,
    renderer='/search/pokemon.mako')
def explore_pokemon(context, request):
    # TODO should this be part of the api?  it knows if there was "really" a
    # search
    did_search = bool(request.GET)

    if not did_search:
        return dict(
            did_search=did_search,
            results=None,
            all_pokemon=None,
            all_types=None,
            all_generations=None,
        )

    q = api.Query(api.PokemonLocus, session)
    q.parse_multidict(request.GET)


    return dict(
        did_search=did_search,
        results=q.execute(),



        # XXX these really oughta come from the locus, or something.  fix this
        # up yo
        all_types=session.query(t.Type),
        all_generations=session.query(t.Generation),
    )


# XXX delete me
def pokemon_search_landing_test(context, request):
    did_search = bool(request.GET)

    if did_search:
        all_pokemon = (
            session.query(t.Pokemon)
            .filter(t.Pokemon.is_default)
            .order_by(t.Pokemon.species_id.asc())
            .options(joinedload(t.Pokemon.species))
            .all()
        )

@view_config(
    route_name='move-search',
    renderer='/search/moves.mako')
def move_search(context, request):
    # XXX
    request._LOCALE_ = 'en'

    # TODO should this be part of the api?  it knows if there was "really" a
    # search
    did_search = bool(request.GET)


    q = api.Query(api.MoveLocus, session)
    q.parse_multidict(request.GET)

    move_groups, moves, move_previews = q.results()


    return dict(
        did_search=did_search,

        move_groups=move_groups,
        moves=moves,
        move_previews=move_previews,



        # XXX these really oughta come from the locus, or something.  fix this
        # up yo
        all_types=session.query(t.Type),
        all_generations=session.query(t.Generation),
    )
