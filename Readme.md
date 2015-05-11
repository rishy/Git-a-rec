Git-a-rec
========================

Git-a-rec is a Data Analytics system, which uses huge amount of open Github Data to find deep patterns among Github Repos and Users Data. 

##Installation
1. Go to web-app root directory
    ```bash
        $ cd RecommendationApp
    ```

2. For first time, run `install.sh` to create virtual environment of python
    ```bash
        $ chmod +x install.sh
        $ ./install.sh 
    ```

3. To start/activate virtual environment
    ```bash
        $ source venv/bin/activate
    ```

4. Install dependencies listed in `bower.json` and `package.json`
    ```bash
        $ bower install & npm install
    ```

5. To run flask service
    ```bash
        $ python run.py
    ```
    **Note:** Flask service will run at [http://localhost:5000](http://localhost:5000).

6. To run client-side AngularJS application
    ```bash
        $ grunt server
    ```
    **Note:** The Grunt server will run at [http://localhost:8080](http://localhost:8080).The Grunt server supports hot reloading of client-side HTML/CSS/Javascript file changes.

7. To stop/deactivate virtual environment
    ```bash
        $ deactivate
    ```
