# orders/urls.py
from django.urls import path
from .views import (
    OrderListView, 
    OrderCreateView, 
    OrderDetailView, 
    OrderCancelView,
    InitializePaymentView,
    payment_webhook,
)

urlpatterns = [
    path('', OrderListView.as_view(), name='order-list'),
    path('create/', OrderCreateView.as_view(), name='order-create'),
    path('<int:id>/', OrderDetailView.as_view(), name='order-detail'),
    path('<int:id>/cancel/', OrderCancelView.as_view(), name='order-cancel'),
    path('initiate-payment/', InitializePaymentView.as_view(), name='initiate-payment'),
    path('webhook/', payment_webhook, name='payment-webhook'),
]