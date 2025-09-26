#!/bin/bash

# Install Flutter
echo "Installing Flutter..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz | tar -xJ

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Check Flutter installation
echo "Checking Flutter installation..."
flutter doctor

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "Building Flutter web app..."
flutter build web

echo "Build completed successfully!"
