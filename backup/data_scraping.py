import requests
from dotenv import load_dotenv; load_dotenv()
import os
import json
import random
import string
from fuzzywuzzy import process
from tqdm import tqdm


cities = ['Delhi', 'Mumbai', 'Bengaluru', 'Hyderabad', 'Pune', 'Tokyo', 'Hong Kong', 'Singapore', 'Dubai']
APIKey=os.getenv('X-RapidAPI-Key')
baseURL = "https://rapidapi.p.rapidapi.com/"

def locationIdGet(fileName='cities'):

    locationId_JSON = {}

    for city in cities:

        querystring = {"query":city}

        headers = {'x-rapidapi-host': 'hotels4.p.rapidapi.com', 'x-rapidapi-key':APIKey}
        response = requests.request("GET", baseURL + 'locations/search', headers=headers, params=querystring).json()

        for x in response['suggestions'][0]['entities']:

            print(x)
            use = input('use? ')
            if use in ['n', 'N']:
                continue
            elif use in ['', 'y', 'Y']:
                locationId_JSON[city] = x
                break

        print('=======================')

    jsonWrite = json.dumps(locationId_JSON, indent = 2) 
    with open(fileName + ".json", "w") as output: 
        output.write(jsonWrite)

def propertiesGet(fileName='hotelSummary'):

    properties_JSON = {}
    cities = json.load(open('cities.json'))

    for key, value in cities.items():

        destinationId = value['destinationId']
        querystring = {
            "destinationId":destinationId, 
            "pageNumber":1, 
            "checkIn":'2020-11-25', 
            "checkOut":'2020-11-26', 
            "pageSize":20, 
            "adults1":1,
            "currency":'INR',
            "starRatings":'3,4,5',
            "sortOrder":'BEST_SELLER'}
    
        headers = {'x-rapidapi-host': 'hotels4.p.rapidapi.com', 'x-rapidapi-key':APIKey}
        response = requests.request("GET", baseURL + 'properties/list', headers=headers, params=querystring).json()

        if response['result'] != 'OK':
            print(f'Issue in {key}')
            input('Waiting...')
        
        results = response['data']['body']['searchResults']['results']

        for hotel in results:

            before_price = float((hotel['ratePlan']['price'].get('old') or hotel['ratePlan']['price']['current']).replace('Rs', '').replace(',','')) + 100
            current_price = float(hotel['ratePlan']['price']['current'].replace('Rs', '').replace(',',''))

            savings_amount = before_price - current_price
            savings_percent = int(savings_amount * 100 / before_price)

            if hotel.get('guestReviews') is not None:
                rating = float(hotel['guestReviews']['rating'])
            else:
                rating = float(random.randint(6, 10))

            name = hotel['name']
            if key.lower() not in name.lower():
                name = name + f', {key}'

            tempHotel = {
                'id': hotel['id'],
                'title': name,
                'thumbnail': hotel['thumbnailUrl'],
                'price': {
                    'before_price': before_price, 
                    'currency': 'INR',
                    'current_price': current_price,
                    'discounted': True,
                    'savings_amount': savings_amount,
                    'savings_percent': savings_percent
                },
                'starRating': int(hotel['starRating']),
                'rating': rating,
                'neighbourhood': hotel['neighbourhood'],
                'city': key,
                'destinationId': destinationId
            }

        properties_JSON[name] = tempHotel
    
    jsonWrite = json.dumps(properties_JSON, indent = 2) 
    with open(fileName + ".json", "w") as output: 
        output.write(jsonWrite)

def hotelDetails(fileName='allHotels'):

    hotelsJSON = json.load(open('hotelSummary.json'))
    finalJSON = {}

    counter = -1

    for hotel, summary in hotelsJSON.items():

        counter += 1

        tempId = summary['id']

        querystring = {"id":tempId, "currency":'INR'}
    
        headers = {'x-rapidapi-host': 'hotels4.p.rapidapi.com', 'x-rapidapi-key':APIKey}
        responseLarge = requests.request("GET", baseURL + 'properties/get-details', headers=headers, params=querystring).json()

        response = responseLarge['data']['body']

        if responseLarge['result'] != 'OK':
            print(f'Issue in {hotel}')
            input('Waiting...')

        #======
        # FEATURES

        feature_bullets = {}
        overview = response['overview']['overviewSections']

        for o in overview:
            if o['type'] in ['HOTEL_FEATURE' , 'LOCATION_SECTION']:
                feature_bullets[o['title'].replace('\u2019', ' i')] = o['content']

        #======
        # ROOMS

        rooms = response['propertyDescription'].get('roomTypeNames')
        if rooms is not None:
            if len(rooms) >= 3:
                rooms = rooms[0:3]
        else:
            rooms = []

        #======
        # REVIEWS

        reviewArray = []
        reviews = response['guestReviews']['trustYouReviews']
        randomNames = ['Tanish', 'Pritish', 'Adhiraj', 'Professor', 'Koishore', 'Debhargha', 'Akhil', 'Arup']
        
        for r in reviews:
            
            if randomNames == []:
                break

            tempName = random.choice(randomNames)
            randomNames.remove(tempName)
            temp = {
                'id': ''.join(random.choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k = 20)),
                'name': tempName,
                'rating': float(r['percentage'])/10,
                'title': r['categoryName'],
                'review': r['text']
            }
            reviewArray.append(temp)

        #======
        # DESCRIPTION

        descriptionHTML = response['propertyDescription']['tagline'][0]

        try:
            description = descriptionHTML[descriptionHTML.index('>')+1:descriptionHTML.index('<', 4)].replace('\n', '') + '.'
        except:
            description = descriptionHTML

        #======
        # TAGS

        # Location
        tags = [summary['city'].lower(), summary['neighbourhood'].lower()]

        # Star
        starTag = str(int(summary['starRating'])) + ' stars'
        tags.append(starTag.lower())

        # Landmarks
        for l in summary['landmarks']:
            if l != '' and not l.isspace():
                tags.append(l.lower())
        
        # Features
        for v in feature_bullets.values():
            for f in v:
                if (' mi ') in f or (' km ') in f or ('walk') in f:
                    try:
                        f = f[0:f.index(' -')]
                    except:
                        pass
                tags.append(f.lower())

        #======
        # COMPLETE JSON
        
        tempHotel = {
            'id': summary['id'],
            'title': summary['title'],
            'main_image': summary['thumbnail'],
            'description': description,
            'price': summary['price'],
            'starRating': summary['starRating'],
            'rating': summary['rating'],
            'reviews': reviewArray,
            'feature_bullets': feature_bullets,
            'mapWidget': response['propertyDescription']['mapWidget']['staticMapUrl'],
            'rooms': rooms,
            'address': response['propertyDescription']['address']['fullAddress'],
            'neighbourhood': summary['neighbourhood'],
            'city': summary['city'],
            'destinationId': summary['destinationId'],
            'checkIn': random.choice(['11 AM', '12 PM', '1 PM', '2 PM']),
            'checkOut': random.choice(['10 AM', '11 AM', '12 PM', '1 PM']),
            'tags': tags
        }

        finalJSON[str(tempId)] = tempHotel
    
        if counter % 10 == 0:

            print(f'Total Done: {counter}')

            # BACKUP
            json_object = json.dumps(finalJSON, indent = 2) 

            # Writing to sample.json 
            with open(str(fileName) + f".json", "w") as outfile: 
                outfile.write(json_object)

    jsonWrite = json.dumps(finalJSON, indent = 2) 
    with open(fileName + ".json", "w") as output: 
        output.write(jsonWrite)

def editReviews():

    hotelSummaryJSON = json.load(open('backup/hotelSummary.json'))
    allHotels = json.load(open('backup/allHotels.json'))

    counter = -1

    for hotel, summary in allHotels.items():

        counter += 1
        totalRating = 0

        if len(summary['reviews']) > 0:

            for r in summary['reviews']:
                totalRating += r['rating']
            
            summary['rating'] = round(totalRating/len(summary['reviews']), 1)
        
        else:

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

            summary['reviews'] = reviewArray
            summary['rating'] = rating
        
        hotelSummaryJSON[summary['title']]['rating'] = summary['rating']
        allHotels[hotel] = summary

    
    jsonWrite = json.dumps(hotelSummaryJSON, indent = 2) 
    with open('hotelSummary' + ".json", "w") as output: 
        output.write(jsonWrite)
    
    jsonWrite = json.dumps(allHotels, indent = 2) 
    with open('allHotels' + ".json", "w") as output: 
        output.write(jsonWrite)

def editNames():

    hotelSummaryJSON = json.load(open('backup/hotelSummary.json'))
    allHotels = json.load(open('backup/allHotels.json'))

    shallowCopy = hotelSummaryJSON.keys()
    hotelNames = [x for x in shallowCopy]

    for i in hotelNames:

        if len(i) > 200:

            print(i)
            newName = input('New Name: ')

            if newName == '':
                continue
            
            summary = hotelSummaryJSON[i]
            summary['title'] = newName

            hotelSummaryJSON[newName] = summary
            hotelSummaryJSON.pop(i)

            value = allHotels[str(summary['id'])]
            value['title'] = newName

            allHotels[str(summary['id'])] = value

            print('changed...')

        hotelSummaryJSON[i].pop('landmarks')
        hotelSummaryJSON[i].pop('features')

        allHotels[str(hotelSummaryJSON[i]['id'])].pop('landmarks')
    
    jsonWrite = json.dumps(hotelSummaryJSON, indent = 2) 
    with open('hotelSummary' + ".json", "w") as output: 
        output.write(jsonWrite)
    
    jsonWrite = json.dumps(allHotels, indent = 2) 
    with open('allHotels' + ".json", "w") as output: 
        output.write(jsonWrite)

editNames()