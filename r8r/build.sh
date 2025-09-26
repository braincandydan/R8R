#!/bin/bash

set -e  # Exit on any error

echo "Starting Flutter build process..."

# Install Flutter
echo "Installing Flutter..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz | tar -xJ

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "Building Flutter web app..."
flutter build web --release

echo "Build completed successfully!"
ls -la build/web/
