# orders/models.py
from django.db import models
from users.models import User
from products.models import Product
from farmers.models import Farmer

class Order(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Order Placed'),
        ('packing', 'Farmer Packing'),
        ('at_gateway', 'At Gateway Mall'),
        ('out_for_delivery', 'Out for Delivery'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    )
    
    PAYMENT_CHOICES = (
        ('cash_on_delivery', 'Cash on Delivery'),
        ('airtel_money', 'Airtel Money'),
        ('tnm_mpamba', 'TNM Mpamba'),
    )
    
    order_number = models.CharField(max_length=20, unique=True)
    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders')
    delivery_area = models.CharField(max_length=50)
    delivery_address = models.TextField()
    delivery_date = models.DateField()
    special_instructions = models.TextField(blank=True)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_CHOICES)
    payment_status = models.CharField(max_length=20, default='pending')
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Order {self.order_number}"
    
    def save(self, *args, **kwargs):
        if not self.order_number:
            import random
            import datetime
            year = datetime.datetime.now().year
            random_num = str(random.randint(10000, 99999))
            self.order_number = f"MW-{year}-{random_num}"
        super().save(*args, **kwargs)
    
    class Meta:
        ordering = ['-created_at']

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE)
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    
    def save(self, *args, **kwargs):
        self.total_price = self.quantity * self.unit_price
        super().save(*args, **kwargs)