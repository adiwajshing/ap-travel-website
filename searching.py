from flask import request, Response
from functools import wraps

def verifySearch(cityList=['Delhi', 'Mumbai', 'Bengaluru', 'Hyderabad', 'Pune', 'Tokyo', 'Hong Kong', 'Singapore', 'Dubai']):

    def searchDec(f):
        @wraps(f)
        def decorated(*args, **kwargs):

            q = request.args.get('q', type=str, default=None)
            if q is None or q == '' or q.isspace():
                return Response(status=400, response='Invalid Search Term')

            check_In = request.args.get('check_In', type=str, default=None)
            check_Out = request.args.get('check_Out', type=str, default=None)
            
            city = request.args.get('city', type=str, default=None)

            if city is None or city.isspace() or city == '':
                city = None
            else:
                city = city.title()
                if city not in cityList:
                    return Response(status=404, response='No Such City')

            return f(q, city, check_In, check_Out, *args, **kwargs)
        return decorated
    return searchDec

def verifyFuzzy(cityList=['Delhi', 'Mumbai', 'Bengaluru', 'Hyderabad', 'Pune', 'Tokyo', 'Hong Kong', 'Singapore', 'Dubai']):

    def searchDec(f):
        @wraps(f)
        def decorated(*args, **kwargs):

            q = request.args.get('q', type=str, default=None)
            if q is None or q == '' or q.isspace():
                return Response(status=400, response='Invalid Search Term')
            
            city = request.args.get('city', type=str, default=None)

            if city is None or city.isspace() or city == '':
                city = None
            else:
                city = city.title()
                if city not in cityList:
                    return Response(status=404, response='No Such City')

            return f(q, city, *args, **kwargs)
        return decorated
    return searchDec

#==============================