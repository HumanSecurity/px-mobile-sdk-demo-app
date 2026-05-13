package com.humansecurity.human_sdk_demo

import com.humansecurity.mobile_sdk.HumanSecurity
import com.humansecurity.mobile_sdk.main.HSBotDefenderErrorType
import okhttp3.Interceptor
import okhttp3.Response
import okhttp3.ResponseBody.Companion.toResponseBody

/*
This is an example to how write a c custom interceptor that interacts with the SDK manually.
 */
class MyInterceptor: Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val newRequest = chain.request().newBuilder()

        // When HSPolicy.automaticInterceptorPolicy.interceptorType is set to `HSAutomaticInterceptorType/none` => get HTTP headers from HUMAN and add them to your request //
        val headers = HumanSecurity.BD.headersForURLRequest(null)
        for ((key, value) in headers) {
            newRequest.addHeader(key, value)
        }

        val response = chain.proceed(newRequest.build())
        if (!response.isSuccessful) {
            // The code below is an example to how you can check that the request was blocked. This is not required
            val responseBody = response.body?.string()
            if (responseBody != null) {
                // When HSPolicy.automaticInterceptorPolicy.interceptorType is set to any value rather than `HSAutomaticInterceptorType/none`  => check that the error is "Request blocked by HUMAN" //
                when (HumanSecurity.BD.errorType(responseBody)) {
                    HSBotDefenderErrorType.REQUEST_WAS_BLOCKED -> {
                        println("request was blocked by HUMAN")
                    }
                    else -> {
                        println("unknown error")
                    }
                }

                // When HSPolicy.automaticInterceptorPolicy.interceptorType is set to `HSAutomaticInterceptorType/none` => pass the data and response to HUMAN to handle it //
                val isHandledByPX = HumanSecurity.BD.handleBlockResponse(responseBody, chain.request().url.toString()) { result ->
                    println("challenge result = $result")
                }
                if (isHandledByPX) {
                    println("block response was handled by HUMAN")
                    // Replace the original response with a specific blocked error
                    return response.newBuilder().body(HumanSecurity.BD.errorBody(HSBotDefenderErrorType.REQUEST_WAS_BLOCKED).toResponseBody()).build()
                }

                // Put back the response's body (can be read only once and we just did)
                return response.newBuilder().body(responseBody.toResponseBody()).build()
            }
        }
        return response
    }
}
