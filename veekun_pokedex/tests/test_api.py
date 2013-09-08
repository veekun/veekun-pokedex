from __future__ import absolute_import
from __future__ import unicode_literals

import contextlib

import pytest
from sqlalchemy import create_engine
import transaction

import veekun_pokedex.api as api
import veekun_pokedex.model

skip = pytest.mark.skipif


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

def check_query(aq, expected, exact=False):
    results = aq.execute()
    actual = frozenset(row.identifier for row in results)
    expected = frozenset(expected)

    if exact:
        assert actual == expected
    else:
        assert actual <= expected


### Test that simple filters work correctly

def test_filter_simple_identifier(session):
    aq = api.Query(api.MoveLocus, session)
    aq.add_criterion('identifier', 'pay-day')

    check_query(aq, ['pay-day'])

def test_filter_simple_type(session):
    aq = api.Query(api.MoveLocus, session)
    aq.add_criterion('type', 'dragon')

    check_query(aq, [
        'draco-meteor',
        'dragonbreath', 'dragon-claw', 'dragon-dance',
        'dragon-pulse', 'dragon-rage', 'dragon-rush', 'dragon-tail',
        'dual-chop',
        'outrage', 'roar-of-time', 'spacial-rend', 'twister',
    ])


def test_filter_simple_name(session):
    aq = api.Query(api.MoveLocus, session)
    aq.add_criterion('name', 'flamethrower')

    check_query(aq, ['flamethrower'], exact=True)

    '''
        check_query(
            dict(name=u'flamethrower'),
            [u'Flamethrower'],
            'searching by name',
            exact=True,
        )

        check_query(
            dict(name=u'durp'),
            [],
            'searching for a nonexistent name',
            exact=True,
        )

        check_query(
            dict(name=u'quICk AttACk'),
            [u'Quick Attack'],
            'case is ignored',
            exact=True,
        )

        check_query(
            dict(name=u'thunder'),
            [ u'Thunder', u'Thunderbolt', u'Thunder Wave',
              u'ThunderShock', u'ThunderPunch', u'Thunder Fang' ],
            'no wildcards is treated as substring',
            exact=True,
        )
        check_query(
            dict(name=u'*under'),
            [u'Thunder'],  # not ThunderShock, etc.!
            'splat wildcard works and is not used as substring',
            exact=True,
        )
        check_query(
            dict(name=u'b?te'),
            [u'Bite'],  # not Bug Bite!
            'question wildcard works and is not used as substring',
            exact=True,
        )
'''


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















## id
## identifier
## name

## ability
## held item
## growth rate
## gender
## egg group
## species
## color
## habitat
## shape
## type
## evolution
## generation
## pokedexes
## NUMBERS
## moves


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


### Test prefetching

@skip
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


