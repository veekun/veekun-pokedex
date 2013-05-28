from __future__ import absolute_import
from __future__ import unicode_literals

import contextlib

import pytest
from sqlalchemy import create_engine
import transaction

import veekun_pokedex.api as api
import veekun_pokedex.model


@pytest.fixture(scope='module')
def session(request):
    engine = create_engine('postgresql:///veekun_pokedex')
    sess = veekun_pokedex.model.session
    sess.configure(bind=engine)

    request.addfinalizer(transaction.abort)
    return sess

@contextlib.contextmanager
def disable_session(session):
    """Removes a session's `bind`, so nothing can be lazy-loaded."""
    bind = session.bind
    try:
        yield
    finally:
        session.bind = bind


### Test that simple filters work correctly

def test_filter_simple_identifier(session):
    aq = api.Query(api.MoveLocus, session)
    aq.add_criterion('identifier', 'pay-day')
    results = aq.execute()

    actual = set(row.identifier for row in results.orm_rows)
    assert actual == set((
        'pay-day',
    ))

def test_filter_simple_type(session):
    aq = api.Query(api.MoveLocus, session)
    aq.add_criterion('type', 'dragon')
    results = aq.execute()

    actual = set(row.identifier for row in results.orm_rows)
    assert actual == set((
        'draco-meteor',
        'dragonbreath', 'dragon-claw', 'dragon-dance',
        'dragon-pulse', 'dragon-rage', 'dragon-rush', 'dragon-tail',
        'dual-chop',
        'outrage', 'roar-of-time', 'spacial-rend', 'twister',
    ))


### Test various output formats

def test_output_datae(session):
    aq = api.Query(api.MoveLocus, session)
    aq.add_criterion('type', 'dragon')
    results = aq.execute()

    return

    for result in results:
        print result
        print result.identifier
        print result.type
        print result.generation
        print result.damage_class

def test_output_struct(session):
    aq = api.Query(api.MoveLocus, session)
    aq.add_criterion('type', 'dragon')
    results = aq.execute()

    for result in results:
        print result
        print result.identifier
        print result.type
        print result.generation
        print result.damage_class


## name
## damage class
## generation
## flags
## same effect as
## +crit
## multihit
## multiturn
## category
## status ailment
## accuracy
## pp ...
## learned by


### Test prefetching

def test_simple_prefetch(session):
    aq = api.Query(api.PokemonLocus, session)
    aq.add_criterion('type', 'normal')
    aq.add_fetch('generation')
    aq.add_language('en')
    results = aq.execute()

    with disable_session(session):
        for result in results:
            print result
            print result.identifier
            print result.type
            print result.generation


