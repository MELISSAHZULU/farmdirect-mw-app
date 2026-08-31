# farmdirect/urls.py
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def api_home(request):
    return JsonResponse({
        'message': 'Welcome to FarmDirect MW API',
        'version': '1.0.0',
        'status': 'running',
        'endpoints': {
            'admin': '/admin/',
            'auth': '/api/auth/',
            'products': '/api/products/',
            'orders': '/api/orders/',
            'farmers': '/api/farmers/',
        }
    })

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', api_home, name='api_home'),
    path('api/auth/', include('users.urls')),
    path('api/products/', include('products.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/farmers/', include('farmers.urls')),
]