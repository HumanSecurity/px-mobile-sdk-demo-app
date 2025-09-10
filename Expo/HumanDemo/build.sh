#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
echo "Starting build process..."

# Remove existing node modules, lock files, and Pods
echo "Cleaning example project..."
rm -rf node_modules package-lock.json
rm -rf ios/Podfile.lock ios/Pods
npm install --loglevel=error

# Run Expo prebuild
echo "Running Expo prebuild..."
npx expo prebuild

echo "Build process completed successfully!"
