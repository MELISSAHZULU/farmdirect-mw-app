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

class OrderItemCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating order items"""
    class Meta:
        model = OrderItem
        fields = ['product', 'farmer', 'quantity', 'unit_price']

class OrderCreateSerializer(serializers.ModelSerializer):
    items = OrderItemCreateSerializer(many=True, required=True)
    
    class Meta:
        model = Order
        fields = [
            'delivery_area', 
            'delivery_address', 
            'delivery_date',
            'special_instructions', 
            'payment_method', 
            'items'
        ]
    
    def validate(self, data):
        """Validate that items list is not empty"""
        if not data.get('items'):
            raise serializers.ValidationError({"items": "At least one item is required"})
        return data
    
    def create(self, validated_data):
        items_data = validated_data.pop('items', [])
        
        # Calculate total amount first
        total_amount = 0
        for item_data in items_data:
            total_amount += item_data['quantity'] * item_data['unit_price']
        
        # Create order with calculated total_amount
        order = Order.objects.create(
            **validated_data,
            total_amount=total_amount  # ← ADD THIS
        )
        
        # Create order items
        for item_data in items_data:
            OrderItem.objects.create(
                order=order,
                product=item_data['product'],
                farmer=item_data['farmer'],
                quantity=item_data['quantity'],
                unit_price=item_data['unit_price'],
                total_price=item_data['quantity'] * item_data['unit_price']
            )
        
        return order