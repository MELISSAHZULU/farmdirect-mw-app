# backend/orders/sms_service.py
import os
import africastalking

africastalking.initialize(
    username=os.getenv('AFRICASTALKING_USERNAME'),
    api_key=os.getenv('AFRICASTALKING_API_KEY')
)

sms = africastalking.SMS


def send_sms(phone_number, message):
    try:
        phone = phone_number.strip()
        if not phone.startswith('+'):
            if phone.startswith('0'):
                phone = '+265' + phone[1:]
            else:
                phone = '+265' + phone
        response = sms.send(message, [phone])
        print(f"[SMS] Sent to {phone}: {response}")
        return {'success': True, 'response': response}
    except Exception as e:
        print(f"[SMS] Failed to send to {phone_number}: {e}")
        return {'error': str(e)}


def send_farmer_order_notification(farmer, order, farmer_items):
    if not farmer.contact_phone:
        print(f"[SMS] No phone for farmer {farmer.name}")
        return None

    lines = []
    for item in farmer_items:
        lines.append(
            f"- {item.product.name}: {item.quantity} {item.product.unit}"
        )
    items_text = "\n".join(lines)

    message = (
        f"FarmDirect MW - New Order\n"
        f"Order: {order.order_number}\n"
        f"Delivery: {order.delivery_date}\n"
        f"Area: {order.delivery_area}\n\n"
        f"Please prepare:\n{items_text}\n\n"
        f"Deliver to Gateway Mall by 8 AM."
    )

    return send_sms(farmer.contact_phone, message)