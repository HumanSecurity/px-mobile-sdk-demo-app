import Foundation
import Capacitor
import HUMAN
import WebKit

@objc(HumanManagerPlugin)
class HumanManagerPlugin: CAPPlugin, HSBotDefenderDelegate {
    private var hasStarted = false

    @objc func start(_ call: CAPPluginCall) {
        let appId = call.getString("appId") ?? ""
        let domains = call.getArray("webRootDomains", String.self) ?? []
        let external = call.getBool("supportExternalWebViews") ?? true
        if appId.isEmpty {
            call.reject("appId is required")
            return
        }
        DispatchQueue.main.async {
            do {
                try self.startSDK(appId: appId, domains: domains, supportExternalWebViews: external)
                call.resolve()
            } catch {
                call.reject("START_ERROR", nil, error)
            }
        }
    }

    @objc func vid(_ call: CAPPluginCall) {
        let appId = call.getString("appId")
        let resolved = (appId?.isEmpty == false) ? appId : nil
        call.resolve(["value": HumanSecurity.vid(forAppId: resolved) ?? ""])
    }

    @objc func hybridSyncState(_ call: CAPPluginCall) {
        let appId = call.getString("appId")
        let resolved = (appId?.isEmpty == false) ? appId : nil
        let state = HumanSecurity.hybridSyncState(forAppId: resolved)
        call.resolve(Self.dictionary(for: state))
    }

    @objc func setupWebView(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard self.hasStarted else {
                call.reject("NOT_STARTED", "Call start before setupWebView")
                return
            }
            guard let webView = self.bridge?.webView else {
                call.reject("WEBVIEW_NOT_FOUND", "Capacitor WebView is not ready")
                return
            }
            HumanSecurity.setupWebView(webView: webView, navigationDelegate: webView.navigationDelegate)
            call.resolve()
        }
    }

    @objc func readPxVid(_ call: CAPPluginCall) {
        let urlString = call.getString("url") ?? ""
        guard let host = URL(string: urlString)?.host else {
            call.reject("BAD_URL", "url is required")
            return
        }
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let value = cookies.first { cookie in
                cookie.name == "_pxvid" && Self.host(host, matches: cookie.domain)
            }?.value ?? ""
            call.resolve(["value": value])
        }
    }

    @objc func getHttpHeaders(_ call: CAPPluginCall) {
        call.resolve(HumanSecurity.BD.headersForURLRequest(forAppId: nil))
    }

    @objc func handleResponse(_ call: CAPPluginCall) {
        let response = call.getString("value") ?? ""
        let data = response.data(using: .utf8)
        let handled = HumanSecurity.BD.handleBlockResponse(data: data!, url: nil) { challengeResult in
            call.resolve(["value": challengeResult == .solved ? "solved" : "cancelled"])
        }
        if !handled {
            call.resolve(["value": "false"])
        }
    }

    func hybridSyncDidFail(appId: String, host: String, reason: HSHybridSyncFailureReason, isRecoverable: Bool) {
        notifyListeners("hybridSyncDidFail", data: [
            "appId": appId,
            "host": host,
            "reason": reason.wireValue,
            "isRecoverable": isRecoverable
        ])
    }

    func hybridSyncDidRecover(appId: String, host: String, channel: HSHybridChannel) {
        notifyListeners("hybridSyncDidRecover", data: [
            "appId": appId,
            "host": host,
            "channel": channel.wireValue
        ])
    }

    private func startSDK(appId: String, domains: [String], supportExternalWebViews: Bool) throws {
        if hasStarted {
            return
        }
        let policy = HSPolicy()
        policy.automaticInterceptorPolicy.interceptorType = .none
        policy.doctorAppPolicy.enabled = true
        policy.hybridAppPolicy.supportExternalWebViews = supportExternalWebViews
        if !domains.isEmpty {
            policy.hybridAppPolicy.set(webRootDomains: Set(domains), forAppId: appId)
        }
        try HumanSecurity.start(appId: appId, policy: policy)
        HumanSecurity.BD.delegate = self
        hasStarted = true
    }

    private static func host(_ host: String, matches domain: String) -> Bool {
        let normalized = domain.hasPrefix(".") ? String(domain.dropFirst()) : domain
        return host == normalized || host.hasSuffix("." + normalized)
    }

    private static func dictionary(for state: HSHybridSyncState) -> [String: Any] {
        let kind: String
        switch state.kind {
        case .notApplicable: kind = "notApplicable"
        case .pending: kind = "pending"
        case .healthy: kind = "healthy"
        case .degraded: kind = "degraded"
        case .failed: kind = "failed"
        }
        var payload: [String: Any] = [
            "kind": kind,
            "isHealthy": state.kind == .healthy
        ]
        if state.hasChannel, let channel = state.channel {
            payload["channel"] = channel.wireValue
        }
        if state.hasReason, let reason = state.reason {
            payload["reason"] = reason.wireValue
        }
        return payload
    }
}
