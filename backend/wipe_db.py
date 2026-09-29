# backend/wipe_db.py
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'farmdirect.settings')
django.setup()

from django.db import connection

print("Wiping database schema...")

with connection.cursor() as cursor:
    cursor.execute("DROP SCHEMA public CASCADE")
    cursor.execute("CREATE SCHEMA public")
    cursor.execute("GRANT ALL ON SCHEMA public TO public")

print("Database wiped clean")