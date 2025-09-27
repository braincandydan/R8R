#!/bin/bash

set -e  # Exit on any error

echo "Starting Flutter build process..."

# Change to Flutter project directory
cd r8r

# Fix git ownership issues for CI/CD environments
git config --global --add safe.directory /vercel/path0/flutter || true
git config --global --add safe.directory $PWD/flutter || true

# Install Flutter
echo "Installing Flutter..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz | tar -xJ

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Configure Flutter for CI/CD
flutter config --no-analytics
flutter precache --web

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

echo "Build completed successfully!"
ls -la build/web/

# Verify output directory exists for Vercel
echo "Verifying output directory structure..."
pwd
ls -la build/
