# Multi-stage Dockerfile for building and serving Flutter web app

# Stage 1: Build the Flutter web app
FROM ubuntu:20.04 AS build

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /flutter
ENV PATH="/flutter/bin:$PATH"

# Verify Flutter installation
RUN flutter --version

# Copy the project files
COPY . /app
WORKDIR /app

# Get dependencies and build the web app
RUN flutter pub get
RUN flutter build web

# Stage 2: Serve the static website with nginx
FROM nginx:alpine

# Copy the built web files from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
# CMD ["nginx", "-g", "daemon off;"]