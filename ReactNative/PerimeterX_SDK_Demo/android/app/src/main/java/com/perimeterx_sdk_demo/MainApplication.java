package com.perimeterx_sdk_demo;

import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.config.ReactFeatureFlags;
import com.facebook.soloader.SoLoader;
import com.perimeterx.mobile_sdk.PerimeterX;
import com.perimeterx.mobile_sdk.PerimeterXDelegate;
import com.perimeterx.mobile_sdk.main.PXPolicy;
import com.perimeterx.mobile_sdk.main.PXPolicyUrlRequestInterceptionType;
import com.perimeterx.mobile_sdk.main.PXStorageMethod;
import com.perimeterx_sdk_demo.newarchitecture.MainApplicationReactNativeHost;
import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.List;

public class MainApplication extends Application implements ReactApplication, PerimeterXDelegate {

    private final ReactNativeHost mReactNativeHost =
            new ReactNativeHost(this) {
                @Override
                public boolean getUseDeveloperSupport() {
                    return BuildConfig.DEBUG;
                }

                @Override
                protected List<ReactPackage> getPackages() {
                    @SuppressWarnings("UnnecessaryLocalVariable")
                    List<ReactPackage> packages = new PackageList(this).getPackages();
                    // Packages that cannot be autolinked yet can be added manually here, for example:
                    // packages.add(new MyReactNativePackage());
                    packages.add(new PerimeterXPackage());
                    return packages;
                }

                @Override
                protected String getJSMainModuleName() {
                    return "index";
                }
            };

    private final ReactNativeHost mNewArchitectureNativeHost =
            new MainApplicationReactNativeHost(this);

    @Override
    public ReactNativeHost getReactNativeHost() {
        if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
            return mNewArchitectureNativeHost;
        } else {
            return mReactNativeHost;
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // If you opted-in for the New Architecture, we enable the TurboModule system
        ReactFeatureFlags.useTurboModules = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
        SoLoader.init(this, /* native exopackage */ false);
        initializeFlipper(this, getReactNativeHost().getReactInstanceManager());

        PXPolicy policy = new PXPolicy();
        policy.setStorageMethod(PXStorageMethod.DATA_STORE);
        policy.setUrlRequestInterceptionType(PXPolicyUrlRequestInterceptionType.NONE);
        policy.setDoctorCheckEnabled(true);
        try {
            PerimeterX.INSTANCE.start(this, "PXj9y4Q8Em", this, policy);
        }
        catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    /**
     * Loads Flipper in React Native templates. Call this in the onCreate method with something like
     * initializeFlipper(this, getReactNativeHost().getReactInstanceManager());
     *
     * @param context
     * @param reactInstanceManager
     */
    private static void initializeFlipper(
            Context context, ReactInstanceManager reactInstanceManager) {
        if (BuildConfig.DEBUG) {
            try {
        /*
         We use reflection here to pick up the class that initializes Flipper,
        since Flipper library is not available in release mode
        */
                Class<?> aClass = Class.forName("com.perimeterx_sdk_demo.ReactNativeFlipper");
                aClass
                        .getMethod("initializeFlipper", Context.class, ReactInstanceManager.class)
                        .invoke(null, context, reactInstanceManager);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
    }

    // PerimeterXDelegate

    @Override
    public void perimeterxChallengeCancelledHandler(@NonNull String s) {
        PerimeterXModule.shared.handleChallengeCancelledEvent();
    }

    @Override
    public void perimeterxChallengeSolvedHandler(@NonNull String s) {
        PerimeterXModule.shared.handleChallengeSolvedEvent();
    }

    @Override
    public void perimeterxHeadersWereUpdated(@NonNull HashMap<String, String> hashMap, @NonNull String s) {
        if (PerimeterXModule.shared != null) {
            PerimeterXModule.shared.handleUpdatedHeaders(hashMap);
        }
    }

    @Override
    public void perimeterxRequestBlockedHandler(@Nullable String s, @NonNull String s1) {

    }

    @Override
    public void perimeterxChallengeRenderFailedHandler(@NonNull String s) {

    }

    @Override
    public void perimeterxChallengeRenderedHandler(@NonNull String s) {

    }
}
