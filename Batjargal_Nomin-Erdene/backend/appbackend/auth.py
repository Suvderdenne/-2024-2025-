from django.http.response import JsonResponse
from django.shortcuts import render
from datetime import datetime
from django.http import JsonResponse
import json
from django.views.decorators.csrf import csrf_exempt
from backend.settings import sendMail, sendResponse ,disconnectDB, connectDB, resultMessages,generateStr, generateStrNum

#login service
def dt_login(request):
    jsons = json.loads(request.body) 
    action = jsons['action']
    try:
        email = jsons['email'].lower() 
        password = jsons['password'] 
    except: 
        action = jsons['action']
        respData = []
        resp = sendResponse(request, 3000, respData, action) 
        return resp
    
    try: 
        myConn = connectDB() 
        cursor = myConn.cursor() 
        
        # Hereglegchiin ner, password-r nevtreh erhtei (isverified=True) hereglegch login hiij baigaag toolj baina.
        query = F"""SELECT COUNT(*) AS usercount, MIN(email) AS email, MAX(username) AS username FROM users 
                WHERE email = '{email}' 
                AND isverified = True 
                AND password = '{password}'
                """ 
        cursor.execute(query) 
        columns = cursor.description 
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        cursor.close() 

        if respRow[0]['usercount'] == 1:
            cursor1 = myConn.cursor() 
            query = F"""SELECT userid, username, email
                    FROM users 
                    WHERE email = '{email}' AND isverified = True AND password = '{password}'"""
            
            cursor1.execute(query) 
            columns = cursor1.description 
            respData = [{columns[index][0]:column for index, 
                column in enumerate(value)} for value in cursor1.fetchall()] 
            resp = sendResponse(request, 200, respData, action)
            cursor1.close() 
        else:
            data = [{'email':email}]
            resp = sendResponse(request, 4001, data, action) 
    except Exception as e:
        respData = [] 
        resp = sendResponse(request, 5000, respData, action) 
        
    finally:
        disconnectDB(myConn) 
        return resp 
#dt_login

def dt_register(request):
    jsons = json.loads(request.body) 
    action = jsons["action"] 
    try :
        username = jsons["username"].lower() 
        email = jsons["email"].lower()
        password = jsons["password"]
    except:
        action = jsons['action']
        respData = []
        resp = sendResponse(request, 3000, respData, action) 
        return resp
    
    try:
        conn = connectDB() 
        cursor = conn.cursor() 
        cursor.execute(F"""SELECT COUNT(*) AS usercount FROM users WHERE username = '{username}' AND email = '{email}' AND isverified = True""") 
        columns = cursor.description 
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        cursor.close() 

        if respRow[0]["usercount"] == 0: 
            cursor1 = conn.cursor() 
            token = generateStrNum(6) 
            cursor1.execute(F"""INSERT INTO users(username, email, password, isverified, token) 
                        VALUES('{username}','{email}','{password}', False, '{token}') 
            RETURNING userid""") 
            userid = cursor1.fetchone()[0] 
            conn.commit() 
            cursor1.close() 
                        
            subject = "Хэрэглэгч баталгаажлуулах"
            bodyHTML = F"""Таны оруулах нууц үг. {token}"""
            sendMail(email,subject,bodyHTML)
            respData = [{"username":username,"email":email, "userid": userid}]
            resp = sendResponse(request, 201, respData, action) 
        else:
            respData = [{"username":username,"email":email}]
            resp = sendResponse(request, 3008, respData, action) 
    except (Exception) as e:
        respData = [{"aldaa":str(e)}] 
        resp = sendResponse(request, 5000, respData, action) 
        
    finally:
        disconnectDB(conn) 
        return resp 
# dt_register
    
def dt_token(request):
    jsons = json.loads(request.body) 
    action = jsons["action"] 
    try :
        email = jsons["email"].lower()
        token = jsons["token"].lower() 
    except:
        action = jsons['action']
        respData = []
        resp = sendResponse(request, 3000, respData, action) 
        return resp
    try:
        conn = connectDB() 
        cursor = conn.cursor() 
        # Имэйл хаяг дээрх токен байгаа эсэхийг шалгах
        cursor.execute(F"""SELECT COUNT(*) AS usercount FROM users WHERE email = '{email}' AND token = '{token}' AND isverified = False""") 
        columns = cursor.description 
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 

        if respRow[0]["usercount"] == 1: 
            cursor.execute(F"""UPDATE users SET isverified = True, token = '{generateStrNum(7)}' WHERE email = '{email}' AND token = '{token}'""") 
            conn.commit() 
            cursor.execute(F"""SELECT userid, username, email FROM users WHERE email = '{email}' AND   isverified = True""") 
            columns = cursor.description 
            respData = [{columns[index][0]:column for index, 
                column in enumerate(value)} for value in cursor.fetchall()] 
            resp = sendResponse(request, 201, respData, action) 
        else:
            respData = [{"email":email,"token":token}]
            resp = sendResponse(request, 3008, respData, action) 
    except (Exception) as e:
        respData = [{"aldaa":str(e)}] 
        resp = sendResponse(request, 5000, respData, action) 
    finally:
        cursor.close() 
        disconnectDB(conn) 
        return resp 
# dt_token

# Nuuts ugee martsan bol duudah service
def dt_forgot(request):
    jsons = json.loads(request.body) 
    action = jsons['action'] 
    
    resp = {}
    
    # url: http://localhost:8000/user/
    # Method: POST
    # Body: raw JSON
    
    # request body:
    # {
    #     "action": "forgot",
    #     "username": "ganzoo@mandakh.edu.mn"
    # }
    
    # response: 
    # {
    #     "resultCode": 3012,
    #     "resultMessage": "Forgot password huselt ilgeelee",
    #     "data": [
    #         {
    #             "username": "ganzoo@mandakh.edu.mn"
    #         }
    #     ],
    #     "size": 1,
    #     "action": "forgot",
    #     "curdate": "2025/4/06 08:00:32"
    # }
    try:
        username = jsons['username'].lower() 
    except: 
        action = jsons['action']
        respData = []
        resp = sendResponse(request, 3016, respData, action) 
        return resp
    
    try: 
        myConn = connectDB() 
        cursor = myConn.cursor() 
        # hereglegch burtgeltei esehiig shalgaj baina. Burtgelgui, verified hiigeegui hereglegch bol forgot password ajillahgui.
        query = f"""SELECT COUNT(*) AS usercount, MIN(username) AS username , MIN(userid) AS userid
                    FROM users
                    WHERE username = '{username}' AND isverified = True"""
        cursor.execute(query) 
        cursor.description
        columns = cursor.description #
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        
        
        
        if respRow[0]['usercount'] == 1: # verified hereglegch oldson bol nuuts ugiig sergeehiig zuvshuurnu. 
            userid = respRow[0]['userid']
            username = respRow[0]['username']
            token = generateStr(25) # forgot password-iin token uusgej baina. 25 urttai
            query = F"""INSERT INTO t_token(userid, token, tokentype, tokenenddate, createddate) 
            VALUES({userid}, '{token}', 'forgot', NOW() + interval \'1 day\', NOW() )""" # Inserting forgot token in t_token
            cursor.execute(query) 
            myConn.commit() 
            
            # forgot password verify hiih mail
            subject = "Nuuts ug shinechleh"
            body = f"<a href='http://localhost:8000/user?token={token}'>Martsan nuuts ugee shinechleh link</a>"
            sendMail(username, subject, body)
            
            # sending Response
            action = jsons['action']
            respData = [{"username":username}]
            resp = sendResponse(request,3012,respData,action )
            
        else: # verified user not found 
            action = jsons['action']
            respData = [{"username":username}]
            resp = sendResponse(request,3013,respData,action )
            
    except Exception as e: # forgot service deer dotood aldaa garsan bol ajillana.
        # forgot service deer aldaa garval ajillana. 
        action = jsons["action"]
        respData = [{"error":str(e)}] 
        resp = sendResponse(request, 5003, respData, action) 
    finally:
        cursor.close() 
        disconnectDB(myConn) 
        return resp 
# dt_forgot

# Nuuts ugee martsan uyd resetpassword service-r nuuts ugee shinechilne
def dt_resetpassword(request):
    jsons = json.loads(request.body) 
    action = jsons['action'] 
    
    resp = {}
    
    # url: http://localhost:8000/user/
    # Method: POST
    # Body: raw JSON
    
    # request body:
    #  {
    #     "action": "resetpassword",
    #     "token":"145v2n080t0lqh3i1dvpt3tgkrmn3kygqf5sqwnw",
    #     "newpass":"MandakhSchool"
    # }
    
    # response:
    # {
    #     "resultCode": 3019,
    #     "resultMessage": "martsan nuuts ugiig shinchille",
    #     "data": [
    #         {
    #             "username": "ganzoo@mandakh.edu.mn"
    #         }
    #     ],
    #     "size": 1,
    #     "action": "resetpassword",
    #     "curdate": "2025/4/06 08:03:25"
    # }
    try:
        newpass = jsons['newpass'] 
        token = jsons['token'] 
    except: # newpass, token key ali neg ni baihgui bol aldaanii medeelel butsaana
        action = jsons['action']
        respData = []
        resp = sendResponse(request, 3018, respData, action) 
        return resp
    
    try: 
        myConn = connectDB() 
        cursor = myConn.cursor() 
        
        # Tuhain token deer burtgeltei batalgaajsan hereglegch baigaa esehiig shalgana. Neg l hereglegch songogdono esvel songogdohgui. Token buruu, hugatsaa duussan bol resetpassword service ajillahgui.
        query = f"""SELECT COUNT (users.userid) AS usercount
                , MIN(username) AS username
                , MAX(users.userid) AS userid
                , MAX(t_token.tokenid) AS tokenid
                FROM users INNER JOIN t_token
                ON users.userid = t_token.userid
                WHERE t_token.token = '{token}'
                AND users.isverified = True
                AND t_token.tokenenddate > NOW()"""
        cursor.execute(query) 
        columns = cursor.description #
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        
        if respRow[0]['usercount'] == 1: # token idevhtei, verified hereglegch oldson bol nuuts ugiig shinechlehiig zuvshuurnu.
            userid = respRow[0]['userid']
            username = respRow[0]['username']
            tokenid = respRow[0] ['tokenid'] 
            token = generateStr(40) 
            query = F"""UPDATE users SET password = '{newpass}'
                        WHERE users.userid = {userid}""" # Updating user's new password in users
            cursor.execute(query) 
            myConn.commit() 
            
            query = F"""UPDATE t_token 
                SET token = '{token}'
                , tokenenddate = '1970-01-01' 
                WHERE tokenid = {tokenid}""" # Updating token and tokenenddate in t_token. Token-iig idevhgui bolgoj baina
            cursor.execute(query) 
            myConn.commit()              
            
            # sending Response
            action = jsons['action']
            respData = [{"username":username}]
            resp = sendResponse(request,3019,respData,action )
            
        else: # token not found 
            action = jsons['action']
            respData = []
            resp = sendResponse(request,3020,respData,action )
            
    except Exception as e: # reset password service deer dotood aldaa garsan bol ajillana.
        # reset service deer aldaa garval ajillana. 
        action = jsons["action"]
        respData = [{"error":str(e)}] # aldaanii medeelel bustaana.
        resp = sendResponse(request, 5005, respData, action) 
    finally:
        cursor.close() 
        disconnectDB(myConn) 
        return resp 
#dt_resetpassword

# Huuchin nuuts ugee ashiglan Shine nuuts ugeer shinechleh service
def dt_changepassword(request):
    jsons = json.loads(request.body) 
    action = jsons['action'] 
    
    resp = {}
    
    # url: http://localhost:8000/user/
    # Method: POST
    # Body: raw JSON
    
    # request body:
    # {
    #     "action": "changepassword",
    #     "username": "ganzoo@mandakh.edu.mn",
    #     "oldpass":"a1b2c3d4",
    #     "newpass":"a1b2"
    # }
    
    # response: 
    # {
    #     "resultCode": 3022,
    #     "resultMessage": "nuuts ug amjilttai soligdloo ",
    #     "data": [
    #         {
    #             "username": "ganzoo@mandakh.edu.mn",
    #             "lname": "U",
    #             "fname": "Ganzo"
    #         }
    #     ],
    #     "size": 1,
    #     "action": "changepassword",
    #     "curdate": "2025/4/06 08:04:18"
    # }
    try:
        username = jsons['username'].lower() 
        newpass = jsons['newpass'] 
        oldpass = jsons['oldpass'] # get oldpass key from jsons
    except: # username, newpass, oldpass key ali neg ni baihgui bol aldaanii medeelel butsaana
        action = jsons['action']
        respData = []
        resp = sendResponse(request, 3021, respData, action) 
        return resp
    
    try: 
        myConn = connectDB() 
        cursor = myConn.cursor() 
        # burtgeltei batalgaajsan hereglegchiin nuuts ug zuv esehiig shalgaj baina. Burtgelgui, verified hiigeegui, huuchin nuuts ug taarahgui hereglegch bol change password ajillahgui.
        query = f"""SELECT COUNT(userid) AS usercount ,MAX(userid) AS userid
                    ,MIN(username) AS username
                    ,MIN (lname) AS lname
                    ,MAX (fname) AS fname
                    FROM users
                    WHERE username='{username}'  
                    AND isverified=true
                    AND password='{oldpass}'"""
        cursor.execute(query) 
        columns = cursor.description #
        respRow = [{columns[index][0]:column for index, 
            column in enumerate(value)} for value in cursor.fetchall()] 
        
        if respRow[0]['usercount'] == 1: # Burtgeltei, batalgaajsan, huuchin nuuts ug taarsan hereglegch oldson bol nuuts ugiig shineer solihiig zuvshuurnu.
            userid = respRow[0]['userid']
            username = respRow[0]['username']
            lname = respRow[0]['lname']
            fname = respRow[0]['fname']
            
            query = F"""UPDATE users SET password='{newpass}'
                        WHERE userid={userid}""" # Updating user's new password using userid in users
            cursor.execute(query) 
            myConn.commit() 
            
            # sending Response
            action = jsons['action']
            respData = [{"username":username, "lname": lname, "fname":fname}]
            resp = sendResponse(request, 3022, respData, action )
            
        else: # old password not match
            action = jsons['action']
            respData = [{"username":username}]
            resp = sendResponse(request, 3023, respData, action )
            
    except Exception as e: # change password service deer dotood aldaa garsan bol ajillana.
        # change service deer aldaa garval ajillana. 
        action = jsons["action"]
        respData = [{"error":str(e)}] 
        resp = sendResponse(request, 5006, respData, action) 
    finally:
        cursor.close() 
        disconnectDB(myConn) 
        return resp 
# dt_changepassword

@csrf_exempt # method POST uyd ajilluulah csrf
def checkService(request):
    if request.method == "POST": 
        try:
            # request body-g dictionary bolgon avch baina
            jsons = json.loads(request.body)
        except:
            # request body json bish bol aldaanii medeelel butsaana. 
            action = "no action"
            respData = [] 
            resp = sendResponse(request, 3003, respData) 
            return JsonResponse(resp) 
            
        try: 
            #jsons-s action-g salgaj avch baina
            action = jsons["action"]
        except:
            # request body-d action key baihgui bol aldaanii medeelel butsaana. 
            action = "no action"
            respData = [] 
            resp = sendResponse(request, 3005, respData,action) 
            return JsonResponse(resp)
        
        if action == "login":
            result = dt_login(request)
            return JsonResponse(result)
        elif action == "register":
            result = dt_register(request)
            return JsonResponse(result)
        elif action == "token":
            result = dt_token(request)
            return JsonResponse(result)
        elif action == "forgot":
            result = dt_forgot(request)
            return JsonResponse(result)
        elif action == "resetpassword":
            result = dt_resetpassword(request)
            return JsonResponse(result)
        elif action == "changepassword":
            result = dt_changepassword(request)
            return JsonResponse(result)
        else:
            action = "no action"
            respData = []
            resp = sendResponse(request, 3001, respData, action)
            return JsonResponse(resp)
    
    # Method ni GET esehiig shalgaj baina. register service, forgot password service deer mail yavuulna. Ene uyd link deer darahad GET method-r url duudagdana.
    elif request.method == "GET":
        # url: http://localhost:8000/user?token=erjhfbuegrshjwiefnqier
        # Method: GET
        # Body: NONE
        
        # request body: NONE
        
        # response:
        # {
        #     "resultCode": 3011,
        #     "resultMessage": "Forgot password verified",
        #     "data": [
        #         {
        #             "userid": 33,
        #             "username": "ganzoo@mandakh.edu.mn",
        #             "tokentype": "forgot",
        #             "createddate": "2024-10-16T11:21:57.455+08:00"
        #         }
        #     ],
        #     "size": 1,
        #     "action": "forgot user verify",
        #     "curdate": "2025/4/06 08:06:25"
        # }
        
        token = request.GET.get('token') # token parameteriin utgiig avch baina.
        
        if (token is None):
            action = "no action" 
            respData = []  # response-n data-g beldej baina. list turultei baih
            resp = sendResponse(request, 3015, respData, action)
            return JsonResponse(resp)
        try: 
            conn = connectDB() 
            cursor = conn.cursor() 
            # gadnaas orj irsen token-r mur songoj toolj baina. Tuhain token ni idevhtei baigaag mun shalgaj baina.
            query = F"""
                    SELECT COUNT(*) AS tokencount
                        , MIN(tokenid) AS tokenid
                        , MAX(userid) AS userid
                        , MIN(token) token
                        , MAX(tokentype) tokentype
                    FROM t_token 
                    WHERE token = '{token}' 
                            AND tokenenddate > NOW()"""
            
            cursor.execute(query) 
            
            columns = cursor.description #
            respRow = [{columns[index][0]:column for index, 
                column in enumerate(value)} for value in cursor.fetchall()] 
            
            userid = respRow[0]["userid"]
            tokentype = respRow[0]["tokentype"]
            tokenid = respRow[0]["tokenid"]
            
            if respRow[0]["tokencount"] == 1: # Hervee hargalzah token oldson baival ajillana.
                #tokentype ni 3 turultei. (register, forgot, login) 
                # End register, forgot hoyriig shagaj uzehed hangalttai. Uchir ni login type ni GET method-r hezee ch orj irehgui.
                if tokentype == "register": # Hervee tokentype ni register bol ajillana.
                    query = f"""SELECT username, lname, fname, createddate 
                            FROM users
                            WHERE userid = {userid}""" # Tuhain neg hunii medeelliig avch baina.
                    cursor.execute(query) 
                    
                    columns = cursor.description #
                    respRow = [{columns[index][0]:column for index, 
                        column in enumerate(value)} for value in cursor.fetchall()]
                    username = respRow[0]['username']
                    lname = respRow[0]['lname']
                    fname = respRow[0]['fname']
                    createddate = respRow[0]['createddate']
                    
                    # Umnu username-r verified bolson hereglegch baival tuhain username-r dahin verified bolgoj bolohgui. Iimees umnu verified hereglegch oldoh yosgui. 
                    query  = f"""SELECT COUNT(*) AS verifiedusercount 
                                , MIN(username) AS username
                            FROM users 
                            WHERE username = '{username}' AND isverified = True"""
                    cursor.execute(query) 
                    columns = cursor.description #
                    respRow = [{columns[index][0]:column for index, 
                        column in enumerate(value)} for value in cursor.fetchall()]
                    
                    if respRow[0]['verifiedusercount'] == 0:
                        
                        # verified user oldoogui tul hereglegchiin verified bolgono.
                        query = f"UPDATE users SET isverified = true WHERE userid = {userid}"
                        cursor.execute(query) 
                        conn.commit() # saving database
                        
                        token = generateStr(30) # huuchin token-oo uurchluh token uusgej baina
                        # huuchin token-g idevhgui bolgoj baina.
                        query = f"""UPDATE t_token SET token = '{token}', 
                                    tokenenddate = '1970-01-01' WHERE tokenid = {tokenid}"""
                        cursor.execute(query) 
                        conn.commit() # saving database
                        
                        # token verified service-n response
                        action = "userverified"
                        respData = [{"userid":userid,"username":username, "lname":lname,
                                    "fname":fname,"tokentype":tokentype
                                    , "createddate":createddate}]
                        resp = sendResponse(request, 3010, respData, action) 
                    else: # user verified already. User verify his or her mail verifying again. send Response. No change in Database.
                        action = "user verified already"
                        respData = [{"username":username,"tokentype":tokentype}]
                        resp = sendResponse(request, 3014, respData, action) 
                elif tokentype == "forgot": # Hervee tokentype ni forgot password bol ajillana.
                    
                    query = f"""SELECT username, lname, fname, createddate FROM users
                            WHERE userid = {userid} AND isverified = True""" # Tuhain neg hunii medeelliig avch baina.
                    cursor.execute(query) 
                    columns = cursor.description #
                    respRow = [{columns[index][0]:column for index, 
                        column in enumerate(value)} for value in cursor.fetchall()]
                    
                    username = respRow[0]['username']
                    lname = respRow[0]['lname']
                    fname = respRow[0]['fname']
                    createddate = respRow[0]['createddate']
                    
                    # forgot password check token response
                    action = "forgot user verify"
                    respData = [{"userid":userid,"username":username,  "tokentype":tokentype
                                , "createddate":createddate}]
                    resp = sendResponse(request, 3011, respData, action) 
                else:
                    # token-ii turul ni forgot, register ali ali ni bish bol buruu duudagdsan gej uzne.
                    # login-ii token GET-r duudagdahgui. 
                    action = "no action"
                    respData = []
                    resp = sendResponse(request, 3017, respData, action) 
                
            else: # Hervee hargalzah token oldoogui bol ajillana.
                # token buruu esvel hugatsaa duussan . Send Response
                action = "notoken" 
                respData = []
                resp = sendResponse(request, 3009, respData, action) 
                
        except:
            # GET method dotood aldaa
            action = "no action" 
            respData = []  # response-n data-g beldej baina. list turultei baih
            resp = sendResponse(request, 5004, respData, action)
            
        finally:
            cursor.close()
            disconnectDB(conn)
            return JsonResponse(resp)
    
    # Method ni POST, GET ali ali ni bish bol ajillana
    else:
        #GET, POST-s busad uyd ajillana
        action = "no action"
        respData = []
        resp = sendResponse(request, 3002, respData, action)
        return JsonResponse(resp)
