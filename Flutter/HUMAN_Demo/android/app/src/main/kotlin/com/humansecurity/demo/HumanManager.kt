package com.perimeterx.perimeterx

import android.app.Application
import com.humansecurity.mobile_sdk.HumanSecurity
import com.humansecurity.mobile_sdk.main.HSBotDefenderChallengeResult
import com.humansecurity.mobile_sdk.main.policy.HSAutomaticInterceptorType
import com.humansecurity.mobile_sdk.main.policy.HSPolicy
import com.humansecurity.mobile_sdk.main.policy.HSStorageMethod
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class HumanManager {

    companion object {

        fun start(application: Application) {
            try {
                val policy = HSPolicy()
                policy.storageMethod = HSStorageMethod.DATA_STORE
                policy.automaticInterceptorPolicy.interceptorType = HSAutomaticInterceptorType.NONE
                policy.doctorAppPolicy.enabled = true
                HumanSecurity.start(application, "PXj9y4Q8Em", policy)
            }
            catch (exception: Exception) {
                println("failed to start. exception: $exception")
            }
        }

        fun handleEvent(call: MethodCall, result: MethodChannel.Result) {
            if (call.method == "_getHumanHeaders") {
                val json = JSONObject(HumanSecurity.BD.headersForURLRequest(null) as Map<*, *>?)
                result.success(json.toString())
            }
            else if (call.method == "_handleHumanResponse") {
                val handled = HumanSecurity.BD.handleBlockResponse(call.arguments!! as String, null) { challengeResult: HSBotDefenderChallengeResult ->
                    result.success(if (challengeResult == HSBotDefenderChallengeResult.SOLVED) "solved" else "cancelled")
                    null
                }
                if (!handled) {
                    result.success("false")
                }
            }
            else {
                result.notImplemented()
            }
        }
    }
}
