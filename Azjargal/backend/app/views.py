from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import transaction
from django.db.models import Q
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework.authtoken.models import Token
import json

from .models import CarPart, Order, OrderItem, UserProfile
from .serializers import *

# ---------------------------
# 🟢 Authentication Views
# ---------------------------

@csrf_exempt
def register_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            email = data.get('email')
            password = data.get('password')

            if not username or not email or not password:
                return JsonResponse({'error': 'All fields are required'}, status=400)

            if User.objects.filter(username=username).exists():
                return JsonResponse({'error': 'Username already exists'}, status=400)

            user = User.objects.create_user(username=username, email=email, password=password)
            serializer = UserSerializer(user)
            return JsonResponse({'message': 'User registered successfully', 'user': serializer.data}, status=201)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON data'}, status=400)

    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')

            if not username or not password:
                return JsonResponse({'error': 'Username and password are required'}, status=400)

            user = authenticate(request, username=username, password=password)

            if user is not None:
                login(request, user)
                token, _ = Token.objects.get_or_create(user=user)
                return JsonResponse({
                    'message': 'Login successful',
                    'token': token.key,
                    'user': {
                        'id': user.id,
                        'username': user.username,
                        'email': user.email
                    }
                }, status=200)

            return JsonResponse({'error': 'Invalid credentials'}, status=401)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON format'}, status=400)

    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    request.user.auth_token.delete()
    logout(request)
    return JsonResponse({'message': 'Logout successful'}, status=200)

# ---------------------------
# 🟢 Product Views
# ---------------------------

@csrf_exempt
def carPart_list(request):
    if request.method == "GET":
        category_id = request.GET.get('category_id')
        car_parts = CarPart.objects.select_related('brand', 'Төрөл').all()
        if category_id:
            car_parts = car_parts.filter(Төрөл__id=category_id)

        data = [
            {
                "id": part.id,
                "Нэр": part.Нэр,
                "Төрөл": part.Төрөл.name,
                "Үнэ": str(part.Үнэ),
                "Тайлбар": part.Тайлбар,
                "Зураг": request.build_absolute_uri(part.Зураг.url) if part.Зураг else None,
                "Орсон_цаг": part.Орсон_цаг.strftime('%Y-%m-%d %H:%M:%S'),
                "brand": part.brand.name if part.brand else None
            }
            for part in car_parts
        ]
        return JsonResponse({"car_parts": data}, safe=False)

    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
def engine_parts_list(request):
    if request.method == "GET":
        ENGINE_CATEGORY_ID = 2
        car_parts = CarPart.objects.select_related('brand', 'Төрөл') \
                                   .filter(Төрөл__id=ENGINE_CATEGORY_ID)

        data = [
            {
                "id": part.id,
                "Нэр": part.Нэр,
                "Төрөл": part.Төрөл.name,
                "Үнэ": str(part.Үнэ),
                "Тайлбар": part.Тайлбар,
                "Зураг": request.build_absolute_uri(part.Зураг.url) if part.Зураг else None,
                "Орсон_цаг": part.Орсон_цаг.strftime('%Y-%m-%d %H:%M:%S'),
                "brand": part.brand.name if part.brand else None
            }
            for part in car_parts
        ]
        return JsonResponse({"engine_parts": data}, safe=False)

    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
def car_part_detail(request, part_id):
    if request.method == "GET":
        try:
            part = CarPart.objects.select_related('brand', 'Төрөл').get(id=part_id)
            data = {
                "id": part.id,
                "Нэр": part.Нэр,
                "Төрөл": part.Төрөл.name,
                "Үнэ": str(part.Үнэ),
                "Тайлбар": part.Тайлбар,
                "Зураг": request.build_absolute_uri(part.Зураг.url) if part.Зураг else None,
                "Орсон_цаг": part.Орсон_цаг.strftime('%Y-%m-%d %H:%M:%S'),
                "brand": part.brand.name if part.brand else None
            }
            return JsonResponse(data)
        except CarPart.DoesNotExist:
            return JsonResponse({'error': 'Car part not found'}, status=404)

    return JsonResponse({'error': 'Invalid request method'}, status=405)

@csrf_exempt
def search_car_parts(request):
    if request.method == "GET":
        query = request.GET.get("q", "").strip()
        if not query:
            return JsonResponse({"error": "Search query cannot be empty."}, status=400)

        car_parts = CarPart.objects.select_related("brand", "Төрөл").filter(
            Q(Нэр__icontains=query) | Q(Төрөл__name__icontains=query)
        )

        data = [
            {
                "id": part.id,
                "Нэр": part.Нэр,
                "Төрөл": part.Төрөл.name,
                "Үнэ": str(part.Үнэ),
                "Тайлбар": part.Тайлбар,
                "Зураг": request.build_absolute_uri(part.Зураг.url) if part.Зураг else None,
                "Орсон_цаг": part.Орсон_цаг.strftime('%Y-%m-%d %H:%M:%S'),
                "brand": part.brand.name if part.brand else None
            }
            for part in car_parts
        ]
        return JsonResponse({"results": data}, safe=False)

    return JsonResponse({'error': 'Invalid request method'}, status=405)

# ---------------------------
# 🟢 Cart Views
# ---------------------------

@csrf_exempt
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def cart_view(request):
    if request.method == 'GET':
        cart_items = OrderItem.objects.filter(
            order__user=request.user,
            order__status='Pending'
        ).select_related('car_part', 'order')

        data = [
            {
                "id": item.id,
                "car_part_id": item.car_part.id,
                "name": item.car_part.Нэр,
                "price": str(item.price),
                "quantity": item.quantity,
                "image": request.build_absolute_uri(item.car_part.Зураг.url) if item.car_part.Зураг else None,
                "total": str(item.price * item.quantity)
            }
            for item in cart_items
        ]
        return JsonResponse({"cart_items": data}, safe=False)

    elif request.method == 'POST':
        try:
            data = json.loads(request.body)
            car_part_id = data.get('car_part_id')
            quantity = int(data.get('quantity', 1))

            if not car_part_id:
                return JsonResponse({'error': 'car_part_id is required'}, status=400)

            car_part = CarPart.objects.get(id=car_part_id)

            order, _ = Order.objects.get_or_create(
                user=request.user,
                status='Pending',
                defaults={'total_price': 0}
            )

            order_item, created = OrderItem.objects.get_or_create(
                order=order,
                car_part=car_part,
                defaults={'quantity': quantity, 'price': car_part.Үнэ}
            )

            if not created:
                order_item.quantity += quantity
                order_item.save()

            order.total_price = sum(item.price * item.quantity for item in order.items.all())
            order.save()

            return JsonResponse({'message': 'Item added to cart successfully'}, status=201)

        except CarPart.DoesNotExist:
            return JsonResponse({'error': 'Car part not found'}, status=404)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)

@csrf_exempt
@api_view(['PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def cart_item_view(request, item_id):
    try:
        order_item = OrderItem.objects.get(
            id=item_id,
            order__user=request.user,
            order__status='Pending'
        )
    except OrderItem.DoesNotExist:
        return JsonResponse({'error': 'Cart item not found'}, status=404)

    if request.method == 'PUT':
        try:
            data = json.loads(request.body)
            quantity = int(data.get('quantity'))
            if quantity <= 0:
                return JsonResponse({'error': 'Quantity must be positive'}, status=400)

            order_item.quantity = quantity
            order_item.save()

            order = order_item.order
            order.total_price = sum(item.price * item.quantity for item in order.items.all())
            order.save()

            return JsonResponse({'message': 'Cart item updated successfully'})

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)

    elif request.method == 'DELETE':
        try:
            order = order_item.order
            order_item.delete()
            order.total_price = sum(item.price * item.quantity for item in order.items.all())
            order.save()
            return JsonResponse({'message': 'Item removed from cart successfully'})
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def checkout_view(request):
    try:
        with transaction.atomic():
            order = Order.objects.get(user=request.user, status='Pending')
            if order.items.count() == 0:
                return JsonResponse({'error': 'Cart is empty'}, status=400)

            order.status = 'Shipped'
            order.save()

            return JsonResponse({
                'message': 'Order placed successfully',
                'order_id': order.id,
                'total': str(order.total_price)
            })

    except Order.DoesNotExist:
        return JsonResponse({'error': 'No pending order found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@csrf_exempt
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticatedOrReadOnly])
def comment_list(request, car_part_id):
    try:
        car_part = CarPart.objects.get(id=car_part_id)
    except CarPart.DoesNotExist:
        return JsonResponse({'error': 'Car part not found'}, status=404)

    if request.method == 'GET':
        comments = Comment.objects.filter(car_part=car_part).select_related('user')
        serializer = CommentSerializer(comments, many=True)
        return JsonResponse({'comments': serializer.data}, safe=False)

    elif request.method == 'POST':
        data = json.loads(request.body)
        data['car_part'] = car_part_id
        data['user'] = request.user.id
        
        serializer = CommentSerializer(data=data)
        if serializer.is_valid():
            serializer.save(user=request.user, car_part=car_part)
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)

@csrf_exempt
@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def comment_detail(request, comment_id):
    try:
        comment = Comment.objects.select_related('user').get(id=comment_id)
    except Comment.DoesNotExist:
        return JsonResponse({'error': 'Comment not found'}, status=404)

    # Check if the current user is the owner of the comment
    if comment.user != request.user:
        return JsonResponse(
            {'error': 'You do not have permission to perform this action'}, 
            status=403
        )

    if request.method == 'GET':
        serializer = CommentSerializer(comment)
        return JsonResponse(serializer.data)

    elif request.method == 'PUT':
        data = json.loads(request.body)
        serializer = CommentSerializer(comment, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)

    elif request.method == 'DELETE':
        comment.delete()
        return JsonResponse(
            {'message': 'Comment deleted successfully'}, 
            status=204
        )

# ---------------------------
# 🟢 User Profile Views
# ---------------------------

@csrf_exempt
@api_view(['GET'])
@permission_classes([IsAuthenticatedOrReadOnly])
def profile_detail(request, user_id):
    try:
        user = User.objects.get(id=user_id)
        profile = user.profile
        serializer = UserProfileSerializer(profile)
        return JsonResponse(serializer.data)
    except User.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)
    except UserProfile.DoesNotExist:
        # Create profile if it doesn't exist
        profile = UserProfile.objects.create(
            user=user,
            bio=f"Welcome to {user.username}'s profile!"
        )
        serializer = UserProfileSerializer(profile)
        return JsonResponse(serializer.data)

@csrf_exempt
@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def my_profile(request):
    try:
        profile = request.user.profile
    except UserProfile.DoesNotExist:
        # Create profile if it doesn't exist
        profile = UserProfile.objects.create(
            user=request.user,
            bio=f"Welcome to {request.user.username}'s profile!"
        )
    
    if request.method == 'GET':
        serializer = UserProfileSerializer(profile)
        return JsonResponse(serializer.data)
    
    elif request.method == 'PUT':
        try:
            data = json.loads(request.body)
            
            # Handle profile picture update
            if 'profile_picture' in data:
                # Validate base64 image
                try:
                    # Check if the string is valid base64
                    if not data['profile_picture'].startswith('data:image'):
                        # Add data URL prefix if missing
                        data['profile_picture'] = f"data:image/jpeg;base64,{data['profile_picture']}"
                except Exception as e:
                    return JsonResponse({'error': 'Invalid image format'}, status=400)
            
            serializer = UserProfileSerializer(profile, data=data, partial=True)
            
            if serializer.is_valid():
                serializer.save()
                return JsonResponse(serializer.data)
            return JsonResponse(serializer.errors, status=400)
            
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON data'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)

# ---------------------------
# 🟢 Health Check
# ---------------------------

@csrf_exempt
def health_check(request):
    return JsonResponse({'status': 'ok'}, status=200)

@csrf_exempt
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def clear_cart_view(request):
    try:
        with transaction.atomic():
            # Get the user's pending order (cart)
            order = Order.objects.get(user=request.user, status='Pending')
            
            # Delete all items in the cart
            order.items.all().delete()
            
            # Reset the total price
            order.total_price = 0
            order.save()
            
            return JsonResponse({
                'message': 'Cart cleared successfully',
                'status': 'success'
            }, status=200)
            
    except Order.DoesNotExist:
        return JsonResponse({
            'error': 'No active cart found',
            'status': 'error'
        }, status=404)
    except Exception as e:
        return JsonResponse({
            'error': str(e),
            'status': 'error'
        }, status=400)


