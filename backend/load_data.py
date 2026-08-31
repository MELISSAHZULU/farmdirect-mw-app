# load_data.py
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'farmdirect.settings')
django.setup()

from products.models import Category, Product
from farmers.models import Farmer

print("=" * 50)
print("📦 Loading FarmDirect MW Data...")
print("=" * 50)

# ============ CREATE CATEGORIES ============
print("\n📂 Creating categories...")
categories = [
    ('Tomatoes', '🍅'),
    ('Leafy Greens', '🥬'),
    ('Onions', '🧅'),
    ('Peppers', '🌶️'),
    ('Root Veggies', '🥕'),
    ('Herbs', '🌿'),
    ('Other', '🥦'),
]

for i, (name, icon) in enumerate(categories):
    obj, created = Category.objects.get_or_create(
        name=name,
        defaults={'icon': icon, 'display_order': i}
    )
    if created:
        print(f"  ✅ Created category: {name} {icon}")
    else:
        print(f"  ⏭️ Category already exists: {name}")

print(f"✅ Total categories: {Category.objects.count()}")

# ============ CREATE FARMERS ============
print("\n🧑‍🌾 Creating farmers...")
farmers = [
    ('Produhort Investments', '0994581339', 'Thom'),
    ('GreenGold Enterprise', '0881362908', 'Tsinde'),
    ('Rose Farms', '0999570858', 'Rose'),
    ('Isidore Farms', '', ''),
    ('Mr Fresh', '', ''),
]

for name, phone, contact in farmers:
    obj, created = Farmer.objects.get_or_create(
        name=name,
        defaults={'contact_phone': phone, 'contact_name': contact}
    )
    if created:
        print(f"  ✅ Created farmer: {name}")
    else:
        print(f"  ⏭️ Farmer already exists: {name}")

print(f"✅ Total farmers: {Farmer.objects.count()}")

# ============ CREATE PRODUCTS ============
print("\n🍅 Creating products...")
products = [
    ('Fresh Ripe Tomatoes', 'Tomatoes', 'kg', 3000),
    ('Fresh Semi-Ripe Tomatoes', 'Tomatoes', 'kg', 3000),
    ('Tomato Oval', 'Tomatoes', 'kg', 3000),
    ('White Onion', 'Onions', 'kg', 6000),
    ('Red Onion (Dry)', 'Onions', 'kg', 6000),
    ('Rape', 'Leafy Greens', 'bunch', 700),
    ('Chinese Cabbage', 'Leafy Greens', 'bunch', 700),
    ('Spinach', 'Leafy Greens', 'bunch', 1000),
    ('Lettuce', 'Leafy Greens', 'piece', 1000),
    ('Green Peppers', 'Peppers', 'piece', 1000),
    ('Red Pepper', 'Peppers', 'piece', 3000),
    ('Yellow Pepper', 'Peppers', 'piece', 3000),
    ('Carrots', 'Root Veggies', 'piece', 833),
    ('Irish Potatoes', 'Root Veggies', 'kg', 3500),
    ('Ginger', 'Root Veggies', 'kg', 12000),
    ('Garlic', 'Other', 'bulb', 1000),
    ('Broccoli', 'Other', 'head', 4000),
    ('Cucumber', 'Other', 'piece', 1000),
    ('Zucchini', 'Other', 'piece', 1500),
    ('Butternut', 'Other', 'piece', 3500),
]

for name, category_name, unit, price in products:
    try:
        category = Category.objects.get(name=category_name)
        obj, created = Product.objects.get_or_create(
            name=name,
            category=category,
            defaults={
                'unit': unit,
                'price': price,
                'is_active': True
            }
        )
        if created:
            print(f"  ✅ Created product: {name} (K{price}/{unit})")
        else:
            print(f"  ⏭️ Product already exists: {name}")
    except Category.DoesNotExist:
        print(f"  ❌ ERROR: Category '{category_name}' not found for product '{name}'")

print(f"✅ Total products: {Product.objects.count()}")

print("\n" + "=" * 50)
print("🎉 Data loaded successfully!")
print("=" * 50)
print("\n📊 Summary:")
print(f"  🏷️ Categories: {Category.objects.count()}")
print(f"  👨‍🌾 Farmers: {Farmer.objects.count()}")
print(f"  🍅 Products: {Product.objects.count()}")