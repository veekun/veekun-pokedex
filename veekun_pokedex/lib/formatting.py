#encoding: utf8
"""Helpers for formatting data for human consumption.  Generally used from
templates.
"""
import re

from mako.runtime import supports_caller


@supports_caller
def render_markdown(context, row, relation, inline=False):
    """Renders a block of Markdown from the database.

    Call with a row and column name SEPARATELY -- then I can handle language
    fallback if we don't have this particular text translated yet.
    """
    # XXX with the way this is set up, pokedex lib will do the markdowning for
    # us, which makes it hard for the linkifier to find the request.

    local = getattr(row, relation, None)
    if local:
        markdown = local
    else:
        # XXX uhm how do i get the original default language
        from veekun_pokedex.model import session
        import pokedex.db.tables as t
        english = session.query(t.Language).get(9)
        english_prose = getattr(row, relation + '_map').get(english)

        if english_prose:
            _ = context['_']
            context.write(u"""<p class="missing-translation">{0}</p>""".format(
                _(u"Sorry, we haven't translated this into your language yet!  "
                  u"Here's the original English.  (If you can help translate, let us know!)")
            ))
            markdown = english_prose
        else:
            import warnings
            warnings.warn(u"""Can't find {0!r} prose for row {1!r}""".format(relation, row))

            context.write(u'<em>(?)</em>')

            return u''

    rendered = markdown.as_html()

    # Remove the <p> wrapper, if requested
    if inline:
        if not rendered.startswith(u'<p>') or not rendered.endswith(u'</p>'):
            raise ValueError(u"""Can't make {0!r} inline for row {1!r}""".format(relation, row))

        rendered = rendered[3:-4]

        if u'<p>' in rendered or u'</p>' in rendered:
            raise ValueError(u"""Can't make {0!r} inline for row {1!r}""".format(relation, row))

    context.write(rendered)
    return u''

def version_initials(name):
    # Ruby → R, HeartGold → HG, Black 2 → B2
    # TODO: how does this play with other languages
    letters = re.findall(r'(\b\w|(?<=[a-z])[A-Z])', name)
    return u''.join(letters)
