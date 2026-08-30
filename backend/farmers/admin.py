# farmers/admin.py
from django.contrib import admin
from .models import Farmer

@admin.register(Farmer)
class FarmerAdmin(admin.ModelAdmin):
    list_display = ('name', 'contact_phone', 'contact_name', 'is_active')
    list_filter = ('is_active',)
    search_fields = ('name', 'contact_phone')