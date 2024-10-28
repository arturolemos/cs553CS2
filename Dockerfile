# Start from a base image with wget
FROM ubuntu:latest

# Set environment variables
ENV PYTHON_VERSION=3.9

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget git && \
    apt-get clean

# Download and install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -u -p /opt/miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Add Miniconda to PATH
ENV PATH=/opt/miniconda/bin:$PATH

# Create the Conda environment
RUN conda create --name myenv python=${PYTHON_VERSION} -y

# Activate the Conda environment
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]

# Clone the repository
RUN git clone https://github.com/arturolemos/cs553CS2.git && cd cs553CS2

# Install dependencies in the Conda environment
WORKDIR /cs553CS2
RUN conda run -n myenv pip install -r requirements.txt

# Make app.py executable and set it as the default command
RUN chmod +x app.py
CMD ["conda", "run", "-n", "myenv", "python3", "app.py"]
