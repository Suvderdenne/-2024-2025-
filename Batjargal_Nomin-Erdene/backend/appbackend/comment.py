from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from django.db import connection
import json
from datetime import datetime

@csrf_exempt
def commentService(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        action = data.get('action')

        if action == 'add':
            user_id = data.get('user_id')
            rating_id = data.get('rating_id')  # энэ заавал байх албагүй бол null болгож болно
            legend_id = data.get('legend_id')
            content = data.get('content', '').strip()

            if not user_id or not legend_id or not content:
                return JsonResponse({'message': 'Мэдээлэл дутуу байна'}, status=400)

            created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO comments (user_id, rating_id, legend_id, content, created_at)
                    VALUES (%s, %s, %s, %s, %s)
                """, [user_id, rating_id, legend_id, content, created_at])

            return JsonResponse({'message': 'Сэтгэгдэл амжилттай нэмэгдлээ'}, status=200)

        elif action == 'get':
            legend_id = data.get('legend_id')
            if not legend_id:
                return JsonResponse({'message': 'legend_id дутуу байна'}, status=400)

            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT c.comment_id, c.user_id, c.legend_id, c.content, c.created_at, u.username
                    FROM comments c
                    JOIN auth_user u ON c.user_id = u.id
                    WHERE c.legend_id = %s
                    ORDER BY c.created_at DESC
                """, [legend_id])
                rows = cursor.fetchall()
                comments = [{
                    'comment_id': r[0],
                    'user_id': r[1],
                    'legend_id': r[2],
                    'content': r[3],
                    'created_at': r[4].strftime("%Y-%m-%d %H:%M"),
                    'username': r[5]
                } for r in rows]

            return JsonResponse({'comments': comments}, status=200)

        return JsonResponse({'message': 'Action буруу байна'}, status=400)

    return JsonResponse({'message': 'POST л зөвшөөрнө'}, status=405)
