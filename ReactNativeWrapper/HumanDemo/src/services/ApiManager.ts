import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { HSBotDefenderChallengeResult } from '@humansecurity/react-native-sdk';
import { HumanSecurityManager } from './HumanSecurityManager.ts';

class ApiManager {
    private static instance: AxiosInstance = axios.create({
        timeout: 10000,
        headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
        },
    });

    public static getInstance(): AxiosInstance {
        return ApiManager.instance;
    }

    public static async fetchData(url: string): Promise<any> {
        try {
            const headers = await HumanSecurityManager.getHeaders();
            const response = await fetch(url, { method: 'GET', headers });
            const statusCode = response.status;
            const responseText = await response.text();

            if (statusCode === 200) {
                return { status: statusCode, data: responseText };
            }

            if (HumanSecurityManager.canHandleResponse(responseText)) {
                const result = await HumanSecurityManager.handleResponse(responseText);
                return { challengeResult: HSBotDefenderChallengeResult[result] };
            }

            throw new Error(`Unhandled response - Status: ${statusCode}`);
        } catch (error) {
            throw error instanceof Error ? error : new Error('Unknown error occurred');
        }
    }

    public static async fetchDataWithAxios(url: string): Promise<any> {
        try {
            const headers = await HumanSecurityManager.getHeaders();
            const response: AxiosResponse = await ApiManager.getInstance().get(url, {
                headers,
            });

            return { status: response.status, data: response.data };
        } catch (error: any) {
            const responseText = JSON.stringify(error.response?.data) || 'No response data';

            if (HumanSecurityManager.canHandleResponse(responseText)) {
                const result = await HumanSecurityManager.handleResponse(responseText);
                return { challengeResult: HSBotDefenderChallengeResult[result] };
            }

            throw error;
        }
    }
}

export default ApiManager;
