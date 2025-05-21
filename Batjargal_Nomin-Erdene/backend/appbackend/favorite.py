from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
favorite_books_by_user = {}  # {'user_id': [book1, book2, ...]}

@csrf_exempt
def favoriteService(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        action = data.get('action')
        user_id = str(data.get('user_id'))  # Хэрэглэгч ID-г авах

        if not user_id:
            return JsonResponse({'message': 'Хэрэглэгчийн ID шаардлагатай'}, status=400)

        if action == 'add':
            book = data.get('book')
            if book:
                user_favorites = favorite_books_by_user.setdefault(user_id, [])
                if book not in user_favorites:
                    user_favorites.append(book)
                return JsonResponse({'message': 'Ном хадгалагдлаа', 'data': book}, status=200)
            return JsonResponse({'message': 'Номын мэдээлэл дутуу байна'}, status=400)

        elif action == 'get':
            return JsonResponse({'data': favorite_books_by_user.get(user_id, [])}, status=200)

        elif action == 'remove':
            book_id = data.get('book_id')
            if book_id:
                user_favorites = favorite_books_by_user.get(user_id, [])
                for book in user_favorites:
                    if str(book.get('id')) == str(book_id):
                        user_favorites.remove(book)
                        return JsonResponse({'message': 'Ном устгагдлаа'}, status=200)
                return JsonResponse({'message': 'Ном олдсонгүй'}, status=404)
            return JsonResponse({'message': 'Номын ID дутуу байна'}, status=400)

        return JsonResponse({'message': 'Action олдсонгүй'}, status=400)

    return JsonResponse({'message': 'POST хүсэлт биш байна'}, status=405)
