from django.urls import path
from .views import *

urlpatterns = [
    path('register/', RegisterView.as_view()),
    path('login/', LoginView.as_view()),
    path('logout/', LogoutView.as_view()),
    path('profile/<str:uid>/', ProfileView.as_view(), name='profile'),
    path("family/add/", AddFamilyMemberView.as_view(), name="add-family-member"),
    path("family/<str:person_id>/list/", FamilyMembersListView.as_view(), name="list-family-members"),
    path("family/<str:uid>/update/", UpdateFamilyMemberView.as_view(), name="update-family-member"),
    path('family/<str:uid>/delete/', DeleteFamilyMemberView.as_view(), name="delete-family-member"),
    path('profile/<str:uid>/delete/', DeleteUserView.as_view()),
    path('person/', PersonCreateView.as_view()),
    path('person/<str:element_id>/', PersonEditView.as_view()),
    path('relationship/', AddRelationshipView.as_view()),
    
    # Add new endpoints
    path('places/', PlaceListCreateView.as_view(), name='places-list'),
    path('uye/', UyeListCreateView.as_view(), name='uye-list'),
    path('urgiinovog/', UrgiinOvogListCreateView.as_view(), name='urgiinovog-list'),
    path('relationship-types/', RelationshipTypesView.as_view(), name='relationship-types'),
    
    # New simple person endpoint
    path('simple-person/', SimplePersonCreateView.as_view(), name='simple-person'),
]
