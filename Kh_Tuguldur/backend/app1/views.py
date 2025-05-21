from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from collections import defaultdict
import requests
import re
import json
from django.conf import settings
from django.shortcuts import get_object_or_404
import google.generativeai as genai
from rest_framework import status

from .models import *
from .serializers import (
    EditCommentSerializer,
    UserSerializer,
    RegisterSerializer,
    LoginSerializer,
    QuestionSerializer,
    SubmitResponsesSerializer,
    RecommendationHistorySerializer,
    CareerInsightSerializer,
    JobListingSerializer,
    CourseSerializer,
    UniversitySerializer,
    UniversityDetailsSerializer,
    NewsSerializer,
    NewsDetailsSerializer,
    CareerDetailsSerializer,
    PostSerializer,
    CommentSerializer,
    EditPostSerializer
)

genai.configure(api_key=settings.GOOGLE_GEMINI_API_KEY)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        username = serializer.validated_data["username"]
        password = serializer.validated_data["password"]
        user = authenticate(username=username, password=password)

        if user:
            refresh = RefreshToken.for_user(user)
            return Response({
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            })
        return Response({"error": "Invalid credentials"}, status=400)
    return Response(serializer.errors, status=400)


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            "message": "User created successfully",
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        })
    return Response(serializer.errors, status=400)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_questions(request):
    questions = Question.objects.all()
    data = []

    for question in questions:
        options = Option.objects.filter(question=question).values("id", "text")
        data.append({
            "id": question.id,
            "text": question.text,
            "options": list(options)
        })

    return Response(data)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_courses(request):
    courses = Course.objects.all()
    serializer = CourseSerializer(courses, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def submit_responses(request):
    serializer = SubmitResponsesSerializer(data=request.data)

    if serializer.is_valid():
        user = request.user
        responses = serializer.validated_data["responses"]

        response_text_parts = []
        for resp in responses:
            try:
                question = Question.objects.get(id=resp['question_id'])
                option = Option.objects.get(id=resp['option_id'])
                response_text_parts.append(f"Q: {question.text} | A: {option.text}")
            except (Question.DoesNotExist, Option.DoesNotExist):
                continue

        response_text = "\n".join(response_text_parts)

        model = genai.GenerativeModel("gemini-2.0-flash")
        ai_prompt = f"""
Доорх хариултууд дээр үндэслэн тохиромжтой мэргэжлийг санал болгоно уу. 
Мөн тухайн мэргэжилд шаардлагатай ерөнхий боловсролын 3 хичээл болон 
Монгол Улсын их дээд сургуулиудаас хамгийн тохиромжтой 4 сургуулийг нэрлэнэ үү.

--- Хариултууд ---
{response_text}

--- Хариултын формат ---
Мэргэжил: <Зөвхөн мэргэжлийн нэр>
Тайлбар: <Яагаад энэ мэргэжил тохиромжтойг товч тайлбарла>
Хичээлүүд: <3 хичээлийн нэр, таслалаар тусгаарласан>
Сургуулиуд: <4 сургуулийн нэр, таслалаар тусгаарласан>
"""
        response = model.generate_content(ai_prompt)

        result = {
            "suggested_career": "Unknown Career",
            "explanation": "Тайлбар байхгүй.",
            "high_school_subjects": [],
            "universities": []
        }

        if response.text:
            response_lines = [line.strip() for line in response.text.split("\n") if line.strip()]
            try:
                current_section = None
                career_found = False

                for line in response_lines:
                    line_lower = line.lower()
                    if "тайлбар" in line_lower:
                        result["explanation"] = line.split(":", 1)[-1].strip()
                    elif "хичээл" in line_lower:
                        result["high_school_subjects"] = re.split(r'[,\n;]\s*', line.split(":", 1)[-1].strip())
                    elif "сургууль" in line_lower:
                        result["universities"] = re.split(r'[,\n;]\s*', line.split(":", 1)[-1].strip())
                    elif not career_found:
                        result["suggested_career"] = line.split(":", 1)[-1].strip()
                        career_found = True
            except Exception as e:
                print(f"Parsing error: {str(e)}")

        result["high_school_subjects"] = list(result["high_school_subjects"])[:3]
        result["universities"] = list(result["universities"])

        # Save recommendation
        RecommendationHistory.objects.create(
            user=user,
            suggested_career=result["suggested_career"],
            explanation=result["explanation"],
            high_school_subjects=", ".join(result["high_school_subjects"]),
            recommended_universities=", ".join(result["universities"]),
            responses_json=json.dumps(responses)
        )

        return Response(result)

    return Response(serializer.errors, status=400)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_universities(request):
    query = request.query_params.get('search', '')
    universities = University.objects.all()
    if query:
        universities = universities.filter(name__icontains=query)
    serializer = UniversitySerializer(universities, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_university_details(request, university_id):
    try:
        university = University.objects.get(id=university_id)
        details = university.details
        serializer = UniversityDetailsSerializer(details)
        return Response(serializer.data)
    except University.DoesNotExist:
        return Response({"error": "University not found"}, status=404)
    except AttributeError:
        return Response({"error": "University details not found"}, status=404)


@api_view(['GET'])
def get_career_insights(request, career):
    try:
        insight = CareerInsight.objects.get(career=career)
        serializer = CareerInsightSerializer(insight)
        return Response(serializer.data)
    except CareerInsight.DoesNotExist:
        return Response({"error": "Career insights not found"}, status=404)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_career_details(request, career):
    try:
        details = CareerDetails.objects.get(career__id=career)
        serializer = CareerDetailsSerializer(details)
        return Response(serializer.data)
    except CareerDetails.DoesNotExist:
        return Response({"error": "Career details not found"}, status=404)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_careers(request):
    careers = CareerInsight.objects.all()
    serializer = CareerInsightSerializer(careers, many=True)
    return Response(serializer.data)


@api_view(['GET'])
def get_job_listings(request, career):
    api_url = "https://jsearch.p.rapidapi.com/search"
    headers = {
        "X-RapidAPI-Key": settings.RAPIDAPI_KEY,
        "X-RapidAPI-Host": "jsearch.p.rapidapi.com"
    }
    params = {"query": career, "page": "1"}

    response = requests.get(api_url, headers=headers, params=params)
    if response.status_code == 200:
        job_data = response.json().get("data", [])
        serializer = JobListingSerializer(job_data, many=True)
        return Response(serializer.data)
    return Response({"error": "Unable to fetch jobs"}, status=500)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_recommendation_history(request):
    history = RecommendationHistory.objects.filter(user=request.user).order_by('-recommended_at')
    serializer = RecommendationHistorySerializer(history, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_news(request):
    news = News.objects.all().order_by('-id')
    serializer = NewsSerializer(news, many=True, context={"request": request})
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_news_details(request, news_id):
    try:
        news = get_object_or_404(News, id=news_id)
        details = NewsDetails.objects.get(news=news)
        serializer = NewsDetailsSerializer(details, context={"request": request})
        return Response(serializer.data)
    except NewsDetails.DoesNotExist:
        return Response({"error": "News details not found"}, status=404)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile(request):
    try:
        user = request.user

        # Serialize user info
        user_serializer = UserSerializer(user)

        # Serialize user's recommendation history
        history = RecommendationHistory.objects.filter(user=user).order_by('-recommended_at')
        history_serializer = RecommendationHistorySerializer(history, many=True)

        return Response({
            'user': user_serializer.data,
            'recommendation_history': history_serializer.data
        })

    except Exception as e:
        return Response({"error": str(e)}, status=500)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    try:
        user = request.user
        serializer = UserSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)
    except Exception as e:
        return Response({"error": str(e)}, status=500)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_profile(request):
    try:
        user = request.user
        user.delete()
        return Response({"message": "Profile deleted successfully"}, status=204)
    except Exception as e:
        return Response({"error": str(e)}, status=500)


@api_view(['GET', 'POST', 'DELETE'])
@permission_classes([IsAuthenticated])  # Ensure the user is authenticated
def posts(request, post_id=None):
    if request.method == 'DELETE':
        try:
            post = Post.objects.get(id=post_id, user=request.user)  # Ensure the post exists and belongs to the user
            post.delete()
            return Response({"message": "Post deleted successfully"}, status=204)
        except Post.DoesNotExist:
            return Response({"error": "Post not found or you do not have permission to delete it"}, status=404)

    if request.method == 'GET':
        posts = Post.objects.all().order_by('-created_at')
        serializer = PostSerializer(posts, many=True, context={'request': request})
        return Response(serializer.data)

    elif request.method == 'POST':
        data = request.data.copy()
        if 'image' in request.FILES:  # Check if an image file is included
            data['image'] = request.FILES['image']  # Attach the image file

        serializer = PostSerializer(data=data, context={'request': request})  # Pass request in context
        if serializer.is_valid():
            serializer.save(user=request.user)  # Associate the post with the authenticated user
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def comment_on_post(request, post_id):
    """
    API view to add a new top-level comment to a post.
    Requires authentication.
    """
    try:
        post = Post.objects.get(id=post_id)
    except Post.DoesNotExist:
        return Response({'error': 'Post not found'}, status=status.HTTP_404_NOT_FOUND)

    data = request.data.copy()
    data['post'] = post.id
    # No parent is set for top-level comments
    serializer = CommentSerializer(data=data)
    if serializer.is_valid():
        # Associate the comment with the authenticated user
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_like(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    like, created = Like.objects.get_or_create(user=request.user, post=post)
    if not created:
        like.delete()
        return Response({'message': 'Unliked'}, status=204)
    return Response({'message': 'Liked'}, status=201)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_post_comments(request, post_id):
    """
    API view to retrieve all comments for a specific post.
    Requires authentication.
    """
    try:
        # Ensure the post exists
        post = Post.objects.get(id=post_id)
        # Fetch comments for the post, ordered by creation date
        # You might want to refine this query to handle threading (e.g., filter parent=None for top-level)
        comments = Comment.objects.filter(post=post).order_by('-created_at')
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Post.DoesNotExist:
        return Response({"error": "Post not found"}, status=status.HTTP_404_NOT_FOUND)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])  # Ensure the user is authenticated
def edit_post(request, post_id):
    try:
        post = Post.objects.get(id=post_id, user=request.user)  # Ensure the post belongs to the user
        data = request.data.copy()

        # Handle image update if provided
        if 'image' in request.FILES:
            data['image'] = request.FILES['image']

        serializer = EditPostSerializer(post, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)
    except Post.DoesNotExist:
        return Response({"error": "Post not found or you do not have permission to edit it"}, status=404)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reply_to_comment(request, post_id, comment_id):
    """
    API view to reply to a specific comment on a post.
    Requires authentication.
    """
    try:
        # Ensure the post exists
        post = Post.objects.get(id=post_id)
        # Ensure the parent comment exists and belongs to the post
        parent_comment = Comment.objects.get(id=comment_id, post=post)

        data = request.data.copy()
        data['post'] = post.id
        data['parent'] = parent_comment.id  # Set the parent comment

        serializer = CommentSerializer(data=data)
        if serializer.is_valid():
            # Associate the comment with the authenticated user
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except Post.DoesNotExist:
        return Response({"error": "Post not found"}, status=status.HTTP_404_NOT_FOUND)
    except Comment.DoesNotExist:
        return Response({"error": "Comment not found"}, status=status.HTTP_404_NOT_FOUND)
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def edit_comment(request, comment_id):
    """
    API view to edit an existing comment.
    Requires authentication and checks if the user is the comment author.
    """
    try:
        comment = Comment.objects.get(id=comment_id)
    except Comment.DoesNotExist:
        return Response({"error": "Comment not found"}, status=status.HTTP_404_NOT_FOUND)

    # Check if the authenticated user is the author of the comment
    if comment.user != request.user:
        return Response({"error": "You do not have permission to edit this comment."},
                        status=status.HTTP_403_FORBIDDEN)

    serializer = EditCommentSerializer(comment, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_comment(request, comment_id):
    """
    API view to delete an existing comment.
    Requires authentication and checks if the user is the comment author.
    """
    try:
        comment = Comment.objects.get(id=comment_id)
    except Comment.DoesNotExist:
        return Response({"error": "Comment not found"}, status=status.HTTP_404_NOT_FOUND)

    # Check if the authenticated user is the author of the comment
    if comment.user != request.user:
        return Response({"error": "You do not have permission to delete this comment."},
                        status=status.HTTP_403_FORBIDDEN)

    comment.delete()
    return Response({"message": "Comment deleted successfully"}, status=status.HTTP_204_NO_CONTENT)

    comment.delete()
    # Return 204 No Content for a successful deletion
    return Response(status=status.HTTP_204_NO_CONTENT)
