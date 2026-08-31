# farmers/urls.py
from django.urls import path
from .views import FarmerListView, FarmerDetailView

urlpatterns = [
    path('', FarmerListView.as_view(), name='farmer-list'),
    path('<int:id>/', FarmerDetailView.as_view(), name='farmer-detail'),
]