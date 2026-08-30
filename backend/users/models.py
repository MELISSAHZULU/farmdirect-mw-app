# users/models.py
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models

class UserManager(BaseUserManager):
    """Custom user manager where phone is the unique identifier"""
    
    def create_user(self, phone, password=None, **extra_fields):
        if not phone:
            raise ValueError('The Phone number must be set')
        user = self.model(phone=phone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, phone, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
        
        return self.create_user(phone, password, **extra_fields)

class User(AbstractUser):
    # Remove username - we'll use phone instead
    username = None
    
    # Primary identifier
    phone = models.CharField(max_length=15, unique=True)
    
    # User types
    ROLE_CHOICES = (
        ('customer', 'Customer'),
        ('farmer', 'Farmer'),
        ('admin', 'Admin'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='customer')
    
    # Additional fields
    area = models.CharField(max_length=50, blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Use phone as the unique identifier for login
    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['first_name', 'last_name']
    
    # Use custom manager
    objects = UserManager()
    
    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.phone})"
    
    class Meta:
        db_table = 'users'
        ordering = ['-date_joined']