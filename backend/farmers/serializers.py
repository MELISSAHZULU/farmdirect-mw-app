# farmers/serializers.py
from rest_framework import serializers
from .models import Farmer

class FarmerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Farmer
        fields = ['id', 'name', 'contact_phone', 'contact_name', 'email', 'is_active', 'created_at']
        read_only_fields = ['created_at']
        