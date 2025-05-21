from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from backend.settings import sendResponse, disconnectDB, connectDB

def dt_search_books(request):
    jsons = json.loads(request.body)
    action = jsons.get("action", "")
    search_query = jsons.get("query", "")
    search_type = jsons.get("type", "")
    search_turul = jsons.get("turul", "")  # << энэ мөрийг зассан

    myConn = connectDB()
    try:
        cursor = myConn.cursor()

        query_conditions = []
        query_params = []

        if search_query:
            query_conditions.append("title ILIKE %s")
            query_params.append(f"%{search_query}%")

        if search_type and search_turul:
            query_conditions.append("type = %s")
            query_params.append(search_type)

            query_conditions.append("turul = %s")
            query_params.append(search_turul)

        elif search_type:
            query_conditions.append("type = %s")
            query_params.append(search_type)

        elif search_turul:
            query_conditions.append("turul = %s")
            query_params.append(search_turul)

        where_clause = " AND ".join(query_conditions) if query_conditions else "TRUE"

        query = f"""
            SELECT id, type, name, date, img_url, alt_img_urls, audio_url, score, height, duration, title, turul, review
            FROM public.books
            WHERE {where_clause};
        """

        cursor.execute(query, tuple(query_params))
        columns = cursor.description
        respRow = [{columns[index][0]: column for index, column in enumerate(value)} for value in cursor.fetchall()]
        cursor.close()
        resp = sendResponse(request, 200, respRow, action)

    except Exception as e:
        print("Search error:", e)
        resp = sendResponse(request, 5000, [], action)
    finally:
        disconnectDB(myConn)
        return JsonResponse(resp)


@csrf_exempt
def searchBookService(request):
    if request.method == "POST":
        try:
            jsons = json.loads(request.body)
        except:
            return JsonResponse(sendResponse(request, 3003, []))

        action = jsons.get("action", "no action")
        if action == "searchbook":
            return dt_search_books(request)
        else:
            return JsonResponse(sendResponse(request, 3001, [], action))
    else:
        return JsonResponse(sendResponse(request, 3002, []))


@csrf_exempt
def get_options(request):
    if request.method == "GET":
        myConn = connectDB()
        try:
            cursor = myConn.cursor()

            type_filter = request.GET.get("type", "")

            # Төрлүүд
            cursor.execute("SELECT DISTINCT type FROM public.books WHERE type IS NOT NULL;")
            types = [row[0] for row in cursor.fetchall()]

            # Жанрын жагсаалт (type-ээр шүүж болно)
            if type_filter:
                cursor.execute("SELECT DISTINCT turul FROM public.books WHERE turul IS NOT NULL AND type = %s;", [type_filter])
            else:
                cursor.execute("SELECT DISTINCT turul FROM public.books WHERE turul IS NOT NULL;")
            genres = [row[0] for row in cursor.fetchall()]

            return JsonResponse({
                "status": "success",
                "types": types,
                "genres": genres,
            }, status=200)
        except Exception as e:
            return JsonResponse({
                "status": "error",
                "message": str(e),
                "types": [],
                "genres": [],
            }, status=500)
        finally:
            disconnectDB(myConn)
    else:
        return JsonResponse({"status": "error", "message": "GET only"}, status=405)
