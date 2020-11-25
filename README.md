# Staysia (E-Travel Website)

## Documentation:
 - https://staysia.herokuapp.com/docs
 - http://127.0.0.1:5000/docs

# E-Commerce Website (AP2020)

## Project Details

 - [Deployed Application](https://staysia.herokuapp.com/) : Serverless deployment to Heroku (See Github Actions)
 - [REST API Docs](https://staysia.herokuapp.com/docs) : Backend is set up as a REST API. (Documented by team on Swagger)

## Stack

 - Backend: [Python-Flask](https://flask.palletsprojects.com/)
 - Frontend: [Flutter](https://flutter.dev/)
 - Databse: [Firebase Cloud Firestore](https://firebase.google.com/)
 - Deployment: [Heroku](https://www.heroku.com/)

## Local Run
**Note: only possible for developers who have `fbAdminConfig.json` and `env.sample` (included in zip)**

 1) Make `.env.sample` a `.env` file
 2) `cd` into directory and install dependencies using `pip3 install -r requirements.txt`
 3) Run `application.py`. Confirm that it serves on `http://127.0.0.1:5000/`. You can operate the backend separately at `http://127.0.0.1:5000/docs`
 4) `cd` into `frontend` and follow instructions on `https://flutter.dev/docs/get-started/web`.**(flutter should be installed)**
 5) Run `flutter run -d chrome --web-port=3000`
 6) Flutter will open up Chrome with application.

## Look out for

 - Fuzzy Search, Normal Search, Advanced Search with User Preference Filtering (check `application.py -> #search routes`)
 - Recommendation Engine (check `reccomendations/data_rec.py`)
 - Bearer Token Auth
 - Cache-Control (for static files)
 - Single Page Frontend Application

## Citation 

 - [Hotel Data API](https://rapidapi.com/apidojo/api/Hotels) : Used only for scraping data. (check `backup/data_scraping.py`)
 - [Swagger UI Editor](https://editor.swagger.io) : API documenting tool.
 - [Flutter App](https://blog.codemagic.io/flutter-web-getting-started-with-responsive-design/)
 - Other one line code citations done in `application.py` (search for `citations`)