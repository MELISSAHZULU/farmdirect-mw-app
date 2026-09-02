# backend/check_db.py
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'farmdirect.settings')
django.setup()

from django.db import connection
from products.models import Category, Product
from farmers.models import Farmer
from users.models import User

print("=" * 60)
print("🔍 Checking Database Status")
print("=" * 60)

print(f"\n📊 Database: {connection.settings_dict['NAME']}")
print(f"🔌 Engine: {connection.settings_dict['ENGINE']}")

print("\n📂 Checking tables...")

# Check if tables exist
try:
    print(f"  Categories: {Category.objects.count()}")
except Exception as e:
    print(f"  ❌ Categories table error: {e}")

try:
    print(f"  Farmers: {Farmer.objects.count()}")
except Exception as e:
    print(f"  ❌ Farmers table error: {e}")

try:
    print(f"  Products: {Product.objects.count()}")
except Exception as e:
    print(f"  ❌ Products table error: {e}")

try:
    print(f"  Users: {User.objects.count()}")
except Exception as e:
    print(f"  ❌ Users table error: {e}")

print("\n" + "=" * 60)

# List all tables
print("\n📋 All tables in database:")
with connection.cursor() as cursor:
    cursor.execute("""
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public'
        ORDER BY tablename
    """)
    tables = cursor.fetchall()
    for table in tables:
        print(f"  - {table[0]}")