#! /usr/bin/env bash

# install virtualenv package
pip install virtualenv

# create virtual environment
virtualenv venv

# install all required python packages
venv/bin/pip install invoke
venv/bin/pip install flask
venv/bin/pip install flask-login
venv/bin/pip install flask-openid
venv/bin/pip install flask-mail
venv/bin/pip install sqlalchemy
venv/bin/pip install flask-sqlalchemy
venv/bin/pip install sqlalchemy-migrate
venv/bin/pip install flask-whooshalchemy
venv/bin/pip install flask-wtf
venv/bin/pip install pytz
venv/bin/pip install flask-babel
venv/bin/pip install flup
venv/bin/pip install Github-Flask
