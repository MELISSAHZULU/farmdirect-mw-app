# products/serializers.py
from rest_framework import serializers
from .models import Category, Product

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'icon', 'display_order', 'is_active']

class ProductSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    farmer_name = serializers.CharField(source='farmer.name', read_only=True)
    
    class Meta:
        model = Product
        fields = [
            'id', 'name', 'category', 'category_name', 'unit', 'price',
            'min_price', 'max_price', 'has_variants', 'image_url',
            'description', 'farmer', 'farmer_name', 'is_active', 'created_at'
        ]
        read_only_fields = ['created_at']