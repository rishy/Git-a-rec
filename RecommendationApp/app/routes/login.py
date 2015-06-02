from flask import request, g, session, redirect, url_for, flash
from flask import render_template_string, jsonify
from app import app
from app import github
from app import db
from app.models.user import User

# app.logger.warning('A warning occurred (%d apples)', 42)
# app.logger.error('An error occurred')
# app.logger.info('Info')


@app.route('/github-callback')
@github.authorized_handler
def authorized(oauth_token):
    app.logger.info('oauth_token: %s'%(str(oauth_token)))
    next_url = request.args.get('next') or url_for('index')
    if oauth_token is None:
        flash("Authorization failed.")
        return redirect(next_url)

    user = User.query.filter_by(github_access_token=oauth_token).first()
    if user is None:
        user = User(github_access_token=oauth_token)
        db.session.add(user)

    user.github_access_token = oauth_token
    db.session.commit()
    return redirect(next_url)

@app.route('/repo')
def repo():
    repo_dict = github.get('repos/kodekracker/kk-movies')
    return jsonify(**repo_dict)

@app.route('/login')
def login():
    if session.get('user_id', None) is None:
        return github.authorize(redirect_uri="http://localhost:5000"+url_for("authorized"))
    else:
        return 'Already logged in'

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    return redirect(url_for('index'))

@app.route('/user')
def getUserDetails():
    pass

@app.route('/home')
def index():
    return "User = ",g.user
    if g.user:
        t = 'Hello! <a href="{{ url_for("user") }}">Get user</a> ' \
            '<a href="{{ url_for("logout") }}">Logout</a>'
    else:
        t = 'Hello! <a href="{{ url_for("login") }}">Login</a>'

    return render_template_string(t)
