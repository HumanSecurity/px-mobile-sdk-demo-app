import Foundation
import Flutter
import HUMAN

class HumanManager: NSObject, HSBotDefenderDelegate, FlutterStreamHandler {
    static let shared = HumanManager()

    private var hasStarted = false
    private var eventSink: FlutterEventSink?

    func start(appId: String, domains: [String], supportExternalWebViews: Bool) throws {
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

    func setupChannel(with controller: FlutterViewController) {
        let messenger = controller.binaryMessenger
        let humanChannel = FlutterMethodChannel(name: "com.humansecurity.demo/human", binaryMessenger: messenger)
        humanChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
        let events = FlutterEventChannel(name: "com.humansecurity.demo/human_events", binaryMessenger: messenger)
        events.setStreamHandler(self)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    func hybridSyncDidFail(appId: String, host: String, reason: HSHybridSyncFailureReason, isRecoverable: Bool) {
        eventSink?([
            "event": "hybridSyncDidFail",
            "appId": appId,
            "host": host,
            "reason": reason.wireValue,
            "isRecoverable": isRecoverable
        ])
    }

    func hybridSyncDidRecover(appId: String, host: String, channel: HSHybridChannel) {
        eventSink?([
            "event": "hybridSyncDidRecover",
            "appId": appId,
            "host": host,
            "channel": channel.wireValue
        ])
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            let args = call.arguments as? [String: Any]
            let appId = args?["appId"] as? String ?? ""
            let domains = args?["webRootDomains"] as? [String] ?? []
            let external = args?["supportExternalWebViews"] as? Bool ?? true
            if appId.isEmpty {
                result(FlutterError(code: "NO_APP_ID", message: "appId is required", details: nil))
                return
            }
            DispatchQueue.main.async {
                do {
                    try self.start(appId: appId, domains: domains, supportExternalWebViews: external)
                    result(nil)
                } catch {
                    result(FlutterError(code: "START_ERROR", message: "\(error)", details: nil))
                }
            }
        case "vid":
            let args = call.arguments as? [String: Any]
            let appId = args?["appId"] as? String
            result(HumanSecurity.vid(forAppId: appId))
        case "hybridSyncState":
            let args = call.arguments as? [String: Any]
            let appId = args?["appId"] as? String
            let resolved = (appId?.isEmpty == false) ? appId : nil
            result(Self.dictionary(for: HumanSecurity.hybridSyncState(forAppId: resolved)))
        case "setupWebView":
            if !hasStarted {
                result(FlutterError(code: "NOT_STARTED", message: "Call HumanSecurity.start before setupWebView", details: nil))
                return
            }
            result(nil)
        case "_getHumanHeaders":
            var json: String?
            do {
                let headers = HumanSecurity.BD.headersForURLRequest(forAppId: nil)
                let data = try JSONSerialization.data(withJSONObject: headers)
                json = String(data: data, encoding: .utf8)
            } catch {
                print("error: \(error)")
            }
            result(json)
        case "_handleHumanResponse":
            if let response = call.arguments as? String, let data = response.data(using: .utf8) {
                let handled = HumanSecurity.BD.handleBlockResponse(data: data, url: nil) { challengeResult in
                    result(challengeResult == .solved ? "solved" : "cancelled")
                }
                if handled {
                    return
                }
            }
            result("false")
        default:
            result(FlutterMethodNotImplemented)
        }
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
        var channel = ""
        var reason = ""
        if state.hasChannel, let value = state.channel {
            channel = value.wireValue
        }
        if state.hasReason, let value = state.reason {
            reason = value.wireValue
        }
        return [
            "kind": kind,
            "isHealthy": state.isHealthy,
            "channel": channel,
            "reason": reason
        ]
    }
}
