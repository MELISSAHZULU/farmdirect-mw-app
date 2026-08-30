# farmers/views.py
from django.http import JsonResponse

def test_view(request):
    return JsonResponse({'message': 'Farmers API is working!'})