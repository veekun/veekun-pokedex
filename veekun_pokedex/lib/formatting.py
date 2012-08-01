#encoding: utf8
"""Helpers for formatting data for human consumption.  Generally used from
templates.
"""
import re


def version_initials(name):
    # Ruby → R, HeartGold → HG, Black 2 → B2
    # TODO: how does this play with other languages
    letters = re.findall(r'(\b\w|(?<=[a-z])[A-Z])', name)
    return u''.join(letters)
