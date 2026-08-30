# farmers/models.py
from django.db import models

class Farmer(models.Model):
    name = models.CharField(max_length=100)
    contact_phone = models.CharField(max_length=15)
    contact_name = models.CharField(max_length=100, blank=True)
    email = models.EmailField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        ordering = ['name']