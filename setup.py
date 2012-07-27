import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
README = ''#open(os.path.join(here, 'README.txt')).read()
CHANGES = ''#open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
    'pyramid',
    'SQLAlchemy',
    'transaction',
    'pyramid_tm',
    'pyramid_debugtoolbar',
    'pyramid_pyscss',
    'zope.sqlalchemy',
    'waitress',
    'babel',
]

setup(name='veekun_pokedex',
    version='0.0',
    description='veekun_pokedex',
    long_description=README + '\n\n' +  CHANGES,
    classifiers=[
        "Programming Language :: Python",
        "Framework :: Pylons",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
    ],
    author='',
    author_email='',
    url='',
    keywords='web wsgi bfg pylons pyramid',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    test_suite='veekun_pokedex',
    install_requires=requires,
    entry_points="""\
        [paste.app_factory]
        main = veekun_pokedex.app:main
        [console_scripts]
        populate_veekun_pokedex = veekun_pokedex.scripts.populate:main
    """,

    # i18n
    message_extractors={'.': [
        ('**.py', 'python', None),
        ('**.mako', 'mako', dict(
            input_encoding='utf8',
        )),
    ]},
)

