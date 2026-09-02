#!/bin/bash

echo "=========================================="
echo "FarmDirect MW - Render Build Script"
echo "=========================================="

echo "📦 Installing system dependencies..."
apt-get update && apt-get install -y libpq-dev gcc

echo "📦 Installing Python packages..."
pip install --upgrade pip
pip install -r requirements.txt

echo "🗄️ Running migrations..."
python manage.py migrate --noinput

echo "📁 Loading data..."
if [ -f "data.json" ]; then
    echo "Loading data from data.json..."
    python manage.py loaddata data.json || echo "⚠️ Data load failed, continuing..."
else
    echo "⚠️ data.json not found, skipping..."
fi

echo "📁 Collecting static files..."
python manage.py collectstatic --noinput

echo "=========================================="
echo "✅ Build complete!"
echo "=========================================="