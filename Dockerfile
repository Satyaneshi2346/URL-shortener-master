# ---------------------------
# Stage 1 — Build environment
# ---------------------------
FROM python:3.11-slim AS base

# Prevent Python from writing pyc files & using buffered stdout
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies for psycopg2 and other libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy dependency file first for layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy your app code
COPY . .

# ---------------------------
# Stage 2 — Run environment
# ---------------------------
# Expose port Flask runs on
EXPOSE 5000

# Default environment variable (you can override this in cloud)
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV BASE_DOMAIN=http://tinny.local:5000

# Start the app using Gunicorn (production-ready)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
