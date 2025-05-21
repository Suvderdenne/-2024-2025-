#readinghistory.py
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from backend.settings import connectDB, disconnectDB, sendResponse
import json

# Үзсэн түүх авах
def dt_getreadinghistory(request):
    jsons = json.loads(request.body)
    action = jsons.get('action', 'no action')
    user_id = jsons.get('user_id')

    myConn = connectDB()
    try:
        cursor = myConn.cursor()
        query = """
            SELECT rh.read_date AS watched_at,
                   b.id AS book_id,
                   b.title,
                   b.name,
                   b.img_url
            FROM readinghistory rh
            JOIN books b ON rh.book_id = b.id
            WHERE rh.user_id = %s
            ORDER BY rh.read_date DESC;
        """
        cursor.execute(query, [user_id])
        columns = cursor.description
        rows = [
            {columns[index][0]: column for index, column in enumerate(value)}
            for value in cursor.fetchall()
        ]
        cursor.close()
        return sendResponse(request, 200, rows, action)
    except Exception as e:
        print("❌ Error fetching reading history:", e)
        return sendResponse(request, 5000, [], action)
    finally:
        disconnectDB(myConn)

# Үзсэн түүх хадгалах
def dt_addreadinghistory(request):
    jsons = json.loads(request.body)
    action = jsons.get("action", "no action")
    user_id = jsons.get("user_id")
    book_id = jsons.get("book_id")

    myConn = connectDB()
    try:
        cursor = myConn.cursor()
        cursor.execute("""
            INSERT INTO readinghistory (user_id, book_id, read_date)
            VALUES (%s, %s, CURRENT_DATE)
        """, [user_id, book_id])
        myConn.commit()
        cursor.close()
        return sendResponse(request, 200, {"message": "Saved"}, action)
    except Exception as e:
        print("❌ Error saving reading history:", e)
        return sendResponse(request, 5000, [], action)
    finally:
        disconnectDB(myConn)

# POST handler
@csrf_exempt
def editcheckService(request):
    if request.method == 'POST':
        try:
            jsons = json.loads(request.body)
            action = jsons.get("action", "no action")
        except:
            return JsonResponse(sendResponse(request, 3003, []))

        if action == "getreadinghistory":
            return JsonResponse(dt_getreadinghistory(request))
        elif action == "addreadinghistory":
            return JsonResponse(dt_addreadinghistory(request))
        else:
            return JsonResponse(sendResponse(request, 3001, [], action))
    else:
        return JsonResponse(sendResponse(request, 3002, []))
