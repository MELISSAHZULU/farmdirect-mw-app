# products/models.py
from django.db import models
from farmers.models import Farmer

class Category(models.Model):
    name = models.CharField(max_length=50, unique=True)
    icon = models.CharField(max_length=10, blank=True, help_text="Emoji icon")
    display_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        ordering = ['display_order', 'name']

class Product(models.Model):
    UNIT_CHOICES = (
        ('kg', 'Kilogram'),
        ('head', 'Head'),
        ('bunch', 'Bunch'),
        ('piece', 'Piece'),
        ('pack', 'Pack'),
        ('ea', 'Each'),
        ('finger', 'Finger'),
        ('bulb', 'Bulb'),
    )
    
    name = models.CharField(max_length=100)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)
    unit = models.CharField(max_length=10, choices=UNIT_CHOICES)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    min_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    max_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    has_variants = models.BooleanField(default=False)
    image_url = models.URLField(max_length=500, blank=True)
    description = models.TextField(blank=True)
    farmer = models.ForeignKey(Farmer, on_delete=models.SET_NULL, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.name} ({self.get_unit_display()})"
    
    class Meta:
        ordering = ['name']