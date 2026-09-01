#!/bin/bash

# Install dependencies
pip install --upgrade pip
pip install --only-binary :all: Pillow
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --noinput

# Run migrations
python manage.py migrate --noinput