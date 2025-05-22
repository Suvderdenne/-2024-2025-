from django.shortcuts import render, get_object_or_404
from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import User, RecommendedPlace, Place, Restaurant, Hotel, Parking
from .serializers import PlaceSerializer, UserSerializer, RecommendedPlaceSerializer, PlaceImageSerializer, RestaurantSerializer, HotelSerializer, ParkingSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate, get_user_model
from rest_framework.permissions import AllowAny
from django.contrib.auth.hashers import check_password, make_password
from rest_framework.permissions import AllowAny, IsAuthenticated
from geopy.distance import geodesic
from django.http import JsonResponse
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.decorators import api_view
from rest_framework.permissions import AllowAny


class SignUpView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            # Hash the password before saving
            user = serializer.save()
            # Set the password properly using Django's password hashing
            user.set_password(request.data.get('password'))
            user.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]  # Allow unauthenticated access to login

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        try:
            user = User.objects.get(email=email)
            
            # Use Django's built-in check_password method
            if user.check_password(password):
                refresh = RefreshToken.for_user(user)
                return Response({
                    'access': str(refresh.access_token),
                    'refresh': str(refresh),
                    'user': {
                        'id': user.id,
                        'email': user.email,
                        'name': user.name
                    }
                }, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
        except User.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
        

class RecommendedPlaceListView(generics.ListCreateAPIView):
    queryset = RecommendedPlace.objects.all().prefetch_related('images')
    serializer_class = RecommendedPlaceSerializer
    
    

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        return Response({
            'id': user.id,
            'name': user.name,
            'email': user.email,
        })
        
        
class RefreshTokenView(APIView):
    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({'error': 'Refresh token is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Decode the refresh token and get the user
            refresh = RefreshToken(refresh_token)
            user = get_user_model().objects.get(id=refresh['user_id'])  # Assuming you stored the user_id in the token
            # Refresh and send new access token
            new_access_token = str(refresh.access_token)
            return Response({
                'access': new_access_token
            }, status=status.HTTP_200_OK)
        except get_user_model().DoesNotExist:
            return Response({'error': 'User not found for the provided refresh token'}, status=status.HTTP_401_UNAUTHORIZED)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
        
class NearbyPlacesView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        lat = request.GET.get('lat')
        lon = request.GET.get('lon')
        
        print(f"Latitude: {lat}, Longitude: {lon}")

        if not lat or not lon:
            return Response({"detail": "Latitude and longitude are required."}, 
                          status=status.HTTP_400_BAD_REQUEST)

        try:
            lat = float(lat)
            lon = float(lon)
        except ValueError:
            return Response({"detail": "Invalid latitude or longitude."}, 
                          status=status.HTTP_400_BAD_REQUEST)

        places = RecommendedPlace.objects.all()
        nearby_places = []

        for place in places:
            # Skip places without coordinates
            if place.latitude is None or place.longitude is None:
                continue
                
            try:
                distance = geodesic((lat, lon), (place.latitude, place.longitude)).km
                if distance <= 5:  # 5 km radius
                    place_data = {
                        'id': place.id,
                        'name': place.name,
                        'location': place.location,
                        'description': place.description,  # Added description
                        'phone_number': place.phone_number,  # Added phone number
                        'rating': place.rating,
                        'image': request.build_absolute_uri(place.image.url) if place.image else None,
                        'distance': round(distance, 2),  # Rounded to 2 decimal places
                        'latitude': place.latitude,
                        'longitude': place.longitude,
                        'images': [request.build_absolute_uri(img.image.url) 
                                  for img in place.images.all()]  # Gallery images
                    }
                    nearby_places.append(place_data)
            except Exception as e:
                print(f"Error processing place {place.id}: {str(e)}")
                continue

        # Sort by distance (nearest first)
        nearby_places.sort(key=lambda x: x['distance'])
        
        return Response(nearby_places, status=status.HTTP_200_OK)
    

class PlaceListCreate(generics.ListCreateAPIView):
    queryset = Place.objects.all()
    serializer_class = PlaceSerializer

class RestaurantList(generics.ListAPIView):
    serializer_class = RestaurantSerializer
    
    def get_queryset(self):
        place_id = self.request.query_params.get('place_id')
        if place_id:
            return Restaurant.objects.filter(place_id=place_id)
        return Restaurant.objects.none()
    
    def get_serializer_context(self):
        return {'request': self.request}
    
class HotelList(generics.ListAPIView):
    serializer_class = HotelSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['place_id']

    def get_queryset(self):
        queryset = Hotel.objects.all()
        place_id = self.request.query_params.get('place_id')
        if place_id is not None:
            queryset = queryset.filter(place_id=place_id)
        return queryset
    def get_serializer_context(self):
        return {'request': self.request}
    
class ParkingList(generics.ListAPIView):
    serializer_class = ParkingSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['place']  # Change back to 'place' instead of 'place_id'

    def get_queryset(self):
        queryset = Parking.objects.all()
        place_id = self.request.query_params.get('place')
        if place_id:
            queryset = queryset.filter(place_id=place_id)
        return queryset 

class TopRatedNearbyPlacesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        lat = request.GET.get('lat')
        lon = request.GET.get('lon')

        if not lat or not lon:
            return Response({"detail": "Latitude and longitude are required."}, status=400)

        try:
            lat = float(lat)
            lon = float(lon)
        except ValueError:
            return Response({"detail": "Invalid coordinates."}, status=400)

        results = []
        for place in RecommendedPlace.objects.all():
            if place.latitude is None or place.longitude is None:
                continue
            distance = geodesic((lat, lon), (place.latitude, place.longitude)).km
            if distance <= 5:
                results.append({
                    'id': place.id,
                    'name': place.name,
                    'location': place.location,
                    'description': place.description,
                    'phone_number': place.phone_number,
                    'rating': place.rating,
                    'latitude': place.latitude,
                    'longitude': place.longitude,
                    'image': request.build_absolute_uri(place.image.url) if place.image else None,
                    'distance': round(distance, 2),
                })

        results.sort(key=lambda x: x['rating'], reverse=True)
        return Response(results[:10])

class RecommendedPlaceDetailView(APIView):
    permission_classes = [AllowAny]  # нэвтрэлт шаардахгүй болгоно

    def get(self, request, pk):
        try:
            place = RecommendedPlace.objects.get(pk=pk)
            serializer = RecommendedPlaceSerializer(place, context={"request": request})
            return Response(serializer.data, status=200)
        except RecommendedPlace.DoesNotExist:
            return Response({"detail": "Place not found"}, status=404)
