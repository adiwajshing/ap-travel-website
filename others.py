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