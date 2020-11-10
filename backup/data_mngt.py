import json
import random
import string
from search.data_search import fuzzyData, hashTags
from reccomendations.data_rec import cleanTags, engine

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Use the application default credentials
cred = credentials.Certificate(json.load(open('fbAdminConfig.json')))
default_app = firebase_admin.initialize_app(cred)

db = firestore.client()

#==============================

# {city -> {city_info}}
cities = json.load(open('backup/cities.json'))

# {hotel_id -> {hotel_info}}: pushed to db, used for details
allHotels = json.load(open('backup/allHotels.json'))

# {hotel_name -> {hotel_summary}: pushed to db, used for searches
hotelSummary = json.load(open('backup/hotelSummary.json'))

# {hotel_id -> {hotel_info}}: tags are filtered and used for engine use
hashHotels = json.load(open('reccomendations/hashHotels.json'))

# {hotel_id -> {reccomended_hotel_id -> score}}: output of engine
reccomended = json.load(open('reccomendations/reccomended.json'))

# {hotel_name -> {hotel_brief}}: fuzzy search through hotel names
searchHotels = json.load(open('search/searchHotels.json'))

# {city -> {hotel_name -> {hotel_brief}}}: fuzzy search through hotel names
searchCityHotels = json.load(open('search/searchCityHotels.json'))

# {tags -> {hotel_id -> {hotel_brief}}: fuzzy search through tags
searchTags = json.load(open('search/searchTags.json'))

#==============================

def createNewHotel(hotelInfo):

    global allHotels
    global cities
    global hotelSummary
    global hashHotels
    global reccomended
    global searchCityHotels
    global searchHotels
    global searchTags

    '''  
    schema: {
        'id': hotel id [int],
        'title': name [str],
        'thumbnail': url [str],
        'main_image': url [str],
        'description': [str],
        'price': {
            'before_price': [float], 
            'currency': 'INR',
            'current_price': [float],
            'discounted': [boolean],
            'savings_amount': [float],
            'savings_percent': [float]
        },
        'starRating': 1-5 [int],
        'reviews': [
            {
            'id': review id [str],
            'name': [str],
            'rating': 1-10 [float],
            'title': [str],
            'review': [str]
            }
        ],
        'feature_bullets': {
            'Main amenities': [list[str]],
            'What is around': [list[str]]
        },
        'mapWidget': url [str],
        'rooms': [list[str]],
        'address': [str],
        'neighbourhood': [str],
        'city': '[str]',
        'checkIn': [str],
        'checkOut': [str]
    }  
    '''

    idInt = hotelInfo['id']
    idStr = str(idInt)

    name = hotelInfo['title']
    if hotelInfo['city'] not in name:
        name += f', {hotelInfo["city"]}'
    
    city = hotelInfo['city'].title()
    if  city not in cities.keys():
        destinationId = str(random.randint(10000, 9999999))
        cities[city] = {
            'destinationId': destinationId,
            'name': city,
            'thumbnail': ''
        }
        db.collection('cities').document(city).set(cities[city])

    else:
        destinationId = cities[city]['destinationId']
    
    if hotelInfo.get('reviews') is None:
        name = random.choice(['Tanish', 'Pritish', 'Adhiraj', 'Professor', 'Koishore', 'Debargha', 'Akhil', 'Arup'])
        reviewId = ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k = 20))
        review = random.choice(['Amazing hotel', 'Good locations', 'Had a nice stay', 'Lovely staff'])
        rating = float(random.randint(6,10))
        reviewArray = [{
            'id': reviewId,
            'name': name,
            'title': 'Honest Opinion',
            'review': review,
            'rating': rating
        }]
    else:
        rating = 0.0
        for r in hotelInfo.get('reviews'):
            rating += r['rating']
        rating = round(rating/len(hotelInfo.get('reviews')), 1)


    # Location
    tags = [hotelInfo['city'].lower(), hotelInfo['neighbourhood'].lower()]

    # Star
    starTag = str(int(hotelInfo['starRating'])) + ' stars'
    tags.append(starTag.lower())
    
    # Features
    for v in hotelInfo['feature_bullets'].values():
        for f in v:
            if (' mi ') in f or (' km ') in f or ('walk') in f:
                try:
                    f = f[0:f.index(' -')]
                except:
                    pass
            tags.append(f.lower())

    tempHotelSummary = {
        'id': idInt,
        'title': name,
        'thumbnail': hotelInfo['thumbnail'],
        'price': hotelInfo['price'],
        'starRating': hotelInfo['starRating'],
        'rating': rating,
        'neighbourhood': hotelInfo['neighbourhood'],
        'city': hotelInfo['city'],
        'destinationId': destinationId
    }

    tempHotelDetails = {
        'id': idInt,
        'title': name,
        'main_image': hotelInfo['thumbnail'],
        'description': hotelInfo['description'],
        'price': hotelInfo['price'],
        'starRating': hotelInfo['starRating'],
        'rating': rating,
        'reviews': hotelInfo.get('reviews') or reviewArray,
        'feature_bullets': hotelInfo['feature_bullets'],
        'mapWidget': hotelInfo['mapWidget'],
        'rooms': hotelInfo['rooms'],
        'neighbourhood': hotelInfo['neighbourhood'],
        'city': hotelInfo['city'],
        'destinationId': destinationId,
        'checkIn': hotelInfo['checkIn'],
        'checkOut': hotelInfo['checkOut'],
        'tags': tags
    }


    hotelSummary[name] = tempHotelSummary
    jsonWrite = json.dumps(hotelSummary, indent = 2) 
    with open('backup/hotelSummary' + ".json", "w") as output: 
        output.write(jsonWrite)
    db.collection('hotelSummary').document(name).set(tempHotelSummary)
    
    
    allHotels[idStr] = tempHotelDetails
    jsonWrite = json.dumps(allHotels, indent = 2) 
    with open('backup/allHotels' + ".json", "w") as output: 
        output.write(jsonWrite)
    
    
    alternateTags = list(set(tags) - set([hotelInfo['city'].lower(), hotelInfo['neighbourhood'].lower(), f"{hotelInfo['starRating']} stars"]))
    tempHotelDetails['tags'] = alternateTags
    hashHotels[idStr] = tempHotelDetails
    jsonWrite = json.dumps(hashHotels, indent = 2) 
    with open('reccomendations/hashHotels' + ".json", "w") as output: 
        output.write(jsonWrite)
    
    cleanTags() # cleans tags
    fuzzyData() # writes searchCityHotels.json and searchHotels.json
    hashTags()  # writes searchTags.json
    engine() # writes reccomended.json

    allHotels = json.load(open('backup/allHotels'))
    db.collection('hotels').document(idStr).set(allHotels[idStr])

#==============================

for hotelId, hotelInfo in allHotels.items():

    idStr = hotelId
    idInt = hotelInfo['id']
    name = hotelInfo['title']

    try:
        assert hotelId == str(idInt)

        assert hotelSummary[name]['id'] == idInt
        assert hotelSummary[name]['rating'] == hotelInfo['rating']
        assert hotelSummary[name]['title'] == name

        assert searchHotels[name]['id'] ==  idInt
        assert searchCityHotels[hotelInfo['city']][name]['id'] == idInt

        assert reccomended.get(idStr) is not None
        assert hashHotels[idStr]['title'] == name

    except AssertionError:
        print(hotelId)
        input('waiting...')

