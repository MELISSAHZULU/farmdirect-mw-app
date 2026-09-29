import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'farmdirect.settings')
django.setup()

from users.models import User

phone = '0884803295'
password = 'LexaFarm2025!'

user, created = User.objects.get_or_create(
    phone=phone,
    defaults={
        'first_name': 'Lexa',
        'last_name': 'Tsamwa',
        'role': 'admin',
        'is_active': True,
        'is_staff': True,
        'is_superuser': True,
    }
)

user.set_password(password)
user.is_staff = True
user.is_superuser = True
user.role = 'admin'
user.save()

print(f"{'Created' if created else 'Updated'} admin: {user.phone} / {password}")