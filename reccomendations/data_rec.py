import json
import re
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize 
from fuzzywuzzy import fuzz
from fuzzywuzzy import process
from tqdm import tqdm

#====================================================

starWeight = {"0":4, "1":3, "2":2, "3":1, "4":0}
starKeys = [int(x) for x in starWeight.keys()]

priceWeight = {"500":5, "750":4, "1000":3, "1250":2, "1500":1, "1750":0}
priceKeys = [int(x) for x in priceWeight.keys()]

stopWordSet = set(stopwords.words('english'))

#====================================================

def cleanTags(fileName='tagFrequency'):
    
    allHotels = json.load(open('backup/allHotels.json'))
    # finalJSON = {}

    for k, v in allHotels.items():

        for xOld in v['tags']:
            
            x = xOld

            if 'guestrooms' in x:
                x = 'smoke-free guestrooms'
            elif 'apartment' in x:
                x = 'apartments'
            elif 'outdoor pool' in x:
                x = 'outdoor pool'
            elif 'indoor pool' in x:
                x = 'indoor pool'
            elif 'golf course' in x:
                x = 'golf course'
            elif 'spa' in x and 'service' in x:
                x = 'spa services'
            elif 'airport' in x and 'road' not in x:
                x = 'airport shuttle'
            elif 'tennis court' in x:
                x = 'tennis court'
            elif 'health club' in x:
                x = 'health club'
            elif 'business center' in x:
                x = 'business center'
            elif 'childcare' in x:
                x = 'childcare'
            elif 'meeting room' in x:
                x = 'meeting rooms'
            elif x == 'terrace':
                x = 'rooftop terrace'
            elif 'fitness center' in x or 'gym' in x:
                x = 'gym'
            elif 'shopping center shuttle' in x:
                x = 'shopping center shuttle'
            elif x == 'room service':
                x = '24-hour room service'
            elif 'nehru stadium' in x:
                x = 'nehru stadium'
            elif "children's club" in x:
                x = "children's club"
            elif 'phoenix' in x:
                x = 'phoenix market city mall'
            elif 'ocean park' in x:
                x = 'ocean park'
            elif 'juhu' in x:
                x = 'juhu beach'
            elif 'colaba' in x:
                x = 'colaba'
            elif 'ulsoor' in x:
                x = 'ulsoor lake'

            elif 'restaurants' in x or 'bar/lounge' in x or ('restaurant' in x and 'bars/lounges' in x) or x == 'restaurant':
                x = 'restaurants and bar/lounge'
            elif x == 'new delhi':
                x = 'delhi'
            elif x == 'free area shuttle':
                x = 'free shuttle'

            elif 'internet' in x:
                x = 'free wifi'
            elif 'free wifi' in x and 'parking' in x and 'breakfast' in x:
                x = 'free breakfast, wifi and parking'
            elif 'free wifi' in x and 'parking' in x and 'breakfast' not in x:
                x = 'free wifi and parking'
            elif 'free wifi' in x and 'parking' not in x and 'breakfast' in x:
                x = 'free breakfast and wifi'
            elif 'free wifi' not in x and 'parking' in x and 'breakfast' in x:
                x = 'free parking and breakfast'
            elif 'free wifi' in x:
                x = 'free wifi'
            
            elif x[0:3] == 'in ':
                x = x[3:]
            
            # if finalJSON.get(x) is not None:
            #     finalJSON[x] = finalJSON.get(x) + 1
            # else:
            #     finalJSON[x] = 1
            
            allHotels[k]['tags'] = [x if m == xOld else m for m in allHotels[k]['tags']]
    
    # finalJSON = {k: v for k, v in sorted(finalJSON.items(), key=lambda item: item[1], reverse=True)}

    # allTagNames = [x for x in finalJSON.keys()]
    # compare = [x for x in allTagNames]
    # allRes = []

    # for q in tqdm(allTagNames):

    #     compare.remove(q)
    #     res = process.extractOne(q, compare, score_cutoff=90)
    #     if res is not None:
    #         allRes.append(f'{q}: {res}')
    #     compare.append(q)

    # jsonWrite = json.dumps(finalJSON, indent = 2) 
    # with open('reccomendations/' + fileName + ".json", "w") as output: 
    #     output.write(jsonWrite)
    
    # with open('reccomendations/mismatch.txt', 'w') as output:
    #     output.write('\n'.join(allRes))

    jsonWrite = json.dumps(allHotels, indent = 2) 
    with open('backup/allHotels' + ".json", "w") as output: 
        output.write(jsonWrite)

def editedHotels(fileName='hashHotels'):
    ''' Removes Neighbourhood, Stars and City from tags to reassign weights '''

    allHotels = json.load(open('backup/allHotels.json'))
    removal = ['main_image', 'description', 'feature_bullets', 'mapWidget', 'rooms', 'address', 'landmarks', 'destinationId', 'checkIn', 'checkOut']

    for k, v in allHotels.items():

        try:
            for x in removal:
                allHotels[k].pop(x)

            allHotels[k]['tags'].remove(v['city'].lower())
            allHotels[k]['tags'].remove(f"{v['starRating']} stars")
            allHotels[k]['tags'].remove(v['neighbourhood'].lower())
        
        except:
            try:
                if v['neighbourhood'].lower() == 'new delhi':
                    allHotels[k]['tags'].remove('delhi')
            except:
                print(f"{k}:{v}")
                input()
    
    jsonWrite = json.dumps(allHotels, indent = 2) 
    with open('reccomendations/' + fileName + ".json", "w") as output: 
        output.write(jsonWrite)

def engine(fileName='reccomended'):

    allHotels = json.load(open('reccomendations/hashHotels.json'))
    tagHash = json.load(open('search/searchTags.json'))

    tagWeight = 1
    cityWeight = 4
    neighbourhoodWeight = 5
    fuzzyWeight = 0.1

    starWeight = {"0":4, "1":3, "2":2, "3":1, "4":0}
    starKeys = [int(x) for x in starWeight.keys()]

    priceWeight = {"500":5, "750":4, "1000":3, "1250":2, "1500":1, "1750":0}
    priceKeys = [int(x) for x in priceWeight.keys()]

    finalJSON = {}

    for hotelId, hotelInfo in allHotels.items():

        calcWeight = dict()

        currentTagArray = hotelInfo['tags']
        for tag in currentTagArray:
            for sameTagHotel in tagHash[tag].keys():

                if sameTagHotel != hotelId:
                    calcWeight[sameTagHotel] = (calcWeight.get(sameTagHotel) or 0) + tagWeight
             

        for indvHotel in allHotels.values():

            tempId = str(indvHotel['id'])
            if tempId != hotelId:
                
                priceDiff = abs(indvHotel['price']['current_price'] - hotelInfo['price']['current_price'])
                starDiff = abs(indvHotel['starRating'] - hotelInfo['starRating'])
            
                priceRange = priceKeys[min(range(len(priceKeys)), key = lambda i: abs(priceKeys[i]-priceDiff))]
                starRange = starKeys[min(range(len(starKeys)), key = lambda i: abs(starKeys[i]-starDiff))]
                editDistance = fuzz.partial_ratio(hotelInfo['title'], indvHotel['title']) * fuzzyWeight

                if calcWeight.get(tempId) is None:
                    calcWeight[tempId] = 0
                
                calcWeight[tempId] = calcWeight[tempId] + priceWeight[str(priceRange)]
                calcWeight[tempId] = calcWeight[tempId] + starWeight[str(starRange)]
                calcWeight[tempId] = calcWeight[tempId] + editDistance
                
                if indvHotel['city'] == hotelInfo['city']:
                    
                    if indvHotel['neighbourhood'] == hotelInfo['neighbourhood']:
                        calcWeight[tempId] = calcWeight[tempId] + neighbourhoodWeight
                    else:
                        calcWeight[tempId] = calcWeight[tempId] + cityWeight
            
                calcWeight[tempId] = round(calcWeight[tempId] * indvHotel['rating'], 3)

        calcWeight = {k: v for k, v in sorted(calcWeight.items(), key=lambda item: item[1], reverse=True)}

        count = 0
        final = dict()
        for key in calcWeight.keys():
            if count == 10:
                break
            count += 1
            final[key] = calcWeight[key]

        finalJSON[hotelId] = final

    jsonWrite = json.dumps(finalJSON, indent = 2) 
    with open('reccomendations/' + fileName + ".json", "w") as output: 
        output.write(jsonWrite)

def userPreferenceScoring(indvHotel, preferences):

    score = 0
    scoreWeight = 0.5

    indvHotelReview = set()
    reviewWeight = 1/30

    priceDiff = abs(indvHotel['price']['current_price'] - preferences['avgPrice'])
    starDiff = abs(indvHotel['starRating'] - preferences['avgStar'])
            
    priceRange = priceKeys[min(range(len(priceKeys)), key = lambda i: abs(priceKeys[i]-priceDiff))]
    starRange = starKeys[min(range(len(starKeys)), key = lambda i: abs(starKeys[i]-starDiff))]

    score += priceWeight[str(priceRange)]
    score += starWeight[str(starRange)]

    for tag in indvHotel['tags']:
        if tag in preferences['commonTags']:
            score += 1
    
    for review in indvHotel['reviews']:
        tempReviewSet = set(review['review'].split()) - stopWordSet
        indvHotelReview = indvHotelReview.union(tempReviewSet)

    indvHotelReview = [re.sub(r'[^\w\s]', '', x.lower()) for x in indvHotelReview]
    for reviewWord in indvHotelReview:
        if not reviewWord.isalpha():
            indvHotelReview.remove(reviewWord)

    # Citation: next line taken from https://www.geeksforgeeks.org/python-percentage-similarity-of-lists/
    similarity = round(len(set(indvHotelReview) & set(preferences['reviewWords'])) / float(len(set(indvHotelReview) | set(preferences['reviewWords']))) * 100)
    score = score + (similarity * reviewWeight)

    return round(score * scoreWeight, 3)

def runRecEngine(hotelId):

    allHotels = json.load(open('reccomendations/hashHotels.json'))
    tagHash = json.load(open('search/searchTags.json'))

    try:
        hotelInfo = allHotels[hotelId]
    except:
        return None

    tagWeight = 1
    cityWeight = 4
    neighbourhoodWeight = 5
    fuzzyWeight = 0.1

    calcWeight = dict()

    currentTagArray = hotelInfo['tags']
    for tag in currentTagArray:
        for sameTagHotel in tagHash[tag].keys():

            if sameTagHotel != hotelId:

                if calcWeight.get(sameTagHotel) is None:
                    calcWeight[sameTagHotel] = 0
                
                calcWeight[sameTagHotel] = calcWeight[sameTagHotel] + tagWeight


    for indvHotel in allHotels.values():

        tempId = str(indvHotel['id'])
        if tempId != hotelId:

            priceDiff = abs(indvHotel['price']['current_price'] - hotelInfo['price']['current_price'])
            starDiff = abs(indvHotel['starRating'] - hotelInfo['starRating'])
            
            priceRange = priceKeys[min(range(len(priceKeys)), key = lambda i: abs(priceKeys[i]-priceDiff))]
            starRange = starKeys[min(range(len(starKeys)), key = lambda i: abs(starKeys[i]-starDiff))]
            editDistance = fuzz.partial_ratio(hotelInfo['title'], indvHotel['title']) * fuzzyWeight

            if calcWeight.get(tempId) is None:
                calcWeight[tempId] = 0
            
            calcWeight[tempId] = calcWeight[tempId] + priceWeight[str(priceRange)]
            calcWeight[tempId] = calcWeight[tempId] + starWeight[str(starRange)]
            calcWeight[tempId] = calcWeight[tempId] + editDistance

            if indvHotel['city'] == hotelInfo['city']:
                
                if indvHotel['neighbourhood'] == hotelInfo['neighbourhood']:
                    calcWeight[tempId] = calcWeight[tempId] + neighbourhoodWeight
                else:
                    calcWeight[tempId] = calcWeight[tempId] + cityWeight
        
            calcWeight[tempId] = round(calcWeight[tempId] * indvHotel['rating'], 3)

    calcWeight = {k: v for k, v in sorted(calcWeight.items(), key=lambda item: item[1], reverse=True)}
    final = [int(k) for k in calcWeight.keys()][0:10]

    return final

def addAvgHotel(hotelInfo, avgHotel):

    if avgHotel is None:

        commonTags = set(hotelInfo['tags'])
        reviewWords = set()
        
        for review in hotelInfo['reviews']:
            tempReviewSet = set(review['review'].split()) - stopWordSet
            reviewWords = reviewWords.union(tempReviewSet)

        reviewWords = [re.sub(r'[^\w\s]', '', x.lower()) for x in reviewWords]
        for reviewWord in reviewWords:
            if not reviewWord.isalpha():
                reviewWords.remove(reviewWord)

        returnDict = {
            'totalHotels': 1,
            'avgPrice': hotelInfo['price']['current_price'],
            'avgStar': hotelInfo['starRating'],
            'commonTags': list(commonTags),
            'reviewWords': reviewWords
        }

        return returnDict

    totalHotels = avgHotel['totalHotels']
    oldAvgPrice = avgHotel['avgPrice']
    oldAvgStar = avgHotel['avgStar']
    oldTags = set(avgHotel['commonTags'])
    oldReviewWords = set(avgHotel['reviewWords'])

    newAvgPrice = ((oldAvgPrice * totalHotels)  + hotelInfo['price']['current_price']) / (totalHotels + 1)
    newAvgStar = ((oldAvgStar * totalHotels)  + hotelInfo['starRating']) / (totalHotels + 1)

    indvHotelReview = set()
    for review in hotelInfo['reviews']:
        tempReviewSet = set(review['review'].split()) - stopWordSet
        indvHotelReview = indvHotelReview.union(tempReviewSet)

    indvHotelReview = [re.sub(r'[^\w\s]', '', x.lower()) for x in indvHotelReview]
    for reviewWord in indvHotelReview:
        if not reviewWord.isalpha():
            indvHotelReview.remove(reviewWord)
        else:
            oldReviewWords.add(reviewWord)

    for tag in hotelInfo['tags']:
        oldTags.add(tag)

    returnDict = {
        'totalHotels': totalHotels + 1,
        'avgPrice': round(newAvgPrice, 3),
        'avgStar': round(newAvgStar, 3),
        'commonTags': list(oldTags),
        'reviewWords': list(oldReviewWords)
    }

    return returnDict