# Use lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependencies
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY app.py .

# Default port
EXPOSE 5000

# Entrypoint
CMD ["python", "app.py"]
