import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { HSBotDefenderChallengeResult } from '@humansecurity/react-native-sdk';
import { HumanSecurityManager } from './HumanSecurityManager.ts';

class ApiManager {
    private static instance: AxiosInstance = axios.create({
        timeout: 10000, // 10 seconds timeout
        headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
        },
    });

    public static getInstance(): AxiosInstance {
        return ApiManager.instance;
    }

    /**
     * Makes an API call using Fetch.
     * - Retrieves headers from `HumanSecurityManager.ts`
     * - Registers URL for Account Defender if enabled. (remove if not in use)
     * - Handles Bot Defender challenge if 403 response is received.
     * @param url - API endpoint to call.
     * @returns API response or challenge result.
     */
    public static async fetchData(url: string): Promise<any> {
        try {
            const headers = HumanSecurityManager.getHeaders();

            // If AD is on.
            // HumanSecurityManager.registerUrl(url);

            const response = await fetch(url, { method: 'GET', headers });
            const statusCode = response.status;
            const responseText = await response.text();

            if (statusCode === 200) {
                return { status: statusCode, data: responseText };
            }

            console.log(`[ApiManager] fetchData ${response.status} and text ${responseText}`);
            if (HumanSecurityManager.canHandleResponse(responseText)) {
                const result = await HumanSecurityManager.handleResponse(responseText);
                // If challenge was solved, retry the request.
                return { challengeResult: HSBotDefenderChallengeResult[result] };
            }

            throw new Error(`Unhandled response - Status: ${statusCode}`);
        } catch (error) {
            throw error instanceof Error ? error : new Error('Unknown error occurred');
        }
    }

    /**
     * Makes an API call using Axios.
     * - Retrieves headers from `HumanSecurityManager.ts`
     * - Registers URL for Account Defender if enabled. (remove if not in use)
     * - Handles Bot Defender challenge if 403 response is received.
     * @param url - API endpoint to call.
     * @returns API response or challenge result.
     */
    public static async fetchDataWithAxios(url: string): Promise<any> {
        try {
            const headers = HumanSecurityManager.getHeaders();
            // If AD is on.
            // HumanSecurityManager.registerUrl(url);
            const response: AxiosResponse = await ApiManager.getInstance().get(url, { headers });
            console.log(`[ApiManager] Axios Call Successful - Status: ${response.status}`);

            return { status: response.status, data: response.data };
        } catch (error: any) {
            const statusCode = error.response?.status || 0;
            const responseText = JSON.stringify(error.response?.data) || 'No response data';

            console.log(`[ApiManager] Axios call failed - Status: ${statusCode}`);

            if (HumanSecurityManager.canHandleResponse(responseText)) {
                const result = await HumanSecurityManager.handleResponse(responseText);
                console.log(`[ApiManager] Challenge result: ${HSBotDefenderChallengeResult[result]}`);
                // If challenge was solved, retry the request.
                return { challengeResult: HSBotDefenderChallengeResult[result] };
            } else {
                throw error;
            }
        }
    }
}

export default ApiManager;
