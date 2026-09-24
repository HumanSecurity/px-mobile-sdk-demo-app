package com.perimeterx.perimeterx

import android.app.Application
import android.os.Handler
import android.os.Looper
import com.humansecurity.mobile_sdk.HumanSecurity
import com.humansecurity.mobile_sdk.main.HSBotDefenderChallengeResult
import com.humansecurity.mobile_sdk.main.HSBotDefenderDelegate
import com.humansecurity.mobile_sdk.main.HSHybridChannel
import com.humansecurity.mobile_sdk.main.HSHybridSyncFailureReason
import com.humansecurity.mobile_sdk.main.HSHybridSyncStateKind
import com.humansecurity.mobile_sdk.main.policy.HSAutomaticInterceptorType
import com.humansecurity.mobile_sdk.main.policy.HSChallengePresentationType
import com.humansecurity.mobile_sdk.main.policy.HSPolicy
import com.humansecurity.mobile_sdk.main.policy.HSStorageMethod
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class HumanManager {

    companion object {
        private var hasStarted = false
        private val mainHandler = Handler(Looper.getMainLooper())
        var eventSink: EventChannel.EventSink? = null

        private val delegate = object : HSBotDefenderDelegate {
            override fun botDefenderRequestBlocked(url: String?, appId: String) {}
            override fun botDefenderChallengeSolved(appId: String) {}
            override fun botDefenderChallengeCancelled(appId: String) {}
            override fun botDefenderChallengeRendered(appId: String) {}
            override fun botDefenderChallengeRenderFailed(appId: String) {}
            override fun botDefenderDidUpdateHeaders(headers: HashMap<String, String>, appId: String) {}

            override fun onHybridSyncFailed(
                appId: String,
                host: String,
                reason: HSHybridSyncFailureReason,
                isRecoverable: Boolean
            ) {
                emit(
                    mapOf(
                        "event" to "hybridSyncDidFail",
                        "appId" to appId,
                        "host" to host,
                        "reason" to reason.wireValue,
                        "isRecoverable" to isRecoverable
                    )
                )
            }

            override fun onHybridSyncRecovered(appId: String, host: String, channel: HSHybridChannel) {
                emit(
                    mapOf(
                        "event" to "hybridSyncDidRecover",
                        "appId" to appId,
                        "host" to host,
                        "channel" to channel.wireValue
                    )
                )
            }
        }

        fun handleEvent(application: Application, call: MethodCall, result: MethodChannel.Result) {
            try {
                when (call.method) {
                    "start" -> {
                        val appId = call.argument<String>("appId")
                        if (appId.isNullOrEmpty()) {
                            result.error("NO_APP_ID", "appId is required", null)
                            return
                        }
                        val domains = call.argument<List<String>>("webRootDomains")?.toSet() ?: emptySet()
                        val external = call.argument<Boolean>("supportExternalWebViews") ?: true
                        start(application, appId, domains, external)
                        result.success(null)
                    }
                    "vid" -> {
                        val appId = call.argument<String>("appId")
                        result.success(HumanSecurity.vid(appId))
                    }
                    "hybridSyncState" -> {
                        val appId = call.argument<String>("appId")
                        result.success(stateMap(HumanSecurity.hybridSyncState(appId?.takeIf { it.isNotEmpty() })))
                    }
                    "setupWebView" -> {
                        if (!hasStarted) {
                            result.error("NOT_STARTED", "Call HumanSecurity.start before setupWebView", null)
                            return
                        }
                        result.success(null)
                    }
                    "_getHumanHeaders" -> {
                        val json = JSONObject(HumanSecurity.BD.headersForURLRequest(null) as Map<*, *>?)
                        result.success(json.toString())
                    }
                    "_handleHumanResponse" -> {
                        val handled = HumanSecurity.BD.handleBlockResponse(call.arguments!! as String, null) { challengeResult: HSBotDefenderChallengeResult ->
                            result.success(if (challengeResult == HSBotDefenderChallengeResult.SOLVED) "solved" else "cancelled")
                            null
                        }
                        if (!handled) {
                            result.success("false")
                        }
                    }
                    else -> result.notImplemented()
                }
            } catch (exception: Exception) {
                result.error("HUMAN_ERROR", exception.message, null)
            }
        }

        private fun start(
            application: Application,
            appId: String,
            domains: Set<String>,
            supportExternalWebViews: Boolean
        ) {
            if (hasStarted) {
                return
            }
            val policy = HSPolicy()
            policy.storageMethod = HSStorageMethod.DATA_STORE
            policy.automaticInterceptorPolicy.interceptorType = HSAutomaticInterceptorType.NONE
            policy.doctorAppPolicy.enabled = true
            policy.challengePresentationType = HSChallengePresentationType.CENTER
            policy.hybridAppPolicy.supportExternalWebViews = supportExternalWebViews
            if (domains.isNotEmpty()) {
                policy.hybridAppPolicy.setWebRootDomains(domains, appId)
            }
            HumanSecurity.start(application, appId, policy)
            HumanSecurity.BD.delegate = delegate
            hasStarted = true
        }

        private fun stateMap(state: com.humansecurity.mobile_sdk.main.HSHybridSyncState): Map<String, Any> {
            val kind = when (state.kind) {
                HSHybridSyncStateKind.NOT_APPLICABLE -> "notApplicable"
                HSHybridSyncStateKind.PENDING -> "pending"
                HSHybridSyncStateKind.HEALTHY -> "healthy"
                HSHybridSyncStateKind.DEGRADED -> "degraded"
                HSHybridSyncStateKind.FAILED -> "failed"
            }
            val includeChannel = state.kind == HSHybridSyncStateKind.HEALTHY ||
                state.kind == HSHybridSyncStateKind.DEGRADED
            return mapOf(
                "kind" to kind,
                "isHealthy" to state.isHealthy,
                "channel" to if (includeChannel) state.channel?.wireValue ?: "" else "",
                "reason" to if (state.kind == HSHybridSyncStateKind.FAILED) state.reason?.wireValue ?: "" else ""
            )
        }

        private fun emit(payload: Map<String, Any>) {
            mainHandler.post {
                try {
                    eventSink?.success(payload)
                } catch (_: Exception) {
                }
            }
        }
    }
}
