from dotenv import load_dotenv; load_dotenv()
from flask import Flask, request, Response, redirect, jsonify
from flask_swagger_ui import get_swaggerui_blueprint
from cerberus import Validator
from flask_cors import CORS
import firebase_admin
from firebase_admin import auth, credentials, firestore
from fuzzywuzzy import process
from google.api_core.exceptions import NotFound
import pyrebase
import requests
import gunicorn

import os
import time
import json
import base64
import string
import random
from functools import wraps
from datetime import datetime, timedelta

from profiles import verifySignUp, verifySignIn, verifyProfile
from bookings import dateConvert, verifyBooking, verifyEdits
from searching import verifySearch, verifyFuzzy
from others import verifyReview, cacheFunc
from reccomendations.data_rec import runRecEngine

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

try:
    cred = credentials.Certificate(json.loads(base64.b64decode(os.getenv('FB_ADMIN_CONFIG'))))
except:
    cred = credentials.Certificate(json.load(open('fbAdminConfig.json')))
default_app = firebase_admin.initialize_app(cred)
db = firestore.client()

#==============================
# In Memory Searching

searchCityHotels = json.load(open('search/searchCityHotels.json'))
searchHotels = json.load(open('search/searchHotels.json'))
searchTags = json.load(open('search/searchTags.json'))
cityList = [x.title() for x in searchCityHotels.keys()]

#==============================
# OpenAPI Documentation

SWAGGER_URL = '/docs'
API_URL = '/openapi.yaml'

swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={'app_name': "Staysia"})

app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

#==============================
# Error Handling

# @app.errorhandler(404)
# def page_not_found(e):
#     return redirect('/docs')

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
            try:
                userId = decodeToken['uid']
            except:
                userId = authCnx.get_account_info(token).get('users')[0]['localId']
        except:
            return Response(status=401, response='Token Verification Failed')
        
        authDict = {'userId':userId, 'token':token}

        return f(authDict, *args, **kwargs)

    return decorated

#=========================
# OAUTH2 SECTION
#=========================

# NEW USER GIVEN USERID
@app.route('/api/signup', methods=["POST"])
@verifySignUp
def addUser(email, password, data):

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
@verifySignIn
def login(email, password):

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
    existing = db.collection('users').document(userId).get().to_dict()

    if existing is not None: # if user already exists
        return Response(status=200, response='User Already Exists')

    data = {
        'name': authDict.get('name') or '...',
        'email': authDict.get('email'),
        'phone_number': None
    }

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
@verifyProfile
def editUser(data, authDict):

    userId = authDict.get('userId')

    db.collection("users").document(userId).update(data)
    data = db.collection("users").document(userId).get().to_dict()

    return jsonify(data)

#=========================
# NAVIGATION ROUTES
#=========================

# Homepage
@app.route('/api/', methods=["GET"])
def homepage():
    
    data = db.collection('homepage').document('homepage').get().to_dict()

    return jsonify(data)

# Universal Hotel search on pressing ENTER
@app.route('/api/search', methods=['GET'])
@verifySearch()
def search(q, city, check_In, check_Out):

    if city:
        hotelNames = searchCityHotels.get(city).keys()
    else:
        hotelNames = searchHotels.keys()

    editDistance = 60
    fuzzy = process.extractBests(q, hotelNames, score_cutoff=editDistance, limit=len(hotelNames))
    searchList = [hotel[0] for hotel in fuzzy]

    if len(searchList) > 10:
        # citation for next line of code: https://www.geeksforgeeks.org/break-list-chunks-size-n-python/
        copyList = [x for x in searchList]
        searchList = [searchList[i * 10:(i + 1) * 10] for i in range((len(searchList) + 10 - 1) // 10 )]

    elif len(searchList) == 0:
        editDistance -= 15
        fuzzy = process.extractBests(q, hotelNames, score_cutoff=editDistance, limit=2)
        if fuzzy == []:
            return Response(status=204, response='No Matches Found')
        copyList = [hotel[0] for hotel in fuzzy]
        searchList = [[x for x in copyList]]
        
    else:
        copyList = [x for x in searchList]
        searchList = [searchList]

    data = dict()

    for searchSubList in searchList:
        hotels = db.collection('hotelSummary').where('title', 'in', searchSubList).get()
        for result in hotels:
            result = result.to_dict()
            data[result['title']] = result

    # sort according to fuzzy score
    sortData = [data.get(x) for x in copyList]

    return jsonify(sortData)

# Universal Hotel search in search bar
@app.route('/api/searchbar', methods=["GET"])
@verifyFuzzy()
def fuzzySearch(q, city):

    if city:
        keySearch = searchCityHotels.get(city.title()).keys()
    else:
        keySearch = searchHotels.keys()

    fuzzy = process.extractBests(q, keySearch, limit=7)
    if fuzzy is None:
        return Response(status=204, response='No Matches Found')

    results = [searchHotels[hotel[0]] for hotel in fuzzy]

    return jsonify(results)

# Advanced search using tags
@app.route('/api/search/tags', methods=['GET'])
@verifySearch()
def advancedSearch(q, city, check_In, check_Out):

    tagNames = searchTags.keys()
    fuzzy = process.extractBests(q, tagNames, limit=3)
    tagList = list()
    searchList = set()

    for tag in fuzzy:
        tagList.append(tag[0])
    for tag in tagList:
        searchList = searchList.union(set(list(searchTags.get(tag).keys())))

    if city:
        searchList = searchList.intersection(set(list(searchTags.get(city.lower()).keys())))

    searchList = [int(x) for x in searchList]

    if len(searchList) > 10:
        # citation for next line of code: https://www.geeksforgeeks.org/break-list-chunks-size-n-python/
        searchList = [searchList[i * 10:(i + 1) * 10] for i in range((len(searchList) + 10 - 1) // 10 )]
    elif len(searchList) == 0:
        return Response(status=204, response='No Matches Found')
    else:
        searchList = [searchList]

    data = dict()

    for searchSubList in searchList:

        hotels = db.collection('hotelSummary').where('id', 'in', searchSubList).get()

        for result in hotels:
            result = result.to_dict()
            data[result['title']] = result

    # Sort again according to title
    copyList = process.extract(q, data.keys(), limit=len(data.keys()))
    sortData = [data.get(x[0]) for x in copyList]
    
    return jsonify(sortData)

# Tag based hotels
@app.route('/api/tags/<string:tag>', methods=['GET'])
def tagHotels(tag):

    tag = tag.lower()
    ref = db.collection('hotels')

    city = request.args.get('city', type=str, default=None)
    if city is None or city.isspace() or city == '':
        city = None
    else:
        city = city.title()
        if city not in cityList:
            return Response(status=404, response='No Such City')
        ref = ref.where('city', '==', city)

    hotelsInfos = ref.where('tags', 'array_contains', tag).get()
    hotelIds = [x.to_dict()['id'] for x in hotelsInfos]
    
    if len(hotelIds) > 0:
        # citation for next line of code: https://www.geeksforgeeks.org/break-list-chunks-size-n-python/
        hotelIds = [hotelIds[i * 10:(i + 1) * 10] for i in range((len(hotelIds) + 10 - 1) // 10 )]
    elif len(hotelIds) == 0:
        return Response(response='No hotel found', status=404)
    else:
        hotelIds = [hotelIds]

    data = list()

    for subList in hotelIds:
    
        hotels = db.collection('hotelSummary').where('id', 'in', subList).get()

        for x in hotels:
            data.append(x.to_dict())        

    return jsonify(data)

# Hotel details
@app.route('/api/hotel/<string:hotelId>', methods=['GET'])
def getHotel(hotelId):

    hotel = db.collection('hotels').document(hotelId).get().to_dict()
    if hotel is None:
        return Response(status=404, response='Hotel Not Found')
    
    hotel.pop('tags')

    return jsonify(hotel)

# Reccomendations
@app.route('/api/hotel/<string:hotelId>/reccomendations', methods=['GET'])
def getRecc(hotelId):

    hotelIds = runRecEngine(hotelId)

    if hotelIds is None:
        return Response(status=404, response='Hotel Not Found')

    hotels = db.collection('hotelSummary').where('id', 'in', hotelIds).get()
    data = dict()

    for result in hotels:
        result = result.to_dict()
        data[str(result['id'])] = result

    sortData = [data.get(str(x)) for x in hotelIds]

    return jsonify(sortData)

#=========================
# BOOKING ROUTES
#=========================

# Get Bookings
@app.route('/api/profile/bookings', methods=['GET']) # 
@userId_required
def getBookings(authDict):

    userId = authDict.get('userId')
    booking = db.collection('users').document(userId).collection('bookings').order_by('timestamp', direction=firestore.firestore.Query.DESCENDING).get()

    if booking is None or booking == []:
        return jsonify([])

    data = [indv.to_dict() for indv in booking]

    return jsonify(data)

# Add Booking
@app.route('/api/profile/bookings/<string:hotelId>', methods=['PUT']) # 
@userId_required
@verifyBooking
def addBooking(booking, authDict, hotelId):
    
    userId = authDict.get('userId')

    hotel = db.collection('hotels').document(hotelId).get().to_dict()
    if hotel is None:
        return Response(status=404, response='Hotel Not Found')
    
    price = 0
    allRooms = hotel['rooms']
    
    for roomName, roomNumber in booking['bookingDetails']['room'].items():
        
        if allRooms.get(roomName) is None:
            return Response(status=403, response='Room with this name not available')

        if booking['status'] == 'booked' and allRooms[roomName]['roomsAvailable'] < roomNumber:
            return Response(status=403, response='Not Enough Rooms of this type')

        else:
            allRooms[roomName]['roomsAvailable'] = allRooms[roomName]['roomsAvailable'] - roomNumber
            price = price + (allRooms[roomName]['price'] * roomNumber)

    
    bookingId = ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k = 20))

    booking['hotelId'] = hotelId
    booking['title'] = hotel['title']
    booking['price'] = price
    booking['bookingId'] = bookingId
    booking['timestamp'] = datetime.now()

    db.collection('users').document(userId).collection('bookings').document(bookingId).set(booking)

    if booking['status'] == 'booked': # update only if it is booked
        db.collection('hotels').document(hotelId).update({'rooms':allRooms})

    return jsonify(booking)

# Delete booking
@app.route('/api/profile/bookings/<string:bookingId>', methods=['DELETE']) # 
@userId_required
def booking(authDict, bookingId):

    userId = authDict.get('userId')

    bookingDict = db.collection('users').document(userId).collection('bookings').document(bookingId).get().to_dict()
    if bookingDict is None:
        return Response(status=404, response='Booking Not Found')
    
    if bookingDict['status'] == 'booked':
        hotel = db.collection('hotels').document(bookingDict['hotelId']).get().to_dict()
        if hotel is None:
            return Response(status=404, response='Hotel Not Found')
        allRooms = hotel['rooms']
        
        for roomName, roomNumber in bookingDict['bookingDetails']['room'].items():
            allRooms[roomName]['roomsAvailable'] = allRooms[roomName]['roomsAvailable'] + roomNumber
        
        db.collection('hotels').document(bookingDict['hotelId']).update({'rooms':allRooms})
    
    db.collection('users').document(userId).collection('bookings').document(bookingId).delete()

    return Response(response='Deleted', status=200)

# Edit bookings
@app.route('/api/profile/bookings/<string:bookingId>/', methods=['PATCH']) # 
@userId_required
@verifyEdits
def editBooking(booking, authDict, bookingId):

    userId = authDict.get('userId')

    try:
        db.collection('users').document(userId).collection('bookings').document(bookingId).update(booking)
    except NotFound:
        return Response(status=404, response='Booking not found')

    data = db.collection('users').document(userId).collection('bookings').document(bookingId).get().to_dict()

    return jsonify(data)


#=========================
# REVIEW ROUTES
#=========================

# Add review
@app.route('/api/hotel/<string:hotelId>/review', methods=['PUT'])
@userId_required
@verifyReview
def addReview(review, authDict, hotelId):

    hotel = db.collection('hotels').document(hotelId).get().to_dict()
    if hotel is None:
        return Response(status=404, response='Hotel Not Found')

    oldRating = hotel['rating']
    newRating = (oldRating * len(hotel['reviews']) + review['rating']) / (len(hotel['reviews']) + 1)
    reviewId = ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k = 20))

    review['id'] = reviewId
    try:
        review['name'] = db.collection('users').document(authDict.get('userId')).get().to_dict().get('name') or 'Some Name'
    except:
        review['name'] = 'Some Name'
    hotel['reviews'].insert(0, review)
    
    tempHotel = {
        'rating': round(newRating, 1),
        'reviews': hotel['reviews']
    }

    db.collection('hotels').document(hotelId).update({'reviews':firestore.firestore.ArrayUnion([review]), 'rating':round(newRating, 1)})
    db.collection('hotelSummary').document(hotel['title']).update({'rating':round(newRating, 1)})

    return jsonify(tempHotel)

#=========================
if __name__ == "__main__":
    app.run(debug=False)