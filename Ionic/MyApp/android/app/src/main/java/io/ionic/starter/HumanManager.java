package io.ionic.starter;

import android.os.Build;
import android.webkit.CookieManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.humansecurity.mobile_sdk.HumanSecurity;
import com.humansecurity.mobile_sdk.main.HSBotDefenderChallengeResult;
import com.humansecurity.mobile_sdk.main.HSBotDefenderDelegate;
import com.humansecurity.mobile_sdk.main.HSHybridChannel;
import com.humansecurity.mobile_sdk.main.HSHybridSyncFailureReason;
import com.humansecurity.mobile_sdk.main.HSHybridSyncState;
import com.humansecurity.mobile_sdk.main.HSHybridSyncStateKind;
import com.humansecurity.mobile_sdk.main.policy.HSAutomaticInterceptorType;
import com.humansecurity.mobile_sdk.main.policy.HSChallengePresentationType;
import com.humansecurity.mobile_sdk.main.policy.HSPolicy;
import com.humansecurity.mobile_sdk.main.policy.HSStorageMethod;

import java.util.HashMap;
import java.util.HashSet;

@CapacitorPlugin(name = "HUMAN")
public class HumanManager extends Plugin {

    private static boolean hasStarted = false;
    private final String humanSolved = "solved";
    private final String humanCancelled = "cancelled";
    private final String humanFalse = "false";

    private final HSBotDefenderDelegate delegate = new HSBotDefenderDelegate() {
        @Override
        public void botDefenderRequestBlocked(String url, String appId) {}

        @Override
        public void botDefenderChallengeSolved(String appId) {}

        @Override
        public void botDefenderChallengeCancelled(String appId) {}

        @Override
        public void botDefenderChallengeRendered(String appId) {}

        @Override
        public void botDefenderChallengeRenderFailed(String appId) {}

        @Override
        public void botDefenderDidUpdateHeaders(HashMap<String, String> headers, String appId) {}

        @Override
        public void onHybridSyncFailed(String appId, String host, HSHybridSyncFailureReason reason, boolean isRecoverable) {
            JSObject payload = new JSObject();
            payload.put("appId", appId);
            payload.put("host", host);
            payload.put("reason", reason.getWireValue());
            payload.put("isRecoverable", isRecoverable);
            notifyListeners("hybridSyncDidFail", payload);
        }

        @Override
        public void onHybridSyncRecovered(String appId, String host, HSHybridChannel channel) {
            JSObject payload = new JSObject();
            payload.put("appId", appId);
            payload.put("host", host);
            payload.put("channel", channel.getWireValue());
            notifyListeners("hybridSyncDidRecover", payload);
        }
    };

    @PluginMethod()
    public void start(PluginCall call) {
        String appId = call.getString("appId");
        if (appId == null || appId.isEmpty()) {
            call.reject("appId is required");
            return;
        }
        boolean external = call.getBoolean("supportExternalWebViews", true);
        if (getActivity() == null) {
            call.reject("NO_ACTIVITY", "Activity is not ready");
            return;
        }
        getActivity().runOnUiThread(() -> {
            try {
                startSDK(appId, call.getArray("webRootDomains", String.class), external);
                call.resolve();
            } catch (Exception exception) {
                call.reject("START_ERROR", exception);
            }
        });
    }

    @PluginMethod()
    public void vid(PluginCall call) {
        JSObject ret = new JSObject();
        String appId = call.getString("appId");
        String value = HumanSecurity.INSTANCE.vid(appId == null || appId.isEmpty() ? null : appId);
        ret.put("value", value == null ? "" : value);
        call.resolve(ret);
    }

    @PluginMethod()
    public void hybridSyncState(PluginCall call) {
        String appId = call.getString("appId");
        HSHybridSyncState state = HumanSecurity.INSTANCE.hybridSyncState(appId == null || appId.isEmpty() ? null : appId);
        call.resolve(stateObject(state));
    }

    @PluginMethod()
    public void setupWebView(PluginCall call) {
        if (getActivity() == null) {
            call.reject("NO_ACTIVITY", "Activity is not ready");
            return;
        }
        getActivity().runOnUiThread(() -> {
            if (!hasStarted) {
                call.reject("NOT_STARTED", "Call start before setupWebView");
                return;
            }
            WebView webView = getBridge().getWebView();
            if (webView == null) {
                call.reject("WEBVIEW_NOT_FOUND", "Capacitor WebView is not ready");
                return;
            }
            HumanSecurity.INSTANCE.setupWebView(webView, hostWebViewClient(webView));
            call.resolve();
        });
    }

    @PluginMethod()
    public void readPxVid(PluginCall call) {
        String url = call.getString("url");
        if (url == null || url.isEmpty()) {
            call.reject("BAD_URL", "url is required");
            return;
        }
        String cookie = CookieManager.getInstance().getCookie(url);
        JSObject ret = new JSObject();
        ret.put("value", pxVid(cookie));
        call.resolve(ret);
    }

    @PluginMethod()
    public void getHttpHeaders(PluginCall call) {
        HashMap headers = HumanSecurity.INSTANCE.getBD().headersForURLRequest(null);
        JSObject ret = new JSObject();
        for (Object key : headers.keySet()) {
            ret.put((String) key, headers.get(key));
        }
        call.resolve(ret);
    }

    @PluginMethod()
    public void handleResponse(PluginCall call) {
        String response = call.getString("value");
        JSObject ret = new JSObject();
        boolean handled = HumanSecurity.INSTANCE.getBD().handleBlockResponse(response, null, result -> {
            ret.put("value", result == HSBotDefenderChallengeResult.SOLVED ? humanSolved : humanCancelled);
            call.resolve(ret);
            return null;
        });
        if (!handled) {
            ret.put("value", humanFalse);
            call.resolve(ret);
        }
    }

    private void startSDK(String appId, java.util.List<String> domains, boolean supportExternalWebViews) throws Exception {
        if (hasStarted) {
            return;
        }
        HSPolicy policy = new HSPolicy();
        policy.setStorageMethod(HSStorageMethod.DATA_STORE);
        policy.getAutomaticInterceptorPolicy().setInterceptorType(HSAutomaticInterceptorType.NONE);
        policy.getDoctorAppPolicy().setEnabled(true);
        policy.setChallengePresentationType(HSChallengePresentationType.CENTER);
        policy.getHybridAppPolicy().setSupportExternalWebViews(supportExternalWebViews);
        if (domains != null && !domains.isEmpty()) {
            policy.getHybridAppPolicy().setWebRootDomains(new HashSet<>(domains), appId);
        }
        HumanSecurity.INSTANCE.start(getActivity().getApplication(), appId, policy);
        HumanSecurity.INSTANCE.getBD().setDelegate(delegate);
        hasStarted = true;
    }

    private static JSObject stateObject(HSHybridSyncState state) {
        String kind;
        switch (state.getKind()) {
            case PENDING:
                kind = "pending";
                break;
            case HEALTHY:
                kind = "healthy";
                break;
            case DEGRADED:
                kind = "degraded";
                break;
            case FAILED:
                kind = "failed";
                break;
            case NOT_APPLICABLE:
            default:
                kind = "notApplicable";
                break;
        }
        JSObject ret = new JSObject();
        ret.put("kind", kind);
        ret.put("isHealthy", state.getKind() == HSHybridSyncStateKind.HEALTHY);
        if (state.getKind() == HSHybridSyncStateKind.HEALTHY || state.getKind() == HSHybridSyncStateKind.DEGRADED) {
            if (state.getChannel() != null) {
                ret.put("channel", state.getChannel().getWireValue());
            }
        }
        if (state.getKind() == HSHybridSyncStateKind.FAILED && state.getReason() != null) {
            ret.put("reason", state.getReason().getWireValue());
        }
        return ret;
    }

    private static WebViewClient hostWebViewClient(WebView webView) {
        WebViewClient current = null;
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                current = webView.getWebViewClient();
            } else {
                java.lang.reflect.Field providerField = WebView.class.getDeclaredField("mProvider");
                providerField.setAccessible(true);
                Object provider = providerField.get(webView);
                if (provider != null) {
                    java.lang.reflect.Method method = provider.getClass().getMethod("getWebViewClient");
                    current = (WebViewClient) method.invoke(provider);
                }
            }
        } catch (Exception ignored) {
        }
        if (current == null) {
            return null;
        }
        if (!"PXWebViewClient".equals(current.getClass().getSimpleName())) {
            return current;
        }
        try {
            java.lang.reflect.Field field = current.getClass().getDeclaredField("originalWebViewClient");
            field.setAccessible(true);
            return (WebViewClient) field.get(current);
        } catch (Exception ignored) {
            return current;
        }
    }

    private static String pxVid(String cookieHeader) {
        if (cookieHeader == null) {
            return "";
        }
        for (String part : cookieHeader.split(";")) {
            String trimmed = part.trim();
            if (trimmed.startsWith("_pxvid=")) {
                return trimmed.substring("_pxvid=".length());
            }
        }
        return "";
    }
}
