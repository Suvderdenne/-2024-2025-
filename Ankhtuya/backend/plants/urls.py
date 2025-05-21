from django.urls import path
from . import views

urlpatterns = [
    path('assess-health/', views.PlantHealthAssessmentView.as_view(), name='plant-health-assessment'),
] 