from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
from .models import User, Driver, Ride
from .serializers import UserSerializer, UserRegistrationSerializer, DriverSerializer, RideSerializer
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework.decorators import api_view, permission_classes
from rest_framework import viewsets, status
from django.contrib.auth.hashers import make_password, check_password

# Create your views here.
@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    try:
        phone_number = request.data.get('phone_number')
        password = request.data.get('password')
        
        if not phone_number or not password:
            return Response({
                'success': False,
                'message': 'Утасны дугаар болон нууц үг шаардлагатай'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(phone_number=phone_number)
            if user.check_password(password):
                serializer = UserSerializer(user)
                return Response({
                    'success': True,
                    'user': serializer.data
                })
            else:
                return Response({
                    'success': False,
                    'message': 'Нууц үг буруу байна'
                }, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Хэрэглэгч олдсонгүй'
            }, status=status.HTTP_404_NOT_FOUND)
            
    except Exception as e:
        return Response({
            'success': False,
            'message': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    try:
        # Check if user already exists
        if User.objects.filter(phone_number=request.data.get('phone_number')).exists():
            return Response({
                'success': False,
                'message': 'Энэ утасны дугаар бүртгэгдсэн байна'
            }, status=status.HTTP_400_BAD_REQUEST)
            
        if User.objects.filter(email=request.data.get('email')).exists():
            return Response({
                'success': False,
                'message': 'Энэ и-мэйл хаяг бүртгэгдсэн байна'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Use serializer to create user
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            user_serializer = UserSerializer(user)
            return Response({
                'success': True,
                'message': 'Бүртгэл амжилттай үүслээ',
                'user': user_serializer.data
            }, status=status.HTTP_201_CREATED)
        else:
            return Response({
                'success': False,
                'message': 'Буруу мэдээлэл',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        return Response({
            'success': False,
            'message': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def get_queryset(self):
        if self.action in ['update', 'partial_update']:
            # For update, only return the current user
            phone_number = self.request.data.get('phone_number')
            if phone_number:
                return User.objects.filter(phone_number=phone_number)
        return super().get_queryset()

    def update(self, request, *args, **kwargs):
        try:
            # Get user by phone number
            phone_number = request.data.get('phone_number')
            if not phone_number:
                return Response({'detail': 'Phone number is required'}, status=status.HTTP_400_BAD_REQUEST)
            
            try:
                user = User.objects.get(phone_number=phone_number)
            except User.DoesNotExist:
                return Response({'detail': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
            
            # Handle file upload
            if 'profile_photo' in request.FILES:
                request.data['profile_photo'] = request.FILES['profile_photo']
            
            serializer = self.get_serializer(user, data=request.data, partial=True)
            if serializer.is_valid():
                updated_user = serializer.save()
                return Response({
                    'id': updated_user.id,
                    'full_name': updated_user.full_name,
                    'phone_number': updated_user.phone_number,
                    'email': updated_user.email,
                    'profile_photo': request.build_absolute_uri(updated_user.profile_photo.url) if updated_user.profile_photo else None,
                    'message': 'User updated successfully'
                })
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({
                'id': user.id,
                'full_name': user.full_name,
                'phone_number': user.phone_number,
                'email': user.email,
                'profile_photo': request.build_absolute_uri(user.profile_photo.url) if user.profile_photo else None,
                'message': 'User created successfully'
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

class DriverViewSet(viewsets.ModelViewSet):
    queryset = Driver.objects.all()
    serializer_class = DriverSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def update(self, request, *args, **kwargs):
        try:
            # Get driver by phone number
            phone_number = request.data.get('phone_number')
            if not phone_number:
                return Response({'detail': 'Phone number is required'}, status=status.HTTP_400_BAD_REQUEST)
            
            try:
                driver = Driver.objects.get(phone_number=phone_number)
            except Driver.DoesNotExist:
                return Response({'detail': 'Driver not found'}, status=status.HTTP_404_NOT_FOUND)
            
            # Handle file upload
            if 'profile_photo' in request.FILES:
                request.data['profile_photo'] = request.FILES['profile_photo']
            
            serializer = self.get_serializer(driver, data=request.data, partial=True)
            if serializer.is_valid():
                updated_driver = serializer.save()
                return Response({
                    'id': updated_driver.id,
                    'first_name': updated_driver.first_name,
                    'last_name': updated_driver.last_name,
                    'phone_number': updated_driver.phone_number,
                    'license_number': updated_driver.license_number,
                    'profile_photo': request.build_absolute_uri(updated_driver.profile_photo.url) if updated_driver.profile_photo else None,
                    'location': updated_driver.location,
                    'message': 'Driver updated successfully'
                })
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class RideViewSet(viewsets.ModelViewSet):
    queryset = Ride.objects.all()
    serializer_class = RideSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            ride = serializer.save()
            return Response({
                'id': ride.id,
                'user': UserSerializer(ride.user).data,
                'driver': DriverSerializer(ride.driver).data,
                'start_time': ride.start_time,
                'pickup_location': ride.pickup_location,
                'dropoff_location': ride.dropoff_location,
                'status': ride.status,
                'message': 'Ride created successfully'
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, *args, **kwargs):
        try:
            ride_id = kwargs.get('pk')
            try:
                ride = Ride.objects.get(id=ride_id)
            except Ride.DoesNotExist:
                return Response({'detail': 'Ride not found'}, status=status.HTTP_404_NOT_FOUND)
            
            serializer = self.get_serializer(ride, data=request.data, partial=True)
            if serializer.is_valid():
                updated_ride = serializer.save()
                return Response({
                    'id': updated_ride.id,
                    'user': UserSerializer(updated_ride.user).data,
                    'driver': DriverSerializer(updated_ride.driver).data,
                    'start_time': updated_ride.start_time,
                    'end_time': updated_ride.end_time,
                    'pickup_location': updated_ride.pickup_location,
                    'dropoff_location': updated_ride.dropoff_location,
                    'status': updated_ride.status,
                    'message': 'Ride updated successfully'
                })
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
