# **HumanSecurity Expo SDK Example**

**This is an [Expo](https://expo.dev) project that demonstrates how to use the `@humansecurity/expo-mobile-sdk` wrapper. This project serves as an example of how to integrate and work with the wrapper, which provides the interface to interact with the native libraries.**

## **🚀 Get Started**

### **1. Install Dependencies**

**Run the following script to clean old dependencies, install fresh ones, and run Expo prebuild:**

```bash
./build.sh
```

**Or manually:**

```bash
npm install
npx expo prebuild
```

### **2. Build and Run the App**

**To build and run the app on your desired platform, use:**

```bash
npx expo run:android
npx expo run:ios
```

**⚠️ Important: This SDK requires a development build. It will NOT work with Expo Go because the HumanSecurity SDK includes native modules that aren't available in the Expo Go app.**

**Note: Ensure you have the necessary setup for running Expo projects on iOS and Android. For iOS, a Mac with Xcode installed is required.**

### **3. Clean Rebuild (if you encounter issues)**

**If you experience build errors or module resolution issues, perform a clean rebuild:**

```bash
rm -rf node_modules package-lock.json
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle android/app/build
npm install
npx expo prebuild --clean
npx expo run:android   # or npx expo run:ios
```

## **📦 Required Configuration**

The `@humansecurity/expo-mobile-sdk` must be added as a plugin in your `app.json` to properly configure the native Android dependencies (JFrog Maven repository):

```json
{
  "expo": {
    "plugins": [
      "@humansecurity/expo-mobile-sdk"
    ]
  }
}
```

**Note:** The config plugin is available starting from **version 1.0.8 and later**. If you are using an earlier version (1.0.2–1.0.6), do not add the plugin line—simply run `npm install` and `npx expo prebuild`.

This is already configured in this demo project.

## **📌 Example Overview**

**The general wa**y to use the **HumanSecurity SDK** is by calling:

```ts
HumanSecurity.start(appId);
```

However, in this example, we have provided a **`HumanSecurityManager`** to keep all calls to the SDK **organized in one place**. This makes it easier to manage and maintain initialization, API requests, and event handling in a structured way.

We have also included some optional configurations **commented out** so that you can adjust them according to your needs.

### 🔹 Setting Up the SDK

Before using the SDK, ensure you **set your app ID** in `HumanSecurityManager.ts`. The policy is optional and can be adjusted based on your specific needs.

```ts
static appId = "YOUR_APP_ID_HERE";

const policy: HSPolicy = {
    hybridAppPolicy: {
        webRootDomains: {
            "YOUR_APP_ID_HERE": [".yourdomain.com"],
        },
    },
    detectionPolicy: {
        allowTouchDetection: true,
        allowDeviceMotionDetection: true,
    },
};
```

### 🔹 Using `HumanSecurityManager`

This project provides a **`HumanSecurityManager`** to help simplify SDK integration, but using it is **not required**. You are free to modify or bypass it based on your preference.

### 🔹 Standard Mode

To initialize the SDK in the standard way:

```ts
HumanSecurityManager.start();
```

### 🔹 Hybrid Mode (Ensuring Consistency Between Native & WebView Calls)

Hybrid Mode should be used when your app embeds a **WebView** that loads a website protected by HUMAN. Enabling Hybrid Mode allows HUMAN to identify consistency between native API calls and WebView interactions, helping to prevent false-positive security blocks.

If your app does **not** use a WebView or does not interact with a HUMAN-protected site, Hybrid Mode should not be used.

Before calling `startHybrid()`, you need to **configure the policy** and **add the domains** for the hybrid sites within `HumanSecurityManager.ts`.

```ts
HumanSecurityManager.startHybrid();
```

You can also uncomment the WebView section in `MainScreen.tsx` to test this functionality.

### 🔹 Bot Defender & Account Defender

The SDK provides two main security features (make sure to verify which service your account is registered for):

- **Bot Defender (BD):** Protects against automated bot threats by detecting and handling suspicious activities.
- **Account Defender (AD):** Helps mitigate account takeover risks by tracking user activity and behaviors.

If using **Bot Defender**, API requests should include security headers:

```ts
const headers = HumanSecurity.BD.headersForURLRequest(appId);
```

When an API call returns an error, let the HumanSecurity SDK handle the response and present a challenge to the user. You can either `await` the response or use the `.then` syntax to proceed with your flow.

```ts
const canHandle = HumanSecurity.BD.canHandleResponse(responseText, statusCode, url);
if (canHandle) {
    const result = await HumanSecurity.BD.handleResponse(responseText, statusCode, url);
}
```

If using **Account Defender**, you may want to register a user ID after the login:

```ts
HumanSecurity.AD.setUserId(userId, appId);
```

To clear user information upon logout:

```ts
HumanSecurity.AD.setUserId(null, appId);
```

Then, after logging in the user, ensure every API request includes:

```ts
HumanSecurity.AD.registerOutgoingUrlRequest(url, appId);
```

### 🔹 Making Secure API Calls

In the `ApiManager` class, we demonstrate how to implement Bot Defender when making API requests. This includes adding security headers and handling challenges when sending requests using both regular `fetch` and `axios`. When using **axios**, the challenge response is handled in the **catch block** since it comes back as an error, unlike the **fetch** example where the challenge is handled as part of the response. Additionally, when using axios, you should apply `JSON.stringify` to the response text before passing it to the challenge handler.

These two examples are provided to highlight the subtle differences in handling security responses between different request methods. If your implementation uses another request method, it is important to recognize these differences and adapt accordingly.

## 🛠 Customization

### Custom Parameters for Bot Defender & Account Defender

For **Bot Defender (BD)**, you can set custom parameters:

```ts
HumanSecurity.BD.setCustomParameters(parameters, appId);
```

For **Account Defender (AD)**, you can set additional data:

```ts
HumanSecurity.AD.setAdditionalData(parameters, appId);
```

In this example, these functions are wrapped by the `HumanSecurityManager` to centralize and manage SDK interactions efficiently.

---

## 📚 Learn More

For more details, check the official documentation: **[HumanSecurity Expo Integration](https://docs.humansecurity.com/applications-and-accounts/docs/expo-integration)**





