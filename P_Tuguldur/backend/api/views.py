from rest_framework import generics,permissions
from rest_framework.generics import RetrieveAPIView
from .models import Lesson, Question, Category, Level
from .serializers import LessonSerializer, QuestionSerializer, CategorySerializer, LevelSerializer,LoginSerializer, RegisterSerializer, UserProfileSerializer,WordSerializer,TestQuestionSerializer,newsSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.db import transaction # Import transaction
from django.utils import timezone

from .models import Question, Choice, User, UserAnswer, TestQuestion, Result
from .serializers import SubmitTestSerializer
from collections import defaultdict
import random
from .models import UserAnswer,UserProfile, TestResult,Word, MyWord,news
from rest_framework.permissions import IsAuthenticated, AllowAny
# Хичээлийн жагсаалт (төрөл, төвшнөөр шүүж болно)
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response({'message': 'User registered successfully'}, status=201)
        print("Serializer errors:", serializer.errors)  # Log errors
        return Response(serializer.errors, status=400)

class LoginView(APIView):
    permission_classes = [AllowAny]  # Allow access without authentication

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'username': user.username,
                'email': user.email,
            }, status=200)
        return Response(serializer.errors, status=400)
class LessonListView(generics.ListAPIView):
    serializer_class = LessonSerializer
    permission_classes = [IsAuthenticated]  # Requires authentication

    def get_queryset(self):
        queryset = Lesson.objects.all()
        category = self.request.query_params.get('category')
        level = self.request.query_params.get('level')
        if category:
            queryset = queryset.filter(category__name=category)
        if level:
            queryset = queryset.filter(level__name=level)
        return queryset

# Хичээлийн ID-р асуултууд авах
class LessonQuestionsView(generics.RetrieveAPIView):
    serializer_class = QuestionSerializer
    queryset = Question.objects.all()


class SubmitTestView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        print("Data received:", request.data)
        data = request.data

        answers_data = data.get('answers') # Renamed to avoid conflict
        category_name = data.get('category')
        level_name = data.get('level')

        if not answers_data:
            return Response({'error': 'Answers are required'}, status=400)
        if not category_name or not level_name:
            return Response({'error': 'Category and level are required'}, status=400)

        try:
            category = Category.objects.get(name=category_name)
        except Category.DoesNotExist:
            return Response({'error': f'Category "{category_name}" does not exist'}, status=400)

        try:
            level = Level.objects.get(name=level_name)
        except Level.DoesNotExist:
            return Response({'error': f'Level "{level_name}" does not exist'}, status=400)

        try:
            with transaction.atomic(): # Use a transaction for atomic operations
                total_questions_submitted = len(answers_data)
                correct_answers_count = 0
                incorrect_details = []
                
                # To store for TestResult.answers and for creating UserAnswer instances
                processed_answers_for_test_result = [] 

                for answer_detail in answers_data:
                    question_id = answer_detail.get('question_id')
                    selected_choice_id = answer_detail.get('selected_choice_id')

                    if question_id is None or selected_choice_id is None:
                        return Response({'error': 'Each answer must have question_id and selected_choice_id'}, status=400)

                    try:
                        question = Question.objects.get(id=question_id)
                        selected_choice = Choice.objects.get(id=selected_choice_id)
                        
                        # Ensure the selected choice belongs to the question
                        if selected_choice.question != question:
                            return Response(
                                {'error': f'Choice ID {selected_choice_id} does not belong to Question ID {question_id}'},
                                status=400
                            )

                    except Question.DoesNotExist:
                        return Response({'error': f'Question with ID {question_id} does not exist'}, status=400)
                    except Choice.DoesNotExist:
                        return Response({'error': f'Choice with ID {selected_choice_id} does not exist'}, status=400)

                    is_correct_answer = selected_choice.is_correct
                    
                    # *** Create UserAnswer record ***
                    UserAnswer.objects.create(
                        user=request.user,
                        question=question,
                        selected_choice=selected_choice,
                        is_correct=is_correct_answer
                    )

                    processed_answers_for_test_result.append({
                        'question_id': question.id,
                        'question_text': question.text, # Optional: for easier review in TestResult
                        'selected_choice_id': selected_choice.id,
                        'selected_choice_text': selected_choice.text, # Optional
                        'is_correct': is_correct_answer
                    })

                    if is_correct_answer:
                        correct_answers_count += 1
                    else:
                        correct_choice = Choice.objects.filter(question=question, is_correct=True).first()
                        incorrect_details.append({
                            'question': question.text,
                            'your_answer': selected_choice.text,
                            'correct_answer': correct_choice.text if correct_choice else 'No correct answer defined'
                        })
                
                if total_questions_submitted == 0:
                     return Response({'error': 'No answers provided in the answers list.'}, status=400)

                score = (correct_answers_count / total_questions_submitted) * 100 if total_questions_submitted > 0 else 0.0

                # UserProfile update (ensure UserProfile model and this method exist and work)
                # user_profile, _ = UserProfile.objects.get_or_create(user=request.user)
                # user_profile.update_test_result(score, category, level)

                TestResult.objects.create(
                    user=request.user,
                    category=category,
                    level=level,
                    score=score,
                    answers=processed_answers_for_test_result # Save the processed list
                )

            return Response({
                'message': 'Test submitted successfully',
                'score': score,
                'total_questions': total_questions_submitted,
                'correct_answers': correct_answers_count,
                'incorrect_questions': incorrect_details
            }, status=200)

        except Exception as e:
            # Log the exception for server-side debugging
            print(f"Error in SubmitTestView: {str(e)}")
            return Response({'error': 'An unexpected error occurred on the server: ' + str(e)}, status=500)

# class UserScoreStatsView(APIView):
#     permission_classes = [IsAuthenticated]

#     def get(self, request):
#         user = request.user
#         answers = UserAnswer.objects.filter(user=user).select_related(
#             'question__lesson__category',
#             'question__lesson__level'
#         )

#         stats = defaultdict(lambda: defaultdict(lambda: {'total': 0, 'correct': 0}))

#         for ans in answers:
#             category = ans.question.lesson.category.name
#             level = ans.question.lesson.level.name

#             stats[category][level]['total'] += 1
#             if ans.is_correct:
#                 stats[category][level]['correct'] += 1

#         result = {}
#         for category, levels in stats.items():
#             result[category] = {}
#             for level, data in levels.items():
#                 total = data['total']
#                 correct = data['correct']
#                 percent = round((correct / total) * 100, 2) if total > 0 else 0.0
#                 result[category][level] = {
#                     "correct": correct,
#                     "total": total,
#                     "score_percent": percent
#                 }

#         return Response(result, status=200)
class UserScoreStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        answers = UserAnswer.objects.filter(user=user).select_related(
            'question__lesson__category',
            'question__lesson__level'
        )

        stats = defaultdict(lambda: defaultdict(lambda: {'total': 0, 'correct': 0}))
        total_correct = 0
        total_questions = 0

        for ans in answers:
            category = ans.question.lesson.category.name
            level = ans.question.lesson.level.name

            stats[category][level]['total'] += 1
            if ans.is_correct:
                stats[category][level]['correct'] += 1

            total_questions += 1
            if ans.is_correct:
                total_correct += 1

        result = {}
        for category, levels in stats.items():
            result[category] = {}
            for level, data in levels.items():
                total = data['total']
                correct = data['correct']
                percent = round((correct / total) * 100, 2) if total > 0 else 0.0
                result[category][level] = {
                    "correct": correct,
                    "total": total,
                    "score_percent": percent
                }

        # Дундаж оноо дээр үндэслэн түвшин гаргах
        average_score = round((total_correct / total_questions) * 100, 2) if total_questions > 0 else 0.0

        if average_score < 50:
            level = "Beginner"
        elif average_score < 75:
            level = "Intermediate"
        else:
            level = "Advanced"

        return Response({
            "category_stats": result,
            "overall_score_percent": average_score,
            "estimated_level": level
        }, status=200)
class GetQuizView(APIView):
    permission_classes = [AllowAny]  # Устгах боломжтой

    def get(self, request):
        category_name = request.query_params.get('category')
        level_name = request.query_params.get('level')

        if not category_name or not level_name:
            return Response({'error': 'category and level are required'}, status=400)

        try:
            lessons = Lesson.objects.filter(
                category__name=category_name,
                level__name=level_name
            )
            questions = Question.objects.filter(lesson__in=lessons).prefetch_related('choices')[:10]

            serializer = QuestionSerializer(questions, many=True)
            return Response(serializer.data, status=200)

        except Exception as e:
            return Response({'error': str(e)}, status=500)
class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]  # Allow access without authentication

class LevelListView(generics.ListAPIView):
    queryset = Level.objects.all()
    serializer_class = LevelSerializer
    permission_classes = [AllowAny]  # Allow access without authentication


class WordListView(generics.ListAPIView):
    queryset = Word.objects.all()
    serializer_class = WordSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()
        search_query = self.request.query_params.get('search', None)

        if search_query:
            queryset = queryset.filter(
                Q(english__icontains=search_query) | Q(mongolian__icontains=search_query)
            )
        return queryset

class WordDetailView(RetrieveAPIView):
    queryset = Word.objects.all()
    serializer_class = WordSerializer
    permission_classes = [IsAuthenticated]
class MyWordsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        words = MyWord.objects.filter(user=request.user)
        return Response([{
            'id': w.word.id,
            'english': w.word.english,
            'mongolian': w.word.mongolian
        } for w in words])

    def delete(self, request, word_id):
        try:
            my_word = MyWord.objects.get(user=request.user, word_id=word_id)
            my_word.delete()
            return Response({'status': 'Word removed successfully'}, status=204)
        except MyWord.DoesNotExist:
            return Response({'error': 'Word not found'}, status=404)

class BookmarkWordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        word_id = request.data.get('word_id')
        if not word_id:
            return Response({'error': 'Missing word_id'}, status=400)
        MyWord.objects.get_or_create(user=request.user, word_id=word_id)
        return Response({'status': 'Bookmarked'})
class GetTestQuestionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        questions = []

        for level in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']:  # Түвшин бүрийн асуултуудыг авах
            qs = list(TestQuestion.objects.filter(level=level).order_by('?')[:5])
            questions.extend(qs)

        random.shuffle(questions)

        serializer = TestQuestionSerializer(questions, many=True)
        return Response(serializer.data)


class SubmitView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # Get answers from the request
        answers = request.data.get('answers')

        if not answers:
            return Response({'error': 'No answers provided'}, status=400)

        total = len(answers)
        correct = 0
        incorrect = []

        # Process answers
        for q_id_str, selected in answers.items():
            try:
                q_id = int(q_id_str)
                q = TestQuestion.objects.get(id=q_id)
                selected_int = int(selected)

                if selected_int not in [1, 2, 3, 4]:
                    continue

                if selected_int == q.correct_choice:
                    correct += 1
                else:
                    your_answer_text = getattr(q, f'choice{selected_int}', 'N/A')
                    correct_answer_text = getattr(q, f'choice{q.correct_choice}', 'N/A')

                    incorrect.append({
                        'question': q.question,
                        'your_answer': selected_int,
                        'your_answer_text': your_answer_text,
                        'correct_answer': q.correct_choice,
                        'correct_answer_text': correct_answer_text,
                    })
            except (TestQuestion.DoesNotExist, ValueError):
                continue

        percent = (correct / total * 100) if total > 0 else 0

        # Determine level based on percentage
        if percent >= 95:
            level_code = 'C2'
        elif percent >= 90:
            level_code = 'C1'
        elif percent >= 80:
            level_code = 'B2'
        elif percent >= 65:
            level_code = 'B1'
        elif percent >= 50:
            level_code = 'A2'
        else:
            level_code = 'A1'

        # Retrieve the Level instance
        try:
                    level_instance = Level.objects.get(name=level_code)
        except Level.DoesNotExist:
            return Response({'error': f'Level "{level_code}" does not exist in the database.'}, status=400)

        # Save the result
        result = Result.objects.create(
            user=request.user,
            score=correct,
            level=level_instance,
            incorrect_questions=incorrect
        )

        # Update UserProfile
        user_profile, created = UserProfile.objects.get_or_create(user=request.user)
        user_profile.last_test_score = correct
        user_profile.last_test_level = level_instance  # Assign the Level instance
        user_profile.last_test_date = timezone.now()
        user_profile.save()

        return Response({
            'score': correct,
            'total': total,
            'level': level_code,
            'level_description': self.get_level_description(level_code),
            'incorrect_questions': incorrect
        })

    def get_level_description(self, level_code):
        descriptions = {
            'A1': 'Beginner',
            'A2': 'Elementary',
            'B1': 'Intermediate',
            'B2': 'Upper Intermediate',
            'C1': 'Advanced',
            'C2': 'Proficient',
        }
        return descriptions.get(level_code, 'Unknown Level')
class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        profile = UserProfile.objects.get(user=request.user)
        return Response({
            'username': request.user.username,
            'email': request.user.email,
            'last_score': profile.last_test_score,
            'last_level': profile.last_test_level.name if profile.last_test_level else None,
            'incorrect_questions': profile.last_test_category.name if profile.last_test_category else None,
        })

class newsListView(generics.ListAPIView):
    queryset = news.objects.all()
    serializer_class = newsSerializer
    permission_classes = [AllowAny]  # Allow access without authentication