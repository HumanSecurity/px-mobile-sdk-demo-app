#!/bin/bash
# Clean build artifacts and caches before running after SDK upgrades.
# Run from project root: ./clean.sh

set -e
echo "Cleaning Android..."
cd android
./gradlew clean 2>/dev/null || true
rm -rf .gradle build app/build
cd ..

echo "Cleaning iOS..."
cd ios
rm -rf build Pods Podfile.lock
pod cache clean --all 2>/dev/null || true
cd ..

echo "Cleaning Metro/React Native caches..."
rm -rf node_modules/.cache /tmp/metro-* /tmp/haste-* 2>/dev/null || true

echo "Done. Next: yarn install, then cd ios && pod install, then run."
# Optional: rm -rf ~/Library/Developer/Xcode/DerivedData/HUMAN_Demo*  # uncomment to clear Xcode DerivedData for this app
