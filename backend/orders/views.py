# orders/views.py
import os
import hmac
import hashlib
import json
import requests
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
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
        print(f"[ORDER] Received order data: {request.data}")
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            print(f"[ORDER] Validation errors: {serializer.errors}")
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
    Initialize a payment with PayChangu.
    Sends NO payment_method field so PayChangu's hosted page
    shows all options (Airtel, TNM, card, bank).
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            order_id = request.data.get('order_id')
            print(f"[PAY] Order ID: {order_id}")

            if not order_id:
                return Response({'error': 'Order ID is required'}, status=status.HTTP_400_BAD_REQUEST)

            try:
                order = Order.objects.get(id=order_id, customer=request.user)
                print(f"[PAY] Found order: {order.order_number} - Total: {order.total_amount}")
            except Order.DoesNotExist:
                return Response({'error': 'Order not found'}, status=status.HTTP_404_NOT_FOUND)

            if order.total_amount <= 0:
                return Response({'error': 'Invalid order amount'}, status=status.HTTP_400_BAD_REQUEST)

            paychangu_secret = os.getenv('PAYCHANGU_SECRET_KEY')
            if not paychangu_secret:
                print("[PAY] PAYCHANGU_SECRET_KEY not set")
                return Response(
                    {'error': 'Payment service not configured.'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )

            customer_phone = request.user.phone or ''
            if customer_phone.startswith('+'):
                customer_phone = customer_phone[1:]

            backend_url = os.getenv('BACKEND_URL', 'https://farmdirect-mw-app.onrender.com')
            frontend_url = os.getenv('FRONTEND_URL', 'https://farmdirect-mw-app.onrender.com')

            import time
            tx_ref = f"{order.order_number}-{int(time.time())}"

            payload = {
                'amount': int(round(float(order.total_amount))),
                'currency': 'MWK',
                'tx_ref': tx_ref,
                'first_name': request.user.first_name or 'Customer',
                'last_name': request.user.last_name or '-',
                'email': request.user.email or f"{request.user.phone}@farmdirect.mw",
                'callback_url': f"{backend_url}/api/orders/payment-return/",
                'return_url': f"{backend_url}/api/orders/payment-return/",
                'customization': {
                    'title': 'FarmDirect MW',
                    'description': f'Order {order.order_number}',
                },
                'meta': {
                    'order_id': order.id,
                    'customer_id': request.user.id,
                }
            }

            print(f"[PAY] PayChangu payload: {json.dumps(payload, indent=2)}")

            api_url = 'https://api.paychangu.com/payment'
            headers = {
                'Authorization': f'Bearer {paychangu_secret}',
                'Content-Type': 'application/json',
            }

            response = requests.post(api_url, json=payload, headers=headers, timeout=30)
            print(f"[PAY] PayChangu status: {response.status_code}")
            print(f"[PAY] PayChangu response: {response.text}")

            if response.status_code in [200, 201]:
                response_data = response.json()
                checkout_url = (response_data.get('data') or {}).get('checkout_url')

                order.payment_reference = tx_ref
                order.save()

                return Response({
                    'status': 'success',
                    'payment_url': checkout_url,
                    'tx_ref': tx_ref,
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    'error': 'Payment initiation failed',
                    'detail': response.text
                }, status=status.HTTP_400_BAD_REQUEST)

        except requests.exceptions.Timeout:
            return Response({'error': 'Payment service timeout'}, status=status.HTTP_504_GATEWAY_TIMEOUT)
        except requests.exceptions.ConnectionError:
            return Response({'error': 'Cannot connect to payment service'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            print(f"[PAY] Payment initiation error: {str(e)}")
            import traceback
            traceback.print_exc()
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ============ PAYMENT WEBHOOK ============
WEBHOOK_SECRET = os.getenv('PAYCHANGU_WEBHOOK_SECRET', '')


@csrf_exempt
@require_POST
def payment_webhook(request):
    """Handle PayChangu webhook notifications."""
    try:
        raw_payload = request.body
        signature = request.headers.get('Signature', '')

        print(f"[WEBHOOK] Signature: {signature[:20]}...")

        if WEBHOOK_SECRET:
            computed_signature = hmac.new(
                WEBHOOK_SECRET.encode('utf-8'),
                raw_payload,
                hashlib.sha256
            ).hexdigest()
            if not hmac.compare_digest(computed_signature, signature):
                print('[WEBHOOK] Invalid signature')
                return HttpResponse('Invalid signature', status=401)

        payload = json.loads(raw_payload)
        print(f'[WEBHOOK] Payload: {payload}')

        data = payload.get('data', {})
        tx_ref = data.get('tx_ref') or data.get('reference')

        if not tx_ref:
            return JsonResponse({'status': 'missing tx_ref'}, status=400)

        # Verify with PayChangu API before marking paid
        paychangu_secret = os.getenv('PAYCHANGU_SECRET_KEY')
        verify_url = f"https://api.paychangu.com/verify-payment/{tx_ref}"
        verify_headers = {'Authorization': f'Bearer {paychangu_secret}'}

        verify_resp = requests.get(verify_url, headers=verify_headers, timeout=10)
        if verify_resp.status_code != 200:
            print(f"[WEBHOOK] Verification failed: {verify_resp.text}")
            return HttpResponse('Verification failed', status=400)

        verify_data = verify_resp.json()
        verified_status = (verify_data.get('data') or {}).get('status')
        verified_amount = float((verify_data.get('data') or {}).get('amount', 0))
        verified_currency = (verify_data.get('data') or {}).get('currency')

        # Strip the timestamp suffix to find the order
        order_number = tx_ref.rsplit('-', 1)[0]

        try:
            order = Order.objects.get(order_number=order_number)
            print(f"[WEBHOOK] Found order: {order.order_number}")
        except Order.DoesNotExist:
            print(f'[WEBHOOK] Order not found for tx_ref: {tx_ref}')
            return JsonResponse({'status': 'order not found'}, status=404)

        if verified_currency != 'MWK':
            print(f'[WEBHOOK] Currency mismatch: {verified_currency}')
            return HttpResponse('Currency mismatch', status=400)
        if verified_amount < float(order.total_amount):
            print(f'[WEBHOOK] Amount mismatch: {verified_amount} < {order.total_amount}')
            return HttpResponse('Amount mismatch', status=400)

        if verified_status == 'success':
            order.payment_status = 'paid'
            order.status = 'confirmed'
            order.save()
            print(f'[WEBHOOK] Order {order.order_number} confirmed')
        else:
            print(f'[WEBHOOK] Unhandled status: {verified_status}')

        return JsonResponse({'status': 'success'}, status=200)

    except json.JSONDecodeError as e:
        print(f'[WEBHOOK] Invalid JSON: {e}')
        return HttpResponse('Invalid JSON', status=400)
    except Exception as e:
        print(f'[WEBHOOK] Error: {e}')
        import traceback
        traceback.print_exc()
        return HttpResponse('Error processing webhook', status=500)


# ============ PAYMENT RETURN PAGE ============
@csrf_exempt
def payment_return(request):
    """
    Page the customer sees after paying or cancelling.
    Also verifies payment as a backup in case the webhook is late.
    """
    tx_ref = request.GET.get('tx_ref') or request.POST.get('tx_ref')
    paid = False

    if tx_ref:
        try:
            paychangu_secret = os.getenv('PAYCHANGU_SECRET_KEY')
            verify_url = f"https://api.paychangu.com/verify-payment/{tx_ref}"
            verify_headers = {'Authorization': f'Bearer {paychangu_secret}'}
            verify_resp = requests.get(verify_url, headers=verify_headers, timeout=10)

            if verify_resp.status_code == 200:
                verify_data = verify_resp.json()
                verified_status = (verify_data.get('data') or {}).get('status')

                if verified_status == 'success':
                    order_number = tx_ref.rsplit('-', 1)[0]
                    try:
                        order = Order.objects.get(order_number=order_number)
                        order.payment_status = 'paid'
                        order.status = 'confirmed'
                        order.save()
                        paid = True
                        print(f'[RETURN] Order {order.order_number} confirmed via return page')
                    except Order.DoesNotExist:
                        print(f'[RETURN] Order not found: {order_number}')
        except Exception as e:
            print(f'[RETURN] Verification error: {e}')

    message = (
        "Payment received. You can close this page and return to the FarmDirect MW app."
        if paid
        else "We have not received your payment yet. Return to the FarmDirect MW app to check your order."
    )
    html = (
        "<!doctype html><html><head><meta charset='utf-8'>"
        "<meta name='viewport' content='width=device-width, initial-scale=1'>"
        "<title>FarmDirect MW</title></head>"
        "<body style='font-family:sans-serif;text-align:center;padding:48px 24px'>"
        f"<h2>FarmDirect MW</h2><p>{message}</p></body></html>"
    )
    return HttpResponse(html)