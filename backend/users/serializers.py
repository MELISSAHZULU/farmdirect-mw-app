# users/serializers.py
from rest_framework import serializers
from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'phone', 'first_name', 'last_name', 'email',
            'role', 'area', 'language', 'is_active', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ['phone', 'first_name', 'last_name', 'password', 'area', 'role', 'language']

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)