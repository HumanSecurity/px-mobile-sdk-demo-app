package com.perimeterx.perimeterx_sdk_demo

import com.perimeterx.mobile_sdk.PerimeterX
import com.perimeterx.mobile_sdk.main.PXInterceptor
import io.ktor.client.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.request.*
import io.ktor.client.statement.*

object KtorClientExample {

    private val ktorHttpClient: HttpClient = HttpClient(OkHttp) {
        engine {
            addInterceptor(MyInterceptor())
            addInterceptor(PXInterceptor()) // MUST BE THE LAST INTERCEPTOR IN THE CHAIN
        }
    }

    // URL requests

    suspend fun sendLoginRequest(email: String, password: String, ) {
        try {
            val response: HttpResponse = ktorHttpClient.request(APIDataManager.loginUrl) {}
            println("request was finished")
        } catch (exception: Exception) {
            println("request was failed. exception: $exception")
            if (exception.message.toString().contains(PerimeterX.INSTANCE.blockedErrorBody())) {
                println("request was blocked")
            }
        }
    }
}
