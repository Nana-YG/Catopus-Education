# Use an official Ubuntu as the base image
FROM ubuntu:latest

# Set the environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package repository and install essential tools
RUN apt-get update && \
    apt-get install -y nano&& \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy website content
COPY ./Content/ /app/Content

# Copy your application files (if any) into the container
# COPY ./your-app /app

# Expose ports (if needed)
# EXPOSE 8080

# Define the default command to run when the container starts
CMD ["/bin/bash"]
