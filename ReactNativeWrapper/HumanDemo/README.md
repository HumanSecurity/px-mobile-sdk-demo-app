# **HumanSecurity React Native SDK Example**

**This is a React Native project that demonstrates how to use the HumanSecurity SDK wrapper. 
This project serves as an example of how to integrate and work with the wrapper, which provides the interface to interact with the native libraries.**

## **🚀 Get Started**

### **1. Install Dependencies**

**Run the following script to clean old dependencies, install fresh ones, and link native dependencies:**

```bash
npm install
```
If you encounter any issues with peer dependencies, you can use the following command to install them:
```bash
npm install --legacy-peer-deps
```
Then run:
```bash
cd ios && pod install
cd ..
```

### **2. Build and Run the App**

**To build and run the app on your desired platform, run from terminal (not from IDE):**

```bash
npm run android
npm run ios
```

> **Note: Ensure you have the necessary setup for running React Native projects on iOS and Android. For iOS, a Mac with Xcode installed is required.**

## **📌 Example Overview**

**The general way to use the HumanSecurity SDK** is by calling:

```ts
HumanSecurity.startWithAppId(appId);
```
However, in this example, we have provided a **`HumanSecurityManager`** to keep all calls to the SDK **organized in one place**. 
This makes it easier to manage and maintain initialization, API requests, and event handling in a structured way.

### 🔹 Bot Defender

The SDK provides two main security features (make sure to verify which service your account is registered for):

- **Bot Defender (BD):** Protects against automated bot threats by detecting and handling suspicious activities.
- **Account Defender (AD):** Helps mitigate account takeover risks by tracking user activity and behaviors.

If using **Bot Defender**, API requests should include security headers:

```ts
const headers = HumanSecurity.BD.headersForURLRequest(appId);
```

When an API call returns an error that the SDK can handle, let the HumanSecurity SDK handle the response and present a challenge to the user. 
You can either `await` the response or use the `.then` syntax to proceed with your flow.

```ts
const canHandle = HumanSecurity.BD.canHandleResponse(responseText);
if (canHandle) {
    const result = await HumanSecurity.BD.handleResponse(responseText);
}
```
### 🔹 Making Secure API Calls

In the `ApiManager` class, we demonstrate how to implement Bot Defender when making API requests. 

This includes adding security headers and handling challenges when sending requests using both regular `fetch` and `axios`. 
When using **axios**, the challenge response is handled in the **catch block** since it comes back as an error,
unlike the **fetch** example where the challenge is handled as part of the response. 

Additionally, when using axios, you should apply `JSON.stringify` to the response text before passing it to the challenge handler.

These two examples are provided to highlight the subtle differences in handling security responses between different request methods. 
If your implementation uses another request method, it is important to recognize these differences and adapt accordingly.

### 🔹 Account Defender

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

## 🛠 Customization

### Custom Parameters for Bot Defender & Account Defender

For **Bot Defender (BD)**, you can set custom parameters (keys like custom_param_1 through custom_param_10):

```ts
HumanSecurity.BD.setCustomParameters(parameters, appId);
```

For **Account Defender (AD)**, you can set additional data:

```ts
HumanSecurity.AD.setAdditionalData(parameters, appId);
```

## ⚠️ Important Note

The Doctor App feature is not supported in this wrapper.
To simulate a challenge, use your own App ID, perform an API call, and block the VID from the HUMAN portal, **[see our official documentation for details](https://docs.humansecurity.com/applications-and-accounts/docs/how-to-test-the-sdk-in-your-app)**.

---

## 📚 Learn More

For more details, check the official documentation: **[HumanSecurity React Native Integration](https://docs.humansecurity.com/applications-and-accounts/docs/react-native-integration-recommended)**

