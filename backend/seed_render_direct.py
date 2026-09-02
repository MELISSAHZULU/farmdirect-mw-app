# backend/seed_render_direct.py
import os
import sys
import django

# Force Django to use the Render database
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'farmdirect.settings')

# Make sure we're using the Render PostgreSQL
# The DATABASE_URL environment variable should point to Render
print(f"🔗 DATABASE_URL: {os.getenv('DATABASE_URL', 'NOT SET')[:50]}...")

# Setup Django
django.setup()

from products.models import Category, Product
from farmers.models import Farmer
from users.models import User
from django.db import connection

print("=" * 60)
print("🌱 Seeding Render PostgreSQL Database")
print("=" * 60)

# Check current connection
print(f"\n📊 Connected to: {connection.settings_dict['NAME']}")
print(f"🔌 Engine: {connection.settings_dict['ENGINE']}")

# ============ CLEAR EXISTING DATA ============
print("\n🗑️ Clearing existing data...")
Product.objects.all().delete()
Category.objects.all().delete()
Farmer.objects.all().delete()
print("✅ Cleared existing data")

# ============ CREATE CATEGORIES ============
print("\n📂 Creating categories...")
categories = [
    ('Leafy Greens', '🥬'),
    ('Vegetables', '🥕'),
    ('Fruits', '🍎'),
    ('Herbs & Spices', '🌿'),
    ('Root Vegetables', '🥔'),
    ('Peppers & Chillies', '🌶️'),
    ('Other', '🥦'),
    ('Macadamia', '🥜'),
]

for name, icon in categories:
    obj = Category.objects.create(name=name, icon=icon, display_order=0, is_active=True)
    print(f"  ✅ Category: {name}")

print(f"✅ Total categories: {Category.objects.count()}")

# ============ CREATE FARMERS ============
print("\n🧑‍🌾 Creating farmers...")
farmers_data = [
    {'name': 'Ellie', 'contact_phone': '0993171774', 'contact_name': 'Ellie'},
    {'name': 'Tsinde', 'contact_phone': '0881362908', 'contact_name': 'Tsinde'},
    {'name': 'Thom', 'contact_phone': '0994581339', 'contact_name': 'Thom'},
    {'name': 'Rose', 'contact_phone': '0999570858', 'contact_name': 'Rose'},
    {'name': 'Alice', 'contact_phone': '0899717545', 'contact_name': 'Alice'},
]

for data in farmers_data:
    obj = Farmer.objects.create(
        name=data['name'],
        contact_phone=data['contact_phone'],
        contact_name=data['contact_name'],
        is_active=True
    )
    print(f"  ✅ Farmer: {data['name']}")

print(f"✅ Total farmers: {Farmer.objects.count()}")

# Get default farmer
default_farmer = Farmer.objects.first()
print(f"📌 Default farmer: {default_farmer.name}")

# ============ CREATE PRODUCTS ============
print("\n🍅 Creating products...")

category_map = {cat.name: cat for cat in Category.objects.all()}

products_data = [
    # Leafy Greens
    {'name': 'Rape', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Chinese Cabbage', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Spinach', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 1000},
    {'name': 'Lettuce', 'category': 'Leafy Greens', 'unit': 'piece', 'price': 1000},
    {'name': 'Mustard', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Kholowa', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Nkhwani', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    # Vegetables
    {'name': 'Tomatoes', 'category': 'Vegetables', 'unit': 'kg', 'price': 3000},
    {'name': 'Green Beans', 'category': 'Vegetables', 'unit': 'pack', 'price': 1500},
    {'name': 'Irish Potatoes', 'category': 'Vegetables', 'unit': 'kg', 'price': 3500},
    {'name': 'Zucchini', 'category': 'Vegetables', 'unit': 'piece', 'price': 1500},
    {'name': 'Cucumber', 'category': 'Vegetables', 'unit': 'piece', 'price': 1000},
    {'name': 'Eggplants', 'category': 'Vegetables', 'unit': 'piece', 'price': 500},
    {'name': 'Sweet Potato (Orange)', 'category': 'Vegetables', 'unit': 'pack', 'price': 3000},
    {'name': 'Plantain', 'category': 'Vegetables', 'unit': 'finger', 'price': 1000},
    # Fruits
    {'name': 'Oranges', 'category': 'Fruits', 'unit': 'piece', 'price': 3000},
    {'name': 'Pineapple', 'category': 'Fruits', 'unit': 'piece', 'price': 6000},
    {'name': 'Watermelon', 'category': 'Fruits', 'unit': 'piece', 'price': 10000},
    {'name': 'Lemon', 'category': 'Fruits', 'unit': 'piece', 'price': 500},
    # Herbs & Spices
    {'name': 'Basil Thai', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Mint', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Parsley', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Rosemary', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Coriander', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Lemon Grass', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Chillies', 'category': 'Herbs & Spices', 'unit': 'lot', 'price': 1000},
    # Root Vegetables
    {'name': 'Carrot', 'category': 'Root Vegetables', 'unit': 'piece', 'price': 833},
    {'name': 'Ginger', 'category': 'Root Vegetables', 'unit': 'kg', 'price': 12000},
    {'name': 'Garlic', 'category': 'Root Vegetables', 'unit': 'bulb', 'price': 1000},
    {'name': 'Red Onion (Dry)', 'category': 'Root Vegetables', 'unit': 'kg', 'price': 4000},
    {'name': 'White Onion', 'category': 'Root Vegetables', 'unit': 'kg', 'price': 6000},
    # Peppers & Chillies
    {'name': 'Green Peppers', 'category': 'Peppers & Chillies', 'unit': 'piece', 'price': 1000},
    {'name': 'Red Peppers', 'category': 'Peppers & Chillies', 'unit': 'piece', 'price': 3000},
    {'name': 'Yellow Pepper', 'category': 'Peppers & Chillies', 'unit': 'piece', 'price': 3000},
    # Other
    {'name': 'Broccoli', 'category': 'Other', 'unit': 'head', 'price': 5000},
    {'name': 'Cabbage', 'category': 'Other', 'unit': 'head', 'price': 2000},
    {'name': 'Hibiscus', 'category': 'Other', 'unit': 'pack', 'price': 3000},
    # Macadamia
    {'name': 'Macadamia Raw Halves', 'category': 'Macadamia', 'unit': 'pack', 'price': 2500},
    {'name': 'Macadamia Raw Grade B Whole', 'category': 'Macadamia', 'unit': 'pack', 'price': 4000},
    {'name': 'Macadamia Raw Grade A Whole', 'category': 'Macadamia', 'unit': 'pack', 'price': 5000},
]

for data in products_data:
    try:
        category = category_map.get(data['category'])
        if not category:
            print(f"  ❌ Category '{data['category']}' not found")
            continue
        
        obj = Product.objects.create(
            name=data['name'],
            category=category,
            unit=data['unit'],
            price=data['price'],
            farmer=default_farmer,
            is_active=True,
            description=f"Fresh {data['name']} from Malawian farms"
        )
        print(f"  ✅ Product: {data['name']} (K{data['price']}/{data['unit']})")
    except Exception as e:
        print(f"  ❌ Error: {e}")

print(f"✅ Total products: {Product.objects.count()}")

# ============ CREATE USERS ============
print("\n👤 Creating users...")

users_data = [
    {'phone': '0993171774', 'first_name': 'Ellie', 'last_name': 'Admin', 'password': 'EllieFarm2024!', 'area': 'Area 25', 'role': 'admin'},
    {'phone': '0999570858', 'first_name': 'Rose', 'last_name': 'Admin', 'password': 'RoseFarm2024!', 'area': 'Area 25', 'role': 'admin'},
    {'phone': '0994581339', 'first_name': 'Thom', 'last_name': 'Admin', 'password': 'ThomFarm2024!', 'area': 'Area 25', 'role': 'admin'},
    {'phone': '0999924002', 'first_name': 'Melissah', 'last_name': 'Tsamwa', 'password': 'LexaFarm2024', 'area': 'Airwing', 'role': 'customer'},
]

for data in users_data:
    try:
        user = User.objects.create_user(
            phone=data['phone'],
            first_name=data['first_name'],
            last_name=data['last_name'],
            password=data['password'],
            area=data['area']
        )
        user.role = data['role']
        user.is_active = True
        user.save()
        print(f"  ✅ Created user: {data['first_name']} {data['last_name']} ({data['phone']})")
    except Exception as e:
        print(f"  ❌ Error creating user '{data['first_name']}': {e}")

print(f"✅ Total users: {User.objects.count()}")

# ============ SUMMARY ============
print("\n" + "=" * 60)
print("✅ SEEDING COMPLETE!")
print("=" * 60)
print(f"\n📊 Summary:")
print(f"  🏷️ Categories: {Category.objects.count()}")
print(f"  👨‍🌾 Farmers: {Farmer.objects.count()}")
print(f"  🍅 Products: {Product.objects.count()}")
print(f"  👤 Users: {User.objects.count()}")
print("\n🔑 Login Credentials:")
print(f"  - Ellie Admin: 0993171774 / EllieFarm2024!")
print(f"  - Rose Admin: 0999570858 / RoseFarm2024!")
print(f"  - Thom Admin: 0994581339 / ThomFarm2024!")
print(f"  - Melissah Tsamwa: 0999924002 / LexaFarm2024")
print("\n" + "=" * 60)