from flask_frozen import Freezer
from RecommendationApp import RecommendationApp

freezer = Freezer(RecommendationApp)

if __name__ == '__main__':
    freezer.freeze()
