# users/views.py
from django.http import JsonResponse

def test_view(request):
    return JsonResponse({'message': 'Users API is working!'})