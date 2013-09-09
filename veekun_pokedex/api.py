### TODO: move this to pokedex.git once it's stable and sensible

import logging
from operator import attrgetter

from sqlalchemy.orm import contains_eager, joinedload, lazyload, noload, subqueryload

import pokedex.db.tables as t

log = logging.getLogger(__name__)


# Three stages here:
# - configuration
# - retrieval
# - formatting



class Datum(object):
    supports_grouping = False

    def __init__(self, *path, **kwargs):
        self.join = path[:-1]
        self.column = path[-1]
        self.identified_by = kwargs.get('identified_by', None)

        # Populated by a locus's metaclass
        self.key = None



class HasOneDatum(Datum):
    def __get__(self, instance, owner):
        if instance is None:
            return self

        return self.get_from_row(instance._obj)

    def get_from_row(self, obj):
        for rel in self.join:
            obj = rel.__get__(obj, type(obj))

        return self.column.__get__(obj, type(obj))

    def match(self, q, identifier):
        for rel in self.join:
            q = q.join(rel)

        if self.identified_by:
            # A `identified_by` means the column is itself an ORM object
            return q.filter(self.column.has(self.identified_by == identifier))
        else:
            # Otherwise, it's just some value
            return q.filter(self.column == identifier)


    ### Inspection

    @property
    def target_locus(self):
        return self.column.property.mapper.class_

    def iter_options(self):
        # XXX
        from veekun_pokedex.model import session
        # TODO need to filter this
        # TODO need to order this?
        for row in session.query(self.target_locus):
            yield self.identified_by.__get__(row, type(row)), row

    supports_grouping = True

    def group_key(self, row):
        value = self.get_from_row(row)
        return [value]

class IdentifierDatum(HasOneDatum):
    pass
    # TODO this needs to be a bit different since it's not one-of-fixed-set

class HasManyDatum(Datum):
    def __get__(self, instance, owner):
        if instance is None:
            return self

        return self.get_from_row(instance._obj)

    def get_from_row(self, obj):
        for rel in self.join:
            obj = rel.__get__(obj, type(obj))

        return self.column.__get__(obj, type(obj))

        return [
            self.identified_by.__get__(item, type(item))
            for item in obj
        ]

    def match(self, q, *values):
        # TODO doesn't join
        return q.filter(
            self.column.any(self.identified_by.in_(values))
        )

    ### Inspection
    # TODO i am too copy/pasted from HasOne

    @property
    def target_locus(self):
        return self.column.property.mapper.class_

    def iter_options(self):
        # XXX
        from veekun_pokedex.model import session
        # TODO need to filter this
        # TODO need to order this?
        for row in session.query(self.target_locus):
            yield self.identified_by.__get__(row, type(row)), row


    supports_grouping = True

    def group_key(self, row):
        value = self.get_from_row(row)
        return value




class LocusMeta(type):
    def __new__(meta, cls, bases, attrs):
        for key, attribute in attrs.iteritems():
            if isinstance(attribute, Datum):
                attribute.key = key

        return type.__new__(meta, cls, bases, attrs)

class Locus(object):
    __metaclass__ = LocusMeta

    def __init__(self, obj):
        self._obj = obj

    def __getitem__(self, identified_by):
        try:
            value = getattr(self, identified_by)
        except AttributeError:
            raise KeyError
        else:
            if isinstance(value, Datum):
                return value
            else:
                raise KeyError

class MoveLocus(Locus):
    __table__ = t.Move


    identifier = IdentifierDatum(
        t.Move.identifier,
    )

    # TODO hold up chief i need to think about this
    #name = WildcardDatum(
    #    t.Move.names_local,
    #)

    generation = HasOneDatum(
        t.Move.generation,
        identified_by=t.Generation.id,
    )
    type = HasOneDatum(
        t.Move.type,
        identified_by=t.Type.identifier,
    )
    damage_class = HasOneDatum(
        t.Move.damage_class,
        identified_by=t.MoveDamageClass.identifier,
    )


class PokemonLocus(Locus):
    __table__ = t.Pokemon


    identifier = IdentifierDatum(
        t.Pokemon.species,
        t.PokemonSpecies.identifier,
    )

    generation = HasOneDatum(
        t.Pokemon.species,
        t.PokemonSpecies.generation,
        identified_by=t.Generation.id,
    )
    type = HasManyDatum(
        t.Pokemon.types,
        identified_by=t.Type.identifier,
    )



class Query(object):
    def __init__(self, locus_cls, session):
        self.locus_cls = locus_cls
        self.session = session
        self.query = (
            session.query(self.locus_cls.__table__)
            # TODO would be nice to raise an exception on read, but that's not
            # what `noload` does
            .options(lazyload('*'))
        )

        self.fetches = set()

        # TODO this is crap
        self.grouper = None


    # todo: all of these things need to be part of the Datum api too...
    # todo: how about writing some tests first, champ.


    # TODO: FILTERING


    # TODO: SORTING


    # TODO: EAGERLOADING


    # TODO: HTML FORM


    # TODO: PARSING (HTML FORM, QUERY, JSON)


    # TODO: RETURNING (LOCUS OBJECT, SQLA OBJECT, JSON)


    # TODO: GROUPING



    def parse_multidict(self, criteria, strict=False):
        """Parse a multidict, as you might receive from a query string."""

        # TODO: `strict` should cause balking in case of errors
        # TODO: what happens with bogus http input?  how is that exposed

        # TODO should this be required in the caller, to avoid relying on
        # specific multidict implementations?
        criteria = criteria.dict_of_lists()

        # TODO anything else need doing with this?  what if it's falsey?
        criteria.pop('all', None)

        ## GROUPING

        # XXX it seems weird for 'browse' to be down here when that's really a
        # url ui thing
        if 'browse' in criteria:
            # XXX this isn't really right at all.
            try:
                grouper_field, = criteria.pop('browse')
            except ValueError:
                raise ValueError("Too many values for 'browse'")
        else:
            grouper_field = 'generation'

        try:
            self.grouper = getattr(self.locus_cls, grouper_field)
        except (AttributeError, ValueError):
            # TODO oops i don't know how error handling works
            raise ValueError("Can't browse by nonexistent field {0!r}".format(grouper_field))

        if not self.grouper.supports_grouping:
            raise ValueError("Field {0!r} doesn't support browsing".format(grouper_field))

        ## FILTERING

        # ... TODO move that down here, or something.  iterate the locus's
        # fields instead of the multidict?


        ## SORTING


        ## XXX WHAT ELSE.  PRELOADING?

        ## CRITERIA
        for key, values in criteria.items():
            # TODO this will explode royally (should it?) if there is any extra
            # stuff
            self.add_criterion(key, *values)


    def _get_field(self, field):
        if isinstance(field, basestring):
            return getattr(self.locus_cls, field)
        else:
            return field

    def add_criterion(self, field, *args, **kwargs):
        print repr(field), repr(args), repr(kwargs)
        field = self._get_field(field)

        self.query = field.match(self.query, *args)

        self.add_fetch(field)


    def add_fetch(self, field):
        field = self._get_field(field)
        self.fetches.add(field)

        # TODO this should be done in results()
        # TODO need to track whether the join has already been done...  maybe?
        # or leave it up to sqla?
        # TODO criteria shouldn't be doing many joins

        join_path = []
        for rel in field.join:
            join_path.append(rel)
            if rel.property.uselist:
                opt = subqueryload(*join_path)
            else:
                opt = joinedload(*join_path)
            self.query = self.query.options(opt)

    def add_language(self, language):
        pass


    def execute(self):
        """Returns results.  Oh dear."""
        # TODO probably want a results object i guess

        # TODO this is some standard preload junk needed for the browse page
        q = self.query
        if self.locus_cls is PokemonLocus:
            q = (
                q
                .join(t.Pokemon.species)
                .options(contains_eager(t.Pokemon.species))
                .options(subqueryload(t.Pokemon.pokemon_abilities))
                .options(joinedload(t.Pokemon.pokemon_abilities, t.PokemonAbility.ability))
                .options(joinedload(t.Pokemon.types))
                .options(joinedload(t.Pokemon.default_form))
                .options(joinedload(t.Pokemon.species, t.PokemonSpecies.names_local))
                .options(joinedload(t.Pokemon.default_form, t.PokemonForm.names_local))
                .options(subqueryload(t.Pokemon.forms))
                .options(subqueryload(t.Pokemon.species, t.PokemonSpecies.parent_species))
                .options(joinedload(t.Pokemon.species, t.PokemonSpecies.parent_species, t.PokemonSpecies.parent_species))
                .order_by(t.PokemonSpecies.generation_id.asc(), t.PokemonSpecies.evolution_chain_id.asc(), t.PokemonSpecies.id.asc())
            )

        print
        print
        print q
        print
        print

        return Results(self.locus_cls, q.all(), self.grouper)


class Results(object):
    # TODO should support multiple output formats for methods, i think, via a
    # lens or formatter or something.  e.g. locus objects, plain structures for
    # json
    def __init__(self, locus_cls, rows, grouper):
        self.locus_cls = locus_cls
        self.rows = rows
        # TODO maybe just the query object
        self.grouper = grouper
        self.grouped = bool(grouper)

        # TODO wait should i, like, actually instantiate PokemonLocus objects,
        # or are they classes pretending to be objects, or what is happening

        if grouper:
            self.grouped_rows = self._post_init_group_rows(rows, grouper)

    def _post_init_group_rows(self, rows, grouper):
        grouped_rows = {}
        group_key = grouper.group_key

        for row in rows:
            keys = group_key(row)

            for key in keys:
                grouped_rows.setdefault(key, []).append(row)

        return grouped_rows

    def __len__(self):
        return len(self.rows)

    def __iter__(self):
        return iter(self.rows)

    @property
    def groups(self):
        return sorted(self.grouped_rows.keys(), key=attrgetter('id'))

    def rows_in_group(self, group):
        return self.grouped_rows[group]

    def previews_for_group(self, group, limit=3):
        seen = 0
        for row in self.grouped_rows[group]:
            if self.locus_cls is PokemonLocus and row.species.evolves_from_species_id:
                continue

            yield row

            seen += 1
            if seen >= limit:
                break
