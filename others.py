# Helper Functions
from flask import request, Response
from datetime import datetime, timedelta
from functools import wraps
from cerberus import Validator


#==============================

def verifyReview(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        body = request.get_json()

        schema = {
            "rating": {'type':'number', 'required':True, 'nullable':False, 'min': 1.0, 'max': 10.0, 'coerce':float},
            "review": {'type':'string', 'required':True, 'empty':False, 'nullable':False},
            "title": {'type':'string', 'required':False, 'empty':False, 'nullable':False, 'maxlength': 50, 'default':'General'}
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

def cacheFunc(minutes=5, content_type='application/json; charset=utf-8'):

    # citation: https://maskaravivek.medium.com/how-to-add-http-cache-control-headers-in-flask-34659ba1efc0
    def fwrap(f):
        @wraps(f)
        def wrapped_f(*args, **kwargs):
            r = f(*args, **kwargs)
            then = datetime.now() + timedelta(minutes=minutes)
            rsp = Response(r, content_type=content_type)
            rsp.headers.add('Expires', then.strftime("%a, %d %b %Y %H:%M:%S GMT"))
            rsp.headers.add('Cache-Control', 'public')
            rsp.headers.add('Cache-Control', 'max-age=%d' % int(60 * minutes))
            rsp.headers.add('Vary', '')
            return rsp
        return wrapped_f
    return fwrap

#==============================

def emailFormat(booking):

    message = f'''Greetings {booking.get('bookingDetails').get('bookingName')}!

We are pleased to confirm your booking at the {booking.get('title')}.

Here are your reservation details:

Reservation Number: {booking.get('bookingId').upper()}
Reservation Status: Booked
Booked Under Name: {booking.get('bookingDetails').get('bookingName')}

Hotel Name: {booking.get('title')}
Check In Date: {booking.get('bookingDetails').get('check_In').strftime('%B %d, %Y')}
Check Out Date: {booking.get('bookingDetails').get('check_Out').strftime('%B %d, %Y')}

Total Guests: {booking.get('bookingDetails').get('guests')}
Rooms: {','.join(booking.get('bookingDetails').get('room').keys())}
Price: ₹{booking.get('price')}

General Instructions:

1) An Invoice of ₹{booking.get('price')} will be provided to you on check-in. 
2) Please carry an ID Proof for verification at the Front Desk. 
3) Since these are trying times for all of us, we humbly ask you to follow COVID-19 safety guidelines during your travel. As an agent between you and the hotel, the responsibility of providing health guarantees often falls on us and thus we request all our clients to take necessary precautions, while we make sure the hotels do the same for you :)

The iconic, stylish and sophisticated, {booking.get("title")} offers stunning, leading edge design with a genuine, inviting ambiance sure to delight travel savvy, modern guests and it can't wait for your visit!!

Looking forward to welcoming you soon! Until then, write to us with any concerns.
The Staysia Booking Team'''

    return message