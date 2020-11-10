import json
from tqdm import tqdm

def fuzzyData(fileName1='searchHotels', fileName2='searchCityHotels'):

    hotelSummaryJSON = json.load(open('backup/hotelSummary.json'))
    finalJSON = {}
    cityJSON = {}

    for hotelName, summary in hotelSummaryJSON.items():

        finalJSON[hotelName] = {
            'title': summary['title'],
            'id': summary['id'],
            'starRating': summary['starRating']
        }

        if cityJSON.get(summary['city']) is None:
            cityJSON[summary['city']] = {}

        cityJSON[summary['city']][hotelName] = {
            'title': summary['title'],
            'id': summary['id'],
            'starRating': summary['starRating']
        }
    
    jsonWrite = json.dumps(finalJSON, indent = 2) 
    with open(fileName1 + ".json", "w") as output: 
        output.write(jsonWrite)

    jsonWrite = json.dumps(cityJSON, indent = 2) 
    with open(fileName2 + ".json", "w") as output: 
        output.write(jsonWrite)

def hashTags(fileName='searchTags'):

    allHotels = json.load(open('backup/allHotels.json'))
    allTags = set()
    finalJSON = dict()

    for v in allHotels.values():
        for tag in v['tags']:
            allTags.add(tag)

    allTags = list(allTags)

    for tag in tqdm(allTags):
        for idStr, hotel in allHotels.items():
            if tag in hotel['tags']:

                if finalJSON.get(tag) is None:
                    finalJSON[tag] = {}

                finalJSON[tag][idStr] = {
                    'title': hotel['title'],
                    'id': hotel['id'],
                    'starRating': hotel['starRating']
                }

    jsonWrite = json.dumps(finalJSON, indent = 2) 
    with open('search/' + fileName + ".json", "w") as output: 
        output.write(jsonWrite)