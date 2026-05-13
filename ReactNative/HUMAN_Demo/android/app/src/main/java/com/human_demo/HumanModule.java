package com.human_demo;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.humansecurity.mobile_sdk.HumanSecurity;
import com.humansecurity.mobile_sdk.main.HSBotDefenderChallengeResult;

import org.json.JSONObject;

import java.util.HashMap;

public class HumanModule extends ReactContextBaseJavaModule {

    static HumanModule shared = null;

    String humanNewHeaders = "HumanNewHeaders";
    String humanChallengeResult = "HumanChallengeResult";
    String humanSolved = "solved";
    String humanCancelled = "cancelled";
    String humanFalse = "false";

    // PX Module

    HumanModule(ReactApplicationContext context) {
        super(context);
    }

    @NonNull
    @Override
    public String getName() {
        return "HumanModule";
    }

    public void handleUpdatedHeaders(HashMap<String, String> headers) {
        if (!this.getReactApplicationContext().hasCatalystInstance()) {
            return;
        }
        JSONObject json = new JSONObject(headers);
        this.getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(humanNewHeaders, json.toString());
    }

    public void handleChallengeSolvedEvent() {
        if (!this.getReactApplicationContext().hasCatalystInstance()) {
            return;
        }
        this.getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(humanChallengeResult, humanSolved);
    }

    public void handleChallengeCancelledEvent() {
        if (!this.getReactApplicationContext().hasCatalystInstance()) {
            return;
        }
        this.getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(humanChallengeResult, humanCancelled);
    }

    @ReactMethod
    public void getHTTPHeaders(Promise promise) {
        JSONObject json = new JSONObject(HumanSecurity.INSTANCE.getBD().headersForURLRequest(null));
        promise.resolve(json.toString());
    }

    @ReactMethod
    public void handleResponse(String response, Integer code, String url, Promise promise) {
        boolean handled = HumanSecurity.INSTANCE.getBD().handleBlockResponse(response, url, result -> {
            promise.resolve(result == HSBotDefenderChallengeResult.SOLVED ? humanSolved : humanCancelled);
            return null;
        });
        if (!handled) {
            promise.resolve(humanFalse);
        }
    }
}
