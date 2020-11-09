from dotenv import load_dotenv; load_dotenv()
from flask import Flask, request, Response, redirect, jsonify
from flask_swagger_ui import get_swaggerui_blueprint
from cerberus import Validator
from flask_cors import CORS
import firebase_admin
from firebase_admin import auth, credentials, firestore
from fuzzywuzzy import process
import pyrebase
import requests
import gunicorn

import os
import json
import time
import string
import random
from functools import wraps
from datetime import datetime, timedelta, date

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
# Helper Functions

def dateConvert(dateStr):

    try:
        dateObj = datetime.strptime(dateStr, '%d/%m/%Y')
    except:
        dateObj = date.today()

    return dateObj

def verifyBooking(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        body = request.get_json()

        schema = {
            'hotelId': {'type':'string', 'required':True, 'nullable':False, 'empty':False},
            'status': {'type':'string', 'required':True, 'allowed':['booked', 'cancelled', 'visited', 'favourite']}, 
            'title': {'type':'string', 'required':True, 'nullable':False, 'empty':False}, 
            'price':{'type':'number', 'required':True, 'nullable':False, 'empty':False, 'coerce':float},

            'bookingDetails': {'type':'dict', 'required':True, 'nullable':False, 'empty':False, 'schema':{
                'bookingName': {'type':'string', 'required':True, 'nullable':False, 'empty':False}, # booking under name
                'guests': {'type':'integer', 'required':True, 'nullable':False, 'empty':False, 'coerce': int, 'min':1}, # number of guests
                'room': {'type':'dict', 'required':True, 'nullable':False, 'empty':False,'default':{'Standard Room':1},
                    'keysrules': {'type': 'string', 'empty': False}, # name of room type
                    'valuesrules': {'type':'integer', 'required':True, 'nullable':False, 'empty':False, 'coerce': int, 'min':1} # number of rooms
                    },
                'check_In': {'required':True, 'nullable':False, 'empty':False, 'coerce': dateConvert}, #dd/mm/yyyy
                'check_Out': {'required':True, 'nullable':False, 'empty':False, 'coerce': dateConvert} #dd/mm/yyyy
            }}
        }

        if body is None:
            return Response(response='No Data Sent', status=400)
    
        v = Validator(schema)
        body = v.normalized(body)

        if v.errors != {}:
            return Response(response=f'Error: {v.errors}', status=400)

        try:
            if not v.validate(body):
                return Response(response=f'Error: {v.errors}', status=400)
        except:
            return Response(status=400, response='Validaton Failed')

        return f(body, *args, **kwargs)

    return decorated

def verifyEdits(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        body = request.get_json()

        schema = {
            'status': {'type':'string', 'required':False, 'allowed':['booked', 'cancelled', 'visited', 'favourite']}, 
            'price':{'type':'number', 'required':False, 'nullable':False, 'empty':False, 'coerce':float},

            'bookingDetails': {'type':'dict', 'required':False, 'nullable':False, 'empty':False, 'schema':{
                'bookingName': {'type':'string', 'required':False, 'nullable':False, 'empty':False}, # booking under name
                'guests': {'type':'integer', 'required':False, 'nullable':False, 'empty':False, 'coerce': int, 'min':1}, # number of guests
                'room': {'type':'dict', 'required':False, 'nullable':False, 'empty':False,
                    'keysrules': {'type': 'string', 'empty': False}, # name of room type
                    'valuesrules': {'type':'integer', 'required':False, 'nullable':False, 'empty':False, 'coerce': int, 'min':1} # number of rooms
                    },
                'check_In': {'required':False, 'nullable':False, 'empty':False, 'coerce': dateConvert}, #dd/mm/yyyy
                'check_Out': {'required':False, 'nullable':False, 'empty':False, 'coerce': dateConvert} #dd/mm/yyyy
            }}
        }

        if body is None:
            return Response(response='No Data Sent', status=400)
    
        v = Validator(schema)
        body = v.normalized(body)

        if v.errors != {}:
            return Response(response=f'Error: {v.errors}', status=400)

        try:
            if not v.validate(body):
                return Response(response=f'Error: {v.errors}', status=400)
        except:
            return Response(status=400, response='Validaton Failed')

        return f(body, *args, **kwargs)

    return decorated

def verifyReview(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        body = request.get_json()

        schema = {
            "rating": {'type':'number', 'required':True, 'nullable':False, 'min': 1.0, 'max': 10.0, 'coerce':float},
            "review": {'type':'string', 'required':True, 'empty':False, 'nullable':False},
            "title": {'type':'string', 'required':False, 'empty':False, 'nullable':False, 'maxlength': 50, 'default':'General'}
            }

        if body is None:
            return Response(response='No Data Sent', status=400)
    
        v = Validator(schema)
        body = v.normalized(body)

        if v.errors != {}:
            return Response(response=f'Error: {v.errors}', status=400)

        try:
            if not v.validate(body):
                return Response(response=f'Error: {v.errors}', status=400)
        except:
            return Response(status=400, response='Validaton Failed')

        return f(body, *args, **kwargs)

    return decorated

#==============================
# Token Auth

def userId_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        try:
            token = request.headers['Authorization']
            token = token.split('Bearer ')[1]
        except:
            return Response(status=401, response='Check Bearer Token')

        # Obtaining userID using token
        try:
            decodeToken = auth.verify_id_token(token)
            userId = decodeToken['uid']
            name = decodeToken.get('name') or ''
        except:
            return Response(status=401, response='Token Verification Failed')
        
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
        phone_number = request.form["phone_number"]
    except:
        return Response(status=400, response='Required Form Data')

    data = {}
    data['name'] = name
    data['email'] = email
    data['phone_number'] = phone_number

    addSchema = {
        "name": {'type':'string', 'required':True, 'empty':False, 'nullable':False},
        "email": {'type':'string', 'required':True, 'empty':False, 'nullable':False},
        "phone_number": {'type':'string', 'required':True, 'empty':False, 'nullable':False, 'minlength':10, 'maxlength':13}
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

    return jsonify({'idToken':user['idToken'], 'refreshToken':user['refreshToken']})

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
        return Response(status=401, response='Sign In Failed')

    return jsonify({'idToken':user['idToken'], 'refreshToken':user['refreshToken']})

# NEW USER GIVEN GOOGLE
@app.route('/api/google-signup', methods=["PUT"])
@userId_required
def addGUser(authDict):

    userId = authDict.get('userId')
    existing = db.collection('users').document(userId).get()

    if existing is not None: # if user already exists
        return Response(status=200, response='User Already Exists')

    data = {}
    data['name'] = authDict.get('name') or '...'
    data['email'] = authDict.get('email')
    data['phone_number'] = None

    # Creating db entry for user
    db.collection('users').document(userId).set(data)

    return Response(status=200, response='Added to DB')

# LOGOUT ROUTE
@app.route('/api/logout', methods=["GET"])
@userId_required
def logout(authDict):

    userId = authDict.get('userId')
    auth.revoke_refresh_tokens(userId)
    return Response(status=200, response='Logged Out')


#=========================
# PROFILE SECTION
#=========================

# VIEW PROFILE
@app.route('/api/profile', methods=["GET"])
@userId_required
def viewUser(authDict):

    userId = authDict.get('userId')
    data = db.collection('users').document(userId).get().to_dict()

    if data is None:
        return Response(status=404, response='User Info Not Found')

    return jsonify(data)

# EDIT PROFILE
@app.route('/api/profile', methods=["PATCH"])
@userId_required
def editUser(authDict):

    userId = authDict.get('userId')

    data = request.get_json()
    addSchema = {
        "name": {'type':'string', 'required':False, 'empty':False, 'nullable':False},
        "phone_number": {'type':'string', 'required':False, 'empty':False, 'nullable':False, 'minlength':10, 'maxlength':13}
    }

    if data is None:
        return Response(status=400, response='No Data Provided')
    v = Validator(addSchema)
    try:
        if not v.validate(data):
            return Response(status=400, response=f'Error: {v.errors}')
    except:
        return Response(status=400, response=f'Error: {v.errors}')

    db.collection("users").document(userId).update(data)
    data = db.collection("users").document(userId).get().to_dict()

    return jsonify(data)


#=========================
# NAVIGATION ROUTES
#=========================

# Homepage
@app.route('/api/', methods=["GET"])
def homepage():
    
    cities = json.load(open('backup/cities.json'))

    return jsonify(cities)

# Universal Hotel search
@app.route('/api/search', methods=['GET'])
def search():

    q = request.args.get('q', type=str, default=None)
    if q is None or q == '' or q.isspace():
        return Response(status=400, response='Invalid Search Term')
    check_In = request.args.get('check_In', type=str, default=None)
    check_Out = request.args.get('check_Out', type=str, default=None)
    
    city = request.args.get('city', type=str, default=None)

    if city is None or city.isspace() or city == '':

        hotelSummary = json.load(open('backup/hotelSummary.json'))
        hotelNames = hotelSummary.keys()
        fuzzy = process.extract(q, hotelNames, limit=len(hotelNames))
        search = []

        for hotel in fuzzy:
            if hotel[1] > 60: # fuzzy search %
                search.append(hotel[0])
        
        print(search)

        if len(search) > 10:
            search = search[0:10]
        elif len(search) < 3:
            editDistance = 60 
            for hotel in fuzzy:
                if len(search) == 3:
                    break
                editDistance -= 10
                if hotel[1] > editDistance: # fuzzy search %
                    search.append(hotel[0])
        
        # data = [hotelSummary.get(hotelName) for hotelName in search]
        hotels = db.collection('hotelSummary').where('title', 'in', search).get()
        data = [x.to_dict() for x in hotels]
        
        return jsonify(data)

    else:

        city = city.capitalize()

        if city not in ['Delhi', 'Mumbai', 'Bengaluru', 'Hyderabad', 'Pune', 'Tokyo', 'Hong Kong', 'Singapore', 'Dubai']:
            return Response(status=404, response='No Such City')
        
        cityWiseHotels = json.load(open('backup/cityWiseHotels.json'))
        hotelNames = cityWiseHotels.get(city).keys()
        fuzzy = process.extract(q, hotelNames, limit=len(hotelNames))
        search = []

        for hotel in fuzzy:
            if hotel[1] >= 50: # fuzzy search %
                search.append(hotel[0])

        if len(search) > 10:
            search = search[0:10]
        elif len(search) < 3:
            editDistance = 50 
            for hotel in fuzzy:
                if len(search) == 3:
                    break
                editDistance -= 10
                if hotel[1] > editDistance: # fuzzy search %
                    search.append(hotel[0])

        # data = [cityWiseHotels.get(city).get(hotelName) for hotelName in search]
        hotels = db.collection('hotelSummary').where('title', 'in', search).get()
        data = [x.to_dict() for x in hotels]
        
        return jsonify(data)

# Citywise hotels
@app.route('/api/city/<string:city>/', methods=['GET'])
def cityHotels(city):

    city = city.capitalize()
    if city not in ['Delhi', 'Mumbai', 'Bengaluru', 'Hyderabad', 'Pune', 'Tokyo', 'Hong Kong', 'Singapore', 'Dubai']:
        return Response(status=404, response='No Such City')
    
    # cityWiseHotels = json.load(open('backup/cityWiseHotels.json'))
    # data = [v for v in cityWiseHotels.get(city).values()]
    hotels = db.collection('hotelSummary').where('city', '==', city).get()
    data = [x.to_dict() for x in hotels]

    return jsonify(data)

# Hotel details
@app.route('/api/hotel/<string:hotelId>', methods=['GET'])
def getHotel(hotelId):

    hotel = db.collection('hotels').document(hotelId).get().to_dict()
    if hotel is None:
        return Response(status=404, response='Hotel Not Found')

    return jsonify(hotel)


#=========================
# BOOKING ROUTES
#=========================

# Get Bookings
@app.route('/api/profile/bookings', methods=['GET']) # @userId_required
def getBookings():

    userId = 'qRPq692Ql9Zb3fRvYQdonCwWJc33' #authDict.get('userId')
    booking = db.collection('users').document(userId).collection('bookings').get()

    data = [indv.to_dict() for indv in booking]

    return jsonify(data)

# Add Booking
@app.route('/api/profile/bookings', methods=['PUT']) # @userId_required
@verifyBooking # See schema to document
def addBooking(booking):

    userId = 'qRPq692Ql9Zb3fRvYQdonCwWJc33' #authDict.get('userId')
    bookingId = ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k = 20))
    booking['bookingId'] = bookingId

    db.collection('users').document(userId).collection('bookings').document(bookingId).set(booking)

    return jsonify(booking)

# Delete booking
@app.route('/api/profile/bookings/<string:bookingId>', methods=['DELETE']) # @userId_required
def booking(bookingId):

    userId = 'qRPq692Ql9Zb3fRvYQdonCwWJc33' #authDict.get('userId')
    db.collection('users').document(userId).collection('bookings').document(bookingId).delete()

    return Response(response='Deleted', status=200)

# Edit bookings
@app.route('/api/profile/bookings/<string:bookingId>/', methods=['PATCH']) # @userId_required
@verifyEdits
def editBooking(booking, bookingId):

    userId = 'qRPq692Ql9Zb3fRvYQdonCwWJc33' #authDict.get('userId')
    db.collection('users').document(userId).collection('bookings').document(bookingId).update(booking)

    data = db.collection('users').document(userId).collection('bookings').document(bookingId).get().to_dict()

    return jsonify(data)


#=========================
# REVIEW ROUTES
#=========================

# Add review
@app.route('/api/hotel/<string:hotelId>/review', methods=['PUT'])
@verifyReview
def addReview(review, hotelId):

    hotel = db.collection('hotels').document(hotelId).get().to_dict()
    if hotel is None:
        return Response(status=400, response='Hotel Not Found')

    oldRating = hotel['rating']
    newRating = (oldRating * len(hotel['reviews']) + review['rating']) / (len(hotel['reviews']) + 1)
    reviewId = ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k = 20))

    review['id'] = reviewId
    review['name'] = 'Tanish' #authDict.get('name') or '...'
    hotel['reviews'].append(review)

    db.collection('hotels').document(hotelId).update({'reviews':firestore.firestore.ArrayUnion([review]), 'rating':round(newRating, 1)})
    db.collection('hotelSummary').document(hotel['title']).update({'rating':round(newRating, 1)})

    return jsonify(hotel)

#=========================
if __name__ == "__main__":
    app.run(debug=True)