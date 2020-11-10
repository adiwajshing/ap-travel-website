# Profile helper functions
from flask import request, Response
from datetime import datetime, timedelta
from functools import wraps
from cerberus import Validator

def verifySignUp(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        try:
            email = request.form["email"]
            password = request.form["password"]
            name = request.form["name"]
            phone_number = request.form["phone_number"]
        except:
            return Response(status=400, response='Required Form Data')

        data = {}
        data['name'] = name
        data['email'] = email
        data['phone_number'] = phone_number

        addSchema = {
            "name": {'type':'string', 'required':True, 'empty':False, 'nullable':False},
            "email": {'type':'string', 'required':True, 'empty':False, 'nullable':False},
            "phone_number": {'type':'string', 'required':True, 'empty':False, 'nullable':False, 'minlength':10, 'maxlength':13}
            }

        v = Validator(addSchema)
        try:
            if not v.validate(data):
                return Response(status=400, response=f'Error: {v.errors}')
        except:
            return Response(status=400, response='Validaton Failed')

        return f(email, password, data, *args, **kwargs)

    return decorated

#==============================

def verifySignIn(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        try:
            email = request.form["email"]
            password = request.form["password"]
        except:
            return Response(status=400, response='Form Data Invalid')
        
        return f(email, password, *args, **kwargs)

    return decorated

#==============================

def verifyProfile(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        data = request.get_json()
        addSchema = {
            "name": {'type':'string', 'required':False, 'empty':False, 'nullable':False},
            "phone_number": {'type':'string', 'required':False, 'empty':False, 'nullable':False, 'minlength':10, 'maxlength':13}
        }

        if data is None:
            return Response(status=400, response='No Data Provided')
        v = Validator(addSchema)
        try:
            if not v.validate(data):
                return Response(status=400, response=f'Error: {v.errors}')
        except:
            return Response(status=400, response=f'Validation Failed')
        
        return f(data, *args, **kwargs)

    return decorated

#==============================