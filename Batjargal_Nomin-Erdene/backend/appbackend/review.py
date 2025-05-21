
# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt
# import json
# from datetime import datetime

# # Түр хадгалах жагсаалт
# book_reviews_data = []

# @csrf_exempt
# def reviewService(request):
#     if request.method != 'POST':
#         return JsonResponse({'message': 'POST хүсэлт илгээнэ үү'}, status=405)

#     data = json.loads(request.body.decode('utf-8'))
#     action = data.get('action')

#     if action == 'rate':
#         user_id = data.get('user_id')
#         book_id = data.get('book_id')
#         rating = data.get('rating')
#         comment = data.get('comment', '')

#         if not user_id or not book_id or not rating:
#             return JsonResponse({'message': 'Мэдээлэл дутуу байна'}, status=400)

#         book_reviews_data.append({
#             'user_id': user_id,
#             'book_id': book_id,
#             'rating': rating,
#             'comment': comment,
#             'created_at': datetime.now().strftime("%Y-%m-%d %H:%M"),
#             'username': f"user_{user_id}"
#         })

#         return JsonResponse({'message': 'Үнэлгээ хадгалагдлаа'}, status=200)

#     elif action == 'comment':
#         user_id = data.get('user_id')
#         book_id = data.get('book_id')
#         comment = data.get('comment', '')

#         if not user_id or not book_id or not comment.strip():
#             return JsonResponse({'message': 'Сэтгэгдэл хоосон байна'}, status=400)

#         book_reviews_data.append({
#             'user_id': user_id,
#             'book_id': book_id,
#             'rating': 0,
#             'comment': comment,
#             'created_at': datetime.now().strftime("%Y-%m-%d %H:%M"),
#             'username': f"user_{user_id}"
#         })

#         return JsonResponse({'message': 'Сэтгэгдэл хадгалагдлаа'}, status=200)

#     elif action == 'get':
#         user_id = data.get('user_id')
#         book_id = data.get('book_id')

#         user_rating = 0
#         reviews = []

#         for review in book_reviews_data:
#             if review['book_id'] == book_id:
#                 reviews.append(review)
#                 if review['user_id'] == user_id and review['rating'] > 0:
#                     user_rating = review['rating']

#         return JsonResponse({
#             'user_rating': user_rating,
#             'reviews': reviews
#         }, status=200)

#     return JsonResponse({'message': 'Танигдаагүй үйлдэл'}, status=400)



from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from datetime import datetime

# Түр хадгалах жагсаалт
book_reviews_data = []

@csrf_exempt
def reviewService(request):
    if request.method != 'POST':
        return JsonResponse({'message': 'POST хүсэлт илгээнэ үү'}, status=405)

    data = json.loads(request.body.decode('utf-8'))
    action = data.get('action')

    if action == 'rate':
        user_id = data.get('user_id')
        book_id = data.get('book_id')
        rating = data.get('rating')
        comment = data.get('comment', '')

        if not user_id or not book_id or not rating:
            return JsonResponse({'message': 'Мэдээлэл дутуу байна'}, status=400)

        book_reviews_data.append({
            'user_id': user_id,
            'book_id': book_id,
            'rating': rating,
            'comment': comment,
            'created_at': datetime.now().strftime("%Y-%m-%d %H:%M"),
            'username': f"user_{user_id}"
        })

        return JsonResponse({'message': 'Үнэлгээ хадгалагдлаа'}, status=200)

    elif action == 'comment':
        user_id = data.get('user_id')
        book_id = data.get('book_id')
        comment = data.get('comment', '')

        if not user_id or not book_id or not comment.strip():
            return JsonResponse({'message': 'Сэтгэгдэл хоосон байна'}, status=400)

        book_reviews_data.append({
            'user_id': user_id,
            'book_id': book_id,
            'rating': 0,
            'comment': comment,
            'created_at': datetime.now().strftime("%Y-%m-%d %H:%M"),
            'username': f"user_{user_id}"
        })

        return JsonResponse({'message': 'Сэтгэгдэл хадгалагдлаа'}, status=200)

    elif action == 'get':
        user_id = data.get('user_id')
        book_id = data.get('book_id')

        user_rating = 0
        reviews = []
        total_rating = 0
        rating_count = 0

        for review in book_reviews_data:
            if review['book_id'] == book_id:
                reviews.append(review)
                if review['rating'] > 0:
                    total_rating += review['rating']
                    rating_count += 1
                if review['user_id'] == user_id and review['rating'] > 0:
                    user_rating = review['rating']

        avg_rating = round(total_rating / rating_count, 1) if rating_count > 0 else 0

        return JsonResponse({
            'user_rating': user_rating,
            'reviews': reviews,
            'avg_rating': avg_rating,
            'rating_count': rating_count
        }, status=200)

    return JsonResponse({'message': 'Танигдаагүй үйлдэл'}, status=400)
