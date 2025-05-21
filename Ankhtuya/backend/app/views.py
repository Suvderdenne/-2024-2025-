import http
from rest_framework import viewsets, permissions
from .models import PlantInfo, UserPlant, Category
from .serializers import *
from .services import *
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from .serializers import RegisterSerializer
from django.contrib.auth.models import User
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from rest_framework.views import APIView
import json 
from openai import OpenAI
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        return response

class PlantInfoCreateView(generics.CreateAPIView):
    queryset = PlantInfo.objects.all()
    serializer_class = PlantInfoSerializer
    permission_classes = [permissions.AllowAny]

class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]

class PlantInfoViewSet(viewsets.ModelViewSet):
    queryset = PlantInfo.objects.all()
    serializer_class = PlantInfoSerializer
    permission_classes = [permissions.AllowAny]

# class UserPlantViewSet(viewsets.ModelViewSet):
#     queryset = UserPlant.objects.none()  # ← нэмэх
#     serializer_class = UserPlantSerializer
#     permission_classes = [IsAuthenticated]

#     def get_queryset(self):
#         return UserPlant.objects.filter(user=self.request.user)

#     def perform_create(self, serializer):
#         serializer.save(user=self.request.user)



class PlantsByCategoryAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, category_id, format=None):
        """
        Get all plants that belong to the specified category ID.
        """
        # Filter plants by category_id
        plants = PlantInfo.objects.filter(category_id=category_id)

        # Check if any plants were found for the given category
        if not plants:
            return Response(
                {"detail": "No plants found for this category."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Serialize the plants
        serializer = PlantInfoSerializer(plants, many=True)

        # Return the list of plants
        return Response(serializer.data, status=status.HTTP_200_OK)

class UserAddPlantView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        """
        Add a plant to the user's collection.
        """
        serializer = UserAddPlantSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            user_plant = serializer.save()
            return Response({
                'message': 'Plant added successfully!',
                'plant': serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)    
    

class UserPlantsListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        user_plants = UserPlant.objects.filter(user=request.user)
        serializer = UserPlantDetailSerializer(user_plants, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class PlantHealthAssessmentView(APIView):
    def post(self, request):
        """
        Assess plant health from base64 encoded image,
        then ask ChatGPT for plant care advice in Mongolian.
        """
        image_base64 = request.data.get('image')

        if not image_base64:
            return Response(
                {'error': 'Image data is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        result = PlantHealthService.assess_plant_health(image_base64)

        if result['status'] == 'error':
            return Response(result, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Compose question for ChatGPT
        user_prompt = (
            f"Энэ бол миний ургамлын талаарх мэдээлэл: {result}. "
            f"Ургамлыг хэрхэн арчлах талаар надад зөвлөгөө өгөөч."
        )
        print(user_prompt)
        base_url = "https://api.aimlapi.com/v1"

# Insert your AIML API key in the quotation marks instead of <YOUR_AIMLAPI_KEY>:
        api_key = "8e0a803baf0744feb4ab81cbdc96e09f" 
        system_prompt = "You are a assistant agent. Be descriptive and helpful."
        # ChatGPT API Call
   
        try:
            api = OpenAI(api_key=api_key, base_url=base_url)
            completion = api.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.7,
            max_tokens=256,
    )

            response = completion.choices[0].message.content

            print("User:", user_prompt)
            print("AI:", response)
            return Response(response, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'error': f'Failed to get care advice: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )