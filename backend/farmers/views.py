# farmers/views.py
from rest_framework import generics, permissions
from rest_framework.filters import SearchFilter
from .models import Farmer
from .serializers import FarmerSerializer

class FarmerListView(generics.ListAPIView):
    """List all farmers"""
    queryset = Farmer.objects.filter(is_active=True)
    serializer_class = FarmerSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [SearchFilter]
    search_fields = ['name', 'contact_phone']

class FarmerDetailView(generics.RetrieveAPIView):
    """Get farmer details"""
    queryset = Farmer.objects.filter(is_active=True)
    serializer_class = FarmerSerializer
    permission_classes = [permissions.AllowAny]
    lookup_field = 'id'