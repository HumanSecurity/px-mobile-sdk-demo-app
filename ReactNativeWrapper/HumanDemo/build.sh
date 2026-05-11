#!/bin/bash

echo "🚀 Starting Full Multi-Platform Clean and Regenerate..."

# 1. Stop Metro and Watchman
echo "Stopping any running Metro servers..."
killall -9 node 2>/dev/null
watchman watch-del-all 2>/dev/null #

# 2. Clean JS Cache
echo "Cleaning Node modules and Yarn cache..."
rm -rf node_modules
rm -rf yarn.lock
yarn cache clean

# 3. Clean Android (Added Section)
echo "Cleaning Android build artifacts..."
rm -rf android/.gradle
rm -rf android/app/build
rm -rf android/build
rm -rf android/generated # New Arch Codegen for Android

# 4. Clean iOS
echo "Cleaning iOS build artifacts and DerivedData..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/build
rm -rf ios/generated # New Arch Codegen for iOS
rm -rf ~/Library/Developer/Xcode/DerivedData/* #

# 5. Reinstall JS Dependencies
echo "Installing JS dependencies..."
yarn install # Re-establishes the link to ../react-native-sdk

# 7. Rebuild iOS Native
echo "Setting up Ruby environment and installing Pods..."
cd ios
bundle config set path 'vendor/bundle' # Prevents Ruby 3.4 permission errors
bundle install
bundle exec pod install # Triggers Codegen
cd ..

echo "✅ Multi-platform clean complete!"
echo "To run iOS: yarn ios"
echo "To run Android: yarn android"