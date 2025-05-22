import json
from django.db.models import Q
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import User
from .models import Restaurant, Comment, RestaurantImage
from .serializers import RestaurantSerializer, CommentSerializer, RestaurantImageSerializer
from django.contrib.auth import authenticate
import logging
from rest_framework.decorators import api_view
from django.shortcuts import get_object_or_404

@api_view(['GET'])
def check_token(request):
    token = request.META.get('HTTP_AUTHORIZATION')  # Токеныг хүлээн авах
    if not token:
        return Response({'error': 'Token not provided'}, status=400)

    try:
        # Token-аар хэрэглэгчийг шалгах
        token = token.split(' ')[1]  # Token split хийж авч байна
        user = Token.objects.get(key=token).user
        return Response({'user': user.username}, status=200)
    except Token.DoesNotExist:
        return Response({'error': 'Invalid token'}, status=401)


# Рестораны API
class RestaurantListCreateView(generics.ListCreateAPIView):
    """
    Рестораны жагсаалт болон шинэ ресторан нэмэх API
    """
    queryset = Restaurant.objects.all().prefetch_related('additional_images')
    serializer_class = RestaurantSerializer
    permission_classes = [AllowAny]  # 🔹 Бүх хэрэглэгчдэд нээлттэй

    def get_queryset(self):
        queryset = super().get_queryset()
        search_term = self.request.query_params.get('search', None)
        print(f"Received search term: {search_term}")  # Debug logging
        if search_term:
            # Enhanced search with better Mongolian address handling
            search_term = search_term.strip()
            print(f"Processing search for: {search_term}")  # Debug logging
            
            # Debug: Print all restaurants for testing
            all_restaurants = Restaurant.objects.all()
            print(f"Total restaurants in DB: {all_restaurants.count()}")
            for r in all_restaurants[:3]:  # Print first 3 for sample
                print(f"Sample restaurant: {r.name} (ID: {r.id})")
            
            # First try exact match on name and addresses
            exact_query = (
                Q(name__iexact=search_term) |
                Q(address1__iexact=search_term) |
                Q(address2__iexact=search_term)
            )
            
            # Then try partial matches on all relevant fields
            partial_query = (
                Q(name__icontains=search_term) |
                Q(address1__icontains=search_term) |
                Q(address2__icontains=search_term) |
                Q(description__icontains=search_term)
            )
            
            # Enhanced Mongolian text search
            words = search_term.split()
            word_query = Q()
            
            # Search each word in all relevant fields
            for word in words:
                if len(word) > 1:  # Search words longer than 1 character
                    word_query |= (
                        Q(name__icontains=word) |
                        Q(address1__icontains=word) |
                        Q(address2__icontains=word) |
                        Q(description__icontains=word) |
                        Q(popular_dishes__icontains=word)
                    )
            
            # Combine all queries with OR and add phonetic search for Mongolian
            final_query = exact_query | partial_query | word_query
            
            # Use basic ORM queries for SQLite compatibility
            queryset = queryset.filter(final_query).distinct()
        return queryset


class RestaurantDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Рестораны дэлгэрэнгүй мэдээлэл, засварлах, устгах API
    """
    queryset = Restaurant.objects.all().prefetch_related('additional_images')
    serializer_class = RestaurantSerializer
    permission_classes = [AllowAny]  # 🔹 Бүх хэрэглэгчдэд нээлттэй


class RestaurantImageView(generics.ListCreateAPIView):
    """
    Рестораны нэмэлт зургуудын API
    """
    serializer_class = RestaurantImageSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        restaurant_id = self.kwargs.get('restaurant_id')
        return RestaurantImage.objects.filter(restaurant_id=restaurant_id)

    def perform_create(self, serializer):
        restaurant_id = self.kwargs.get('restaurant_id')
        restaurant = get_object_or_404(Restaurant, id=restaurant_id)
        serializer.save(restaurant=restaurant)


class CommentListCreateView(generics.ListCreateAPIView):
    serializer_class = CommentSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        restaurant_id = self.kwargs.get('restaurant_id')
        return Comment.objects.filter(restaurant_id=restaurant_id)

    def perform_create(self, serializer):
        restaurant_id = self.kwargs.get('restaurant_id')
        restaurant = get_object_or_404(Restaurant, id=restaurant_id)
        serializer.save(user=self.request.user, restaurant=restaurant)
    
class AddCommentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, restaurant_id):
        try:
            # Verify content type
            if request.content_type != 'application/json':
                return Response(
                    {'error': 'Content-Type must be application/json'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Verify authentication with detailed logging
            logging.info("=== AUTHENTICATION DETAILS ===")
            logging.info(f"Auth header: {request.headers.get('Authorization')}")
            logging.info(f"Request auth: {request.auth}")
            
            if not request.auth:
                logging.error("No authentication token provided")
                return Response(
                    {'error': 'Authentication required'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
                
            # Verify user authentication in detail
            user = request.user
            if not user or not user.is_authenticated:
                logging.error(f"User not authenticated properly. Request user: {user}")
                logging.error(f"Auth header: {request.headers.get('Authorization')}")
                logging.error(f"Request auth: {request.auth}")
                return Response(
                    {'error': 'User authentication failed'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            
            try:
                # Verify token matches user
                token = Token.objects.get(user=user)
                if request.auth != token:
                    logging.error(f"Token mismatch. Request token: {request.auth}, User token: {token}")
                    return Response(
                        {'error': 'Token does not match user'},
                        status=status.HTTP_401_UNAUTHORIZED
                    )
                
                logging.info(f"Authenticated user: {user.username} (ID: {user.id})")
            except Token.DoesNotExist:
                logging.error(f"No token found for user {user.username}")
                return Response(
                    {'error': 'No valid token for user'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            except Exception as e:
                logging.error(f"Token validation failed: {str(e)}")
                return Response(
                    {'error': 'Invalid authentication token'},
                    status=status.HTTP_401_UNAUTHORIZED
                )

            # Get raw request data
            try:
                body_data = json.loads(request.body.decode('utf-8'))
            except json.JSONDecodeError:
                return Response(
                    {'error': 'Invalid JSON data'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Log complete request details
            logging.info("=== REQUEST DETAILS ===")
            logging.info(f"Headers: {dict(request.headers)}")
            logging.info(f"Raw body: {request.body.decode('utf-8')}")
            logging.info(f"Parsed data: {body_data}")

            # Validate required fields
            rating = body_data.get('rating')
            text = body_data.get('text', '').strip()
            
            if not rating:
                return Response(
                    {'error': 'Rating is required'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            try:
                rating = int(rating)
                if not 1 <= rating <= 5:
                    raise ValueError
            except ValueError:
                return Response(
                    {'error': 'Rating must be integer between 1 and 5'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            if len(text) < 5:
                return Response(
                    {'error': 'Comment must be at least 5 characters'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            restaurant = get_object_or_404(Restaurant, id=restaurant_id)
            
            # Create comment with user instance instead of just ID
            try:
                comment = Comment.objects.create(
                    user=request.user,
                    restaurant=restaurant,
                    rating=rating,
                    text=text
                )
                serializer = CommentSerializer(comment)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            except Exception as e:
                logging.error(f"Error creating comment: {str(e)}")
                return Response(
                    {'error': 'Failed to create comment'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        except Exception as e:
            return Response(
                {'error': f'Error adding comment: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    


# Хэрэглэгч бүртгэх API
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def options(self, request, *args, **kwargs):
        return Response(status=200)

    def get(self, request, *args, **kwargs):
        return Response({"detail": "Please use the signup form"}, status=status.HTTP_405_METHOD_NOT_ALLOWED)

    def post(self, request):
        username = request.data.get("username")
        email = request.data.get("email")
        password = request.data.get("password")

        # Бүх талбарыг бөглөсөн эсэхийг шалгах
        if not username or not email or not password:
            return Response({"error": "Бүх талбарыг бөглөнө үү!"}, status=status.HTTP_400_BAD_REQUEST)

        # Хэрэглэгчийн нэр давхардсан эсэхийг шалгах
        if User.objects.filter(username=username).exists():
            return Response({"error": "Хэрэглэгчийн нэр аль хэдийн бүртгэгдсэн байна!"}, status=status.HTTP_400_BAD_REQUEST)

        # Имэйл давхардсан эсэхийг шалгах
        if User.objects.filter(email=email).exists():
            return Response({"error": "Имэйл аль хэдийн бүртгэгдсэн байна!"}, status=status.HTTP_400_BAD_REQUEST)

        # Хэрэглэгч үүсгэх
        user = User.objects.create_user(username=username, email=email, password=password)
        token, created = Token.objects.get_or_create(user=user)

        return Response({
            "message": "Бүртгэл амжилттай үүслээ!",
            "user": {"id": user.id, "username": user.username, "email": user.email},
            "token": token.key
        }, status=status.HTTP_201_CREATED)


# Хэрэглэгч нэвтрэх API
logger = logging.getLogger(__name__)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        password = request.data.get('password')

        logger.info(f"Login attempt: email={email}")

        if not email or not password:
            return Response({'detail': 'Email болон нууц үг шаардлагатай!'}, status=400)

        user = authenticate(request, username=email, password=password)  # Одоо энэ ажиллана

        if user is not None:
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user_id': user.id,
                'email': user.email
            })
        else:
            return Response({'detail': 'Хэрэглэгчийн мэдээлэл буруу байна!'}, status=401)




class UserReviewsView(generics.ListAPIView):
    """
    API to get all reviews by the current authenticated user
    """
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Comment.objects.filter(user=self.request.user).select_related('restaurant').order_by('-created_at')

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return Response({
            'status': 'success',
            'data': serializer.data
        }, status=status.HTTP_200_OK)

# Хэрэглэгчийн статистик API
class UserStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        stats = {
            "id": user.id,
            "name": user.username,
            "email": user.email,
            "stats": {
                "ratings": 10,
                "visits": 5,
                "favorites": 3,
            },
        }
        return Response(stats)
