#!/bin/bash

echo "🚀 Starting Full Multi-Platform Clean and Regenerate..."

# 1. Stop Metro and Watchman
echo "Stopping any running Metro servers..."
killall -9 node 2>/dev/null
watchman watch-del-all 2>/dev/null

# 2. Clean JS Cache
echo "Cleaning Node modules and Yarn cache..."
rm -rf node_modules
rm -rf yarn.lock
yarn cache clean

# 3. Clean Android
echo "Cleaning Android build artifacts..."
if [ -f android/gradlew ]; then
  (cd android && ./gradlew --stop) || true
fi
rm -rf android/.gradle
rm -rf android/app/build
rm -rf android/app/.cxx
rm -rf android/build

# 4. Clean iOS
echo "Cleaning iOS build artifacts and DerivedData..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/build
rm -rf ios/vendor/bundle
rm -rf ~/Library/Developer/Xcode/DerivedData/*HumanDemo*

# 5. Reinstall JS Dependencies (also applies react-native-webview patch via postinstall)
echo "Installing JS dependencies..."
yarn install

# 6. Rebuild iOS Native
echo "Setting up Ruby environment and installing Pods..."
cd ios
bundle install
bundle exec pod install
cd ..

echo "✅ Multi-platform clean complete!"
echo "To run iOS: yarn ios"
echo "To run Android: yarn android"
