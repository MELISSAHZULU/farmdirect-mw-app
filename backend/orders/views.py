# orders/views.py
from django.http import JsonResponse

def test_view(request):
    return JsonResponse({'message': 'Orders API is working!'})