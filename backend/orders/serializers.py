# orders/serializers.py
from rest_framework import serializers
from .models import Order, OrderItem

class OrderItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    farmer_name = serializers.CharField(source='farmer.name', read_only=True)
    
    class Meta:
        model = OrderItem
        fields = ['id', 'product', 'product_name', 'farmer', 'farmer_name', 
                  'quantity', 'unit_price', 'total_price']

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    customer_phone = serializers.CharField(source='customer.phone', read_only=True)
    customer_name = serializers.CharField(source='customer.first_name', read_only=True)
    
    class Meta:
        model = Order
        fields = [
            'id', 'order_number', 'customer', 'customer_phone', 'customer_name',
            'delivery_area', 'delivery_address', 'delivery_date',
            'special_instructions', 'payment_method', 'payment_status',
            'total_amount', 'status', 'items', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'order_number', 'created_at', 'updated_at']

class OrderCreateSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, required=False)
    
    class Meta:
        model = Order
        fields = [
            'delivery_area', 'delivery_address', 'delivery_date',
            'special_instructions', 'payment_method', 'items'
        ]
    
    def create(self, validated_data):
        items_data = validated_data.pop('items', [])
        order = Order.objects.create(**validated_data)
        for item_data in items_data:
            OrderItem.objects.create(order=order, **item_data)
        return order