package com.perimeterx.android_sdk_demo

import com.perimeterx.mobile_sdk.PerimeterX
import com.perimeterx.mobile_sdk.main.PXInterceptor
import okhttp3.OkHttpClient
import okhttp3.Request

object OkHttpClientExample {

    private var okHttpClient: OkHttpClient = OkHttpClient.Builder()
        .addInterceptor(MyInterceptor())
        .addInterceptor(PXInterceptor()) // MUST BE THE LAST INTERCEPTOR IN THE CHAIN
        .build()

    fun sendLoginRequest(email: String, password: String) {
        try {
            val request: Request = Request.Builder().url(APIDataManager.loginUrl).build()
            okHttpClient.newCall(request).execute().use { response ->
                if (!response.isSuccessful) {
                    response.body?.let { body ->
                        if (PerimeterX.isRequestBlockedError(body.string())) {
                            println("request was blocked")
                        }
                    }
                }
                else {
                    println("request was finished")
                }
            }
        } catch (exception: Exception) {
            println("request was failed. exception: $exception")
        }
    }
}
