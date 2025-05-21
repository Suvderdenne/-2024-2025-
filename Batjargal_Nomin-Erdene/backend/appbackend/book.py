from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from backend.settings import sendMail, sendResponse, disconnectDB, connectDB, resultMessages, generateStr
import json

# GET all book function
def dt_getallbook(request):
    jsons = json.loads(request.body)
    action = jsons['action']
    myConn = connectDB()
    try:
        cursor = myConn.cursor()
        query = """
            SELECT 
                id, type, name, date, img_url, alt_img_urls, audio_url,
                score, height, duration, title, turul, review
            FROM public.books;
        """
        cursor.execute(query)
        columns = cursor.description
        respRow = [
            {columns[index][0]: column for index, column in enumerate(value)}
            for value in cursor.fetchall()
        ]
        cursor.close()
        resp = sendResponse(request, 200, respRow, action)
    except Exception as e:
        print("Database error:", e)
        resp = sendResponse(request, 5000, [], action)
    finally:
        disconnectDB(myConn)
        return resp

# Entry point for all book-related API calls
@csrf_exempt
def editcheckService(request):
    if request.method == "POST":
        try:
            jsons = json.loads(request.body)
        except:
            action = "no action"
            respdata = []
            resp = sendResponse(request, 3003, respdata)
            return JsonResponse(resp)

        try:
            action = jsons["action"]
        except:
            action = "no action"
            respdata = []
            resp = sendResponse(request, 3005, respdata, action)
            return JsonResponse(resp)

        if action == "getallbook":
            result = dt_getallbook(request)
            return JsonResponse(result)

        # Add other actions here (e.g., addbook, updatebook, etc.)

        else:
            action = "no action"
            respdata = []
            resp = sendResponse(request, 3001, respdata, action)
            return JsonResponse(resp)

    else:
        action = "no action"
        respdata = []
        resp = sendResponse(request, 3002, respdata, action)
        return JsonResponse(resp)
