# Use a slim Python base image
FROM python:3.10-slim

# Set the working directory
WORKDIR /opt/app

# Copy the current directory contents into the container
COPY . .

# Install required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Expose only the necessary ports
EXPOSE 7860
EXPOSE 8000

# Set environment variable for Gradio
ENV GRADIO_SERVER_NAME="0.0.0.0"

# Run the Python application
CMD ["python", "/opt/app/app.py"]
