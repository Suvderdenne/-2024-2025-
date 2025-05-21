from django.shortcuts import render
from rest_framework import status, viewsets, permissions
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth import authenticate
from rest_framework.authtoken.models import Token
from django.shortcuts import get_object_or_404
from .models import *
from .serializers import *
from django.db.models import Q
from django.utils import timezone
from rest_framework import serializers

# Create your views here.

@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = authenticate(
            username=serializer.validated_data['username'],
            password=serializer.validated_data['password']
        )
        if user:
            # Ensure user has a profile
            if not hasattr(user, 'profile'):
                UserProfile.objects.create(user=user)
            
            token, _ = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user': UserSerializer(user).data
            })
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_user(request):
    request.user.auth_token.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)

# Clothes Views
class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]  # Anyone can view categories

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAuthenticated()]
        return [AllowAny()]

class ClothesViewSet(viewsets.ModelViewSet):
    queryset = Clothes.objects.filter(is_sold=False)
    serializer_class = ClothesSerializer
    permission_classes = [AllowAny]  # Anyone can view clothes

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy', 'my_listings']:
            return [IsAuthenticated()]
        return [AllowAny()]
    
    def get_queryset(self):
        queryset = Clothes.objects.filter(is_sold=False)
        
        # Get search parameters
        search_query = self.request.query_params.get('search', None)
        category_id = self.request.query_params.get('category', None)
        gender = self.request.query_params.get('gender', None)
        
        # Filter by category
        if category_id is not None:
            queryset = queryset.filter(category_id=category_id)
        
        # Filter by gender
        if gender is not None:
            queryset = queryset.filter(gender=gender)
        
        # Search by name or partial name
        if search_query is not None:
            queryset = queryset.filter(
                Q(title__icontains=search_query) |  # Search in title
                Q(description__icontains=search_query)  # Search in description
            )
        
        if self.request.user.is_authenticated:
            if self.action == 'my_listings':
                return queryset.filter(seller=self.request.user)
        return queryset

    @action(detail=False, methods=['get'])
    def my_listings(self, request):
        clothes = self.get_queryset().filter(seller=request.user)
        serializer = self.get_serializer(clothes, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def buy(self, request, pk=None):
        clothes = self.get_object()
        
        # Check if item is already sold
        if clothes.is_sold:
            return Response(
                {'error': 'This item has already been sold'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if user is trying to buy their own item
        if clothes.seller == request.user:
            return Response(
                {'error': 'You cannot buy your own item'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Mark the item as sold
        clothes.is_sold = True
        clothes.save()
        
        # Return the updated item data
        serializer = self.get_serializer(clothes)
        return Response(serializer.data)

# Cart Views
class CartViewSet(viewsets.ModelViewSet):
    serializer_class = CartSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        print(f"Request headers: {self.request.headers}")  # Debug print
        if self.request.user.is_authenticated:
            return Cart.objects.filter(user=self.request.user)
        session_id = self.request.headers.get('X-Session-ID')
        print(f"Session ID from header: {session_id}")  # Debug print
        if session_id:
            return Cart.objects.filter(session_id=session_id)
        return Cart.objects.none()

    def list(self, request, *args, **kwargs):
        print(f"List request headers: {request.headers}")  # Debug print
        queryset = self.get_queryset()
        if not queryset.exists():
            # Create a new cart for guest users if none exists
            if not request.user.is_authenticated:
                session_id = request.headers.get('X-Session-ID')
                if not session_id:
                    session_id = request.session.session_key
                    if not session_id:
                        request.session.create()
                        session_id = request.session.session_key
                cart = Cart.objects.create(session_id=session_id)
                serializer = self.get_serializer(cart)
                response = Response(serializer.data['items'])
                response['X-Session-ID'] = session_id
                return response
            return Response([])
        
        cart = queryset.first()
        serializer = self.get_serializer(cart)
        response = Response(serializer.data['items'])
        
        # Add session ID to response headers for guest carts
        if not request.user.is_authenticated and cart.session_id:
            response['X-Session-ID'] = cart.session_id
            
        return response

    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            session_id = self.request.headers.get('X-Session-ID')
            if not session_id:
                session_id = self.request.session.session_key
                if not session_id:
                    self.request.session.create()
                    session_id = self.request.session.session_key
            serializer.save(session_id=session_id)

    @action(detail=False, methods=['post'])
    def add(self, request):
        print(f"Add to cart request headers: {request.headers}")  # Debug print
        clothes_id = request.data.get('clothes_id')
        if not clothes_id:
            return Response({'error': 'clothes_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            clothes = Clothes.objects.get(id=clothes_id, is_sold=False)
        except Clothes.DoesNotExist:
            return Response({'error': 'Clothes not found'}, status=status.HTTP_404_NOT_FOUND)

        # Get or create cart
        if request.user.is_authenticated:
            cart, _ = Cart.objects.get_or_create(user=request.user)
        else:
            # For guest users, create a new session if needed
            if not request.session.session_key:
                request.session.create()
            
            # Try to get existing cart by session ID
            session_id = request.headers.get('X-Session-ID')
            print(f"Session ID for guest cart: {session_id}")  # Debug print
            
            if session_id:
                try:
                    cart = Cart.objects.get(session_id=session_id)
                    print(f"Found existing cart with session ID: {session_id}")  # Debug print
                except Cart.DoesNotExist:
                    cart = None
                    print(f"No cart found for session ID: {session_id}")  # Debug print
            
            # If no cart found, create a new one
            if not session_id or not cart:
                session_id = request.session.session_key
                cart = Cart.objects.create(session_id=session_id)
                print(f"Created new cart with session ID: {session_id}")  # Debug print

        # Add or update cart item
        cart_item, created = CartItem.objects.get_or_create(
            cart=cart,
            clothes=clothes,
            defaults={'quantity': 1}
        )

        if not created:
            cart_item.quantity += 1
            cart_item.save()

        serializer = self.get_serializer(cart)
        response = Response(serializer.data, status=status.HTTP_201_CREATED)
        
        # Always include session ID in response for guest carts
        if not request.user.is_authenticated:
            response['X-Session-ID'] = cart.session_id
            print(f"Returning session ID in response: {cart.session_id}")  # Debug print
            
        return response

    @action(detail=True, methods=['delete'])
    def remove(self, request, pk=None):
        try:
            cart_item = CartItem.objects.get(id=pk)
            cart = cart_item.cart

            # Check if user has permission to modify this cart
            if request.user.is_authenticated and cart.user != request.user:
                return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
            if not request.user.is_authenticated and cart.session_id != request.session.session_key:
                return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)

            cart_item.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except CartItem.DoesNotExist:
            return Response({'error': 'Cart item not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['put'])
    def update_quantity(self, request, pk=None):
        try:
            cart_item = CartItem.objects.get(id=pk)
            cart = cart_item.cart

            # Check if user has permission to modify this cart
            if request.user.is_authenticated and cart.user != request.user:
                return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
            if not request.user.is_authenticated and cart.session_id != request.session.session_key:
                return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)

            quantity = request.data.get('quantity')
            if not quantity or not isinstance(quantity, int) or quantity < 1:
                return Response({'error': 'Valid quantity is required'}, status=status.HTTP_400_BAD_REQUEST)

            cart_item.quantity = quantity
            cart_item.save()

            serializer = self.get_serializer(cart)
            return Response(serializer.data)
        except CartItem.DoesNotExist:
            return Response({'error': 'Cart item not found'}, status=status.HTTP_404_NOT_FOUND)

class MessageViewSet(viewsets.ModelViewSet):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Users can see messages they sent or received
        return Message.objects.filter(
            Q(sender=self.request.user) | Q(recipient=self.request.user)
        )
    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        message = self.get_object()
        if message.recipient != request.user:
            return Response({'error': 'Not your message'}, status=status.HTTP_403_FORBIDDEN)
        message.is_read = True
        message.save()
        return Response({'status': 'marked as read'})

class SellerRatingViewSet(viewsets.ModelViewSet):
    serializer_class = SellerRatingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Sellers can see ratings they received
        # Buyers can see ratings they gave
        return SellerRating.objects.filter(
            Q(seller=self.request.user) | Q(buyer=self.request.user))
    
    def perform_create(self, serializer):
        order_id = self.request.data.get('order')
        try:
            # Get the order and verify the user is the buyer
            order = Order.objects.get(id=order_id, user=self.request.user)
            
            # Get the seller from the order's items
            seller = order.cart.items.first().clothes.seller
            
            # Check if user has already rated this seller for this order
            if SellerRating.objects.filter(order=order, buyer=self.request.user).exists():
                raise serializers.ValidationError({'order': 'You have already rated this seller for this order'})
            
            # Check if the order is completed (delivered)
            if order.status != 'delivered':
                raise serializers.ValidationError({'order': 'You can only rate sellers after the order is delivered'})
            
            serializer.save(buyer=self.request.user, seller=seller, order=order)
        except Order.DoesNotExist:
            raise serializers.ValidationError({'order': 'Invalid order ID or you are not the buyer of this order'})

# Order Views

class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        if self.request.user.is_authenticated:
            return Order.objects.filter(user=self.request.user)
        return Order.objects.filter(cart__session_id=self.request.session.session_key)

    def perform_create(self, serializer):
        cart = serializer.validated_data['cart']
        total_amount = sum(item.clothes.price * item.quantity for item in cart.items.all())
        
        # Get shipping details from request data
        shipping_name = self.request.data.get('shipping_name')
        shipping_phone = self.request.data.get('shipping_phone')
        shipping_address = self.request.data.get('shipping_address')
        
        if not all([shipping_name, shipping_phone, shipping_address]):
            raise serializers.ValidationError('Shipping details are required')
        
        if self.request.user.is_authenticated:
            serializer.save(
                user=self.request.user,
                total_amount=total_amount,
                shipping_name=shipping_name,
                shipping_phone=shipping_phone,
                shipping_address=shipping_address,
            )
        else:
            serializer.save(
                total_amount=total_amount,
                shipping_name=shipping_name,
                shipping_phone=shipping_phone,
                shipping_address=shipping_address,
            )
        
        # Mark clothes as sold
        for item in cart.items.all():
            item.clothes.is_sold = True
            item.clothes.save()

    @action(detail=True, methods=['post'])
    def update_status(self, request, pk=None):
        order = self.get_object()
        new_status = request.data.get('status')
        
        if not new_status or new_status not in dict(Order.STATUS_CHOICES):
            return Response(
                {'error': 'Invalid status'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update status and related timestamps
        order.status = new_status
        if new_status == 'shipped':
            order.shipped_at = timezone.now()
        elif new_status == 'delivered':
            order.delivered_at = timezone.now()
        order.save()
        
        serializer = self.get_serializer(order)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def update_payment_status(self, request, pk=None):
        order = self.get_object()
        new_status = request.data.get('payment_status')
        
        if not new_status or new_status not in dict(Order.PAYMENT_STATUS_CHOICES):
            return Response(
                {'error': 'Invalid payment status'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        order.payment_status = new_status
        if new_status == 'paid':
            order.paid_at = timezone.now()
        order.save()
        
        serializer = self.get_serializer(order)
        return Response(serializer.data)
    @action(detail=True, methods=['get'])
    def seller_info(self, request, pk=None):
        """Get seller contact info (for buyers)"""
        order = self.get_object()
        if order.user != request.user:
            return Response({'error': 'Not your order'}, status=403)
        
        # Get seller from first item (assuming single seller per order)
        seller = order.cart.items.first().clothes.seller
        return Response({
            'name': f"{seller.first_name} {seller.last_name}",
            'email': seller.email,
            'phone': order.cart.items.first().clothes.phone_number
        })
    
    @action(detail=True, methods=['get'])
    def buyer_info(self, request, pk=None):
        """Get buyer info (for sellers)"""
        order = self.get_object()
        # Check if current user is seller of any item in order
        if not order.cart.items.filter(clothes__seller=request.user).exists():
            return Response({'error': 'Not your sale'}, status=403)
        
        return Response({
            'name': order.shipping_name,
            'phone': order.shipping_phone,
            'address': order.shipping_address
        })

class UserProfileViewSet(viewsets.ModelViewSet):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        return Response(serializer.data)

    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)
    
    @action(detail=True, methods=['get'])
    def profile(self, request, pk=None):
        user = self.get_object()
        serializer = self.get_serializer(user)
        data = serializer.data
        
        # Check if profile is complete
        is_complete = all([
            user.first_name,
            user.last_name,
            user.email,
            user.profile.profile_image
        ])
        
        data['is_profile_complete'] = is_complete
        if not is_complete:
            data['missing_fields'] = []
            if not user.first_name:
                data['missing_fields'].append('first_name')
            if not user.last_name:
                data['missing_fields'].append('last_name')
            if not user.email:
                data['missing_fields'].append('email')
            if not user.profile.profile_image:
                data['missing_fields'].append('profile_image')
        
        return Response(data)
    
    @action(detail=True, methods=['get'])
    def selling_items(self, request, pk=None):
        user = self.get_object()
        items = Clothes.objects.filter(seller=user, is_sold=False)
        serializer = ClothesSerializer(items, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def sold_items(self, request, pk=None):
        user = self.get_object()
        items = Clothes.objects.filter(seller=user, is_sold=True)
        serializer = ClothesSerializer(items, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def bought_items(self, request, pk=None):
        user = self.get_object()
        # Get all orders made by the user
        orders = Order.objects.filter(user=user)
        # Get all clothes items from these orders
        bought_items = Clothes.objects.filter(
            cartitem__cart__order__in=orders,
            is_sold=True
        ).distinct()
        serializer = ClothesSerializer(bought_items, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def ratings(self, request, pk=None):
        user = self.get_object()
        ratings = SellerRating.objects.filter(seller=user)
        serializer = SellerRatingSerializer(ratings, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def average_rating(self, request, pk=None):
        user = self.get_object()
        ratings = SellerRating.objects.filter(seller=user)
        if not ratings.exists():
            return Response({'average_rating': 0, 'total_ratings': 0})
        
        avg_rating = ratings.aggregate(models.Avg('rating'))['rating__avg']
        return Response({
            'average_rating': round(avg_rating, 2),
            'total_ratings': ratings.count()
        })
    
    @action(detail=True, methods=['post'])
    def update_profile(self, request, pk=None):
        user = self.get_object()
        
        # Only allow users to update their own profile
        if request.user != user:
            return Response(
                {'error': 'You can only update your own profile'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Check if required fields are provided
        required_fields = ['first_name', 'last_name', 'email']
        missing_fields = [field for field in required_fields if field not in request.data]
        
        if missing_fields:
            return Response({
                'error': 'Missing required fields',
                'missing_fields': missing_fields
            }, status=status.HTTP_400_BAD_REQUEST)
        
        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            
            # Get updated profile data with completion status
            updated_data = serializer.data
            is_complete = all([
                user.first_name,
                user.last_name,
                user.email,
                user.profile.profile_image
            ])
            updated_data['is_profile_complete'] = is_complete
            
            return Response(updated_data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    