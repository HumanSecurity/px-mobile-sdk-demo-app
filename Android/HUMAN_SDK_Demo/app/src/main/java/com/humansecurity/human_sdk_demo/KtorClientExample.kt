package com.humansecurity.human_sdk_demo

import com.humansecurity.mobile_sdk.HumanSecurity
import com.humansecurity.mobile_sdk.main.HSBotDefenderErrorType
import com.humansecurity.mobile_sdk.main.HSInterceptor
import io.ktor.client.*
import io.ktor.client.call.body
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.request.*
import io.ktor.client.statement.*

object KtorClientExample {

    private val ktorHttpClient: HttpClient = HttpClient(OkHttp) {
        install(HttpTimeout) {
            requestTimeoutMillis = Long.MAX_VALUE
        }
        engine {
//            addInterceptor(MyInterceptor()) // An example of manual integration. Should be added when HSPolicy.automaticInterceptorPolicy.interceptorType is set to `HSAutomaticInterceptorType/none`
            addInterceptor(HSInterceptor()) // When HSPolicy.automaticInterceptorPolicy.interceptorType is set to any value rather than `HSAutomaticInterceptorType/none`. MUST BE THE LAST INTERCEPTOR IN THE CHAIN
        }
    }

    // URL requests

    suspend fun sendLoginRequest(email: String, password: String, ) {
        try {
            val response: HttpResponse = ktorHttpClient.request(APIDataManager.loginUrl) {}
            println("request was finished")
            val responseBody = response.body<String>()
            when (HumanSecurity.BD.errorType(responseBody)) {
                HSBotDefenderErrorType.REQUEST_WAS_BLOCKED -> {
                    println("request was blocked by HUMAN")
                }
                HSBotDefenderErrorType.CHALLENGE_WAS_SOLVED -> {
                    println("request was blocked by HUMAN and user solved the challenge")
                }
                HSBotDefenderErrorType.CHALLENGE_WAS_CANCELLED -> {
                    println("request was blocked by HUMAN and challenge was cancelled")
                }
                else -> {
                    println("unknown error")
                }
            }
        } catch (exception: Exception) {
            println("request was failed. exception: $exception")
        }
    }
}
