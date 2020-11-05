import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Use the application default credentials
cred = credentials.Certificate(json.load(open('fbAdminConfig.json')))
default_app = firebase_admin.initialize_app(cred)

db = firestore.client()

cities = json.load(open("backup/cities.json"))
hotel_summary = json.load(open("backup/hotelSummary.json"))
allHotels = json.load(open('backup/allHotels.json'))

def addCities():

    ref = db.collection('cities')

    for cityName, properties in cities.items():

        ref.document(cityName).set(properties)

def addHotelSummary():

    ref = db.collection('hotelSummary')
    counter = 0
    total = len(hotel_summary.keys())

    for hotelName, hotelInfo in hotel_summary.items():

        try:
            ref.document(hotelName).set(hotelInfo)
        except:
            print(hotelName)
            continue

        counter += 1

        if counter % 20 == 0:
            print(counter * 100/total, end='%...')

def addHotels():

    ref = db.collection('hotels')
    counter = 0
    total = len(allHotels.keys())

    for hotelId, hotelInfo in allHotels.items():

        try:
            ref.document(hotelId).set(hotelInfo)
        except:
            print(hotelId)
            continue

        counter += 1

        if round(counter % 20) == 0:
            print(round(counter * 100/total), end='%...')