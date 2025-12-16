# Use official Python runtime as a parent image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install dependencies (cached if requirements.txt doesn't change)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY src/ .

# Create a non-root user for security (best practice)
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Expose the port
EXPOSE 5000

# Run with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
