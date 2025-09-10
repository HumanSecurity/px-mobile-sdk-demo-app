import {
    HumanSecurity,
    HSBotDefenderChallengeResult,
} from "@humansecurity/expo-mobile-sdk";

export class HumanSecurityManager {
    static appId = "PX5730PH91";

    static start(): void {
        HumanSecurity.startWithAppId(this.appId)
            .then(() => {
                console.log("HumanSecurity SDK started successfully");
            })
            .catch((error: any) => {
                console.error("Error starting HumanSecurity SDK:", error);
            });
    }

    static startHybrid(): void {
        const policy = {
            hybridAppPolicy: {
                webRootDomains: {
                    [this.appId]: [".sandysbundtcakes.com"],
                },
            },
            detectionPolicy: {
                allowTouchDetection: true,
                allowDeviceMotionDetection: true,
            },
        };

        HumanSecurity.startWithAppId(this.appId, policy)
            .then(() => {
                console.log("HumanSecurity SDK started successfully with policy");
            })
            .catch((error: any) => {
                console.error("Error starting HumanSecurity SDK:", error);
            });
    }

    static setUserId(userId: string): void {
        try {
            HumanSecurity.AD.setUserId(userId, this.appId);
            console.log("User ID Set Successfully");
        } catch (error) {
            console.error("Failed to set user ID:", error);
        }
    }

    static logoutUser(): void {
        try {
            HumanSecurity.AD.setUserId(null, this.appId);
            console.log("User ID Cleared Successfully");
        } catch (error) {
            console.error("Failed to clear user ID:", error);
        }
    }

    static setCustomParams(appId: string, parameters: Record<string, string>): void {
        try {
            HumanSecurity.BD.setCustomParameters(parameters, appId);
            console.log("Custom Parameters Set Successfully");
        } catch (error) {
            console.error("Failed to set custom parameters:", error);
        }
    }

    static setAdditionalData(appId: string, parameters: Record<string, string>): void {
        try {
            HumanSecurity.AD.setAdditionalData(parameters, appId);
            console.log("Additional Data Set Successfully");
        } catch (error) {
            console.error("Failed to set additional data:", error);
        }
    }

    static getHeaders(): Record<string, string> {
        return HumanSecurity.BD.headersForURLRequest(this.appId);
    }

    static registerUrl(url: string): void {
        HumanSecurity.AD.registerOutgoingUrlRequest(url, this.appId);
    }

    static canHandleResponse(responseText: string, status: number, url: string): boolean {
        return HumanSecurity.BD.canHandleResponse(responseText, status, url);
    }

    static async handleResponse(responseText: string, status: number, url: string): Promise<HSBotDefenderChallengeResult> {
        return await HumanSecurity.BD.handleResponse(responseText, status, url);
    }
}