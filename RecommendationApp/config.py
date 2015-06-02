import os
basedir = os.path.abspath(os.path.dirname(__file__))

SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')
SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')

SECRET_KEY = 'A0Zr98j/3yX R~XHH!jmN]LWX/,?RT'
DEBUG = True

GITHUB_CLIENT_ID = os.getenv('GITHUB_CLIENT_ID',None)
GITHUB_CLIENT_SECRET = os.getenv('GITHUB_CLIENT_SECRET',None)
