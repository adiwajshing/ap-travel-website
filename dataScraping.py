import requests
from dotenv import load_dotenv; load_dotenv()
import os
import json
import random
import string


cities = ['Delhi', 'Mumbai', 'Bengaluru', 'Hyderabad', 'Pune', 'Tokyo', 'Hong Kong', 'Singapore', 'Dubai']
APIKey=os.getenv('X-RapidAPI-Key')
baseURL = "https://rapidapi.p.rapidapi.com/"

def locationId_GET(fileName='cities'):

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

    json_object = json.dumps(locationId_JSON, indent = 2) 
  
    # Writing to sample.json 
    with open(str(fileName) + ".json", "w") as outfile: 
        outfile.write(json_object)

def properties_GET(fileName='cityWiseHotels'):

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
        propertyList = {}

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
                'features': hotel['ratePlan']['features'],
                'neighbourhood': hotel['neighbourhood'],
                'city': key,
                'destinationId': destinationId,
                'landmarks': hotel['landmarks'][0] if len(hotel['landmarks']) >= 1 else []
            }

            propertyList[name] = tempHotel

        properties_JSON[key] = propertyList
    
    json_object = json.dumps(properties_JSON, indent = 2) 

    # Writing to sample.json 
    with open(str(fileName) + ".json", "w") as outfile: 
        outfile.write(json_object)

def hotelSummary(fileName='hotelSummary'):

    cityWise = json.load(open('cityWiseHotels.json'))
    finalJSON = {}
    i = 0

    for city, cityResults in cityWise.items():
        j = i

        for hotelName in cityResults.keys():
        
            finalJSON[hotelName] = cityWise[city][hotelName]
            i += 1
        
        print(f'{i - j}: {city} Hotels')
    
    json_object = json.dumps(finalJSON, indent = 2) 

    # Writing to sample.json 
    with open(str(fileName) + ".json", "w") as outfile: 
        outfile.write(json_object)

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
            'landmarks': summary['landmarks'],
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

    json_object = json.dumps(finalJSON, indent = 2) 

    # Writing to sample.json 
    with open(str(fileName) + ".json", "w") as outfile: 
        outfile.write(json_object)