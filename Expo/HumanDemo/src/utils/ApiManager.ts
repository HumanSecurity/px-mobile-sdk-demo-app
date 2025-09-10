import axios from "axios";
import { HSBotDefenderChallengeResult } from "@humansecurity/expo-mobile-sdk";
import { HumanSecurityManager } from "./HumanSecurityManager";

export class ApiManager {
    static async callApiWithFetch(url: string): Promise<any> {
        try {
            const headers = HumanSecurityManager.getHeaders();
            // When using account defender.
            // HumanSecurityManager.registerUrl(url);

            const response = await fetch(url, {
                method: "GET",
                headers,
            });
            const statusCode = response.status;
            if (statusCode !== 200) {
                const responseText = await response.text();
                if (HumanSecurityManager.canHandleResponse(responseText, statusCode, url)) {
                    const result = await HumanSecurityManager.handleResponse(responseText, statusCode, url);
                    if (result === HSBotDefenderChallengeResult.SOLVED) {
                        console.log("Challenge solved successfully! Retrying request...");
                    } else {
                        console.log("Challenge was cancelled, or failed.");
                    }
                    return { challengeResult: HSBotDefenderChallengeResult[result] };
                } else {
                    console.log("Response cannot be handled by the library.");
                    throw new Error("Unhandled response");
                }
            } else {
                console.log(`API Call Successful with status ${statusCode}`);
                let data;
                const contentType = response.headers.get("content-type") || "";
                if (contentType.includes("application/json")) {
                    data = await response.json();
                } else {
                    data = await response.text();
                }
                return { status: statusCode, data };
            }
        } catch (error) {
            console.error("Error making API call (fetch):", error);
            throw error;
        }
    }

    static async callApiWithAxios(url: string): Promise<any> {
        try {
            const headers = HumanSecurityManager.getHeaders();
            // When using account defender.
            // HumanSecurityManager.registerUrl(url);
            const response = await axios.get(url, { headers });
            console.log(`API Call Successful with response ${response.status}`);
            return { status: response.status, data: response.data };
        } catch (error: any) {
            const statusCode = error.response?.status || 0;
            const responseText = JSON.stringify(error.response?.data) || "No response data";
            console.log(`API Call failed with status: ${statusCode}`);

            if (HumanSecurityManager.canHandleResponse(responseText, statusCode, url)) {
                const result = await HumanSecurityManager.handleResponse(responseText, statusCode, url);
                console.log(`Challenge result: ${HSBotDefenderChallengeResult[result]}`);
                return { challengeResult: HSBotDefenderChallengeResult[result] };
            } else {
                console.error("Error making API call (axios):", error);
                throw error;
            }
        }
    }
}
