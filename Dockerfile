FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY tracker.py .
COPY tee_manager.py .
COPY bep10_extension.py .
COPY startup.sh .

# Copy experiments directory
COPY experiments/ ./experiments/

# Create results directory for experiment outputs with proper permissions
RUN mkdir -p /app/results && \
    chmod 777 /app/results

# Create non-root user
RUN useradd -m -u 1009 appuser && \
    chown -R appuser:appuser /app && \
    chmod +x /app/startup.sh

USER appuser

# Expose tracker port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 0

# Use startup script to run experiments then tracker
CMD ["/app/startup.sh"]
