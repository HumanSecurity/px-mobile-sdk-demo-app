package com.human_demo;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint;
import com.facebook.react.defaults.DefaultReactNativeHost;
import com.facebook.react.soloader.OpenSourceMergedSoMapping;
import com.facebook.soloader.SoLoader;
import com.humansecurity.mobile_sdk.HumanSecurity;
import com.humansecurity.mobile_sdk.main.HSBotDefenderDelegate;
import com.humansecurity.mobile_sdk.main.policy.HSAutomaticInterceptorType;
import com.humansecurity.mobile_sdk.main.policy.HSPolicy;
import com.humansecurity.mobile_sdk.main.policy.HSStorageMethod;

import java.util.HashMap;
import java.util.List;

public class MainApplication extends Application implements ReactApplication, HSBotDefenderDelegate {

    private final ReactNativeHost mReactNativeHost =
            new DefaultReactNativeHost(this) {
                @Override
                public boolean getUseDeveloperSupport() {
                    return BuildConfig.DEBUG;
                }

                @Override
                protected List<ReactPackage> getPackages() {
                    List<ReactPackage> packages = new PackageList(this).getPackages();
                    packages.add(new HumanPackage());
                    return packages;
                }

                @Override
                protected String getJSMainModuleName() {
                    return "index";
                }

                @Override
                protected boolean isNewArchEnabled() {
                    return BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;
                }

                @Override
                protected Boolean isHermesEnabled() {
                    return BuildConfig.IS_HERMES_ENABLED;
                }
            };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        try {
            SoLoader.init(this, OpenSourceMergedSoMapping.INSTANCE);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
            DefaultNewArchitectureEntryPoint.load();
        }

        HSPolicy policy = new HSPolicy();
        policy.setStorageMethod(HSStorageMethod.DATA_STORE);
        policy.getAutomaticInterceptorPolicy().setInterceptorType(HSAutomaticInterceptorType.NONE);
        policy.getDoctorAppPolicy().setEnabled(true);
        try {
            HumanSecurity.INSTANCE.start(this, "PXj9y4Q8Em", policy);
            HumanSecurity.INSTANCE.getBD().setDelegate(this);
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    // HSBotDefenderDelegate

    @Override
    public void botDefenderDidUpdateHeaders(@NonNull HashMap<String, String> hashMap, @NonNull String s) {
        if (HumanModule.shared != null) {
            HumanModule.shared.handleUpdatedHeaders(hashMap);
        }
    }

    @Override
    public void botDefenderRequestBlocked(@Nullable String s, @NonNull String s1) {
    }

    @Override
    public void botDefenderChallengeSolved(@NonNull String s) {
        HumanModule.shared.handleChallengeSolvedEvent();
    }

    @Override
    public void botDefenderChallengeCancelled(@NonNull String s) {
        HumanModule.shared.handleChallengeCancelledEvent();
    }

    @Override
    public void botDefenderChallengeRendered(@NonNull String s) {
    }

    @Override
    public void botDefenderChallengeRenderFailed(@NonNull String s) {
    }

}
