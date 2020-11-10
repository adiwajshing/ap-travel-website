# Helper Functions
from flask import request, Response
from datetime import datetime, timedelta
from functools import wraps
from cerberus import Validator

#==============================

def dateConvert(dateStr):

    try:
        dateObj = datetime.strptime(dateStr, '%d/%m/%Y')
    except:
        dateObj = datetime.now()

    return dateObj

#==============================

def verifyBooking(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        body = request.get_json()

        schema = {
            'hotelId': {'type':'string', 'required':True, 'nullable':False, 'empty':False},
            'status': {'type':'string', 'required':True, 'allowed':['booked', 'cancelled', 'visited', 'favourite']}, 

            'bookingDetails': {'type':'dict', 'required':True, 'nullable':False, 'empty':False, 'schema':{
                'bookingName': {'type':'string', 'required':True, 'nullable':False, 'empty':False}, # booking under name
                'guests': {'type':'integer', 'required':True, 'nullable':False, 'empty':False, 'coerce': int, 'min':1}, # number of guests
                'room': {'type':'dict', 'required':True, 'nullable':False, 'empty':False,'default':{'Standard Room':1},
                    'keysrules': {'type': 'string', 'empty': False}, # name of room type
                    'valuesrules': {'type':'integer', 'required':True, 'nullable':False, 'empty':False, 'coerce': int, 'min':1} # number of rooms
                    },
                'check_In': {'required':True, 'nullable':False, 'empty':False, 'coerce': dateConvert}, #dd/mm/yyyy
                'check_Out': {'required':True, 'nullable':False, 'empty':False, 'coerce': dateConvert} #dd/mm/yyyy
            }}
        }

        if body is None:
            return Response(response='No Data Sent', status=400)
    
        v = Validator(schema)
        body = v.normalized(body)

        if v.errors != {}:
            return Response(response=f'Error: {v.errors}', status=400)

        try:
            if not v.validate(body):
                return Response(response=f'Error: {v.errors}', status=400)
        except:
            return Response(status=400, response='Validaton Failed')

        return f(body, *args, **kwargs)

    return decorated

#==============================

def verifyEdits(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        body = request.get_json()

        schema = {
            'status': {'type':'string', 'required':False, 'allowed':['booked', 'cancelled', 'visited', 'favourite']},

            'bookingDetails': {'type':'dict', 'required':False, 'nullable':False, 'empty':False, 'schema':{
                'bookingName': {'type':'string', 'required':False, 'nullable':False, 'empty':False}, # booking under name
                'guests': {'type':'integer', 'required':False, 'nullable':False, 'empty':False, 'coerce': int, 'min':1}, # number of guests
                'room': {'type':'dict', 'required':False, 'nullable':False, 'empty':False,
                    'keysrules': {'type': 'string', 'empty': False}, # name of room type
                    'valuesrules': {'type':'integer', 'required':False, 'nullable':False, 'empty':False, 'coerce': int, 'min':1} # number of rooms
                    },
                'check_In': {'required':False, 'nullable':False, 'empty':False, 'coerce': dateConvert}, #dd/mm/yyyy
                'check_Out': {'required':False, 'nullable':False, 'empty':False, 'coerce': dateConvert} #dd/mm/yyyy
            }}
        }

        if body is None:
            return Response(response='No Data Sent', status=400)
    
        v = Validator(schema)
        body = v.normalized(body)

        if v.errors != {}:
            return Response(response=f'Error: {v.errors}', status=400)

        try:
            if not v.validate(body):
                return Response(response=f'Error: {v.errors}', status=400)
        except:
            return Response(status=400, response='Validaton Failed')

        return f(body, *args, **kwargs)

    return decorated

#==============================