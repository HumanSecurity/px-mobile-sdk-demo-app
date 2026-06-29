package io.ionic.starter;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.humansecurity.mobile_sdk.HumanSecurity;
import com.humansecurity.mobile_sdk.main.policy.HSChallengePresentationType;
import com.humansecurity.mobile_sdk.main.policy.HSAutomaticInterceptorType;
import com.humansecurity.mobile_sdk.main.policy.HSPolicy;
import com.humansecurity.mobile_sdk.main.policy.HSStorageMethod;

import java.util.HashMap;

public class MainApplication extends Application {

    // Application

    @Override
    public void onCreate() {
        super.onCreate();

        HSPolicy policy = new HSPolicy();
        policy.setStorageMethod(HSStorageMethod.DATA_STORE);
        policy.getAutomaticInterceptorPolicy().setInterceptorType(HSAutomaticInterceptorType.NONE);
        policy.getDoctorAppPolicy().setEnabled(true);
        policy.setChallengePresentationType(HSChallengePresentationType.CENTER);
        try {
            HumanSecurity.INSTANCE.start(this, "PXj9y4Q8Em", policy);
        }
        catch (Exception exception) {
            exception.printStackTrace();
        }
    }
}
