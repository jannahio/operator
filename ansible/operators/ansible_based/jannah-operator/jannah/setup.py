"""
Jannah (Zen/Mind) Operator: Jalloh Media Development Environment
"""

# Always prefer setuptools over distutils
from setuptools import setup, find_packages
# To use a consistent encoding
from codecs import open
from os import path
from sphinx.setup_command import BuildDoc
cmdclass = {'build_sphinx': BuildDoc}

here = path.abspath(path.dirname(__file__))

# Get the long description from the README file
with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

_name = 'jannah'
_version = '0.0.1'
_release = _version

setup(
    name=_name,

    # Versions should comply with PEP440.  For a discussion on single-sourcing
    # the version across setup.py and the project code, see
    # https://packaging.python.org/en/latest/single_source_version.html
    version=_version,

    description='Jannah (Zen/Mind): Jalloh Media Development Environment',
    long_description=long_description,

    # The project's main homepage.
    url='https://github.com/jannahio/jannah-operator',

    # Author details
    author='Osman Jalloh',
    author_email='osman.jalloh@gmail.com',

    # Choose your license
    license='Jalloh Media LLC',

    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        'Development Status :: 1 - Alpha',

        'Intended Audience :: Developers',
        'Topic :: Software Development :: IDE :: Automation',

        'License :: OSI Approved :: Jalloh Media LLC',

        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.6',
    ],

    # What does your project relate to?
    keywords='Python Development Ansible Automation DevOps',

    # You can just specify the packages manually here if your project is
    # simple. Or you can use find_packages().
    #exclude=['contrib', 'docs', 'tests'])
    packages=find_packages(exclude=[]),

    # Alternatively, if you want to distribute just a my_module.py, uncomment
    # this:
    #   py_modules=["my_module"],

    # List run-time dependencies here.  These will be installed by pip when
    # your project is installed. For an analysis of "install_requires" vs pip's
    # requirements files see:
    # https://packaging.python.org/en/latest/requirements.html
    # install_requires=[
    #                     'ansible >= 2.5',
    #                     'responses',
    #                     'certbot',
    #                     'certbot_dns_digitalocean',
    #                     'python-jenkins',
    #                     'PyGithub',
    #                     # Step 1
    #                     # Google Cloud - GoogleCloudAdaptee
    #                     'google-cloud-storage',
    #                     'google-api-python-client',
    #                     # Debugging/Manhole Purposes
    #                     'cryptography',
    #                     'pyasn1'
    #                  ],
    
    python_requires='>=2.6, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, !=3.4.*, !=3.5.*, <4',

    # List additional groups of dependencies here (e.g. development
    # dependencies). You can install these using the following syntax,
    # for example:
    # $ pip install -e .[dev,test]
    extras_require={
        'dev': ['check-manifest'],
        'test': ['coverage'],
    },

    # If there are data files included in your packages that need to be
    # installed, specify them here.  If using Python 2.6 or less, then these
    # have to be included in MANIFEST.in as well.
    # package_data={
    #     'bazelpythonutils': ['package_data.dat'],
    # },

    # Although 'package_data' is the preferred approach, in some case you may
    # need to place data files outside of your packages. See:
    # http://docs.python.org/3.4/distutils/setupscript.html#installing-additional-files # noqa
    # In this case, 'data_file' will be installed into '<sys.prefix>/my_data'
    #data_files=[('my_data', ['data/data_file'])],

    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and allow
    # pip to create the appropriate form of executable for the target platform.
    entry_points={
        'jannah':[
            'jannah = jannah',
        ],
    },
    
    scripts=[
        'jannah/bin/jannah',
    ],
   cmdclass=cmdclass,
   # these are optional and override the Shinx conf.py settings
   command_options={
        'build_sphinx': {
            'project': ('setup.py', _name),
            'version': ('setup.py', _version),
            'release': ('setup.py', _release),
            'build_dir': ('setup.py', 'doc/build/'),
            'source_dir': ('setup.py', 'doc/source/')}},
)
