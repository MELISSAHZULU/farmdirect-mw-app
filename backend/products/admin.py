# products/admin.py
from django.contrib import admin
from .models import Category, Product

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'icon', 'display_order', 'is_active')
    list_filter = ('is_active',)

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'unit', 'farmer', 'is_active')
    list_filter = ('category', 'unit', 'farmer', 'is_active')
    search_fields = ('name',)