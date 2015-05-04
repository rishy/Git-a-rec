from flask import render_template
from RecommendationApp import RecommendationApp

@RecommendationApp.route('/')
def index():
    return render_template('index.html')
