# HUMAN React Native Demo App

A React Native demo app showcasing the HUMAN Bot Defender SDK integration using a manual (legacy) interceptor pattern.

## SDK Versions

| Platform | SDK | Version |
|----------|-----|---------|
| iOS | HUMAN (CocoaPod) | 4.3.4 |
| Android | com.humansecurity:sdk | 4.2.7 |
| React Native | react-native | 0.79.4 |

## What the app does

- Initializes the HUMAN SDK on app launch (in `MainApplication.java` / `AppDelegate.m`)
- Provides a "Login" button that sends a GET request to `https://sample-ios.pxchk.net/login`
- Attaches HUMAN SDK HTTP headers to the request
- Passes the server response to the SDK via `handleResponse`
- If the SDK detects a block response, it presents a CAPTCHA challenge
- Delegate callbacks handle challenge solved/cancelled events

## Prerequisites

- **Node**: >= 18
- **Android**: Android Studio, JDK 17, an emulator or device with USB debugging
- **iOS**: Xcode, CocoaPods (`gem install cocoapods`), an iPhone simulator or device

## Setup

From the project root (`ReactNative/HUMAN_Demo`):

```bash
yarn install
```

### iOS

```bash
cd ios && pod install && cd ..
npx react-native run-ios --simulator "iPhone 16"
```

To list available simulators: `xcrun simctl list devices available`

### Android

Ensure an emulator is running or a device is connected:

```bash
npx react-native run-android
```

## Clean build (recommended after SDK upgrades)

```bash
# JS
rm -rf node_modules
yarn install

# iOS
cd ios
pod cache clean --all
rm -rf Pods Podfile.lock
pod install
cd ..

# Android
cd android
./gradlew clean
cd ..
```

## Key files

| File | Description |
|------|-------------|
| `App.js` | JavaScript UI and request logic |
| `android/app/src/main/java/com/human_demo/MainApplication.java` | Android SDK init + Bot Defender delegate |
| `android/app/src/main/java/com/human_demo/HumanModule.java` | Android native bridge module |
| `android/app/src/main/java/com/human_demo/HumanPackage.java` | Registers HumanModule with React Native |
| `ios/HUMAN_Demo/AppDelegate.m` | iOS SDK init + Bot Defender delegate |
| `ios/HUMAN_Demo/HumanModule.h` / `.m` | iOS native bridge module |

## Troubleshooting

- **iOS pod install fails**: Run `pod cache clean --all` then `pod install` again from `ios/`.
- **Android Gradle fails**: Run `cd android && ./gradlew clean && cd ..` then rebuild.
- **Metro cache issues**: `npx react-native start --reset-cache`
