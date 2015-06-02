from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.github import GitHub
import logging
from logging.handlers import RotatingFileHandler

app = Flask(__name__, static_url_path='')
app.config.from_object('config')
db = SQLAlchemy(app)

# create github-flask instance
github = GitHub(app)

handler = RotatingFileHandler('Logs/app.log', maxBytes=10000, backupCount=1)
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)

from app.routes import index
from app.routes import login
from app.models import user
