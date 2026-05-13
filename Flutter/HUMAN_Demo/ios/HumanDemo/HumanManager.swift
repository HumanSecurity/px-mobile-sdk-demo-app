import Foundation
import Flutter
import HUMAN

class HumanManager {
    
    static let shared = HumanManager()
    
    func start() {
        do {
            let policy = HSPolicy()
            policy.automaticInterceptorPolicy.interceptorType = .none
            policy.doctorAppPolicy.enabled = true
            try HumanSecurity.start(appId: "PXj9y4Q8Em", policy: policy)
        }
        catch {
            print("error: \(error)")
        }
    }
    
    func setupChannel(with controller: FlutterViewController) {
        let humanChannel = FlutterMethodChannel(name: "com.humansecurity.demo/human", binaryMessenger: controller.binaryMessenger)
        humanChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "_getHumanHeaders" {
                var json: String?
                do {
                    let headers = HumanSecurity.BD.headersForURLRequest(forAppId: nil)
                    let data = try JSONSerialization.data(withJSONObject: headers)
                    json = String(data: data, encoding: .utf8)
                }
                catch {
                    print("error: \(error)")
                }
                result(json)
            }
            else if call.method == "_handleHumanResponse" {
                if let response = call.arguments as? String, let data = response.data(using: .utf8) {
                    let handled = HumanSecurity.BD.handleBlockResponse(data: data, url: nil) { challengeResult in
                        result(challengeResult == .solved ? "solved" : "cancelled")
                    }
                    if handled {
                        return
                    }
                }
                result("false")
            }
            else {
                result("")
            }
        })
    }
}
