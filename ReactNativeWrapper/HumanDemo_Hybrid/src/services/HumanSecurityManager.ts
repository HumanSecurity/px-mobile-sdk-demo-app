import HumanSecurity, {
    HSBotDefenderChallengeResult,
} from '@humansecurity/react-native-sdk';

export class HumanSecurityManager {
    static appId = 'PX5730PH91';

    // 🔹 START SDK with hybrid policy
    static async start(): Promise<void> {
        const policy = {
            hybridAppPolicy: {
                webRootDomains: {
                  'PX5730PH91': ['.sandysbundtcakes.com', 'sandysbundtcakes.com', 'www.sandysbundtcakes.com'],
                },
            },
        };

        try {
            await HumanSecurity.startWithAppId(this.appId, policy);
            console.log('[HumanSecurity] SDK started successfully with hybrid policy');
        } catch (error) {
            console.error('[HumanSecurity] Error starting HumanSecurity SDK with policy:', error);
        }
    }

    // 🔹 GET HEADERS (for API calls)
    static async getHeaders(): Promise<Record<string, string>> {
        const headers = await HumanSecurity.BD.headersForURLRequest(this.appId);
        return headers ?? {};
    }

    // 🔹 REGISTER URL for security tracking
    static registerUrl(url: string): void {
        HumanSecurity.AD.registerOutgoingUrlRequest(url, this.appId).then(() => {
            console.log('[HumanSecurity] URL registered:', url);
        }, e => {
            console.error('[HumanSecurity] Failed to register URL:', e);
        });
    }

    // 🔹 CHECK IF RESPONSE CAN BE HANDLED
    static canHandleResponse(responseText: string): boolean {
        return HumanSecurity.BD.canHandleResponse(responseText);
    }

    // 🔹 HANDLE RESPONSE (for challenges)
    static handleResponse(responseText: string): Promise<HSBotDefenderChallengeResult> {
        return HumanSecurity.BD.handleResponse(responseText);
    }

    // 🔹 USER MANAGEMENT
    static setUserId(userId: string | null): void {
        HumanSecurity.AD.setUserId(userId, this.appId).then(() => {
            console.log(userId ? '[HumanSecurity] User ID set' : '[HumanSecurity] User ID cleared');
        }, e => {
            console.error('[HumanSecurity] Failed to set user ID:', e);
        });
    }

    // 🔹 LOGOUT USER
    static logoutUser(): void {
        this.setUserId(null);
    }

    // 🔹 CUSTOM PARAMETERS
    static setCustomParams(parameters: Record<string, string>): void {
        HumanSecurity.BD.setCustomParameters(parameters, this.appId).then(() => {
            console.log('[HumanSecurity] Custom Parameters Set');
        }, e => {
            console.error('[HumanSecurity] Failed to set custom parameters:', e);
        });
    }

    // 🔹 ADDITIONAL DATA
    static setAdditionalData(parameters: Record<string, string>): void {
        HumanSecurity.AD.setAdditionalData(parameters, this.appId).then(() => {
            console.log('[HumanSecurity] Additional Data Set');
        }, e => {
            console.error('[HumanSecurity] Failed to set additional data:', e);
        });
    }
}
