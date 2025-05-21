from django.http.response import JsonResponse
from django.shortcuts import render
from datetime import datetime
from django.http import JsonResponse
import json
from django.views.decorators.csrf import csrf_exempt
from backend.settings import sendMail, sendResponse ,disconnectDB, connectDB, resultMessages,generateStr

# Odoogiin tsagiig duuddag service
def dt_gettime(request):
    jsons = json.loads(request.body) # request body-g dictionary bolgon avch baina
    action = jsons["action"] #jsons-s action-g salgaj avch baina
    
    # url: http://localhost:8000/user/
    # Method: POST
    # Body: raw JSON
    
    # request body:
    # {"action":"gettime"}
    
    # response:
    # {
    #     "resultCode": 200,
    #     "resultMessage": "Success",
    #     "data": [
    #         {
    #             "time": "2024/11/06, 07:53:58"
    #         }
    #     ],
    #     "size": 1,
    #     "action": "gettime",
    #     "curdate": "2024/11/06 07:53:58"
    # }
    
    respdata = [{'time1':datetime.now().strftime("%Y/%m/%d, %H:%M:%S")}]  # response-n data-g beldej baina. list turultei baih
    resp = sendResponse(request, 200, respdata, action)
    
    return resp
# dt_gettime

#edit user
def dt_edituser(request):
    jsons = json.loads(request.body) 
    action = jsons['action'] 
    try:
        userid = jsons['userid']
        username = jsons['username']
        email = jsons['email'].lower()
        bio = jsons['bio']
        profileimagebase64 = jsons['profileimagebase64']
    except: 
        resp = sendResponse(request, 3000, [], action) 
        return resp
    
    try: 
        myConn = connectDB() 
        cursor = myConn.cursor() 
        
        # uid-r hailt hiij fname, lname update hiij baina.
        query = F"""UPDATE users SET username = '{username}' ,
                    email = '{email}' , bio = '{bio}' ,
                    profileimagebase64 = '{profileimagebase64}' 
                    WHERE userid = {userid}""" 
        
        cursor.execute(query) 
        myConn.commit()
        
        query = F"""SELECT userid, username, email, bio, profileimagebase64 FROM users
                    WHERE userid = {userid}""" 
        
        cursor.execute(query) 
        columns = cursor.description #
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        cursor.close() 
        respdata = respRow
        resp = sendResponse(request, 200, respdata, action) 
    except Exception as e:
        resp = sendResponse(request, 5000, [], action) 
        
    finally:
        disconnectDB(myConn) 
        return resp 
#dt_edituser

def dt_getuserinfo(request):
    jsons = json.loads(request.body) 
    action = jsons['action'] 
    try:
        userid = jsons['userid'] 
    except: 
        action = jsons['action']
        resp = sendResponse(request, 3000, [], action) 
        return resp
    
    try: 
        myConn = connectDB() 
        cursor = myConn.cursor() 
        
        # Hereglegchiin ner, password-r nevtreh erhtei (isverified=True) hereglegch login hiij baigaag toolj baina.
        query = F"""SELECT COUNT(*) AS usercount, MIN(email) AS email, 
                MAX(username) AS username, MAX(bio) AS bio, MAX(profileimagebase64) AS profileimagebase64 FROM users 
                WHERE userid = '{userid}' 
                AND isverified = True 
                """ 
        cursor.execute(query) 
        columns = cursor.description 
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        cursor.close() 
        if respRow[0]['usercount'] == 1:
            resp = sendResponse(request, 200, respRow, action)
        else:
            data = [{'userid':userid}]
            resp = sendResponse(request, 4001, data, action) 
    except Exception as e:
        resp = sendResponse(request, 5000, [], action) 
        
    finally:
        disconnectDB(myConn) 
        return resp 
#dt_getuserinfo
    
def dt_getalluser(request):
    jsons = json.loads(request.body) 
    action = jsons['action'] 
    try:
        uid1 = 1
    except: 
        action = jsons['action']
        respdata = []
        resp = sendResponse(request, 3026, respdata, action) 
        return resp
    
    try: 
        myConn = connectDB() 
        cursor = myConn.cursor() 
        
         
        isverifiedQuery = ""
        if "isverified" in jsons:
            isverified = jsons["isverified"]
            isverifiedQuery = F""" AND  isverified = {isverified}"""
        
        
        isbannedQuery = ""
        if "isbanned" in jsons:
            isbanned = jsons["isbanned"]
            isbannedQuery = F""" AND  isbanned = {isbanned}"""
        
        
        query = F"""SELECT uid, uname, fname, lname, isverified, isbanned
                    FROM t_user WHERE 1=1 """ + isverifiedQuery + isbannedQuery
        
        cursor.execute(query) 
        columns = cursor.description #
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        
        uid = respRow[0]['uid']
        uname = respRow[0]['uname']
        fname = respRow[0]['fname']
        lname = respRow[0]['lname']
        cursor.close() 
        respdata = respRow 
        resp = sendResponse(request, 1007, respdata, action) 
    except:
        
        action = jsons["action"]
        respdata = [] 
        resp = sendResponse(request, 5009, respdata, action) 
        
    finally:
        disconnectDB(myConn) 
        return resp 
#dt_getalluser


@csrf_exempt # method POST uyd ajilluulah csrf
def editcheckService(request): # hamgiin ehend duudagdah request shalgah service
    if request.method == "POST": # Method ni POST esehiig shalgaj baina
        try:
            # request body-g dictionary bolgon avch baina
            jsons = json.loads(request.body)
        except:
            # request body json bish bol aldaanii medeelel butsaana. 
            action = "no action"
            respdata = [] 
            resp = sendResponse(request, 3003, respdata) 
            return JsonResponse(resp) 
            
        try: 
            #jsons-s action-g salgaj avch baina
            action = jsons["action"]
        except:
            # request body-d action key baihgui bol aldaanii medeelel butsaana. 
            action = "no action"
            respdata = [] 
            resp = sendResponse(request, 3005, respdata,action) 
            return JsonResponse(resp)
        
        if action == "gettime":
            result = dt_gettime(request)
            return JsonResponse(result)
        elif action == "edituser":
            result = dt_edituser(request)
            return JsonResponse(result)
        elif action == "getuserinfo":
            result = dt_getuserinfo(request)
            return JsonResponse(result)
        elif action == "getalluser":
            result = dt_getalluser(request)
            return JsonResponse(result)
        else:
            action = "no action"
            respdata = []
            resp = sendResponse(request, 3001, respdata, action)
            return JsonResponse(resp)
    
    # Method ni POST bish bol ajillana
    else:
        #GET, POST-s busad uyd ajillana
        action = "no action"
        respdata = []
        resp = sendResponse(request, 3002, respdata, action)
        return JsonResponse(resp)
