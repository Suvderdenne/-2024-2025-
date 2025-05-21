from rest_framework import viewsets, permissions, status,generics
from rest_framework.response import Response
from rest_framework.decorators import action, permission_classes, api_view
from rest_framework.views import APIView
from django.contrib.auth import authenticate
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_exempt
from rest_framework.authtoken.models import Token
from django.contrib.auth import get_user_model
from .models import *
from .serializers import *
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

User = get_user_model()

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def validate_token(request):
    """
    Validate the authentication token.
    """
    try:
        # If we got here, token is valid because IsAuthenticated passed
        return Response({
            'valid': True,
            'user': {
                'id': request.user.id,
                'email': request.user.email,
                'username': request.user.username
            }
        })
    except Exception as e:
        return Response({'valid': False, 'error': str(e)}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    """
    Delete the user's auth token to log them out.
    """
    try:
        # Delete the user's token
        request.user.auth_token.delete()
        return Response({'success': True})
    except Exception as e:
        return Response({'success': False, 'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user(request):
    """
    Get the current user's details.
    """
    return Response({
        'id': request.user.id,
        'username': request.user.username,
        'email': request.user.email
    })

@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        email = request.data.get('email', '').strip()
        password = request.data.get('password', '')
        
        if not email or not password:
            return Response(
                {'success': False, 'error': 'Please provide both email and password'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Try with email parameter
        user = authenticate(request, username=email, password=password)

        # If first attempt fails, try with email lookup
        if not user:
            try:
                user_obj = User.objects.get(email=email)
                user = authenticate(request, username=user_obj.username, password=password)
            except User.DoesNotExist:
                return Response(
                    {'success': False, 'error': 'Invalid credentials'},
                    status=status.HTTP_401_UNAUTHORIZED
                )

        if not user:
            return Response(
                {'success': False, 'error': 'Invalid credentials'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        # Delete any existing tokens for this user
        Token.objects.filter(user=user).delete()
        
        # Create a new token
        token = Token.objects.create(user=user)

        return Response({
            'success': True,
            'token': token.key,
            'user': {
                'id': user.id,
                'email': user.email,
                'username': user.username,
            }
        })

@method_decorator(csrf_exempt, name='dispatch')
class RegisterView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        email = request.data.get('email')
        username = request.data.get('username')
        password = request.data.get('password')

        if not all([email, username, password]):
            return Response(
                {'success': False, 'error': 'Please provide email, username, and password'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if User.objects.filter(email=email).exists():
            return Response(
                {'success': False, 'error': 'Email already exists'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if User.objects.filter(username=username).exists():
            return Response(
                {'success': False, 'error': 'Username already exists'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.create_user(username=username, email=email, password=password)
        token = Token.objects.create(user=user)

        return Response({
            'success': True,
            'token': token.key,
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)

class UserProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_permissions(self):
        if self.action in ['create', 'retrieve']:
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated()]

    @action(detail=False, methods=['get', 'put'])
    def me(self, request):
        user = request.user
        if request.method == 'GET':
            serializer = self.get_serializer(user)
            return Response(serializer.data)
        elif request.method == 'PUT':
            serializer = self.get_serializer(user, data=request.data, partial=True)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)

class FurnitureCategoryViewSet(viewsets.ModelViewSet):
    queryset = FurnitureCategory.objects.all()
    serializer_class = FurnitureCategorySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

class FurnitureViewSet(viewsets.ModelViewSet):
    queryset = Furniture.objects.all()
    serializer_class = FurnitureSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    def get_serializer_context(self):
        return {'request': self.request}
    
    @action(detail=True, methods=['post'])
    def toggle_like(self, request, pk=None):
        furniture = self.get_object()
        user = request.user
        
        if user in furniture.liked_by.all():
            furniture.liked_by.remove(user)
            liked = False
        else:
            furniture.liked_by.add(user)
            liked = True
        
        return Response({'liked': liked})

    @action(detail=False, methods=['get'])
    def liked(self, request):
        """Get all furniture liked by the current user"""
        liked_furniture = Furniture.objects.filter(liked_by=request.user)
        serializer = self.get_serializer(liked_furniture, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def reviews(self, request, pk=None):
        """Get all reviews for a specific furniture item"""
        furniture = self.get_object()
        reviews = Review.objects.filter(furniture=furniture).order_by('-created_at')
        serializer = ReviewSerializer(reviews, many=True)
        return Response(serializer.data)

class ReviewViewSet(viewsets.ModelViewSet):
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    def get_queryset(self):
        return Review.objects.filter(furniture_id=self.kwargs.get('furniture_pk'))
    
    def perform_create(self, serializer):
        furniture = get_object_or_404(Furniture, pk=self.kwargs.get('furniture_pk'))
        # Check if user already reviewed this furniture
        if Review.objects.filter(user=self.request.user, furniture=furniture).exists():
            raise serializers.ValidationError('Та аль хэдийн үнэлгээ өгсөн байна')
            
        serializer.save(
            user=self.request.user,
            furniture=furniture
        )
        
        # Update furniture rating
        furniture_reviews = Review.objects.filter(furniture=furniture)
        avg_rating = furniture_reviews.aggregate(Avg('rating'))['rating__avg']
        furniture.rating = avg_rating or 0.0
        furniture.save()
        
    def perform_update(self, serializer):
        if serializer.instance.user != self.request.user:
            raise PermissionDenied('Та зөвхөн өөрийн үнэлгээг засах боломжтой')
        serializer.save()
        
    def perform_destroy(self, instance):
        if instance.user != self.request.user:
            raise PermissionDenied('Та зөвхөн өөрийн үнэлгээг устгах боломжтой')
        instance.delete()

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    def perform_update(self, serializer):
        old_status = self.get_object().status
        order = serializer.save()
        new_status = order.status
        
        if old_status != new_status:
            status_messages = {
                'PROCESSING': 'Таны захиалгыг боловсруулж эхэллээ.',
                'SHIPPED': 'Таны захиалга хүргэлтэнд гарлаа.',
                'DELIVERED': 'Таны захиалга амжилттай хүргэгдлээ.',
                'CANCELLED': 'Таны захиалга цуцлагдлаа.',
            }
            
            if new_status in status_messages:
                send_order_notification(
                    order,
                    f'Захиалгын төлөв өөрчлөгдлөө: {new_status}',
                    status_messages[new_status]
                )

def send_order_notification(order, title, message):
    """Helper function to send order notifications"""
    Notification.objects.create(
        user=order.user,
        title=title,
        message=message,
        type='ORDER'
    )

class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'status': 'success'})
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get the number of unread notifications"""
        count = Notification.get_unread_count(request.user)
        return Response({'count': count})
    
    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        """Mark all notifications as read"""
        Notification.mark_all_as_read(request.user)
        return Response({'status': 'success'})
    
    @action(detail=False, methods=['get'])
    def recent(self, request):
        """Get recent notifications with unread first"""
        notifications = self.get_queryset().order_by('-is_read', '-created_at')[:10]
        serializer = self.get_serializer(notifications, many=True)
        return Response(serializer.data)

@api_view(['POST'])
@permission_classes([])
def password_reset_request(request):
    """
    Handle password reset requests.
    """
    email = request.data.get('email')
    if not email:
        return Response(
            {'error': 'Email is required'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = User.objects.get(email=email)
        
        # In a real application, send an email with reset instructions
        # For now, we'll just simulate success
        return Response({
            'success': True,
            'message': 'Password reset instructions sent'
        })
    except User.DoesNotExist:
        # Don't reveal whether a user exists
        return Response({
            'success': True,
            'message': 'If an account exists with this email, instructions have been sent'
        })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """
    Change user password endpoint.
    """
    user = request.user
    current_password = request.data.get('current_password', '').strip()
    new_password = request.data.get('new_password', '').strip()

    if not current_password or not new_password:
        return Response(
            {'error': 'Both current and new password are required.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Check if the provided current password matches the stored one
    if not user.check_password(current_password):
        return Response(
            {'error': 'Current password is incorrect.'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    # Set the new password
    user.set_password(new_password)
    user.save()

    return Response(
        {'message': 'Password changed successfully.'},
        status=status.HTTP_200_OK
    )

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """
    Update user profile endpoint.
    """
    user = request.user
    serializer = UserSerializer(user, data=request.data, partial=True)

    if serializer.is_valid():
        # If email is being changed, check if it's already taken
        new_email = request.data.get('email')
        if new_email and new_email != user.email:
            if User.objects.filter(email=new_email).exists():
                return Response(
                    {'error': 'Email already exists'},
                    status=status.HTTP_400_BAD_REQUEST
                )

        # If username is being changed, check if it's already taken
        new_username = request.data.get('username')
        if new_username and new_username != user.username:
            if User.objects.filter(username=new_username).exists():
                return Response(
                    {'error': 'Username already exists'},
                    status=status.HTTP_400_BAD_REQUEST
                )

        serializer.save()
        return Response(serializer.data)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



class LikedFurnitureList(generics.ListAPIView):
    serializer_class = FurnitureSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        liked_furniture_ids = Like.objects.filter(user=self.request.user).values_list('furniture_id', flat=True)
        return Furniture.objects.filter(id__in=liked_furniture_ids)

class ToggleLike(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, furniture_id):
        furniture = get_object_or_404(Furniture, id=furniture_id)
        like, created = Like.objects.get_or_create(user=request.user, furniture=furniture)
        if not created:
            like.delete()
            return Response({'status': 'unliked'}, status=status.HTTP_200_OK)
        return Response({'status': 'liked'}, status=status.HTTP_200_OK)

class CartViewSet(viewsets.ModelViewSet):
    serializer_class = CartSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Cart.objects.filter(user=self.request.user)

    def get_object(self):
        cart, _ = Cart.objects.get_or_create(user=self.request.user)
        return cart

    @action(detail=False, methods=['post'])
    def add_item(self, request):
        cart = self.get_object()
        furniture_id = request.data.get('furniture_id')
        quantity = int(request.data.get('quantity', 1))

        try:
            # Try to find the furniture item
            furniture = Furniture.objects.get(id=furniture_id)
            cart_item, created = CartItem.objects.get_or_create(
                cart=cart,
                furniture=furniture,
                defaults={'quantity': quantity}
            )

            # If the item already exists in the cart, just update the quantity
            if not created:
                cart_item.quantity += quantity
                cart_item.save()

            return Response({
                'message': f'{furniture.title} сагсанд нэмэгдлээ',
                'cart_item': CartItemSerializer(cart_item).data
            }, status=status.HTTP_201_CREATED)

        except Furniture.DoesNotExist:
            return Response(
                {'error': 'Тавилга олдсонгүй'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['post'])
    def remove_item(self, request):
        cart = self.get_object()
        item_id = request.data.get('item_id')

        try:
            # Try to find and delete the cart item
            item = cart.items.get(id=item_id)
            item.delete()
            return Response({'message': 'Бараа сагснаас хасагдлаа'})
        except CartItem.DoesNotExist:
            return Response(
                {'error': 'Бараа сагсанд байхгүй байна'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['post'])
    def update_quantity(self, request):
        cart = self.get_object()
        item_id = request.data.get('item_id')
        quantity = int(request.data.get('quantity', 1))

        # Ensure quantity is valid
        if quantity < 1:
            return Response(
                {'error': 'Тоо ширхэг 1-ээс бага байж болохгүй'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Try to find the cart item and update the quantity
            item = cart.items.get(id=item_id)
            item.quantity = quantity
            item.save()
            return Response(CartItemSerializer(item).data)
        except CartItem.DoesNotExist:
            return Response(
                {'error': 'Бараа сагсанд байхгүй байна'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['post'])
    def clear(self, request):
        cart = self.get_object()
        
        # Clear all items in the cart
        cart.items.all().delete()

        return Response({'message': 'Сагс цэвэрлэгдлээ'})