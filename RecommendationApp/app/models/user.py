from app import db

class User(db.Model):

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True)
    email = db.Column(db.String(120), unique=True)
    github_access_token = db.Column(db.String(200), unique=True)

    def __init__(self,github_access_token):
        # self.username = username
        # self.email = email
        self.github_access_token = github_access_token

    def __repr__(self):
        return '<User %r>' % self.username
