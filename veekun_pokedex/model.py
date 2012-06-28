from sqlalchemy.orm import scoped_session, sessionmaker
from zope.sqlalchemy import ZopeTransactionExtension

from pokedex.db import ENGLISH_ID
from pokedex.db.multilang import MultilangScopedSession, MultilangSession

session = MultilangScopedSession(
    sessionmaker(
        class_=MultilangSession,
        extension=ZopeTransactionExtension(),
        default_language_id=ENGLISH_ID,
    ),
)

# No tables here.  Only tables are from pokedex.db.tables.
# TODO import all that...?
