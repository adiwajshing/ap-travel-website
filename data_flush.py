import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from tqdm import tqdm

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

    for hotelName, hotelInfo in tqdm(hotel_summary.items()):

        try:
            ref.document(hotelName).set(hotelInfo)
        except:
            print(hotelName)
            continue

def addHotels():

    ref = db.collection('hotels')

    for hotelId, hotelInfo in tqdm(allHotels.items()):

        try:
            ref.document(hotelId).set(hotelInfo)
        except:
            print(hotelId)
            continue

def addHomepage():

    data = json.load(open('backup/homepage.json'))
    db.collection('homepage').document('homepage').set(data)