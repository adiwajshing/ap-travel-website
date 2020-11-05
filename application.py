from dotenv import load_dotenv; load_dotenv()
from flask import Flask, request, Response, redirect, jsonify
from flask_swagger_ui import get_swaggerui_blueprint
from cerberus import Validator
from flask_cors import CORS
import firebase_admin
from firebase_admin import auth, credentials, firestore
import pyrebase
import requests
import gunicorn

import os
import json
import random
from functools import wraps
from datetime import datetime, timedelta

#==============================
# Flask Setup

application = app = Flask(__name__, static_url_path='', static_folder='static')
app.url_map.strict_slashes = False
app.config['SECRET_KEY'] = os.urandom(24)
CORS(app)

#==============================
# Firebase Setup

pb = pyrebase.initialize_app(json.load(open('fbconfig.json')))
authCnx = pb.auth()

cred = credentials.Certificate(json.load(open('fbAdminConfig.json')))
default_app = firebase_admin.initialize_app(cred)
db = firestore.client()

#==============================
# OpenAPI Documentation

SWAGGER_URL = '/docs'
API_URL = '/openapi.yaml'

swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={'app_name': "Best of Asia"})

app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

#==============================
# Error Handling + Cache

@app.errorhandler(404)
def page_not_found(e):
    return redirect('/docs')

def docache(minutes=5, content_type='application/json; charset=utf-8'):
    """ Flask decorator that allow to set Expire and Cache headers. """
    def fwrap(f):
        @wraps(f)
        def wrapped_f(*args, **kwargs):
            r = f(*args, **kwargs)
            then = datetime.now() + timedelta(minutes=minutes)
            rsp = Response(r, content_type=content_type)
            rsp.headers.add('Expires', then.strftime("%a, %d %b %Y %H:%M:%S GMT"))
            rsp.headers.add('Cache-Control', 'public')
            rsp.headers.add('Cache-Control', 'max-age=%d' % int(60 * minutes))
            rsp.headers.add('Vary', '')
            return rsp
        return wrapped_f
    return fwrap

#==============================
# Token Auth

def userId_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        try:
            token = request.headers['Authorization']
            token = token.split('Bearer ')[1]
        except:
            return Response(status=401)

        # Obtaining userID using token
        try:
            decodeToken = auth.verify_id_token(token)
            try:
                userId = decodeToken['uid']
            except:
                userId = authCnx.get_account_info(token).get('users')[0].get('localId')
            name = decodeToken.get('name') or ''
        except:
            return Response(status=401)
        
        authDict = {'userId':userId, 'token':token, 'name': name}

        return f(authDict, *args, **kwargs)

    return decorated


#=========================
# OAUTH2 SECTION
#=========================


# NEW USER GIVEN USERID
@app.route('/api/signup', methods=["POST"])
def addUser():

    try:
        email = request.form["email"]
        password = request.form["password"]
        name = request.form["name"]
    except:
        return Response(status=400, response='Required Form Data')

    data = {}
    data['name'] = name
    data['email'] = email

    addSchema = {
        "name": {'type':'string', 'required':True, 'empty':False, 'nullable':False},
        "email": {'type':'string', 'required':True, 'empty':False, 'nullable':False}
        }

    v = Validator(addSchema)
    v.allow_unknown = True
    try:
        if not v.validate(data):
            return Response(status=400, response=f'Error: {v.errors}')
    except:
        return Response(status=400, response=f'Error: {v.errors}')

    try:
        user = authCnx.create_user_with_email_and_password(email, password)
        userId = user['localId']
    except requests.exceptions.HTTPError as err:
        return Response(status=400, response=str(err))

    # Creating db entry for user
    db.collection('users').document(userId).set(data)

    return json.dumps({'idToken':user['idToken'], 'refreshToken':user['refreshToken']})

# LOGIN ROUTE
@app.route('/api/login', methods=["POST"])
def login():

    try:
        email = request.form["email"]
        password = request.form["password"]
    except:
        return Response(status=400, response='Form Data Invalid')

    try:
        user = authCnx.sign_in_with_email_and_password(email, password)
        user = authCnx.refresh(user['refreshToken'])
    except:
        return Response(status=401)

    return json.dumps({'idToken':user['idToken'], 'refreshToken':user['refreshToken']})

# NEW USER GIVEN GOOGLE
@app.route('/api/google-signup', methods=["PUT"])
@userId_required
def addGUser(authDict):

    userId = authDict.get('userId')
    existing = db.child('userProfile').child(userId).get().val()

    if existing is None: # if user already exists
        return Response(status=200)

    data = {}
    data['name'] = authDict.get('name') or '...'
    data['email'] = authDict.get('email')

    # Creating db entry for user
    db.collection('users').document(userId).set(data)

    return Response(status=200)

# LOGOUT ROUTE
@app.route('/api/logout', methods=["GET"])
@userId_required
def logout(authDict):

    userId = authDict.get('userId')
    auth.revoke_refresh_tokens(userId)
    return Response(status=200)


#=========================
# PROFILE SECTION
#=========================


# VIEW PROFILE
@app.route('/api/profile', methods=["GET"])
@userId_required
def viewUser(authDict):

    userId = authDict.get('userId')
    data = db.child('userProfile').child(userId).get().val()

    if data is None or data == {}:
        return Response(status=404, response='User Info Not Found')

    return json.dumps(data, indent=4)

# EDIT PROFILE
@app.route('/api/profile', methods=["PATCH"])
@userId_required
def editUser(authDict):

    userId = authDict.get('userId')

    data = request.get_json()
    addSchema = {
        "name": {'type':'string', 'required':False, 'empty':False, 'nullable':False}
    }

    if data is None:
        return Response(status=400, response='No Data Provided')
    v = Validator(addSchema)
    try:
        if not v.validate(data):
            return Response(status=400, response=f'Error: {v.errors}')
    except:
        return Response(status=400, response=f'Error: {v.errors}')

    db.child("userProfile").child(userId).update(data)
    data = db.child('userProfile').child(userId).get().val()

    return json.dumps(data, indent=4)


#=========================
# CLIENT ROUTES
#=========================


# Homepage
@app.route('/api/', methods=["GET"])
def homepage():
    
    return jsonify({})

# Citywise hotel search
@app.route('/api/citySearch/<string:city>', methods=['GET'])
def citySearch(city):

    return jsonify({})


#=========================
if __name__ == "__main__":
    app.run(debug=True)