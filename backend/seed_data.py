# backend/seed_data.py
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'farmdirect.settings')
django.setup()

from products.models import Category, Product
from farmers.models import Farmer
from users.models import User
from django.contrib.auth import get_user_model

User = get_user_model()

print("=" * 60)
print("🌱 Seeding FarmDirect MW Database")
print("=" * 60)

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
    obj, created = Category.objects.get_or_create(
        name=name,
        defaults={'icon': icon, 'display_order': 0}
    )
    if created:
        print(f"  ✅ Created category: {name} {icon}")
    else:
        print(f"  ⏭️ Category already exists: {name}")

print(f"✅ Total categories: {Category.objects.count()}")

# ============ CREATE FARMERS ============
print("\n🧑‍🌾 Creating farmers...")
farmers_data = [
    {
        'name': 'Ellie',
        'contact_phone': '0993171774',
        'contact_name': 'Ellie',
        'email': 'ellie@farmdirect.mw'
    },
    {
        'name': 'Tsinde',
        'contact_phone': '0881362908',
        'contact_name': 'Tsinde',
        'email': 'tsinde@farmdirect.mw'
    },
    {
        'name': 'Thom',
        'contact_phone': '0994581339',
        'contact_name': 'Thom',
        'email': 'thom@farmdirect.mw'
    },
    {
        'name': 'Rose',
        'contact_phone': '0999570858',
        'contact_name': 'Rose',
        'email': 'rose@farmdirect.mw'
    },
    {
        'name': 'Alice',
        'contact_phone': '0899717545',
        'contact_name': 'Alice',
        'email': 'alice@farmdirect.mw'
    },
]

for data in farmers_data:
    obj, created = Farmer.objects.get_or_create(
        name=data['name'],
        defaults={
            'contact_phone': data['contact_phone'],
            'contact_name': data['contact_name'],
            'email': data['email'],
            'is_active': True
        }
    )
    if created:
        print(f"  ✅ Created farmer: {data['name']}")
    else:
        print(f"  ⏭️ Farmer already exists: {data['name']}")

print(f"✅ Total farmers: {Farmer.objects.count()}")

# ============ CREATE PRODUCTS ============
print("\n🍅 Creating products...")

# Get first farmer as default supplier (Ellie)
default_farmer = Farmer.objects.first()

# Map category names to objects
category_map = {cat.name: cat for cat in Category.objects.all()}

products_data = [
    # Leafy Greens
    {'name': 'Rape', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Chinese Cabbage', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Spinach', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 1000},
    {'name': 'Lettuce', 'category': 'Leafy Greens', 'unit': 'piece', 'price': 1000},
    {'name': 'Kholowa', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Nkhwani', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Mustard', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Chitambe', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Chisoso', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    {'name': 'Bonongwe', 'category': 'Leafy Greens', 'unit': 'bunch', 'price': 700},
    
    # Vegetables
    {'name': 'Tomatoes', 'category': 'Vegetables', 'unit': 'kg', 'price': 3000},
    {'name': 'Green Beans', 'category': 'Vegetables', 'unit': 'pack', 'price': 1500},
    {'name': 'Fresh Beans', 'category': 'Vegetables', 'unit': 'kg', 'price': 10000},
    {'name': 'Peas', 'category': 'Vegetables', 'unit': 'kg', 'price': 15000},
    {'name': 'Irish Potatoes', 'category': 'Vegetables', 'unit': 'kg', 'price': 3500},
    {'name': 'Zucchini', 'category': 'Vegetables', 'unit': 'piece', 'price': 1500},
    {'name': 'Cucumber', 'category': 'Vegetables', 'unit': 'piece', 'price': 1000},
    {'name': 'Eggplants', 'category': 'Vegetables', 'unit': 'piece', 'price': 500},
    {'name': 'Sweet Potato (Orange)', 'category': 'Vegetables', 'unit': 'pack', 'price': 3000},
    {'name': 'Cassava', 'category': 'Vegetables', 'unit': 'piece', 'price': 1000},
    {'name': 'Plantain', 'category': 'Vegetables', 'unit': 'finger', 'price': 1000},
    
    # Fruits
    {'name': 'Oranges', 'category': 'Fruits', 'unit': 'piece', 'price': 3000},
    {'name': 'Pineapple', 'category': 'Fruits', 'unit': 'piece', 'price': 6000},
    {'name': 'Watermelon', 'category': 'Fruits', 'unit': 'piece', 'price': 10000},
    {'name': 'Lemon', 'category': 'Fruits', 'unit': 'piece', 'price': 500},
    {'name': 'Papayas', 'category': 'Fruits', 'unit': 'piece', 'price': 3000},
    
    # Herbs & Spices
    {'name': 'Basil Thai', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Mint', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Parsley', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Rosemary', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Chomoulier', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Coriander', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Dill', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Lemon Grass', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
    {'name': 'Chigwada', 'category': 'Herbs & Spices', 'unit': 'bunch', 'price': 700},
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
            print(f"  ❌ Category '{data['category']}' not found for product '{data['name']}'")
            continue
        
        obj, created = Product.objects.get_or_create(
            name=data['name'],
            defaults={
                'category': category,
                'unit': data['unit'],
                'price': data['price'],
                'farmer': default_farmer,
                'is_active': True,
                'description': f"Fresh {data['name']} from Malawian farms"
            }
        )
        if created:
            print(f"  ✅ Created product: {data['name']} (K{data['price']}/{data['unit']})")
        else:
            print(f"  ⏭️ Product already exists: {data['name']}")
    except Exception as e:
        print(f"  ❌ Error creating product '{data['name']}': {e}")

print(f"✅ Total products: {Product.objects.count()}")

# ============ CREATE USERS ============
print("\n👤 Creating users...")

users_data = [
    {
        'phone': '0993171774',
        'first_name': 'Ellie',
        'last_name': 'Admin',
        'password': 'EllieFarm2024!',
        'area': 'Area 25',
        'role': 'admin'
    },
    {
        'phone': '0999570858',
        'first_name': 'Rose',
        'last_name': 'Admin',
        'password': 'RoseFarm2024!',
        'area': 'Area 25',
        'role': 'admin'
    },
    {
        'phone': '0994581339',
        'first_name': 'Thom',
        'last_name': 'Admin',
        'password': 'ThomFarm2024!',
        'area': 'Area 25',
        'role': 'admin'
    },
    {
        'phone': '0999924002',
        'first_name': 'Melissah',
        'last_name': 'Tsamwa',
        'password': 'LexaFarm2024',
        'area': 'Airwing',
        'role': 'customer'
    },
]

for data in users_data:
    try:
        user, created = User.objects.get_or_create(
            phone=data['phone'],
            defaults={
                'first_name': data['first_name'],
                'last_name': data['last_name'],
                'area': data['area'],
                'role': data['role'],
                'is_active': True
            }
        )
        if created:
            user.set_password(data['password'])
            user.save()
            print(f"  ✅ Created user: {data['first_name']} {data['last_name']} ({data['phone']})")
        else:
            print(f"  ⏭️ User already exists: {data['first_name']} {data['last_name']}")
    except Exception as e:
        print(f"  ❌ Error creating user '{data['first_name']}': {e}")

print(f"✅ Total users: {User.objects.count()}")

# ============ SUMMARY ============
print("\n" + "=" * 60)
print("📊 SEEDING COMPLETE!")
print("=" * 60)
print(f"\n📊 Summary:")
print(f"  🏷️ Categories: {Category.objects.count()}")
print(f"  👨‍🌾 Farmers: {Farmer.objects.count()}")
print(f"  🍅 Products: {Product.objects.count()}")
print(f"  👤 Users: {User.objects.count()}")
print("\n🔑 Admin Users:")
for user in User.objects.filter(role='admin'):
    print(f"  - {user.first_name} {user.last_name} ({user.phone})")
print("\n👤 Regular Users:")
for user in User.objects.filter(role='customer'):
    print(f"  - {user.first_name} {user.last_name} ({user.phone})")
print("\n" + "=" * 60)
print("✅ Database seeded successfully!")
print("=" * 60)