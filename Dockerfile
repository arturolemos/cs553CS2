# Use a slim Python base image
FROM python:3.10-slim

# Set the working directory
WORKDIR /opt/app

# Copy the current directory contents into the container
COPY . .

# Install required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Install packages that we need. vim is for helping with debugging
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get upgrade -yq ca-certificates && \
    apt-get install -yq --no-install-recommends \
    prometheus-node-exporter

# Expose only the necessary ports
EXPOSE 7860
EXPOSE 8000
EXPOSE 9100

# Set environment variable for Gradio
ENV GRADIO_SERVER_NAME="0.0.0.0"

# Run the Python application
CMD bash -c "prometheus-node-exporter --web.listen-address=':9100' & python /opt/app/app.py"
