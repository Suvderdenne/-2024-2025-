from django.contrib.auth import authenticate, login
from rest_framework import status, generics
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import *
from .serializers import *
#         model = Subject
from django.contrib.auth.hashers import make_password
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import AllowAny
from rest_framework.decorators import permission_classes
from rest_framework.views import APIView
from rest_framework.exceptions import NotFound
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from io import BytesIO
from PIL import Image
import base64
import os
from rest_framework.parsers import MultiPartParser, FormParser
from django.conf import settings
from rest_framework.decorators import parser_classes 
from django.http import JsonResponse
from rest_framework import serializers
from django.core.files.base import ContentFile
import uuid
# Бүх хичээлийн жагсаалт
class LessonListByGroupView(generics.ListAPIView):
    serializer_class = LessonSerializer

    def get_queryset(self):
        lesson_group_id = self.kwargs['lesson_group_id']
        return Lesson.objects.filter(lesson_group__id=lesson_group_id)

# Нэг хичээлийн дэлгэрэнгүй мэдээлэл
class LessonDetailView(generics.RetrieveAPIView):
    queryset = Lesson.objects.all()
    serializer_class = LessonSerializer
# Register User
@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        username = request.data.get('username')
        email = request.data.get('email')
        phone = request.data.get('phone')
        password = request.data.get('password')

        if not phone or not password or not username:
            return Response({"error": "Phone, password and username are required."}, status=status.HTTP_400_BAD_REQUEST)

        # Check if phone already exists
        if User.objects.filter(phone=phone).exists():
            return Response({"error": "Phone number already exists."}, status=status.HTTP_400_BAD_REQUEST)

        # Create the user
        user = User.objects.create_user(phone=phone, password=password, username=username, email=email)
        return Response({"message": "User created successfully!"}, status=status.HTTP_201_CREATED)

# Login User
@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    phone = request.data.get('phone')
    password = request.data.get('password')

    if not phone or not password:
        return Response({'error': 'Phone and password are required.'}, status=400)

    try:
        user = User.objects.get(phone=phone)
    except User.DoesNotExist:
        return Response({'error': 'Invalid credentials.'}, status=400)

    if not user.check_password(password):
        return Response({'error': 'Invalid credentials.'}, status=400)

    refresh = RefreshToken.for_user(user)
    return Response({
        'refresh': str(refresh),
        'access': str(refresh.access_token),
        'user': {
            'id': user.id,
            'phone': user.phone,
            'username': user.username,
            'email': user.email,
        }
    })

# Хэрэглэгчийн профайлыг авах
@api_view(['GET'])
def get_user_profile(request, user_id):
    try:
        # Retrieve user by ID
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({"error": "User not found."}, status=404)

    # Return the user's profile data
    return Response({
        'id': user.id,
        'phone': user.phone,
        'username': user.username,
        'email': user.email,
    })

@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser])
def upload_profile_picture(request, user_id):
    try:
        image = request.FILES['image']
        filename = f"user_{user_id}_profile.jpg"
        path = os.path.join('profile_pictures', filename)
        full_path = os.path.join(settings.MEDIA_ROOT, path)

        # Хуучин зураг байвал устгана
        if os.path.exists(full_path):
            os.remove(full_path)

        with open(full_path, 'wb+') as f:
            for chunk in image.chunks():
                f.write(chunk)

        return Response({"url": settings.MEDIA_URL + path})
    except Exception as e:
        return Response({"error": str(e)}, status=400)
# Хэрэглэгчийн профайлыг шинэчлэх
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_user_profile(request, user_id):
    try:
        if request.user.id != user_id and not request.user.is_staff:
            return Response({"error": "Та зөвхөн өөрийн профайлыг шинэчилж болно."}, status=403)

        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({"error": "Хэрэглэгч олдсонгүй."}, status=404)

    user_profile, created = UserProfile.objects.get_or_create(user=user)

    # 🔥 Handle profile_picture_base64 manually
    profile_picture_base64 = request.data.get('profile_picture_base64')
    if profile_picture_base64:
        try:
            if "base64," in profile_picture_base64:
                format, imgstr = profile_picture_base64.split(';base64,')  # data:image/jpeg;base64,...
                ext = format.split('/')[-1]
            else:
                imgstr = profile_picture_base64
                ext = "png"  # fallback

            file_name = f"{uuid.uuid4()}.{ext}"
            data = ContentFile(base64.b64decode(imgstr), name=file_name)
            user_profile.profile_picture.save(file_name, data, save=False)
        except Exception as e:
            return Response({"error": f"Зургийг боловсруулахад алдаа гарлаа: {str(e)}"}, status=400)

    serializer = UserProfileSerializer(user_profile, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response({"message": "Профайл амжилттай шинэчлэгдлээ."})
    return Response(serializer.errors, status=400)

class SchoolList(APIView):
    def get(self, request):
        schools = School.objects.all()
        serializer = SchoolSerializer(schools, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class SubjectListView(APIView):
    def get(self, request):
        subjects = Subject.objects.all()
        serializer = SubjectSerializer(subjects, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class SubjectListBySchoolView(APIView):
    def get(self, request, school_id):
        subjects = Subject.objects.filter(school_id=school_id)  # school_id-тай холбогдсон subjects-ийг авна
        if not subjects:
            return Response({"detail": "No subjects found for this school."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = SubjectSerializer(subjects, many=True)  # олон өгөгдлийг сериализ хийнэ
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class AnimalListBySubjectView(APIView):
    def get(self, request, subject_id):
        animals = Animal.objects.filter(subject_id=subject_id)
        if not animals.exists():
            return Response({"detail": "No animals found for this subject."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = AnimalSerializer(animals, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class AnimalTypeListAPIView(APIView):
    def get(self, request):
        animal_types = AnimalType.objects.all()
        serializer = AnimalTypeSerializer(animal_types, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class AnimalTypeWithAnimalsAPIView(APIView):
    def get(self, request):
        animal_types = AnimalType.objects.all()
        serializer = AnimalTypeSerializer(animal_types, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class LessonGroupList(APIView):
    def get(self, request, format=None):
        lesson_groups = LessonGroup.objects.all()
        serializer = LessonGroupSerializer(lesson_groups, many=True)
        return Response(serializer.data)
    
    
class LessonGroupBySubjectDetail(generics.ListAPIView):
    serializer_class = LessonGroupSerializer

    def get_queryset(self):
        # URL-аас 'id' буюу subject-ийн id-г авч байна
        subject_id = self.kwargs.get('id')
        try:
            # Subject id-ээр LessonGroup-г хайж байна
            return LessonGroup.objects.filter(subject__id=subject_id)
        except LessonGroup.DoesNotExist:
            raise NotFound(f"Lesson groups for subject with id {subject_id} not found.")
        
        
# ========== ACTIVITY =========
# List all Activities
def get_activities(request):
    lesson_group_id = request.GET.get('lesson_group_id', None)

    # If `lesson_group_id` is provided, filter by it, otherwise fetch all
    if lesson_group_id:
        activities = Activity.objects.filter(lesson_group_id=lesson_group_id)
    else:
        activities = Activity.objects.all()

    # Return activities as JSON response
    data = list(activities.values())
    return JsonResponse(data, safe=False)
# Retrieve one Activity
class ActivityDetailView(generics.RetrieveAPIView):
    queryset = Activity.objects.all()
    serializer_class = ActivitySerializer


# Бүх асуултууд type-аар шүүж авах
class QuestionListByTypeAPIView(APIView):
    def get(self, request):
        question_type = request.query_params.get('type')
        if question_type:
            allowed_types = [choice[0] for choice in Question.TYPE_CHOICES]
            if question_type not in allowed_types:
                return Response({'detail': 'Invalid question type.'}, status=status.HTTP_400_BAD_REQUEST)
            
            questions = Question.objects.filter(type=question_type)
        else:
            questions = Question.objects.all()
        
        serializer = QuestionSerializer(questions, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

# Нэг асуултыг дэлгэрэнгүй авах
class QuestionDetailAPIView(APIView):
    def get(self, request, activity_id):
        try:
            # Get all questions for this activity and order them by id
            questions = Question.objects.filter(activity_id=activity_id).order_by('id')
            if not questions.exists():
                return Response({'error': 'Асуулт олдсонгүй.'}, status=status.HTTP_404_NOT_FOUND)
            
            # Return all questions in order
            serializer = QuestionSerializer(questions, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# === ШИНЭ ===
# Тухайн асуултын бүх хариултуудыг авах
class AnswerListByQuestionAPIView(APIView):
    def get(self, request, question_id):
        try:
            question = Question.objects.get(pk=question_id)
            answers = question.answers.all()  # related_name='answers'
            
            # Convert answers to list of dictionaries with image data
            answer_data = []
            for answer in answers:
                answer_dict = {
                    'id': answer.id,
                    'answer_text': answer.answer_text,
                    'image_base64': answer.image_base64 if answer.image_base64 else None,
                }
                answer_data.append(answer_dict)
                
            return Response(answer_data, status=status.HTTP_200_OK)
        except Question.DoesNotExist:
            return Response({'error': 'Асуулт олдсонгүй.'}, status=status.HTTP_404_NOT_FOUND)

# Нэг хариултыг дэлгэрэнгүй авах (хэрэггүй байж болно гэхдээ хийлээ)
class AnswerDetailAPIView(APIView):
    def get(self, request, pk):
        try:
            answer = Answer.objects.get(pk=pk)
            serializer = AnswerSerializer(answer)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Answer.DoesNotExist:
            return Response({'error': 'Хариулт олдсонгүй.'}, status=status.HTTP_404_NOT_FOUND)
# ========== USER PROGRESS ==========
class UserProgressListCreateAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        progress = UserProgress.objects.all()
        serializer = UserProgressSerializer(progress, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = UserProgressSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)