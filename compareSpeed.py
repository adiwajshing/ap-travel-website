import time
import json

def testJson():
    
    start = time.time()
    hotelSummary = json.load(open('backup/hotelSummary.json'))
    data = []
    for v in hotelSummary.values():
        if v.get('city') == 'Delhi':
            data.append(v)
    
    end = time.time() - start
    print(end)
    print(len(data))

    return True

testJson()