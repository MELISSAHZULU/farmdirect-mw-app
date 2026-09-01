# orders/views.py
import os
import hmac
import hashlib
import json
import requests
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.http import JsonResponse, HttpResponse
from .models import Order, OrderItem
from .serializers import OrderSerializer, OrderCreateSerializer

# ============ ORDER LIST VIEW ============

class OrderListView(generics.ListAPIView):
    """List all orders for the authenticated user"""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Order.objects.filter(customer=self.request.user)

# ============ ORDER CREATE VIEW ============

class OrderCreateView(generics.CreateAPIView):
    """Create a new order"""
    serializer_class = OrderCreateSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(customer=self.request.user)
    
    def create(self, request, *args, **kwargs):
        print(f"📦 Received order data: {request.data}")
        
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            print(f"❌ Order validation errors: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ============ ORDER DETAIL VIEW ============

class OrderDetailView(generics.RetrieveAPIView):
    """Get order details"""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'
    
    def get_queryset(self):
        return Order.objects.filter(customer=self.request.user)

# ============ ORDER CANCEL VIEW ============

class OrderCancelView(generics.UpdateAPIView):
    """Cancel an order"""
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'id'
    
    def get_queryset(self):
        return Order.objects.filter(
            customer=self.request.user,
            status__in=['pending', 'packing']
        )
    
    def update(self, request, *args, **kwargs):
        order = self.get_object()
        order.status = 'cancelled'
        order.save()
        return Response(
            {'message': 'Order cancelled successfully', 'status': order.status},
            status=status.HTTP_200_OK
        )

# ============ PAYMENT INITIATION VIEW ============

class InitializePaymentView(APIView):
    """
    Initialize a payment with PayChangu
    Called from Flutter app when user selects Airtel Money or TNM Mpamba
    """
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        try:
            # Get order details from request
            order_id = request.data.get('order_id')
            payment_method = request.data.get('payment_method')
            
            print(f"🔍 Order ID: {order_id}, Payment Method: {payment_method}")
            
            if not order_id:
                return Response({'error': 'Order ID is required'}, status=status.HTTP_400_BAD_REQUEST)
            
            # Get the order
            try:
                order = Order.objects.get(id=order_id, customer=request.user)
                print(f"✅ Found order: {order.order_number} - Total: {order.total_amount}")
            except Order.DoesNotExist:
                return Response({'error': 'Order not found'}, status=status.HTTP_404_NOT_FOUND)
            
            # Check if order total is valid
            if order.total_amount <= 0:
                return Response({'error': 'Invalid order amount'}, status=status.HTTP_400_BAD_REQUEST)
            
            # Get PayChangu configuration from environment
            paychangu_secret = os.getenv('PAYCHANGU_SECRET_KEY')
            
            if not paychangu_secret:
                print("❌ PAYCHANGU_SECRET_KEY not set in environment")
                return Response(
                    {'error': 'Payment service not configured. Please contact support.'}, 
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            # Determine which mobile money provider to use
            provider = 'airtel-money' if payment_method == 'airtel_money' else 'tnm-mpamba'
            
            # Get customer phone number (remove leading + if present)
            customer_phone = request.user.phone
            if customer_phone.startswith('+'):
                customer_phone = customer_phone[1:]
            
            # Get backend URL from environment (Render provides this)
            backend_url = os.getenv('BACKEND_URL', 'https://your-app.onrender.com')
            frontend_url = os.getenv('FRONTEND_URL', 'https://your-frontend.onrender.com')
            
            # Prepare payload for PayChangu API
            payload = {
                'tx_ref': order.order_number,
                'amount': str(float(order.total_amount)),
                'currency': 'MWK',
                'customer': {
                    'first_name': request.user.first_name,
                    'last_name': request.user.last_name,
                    'email': request.user.email or f"{request.user.phone}@farmdirect.mw",
                    'phone_number': customer_phone,
                },
                'payment_method': provider,
                'redirect_url': f"{frontend_url}/payment-return",
                'callback_url': f"{backend_url}/api/orders/webhook/",
                'metadata': {
                    'order_id': order.id,
                    'customer_id': request.user.id,
                }
            }
            
            print(f"📦 PayChangu Payload: {json.dumps(payload, indent=2)}")
            
            # Make request to PayChangu API
            api_url = 'https://api.paychangu.com/v1/payment/initiate'
            headers = {
                'Authorization': f'Bearer {paychangu_secret}',
                'Content-Type': 'application/json',
            }
            
            print(f"🌐 Calling PayChangu API: {api_url}")
            
            response = requests.post(api_url, json=payload, headers=headers, timeout=30)
            print(f"📡 PayChangu Response Status: {response.status_code}")
            print(f"📝 PayChangu Response: {response.text}")
            
            if response.status_code in [200, 201]:
                response_data = response.json()
                payment_url = response_data.get('data', {}).get('payment_url')
                tx_ref = response_data.get('data', {}).get('tx_ref')
                
                # Update order with payment reference
                order.payment_reference = tx_ref
                order.save()
                
                return Response({
                    'status': 'success',
                    'payment_url': payment_url,
                    'tx_ref': tx_ref,
                }, status=status.HTTP_200_OK)
            else:
                print(f"❌ PayChangu Error: {response.text}")
                return Response({
                    'error': 'Payment initiation failed',
                    'detail': response.text
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except requests.exceptions.Timeout:
            print("❌ PayChangu API timeout")
            return Response(
                {'error': 'Payment service timeout'}, 
                status=status.HTTP_504_GATEWAY_TIMEOUT
            )
        except requests.exceptions.ConnectionError:
            print("❌ PayChangu API connection error")
            return Response(
                {'error': 'Cannot connect to payment service'}, 
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        except Exception as e:
            print(f"❌ Payment initiation error: {str(e)}")
            import traceback
            traceback.print_exc()
            return Response(
                {'error': str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

# ============ PAYMENT WEBHOOK ============

WEBHOOK_SECRET = os.getenv('PAYCHANGU_WEBHOOK_SECRET', '')

@csrf_exempt
@require_POST
def payment_webhook(request):
    """
    Handle PayChangu webhook notifications
    This is where PayChangu sends payment status updates
    """
    try:
        # Get the raw payload and signature
        raw_payload = request.body
        signature = request.headers.get('Signature', '')
        
        print(f"📦 Webhook received. Signature: {signature[:20]}...")
        
        # Verify webhook signature
        if WEBHOOK_SECRET:
            computed_signature = hmac.new(
                WEBHOOK_SECRET.encode('utf-8'),
                raw_payload,
                hashlib.sha256
            ).hexdigest()
            
            if not hmac.compare_digest(computed_signature, signature):
                print('⚠️ Invalid webhook signature')
                return HttpResponse('Invalid signature', status=401)
        
        # Parse the payload
        payload = json.loads(raw_payload)
        print(f'📦 Webhook payload: {payload}')
        
        # Get payment status and reference
        data = payload.get('data', {})
        tx_ref = data.get('tx_ref') or data.get('reference')
        status_type = data.get('status')
        
        if not tx_ref:
            print('❌ No tx_ref found in webhook')
            return JsonResponse({'status': 'missing tx_ref'}, status=400)
        
        # Find the order using the transaction reference
        try:
            order = Order.objects.get(order_number=tx_ref)
            print(f"✅ Found order: {order.order_number}")
        except Order.DoesNotExist:
            print(f'❌ Order not found for tx_ref: {tx_ref}')
            return JsonResponse({'status': 'order not found'}, status=404)
        
        # Update order based on payment status
        if status_type in ['success', 'completed', 'paid']:
            order.payment_status = 'paid'
            order.status = 'confirmed'
            order.save()
            print(f'✅ Order {order.order_number} confirmed via webhook')
            
        elif status_type in ['failed', 'cancelled', 'error']:
            order.status = 'cancelled'
            order.save()
            print(f'❌ Order {order.order_number} payment failed')
        
        elif status_type in ['pending']:
            order.payment_status = 'pending'
            order.save()
            print(f'⏳ Order {order.order_number} payment pending')
        
        # Always return 200 to acknowledge receipt
        return JsonResponse({'status': 'success'}, status=200)
        
    except json.JSONDecodeError as e:
        print(f'❌ Invalid JSON: {e}')
        return HttpResponse('Invalid JSON', status=400)
    except Exception as e:
        print(f'❌ Webhook error: {e}')
        import traceback
        traceback.print_exc()
        return HttpResponse('Error processing webhook', status=500)