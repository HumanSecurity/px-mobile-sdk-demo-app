#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
echo "Starting build process..."

# Remove existing node modules, lock files, and Pods
echo "Cleaning example project..."
rm -rf node_modules package-lock.json
rm -rf ios/Podfile.lock ios/Pods

# Clear Metro and Expo caches
echo "Clearing Metro cache..."
rm -rf .expo
rm -rf "$TMPDIR/metro-*" 2>/dev/null || true
rm -rf "$TMPDIR/haste-map-*" 2>/dev/null || true

# Clear watchman cache (prevents recrawl issues)
echo "Clearing watchman cache..."
watchman watch-del-all 2>/dev/null || true

npm install --loglevel=error

# Run Expo prebuild
echo "Running Expo prebuild..."
npx expo prebuild

echo "Build process completed successfully!"
