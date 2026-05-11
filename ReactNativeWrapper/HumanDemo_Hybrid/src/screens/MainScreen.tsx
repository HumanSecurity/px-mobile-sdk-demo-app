import React, { useEffect, useState } from 'react';
import {
    View,
    Text,
    ScrollView,
    SafeAreaView,
    StyleSheet,
    TouchableOpacity,
} from 'react-native';
 import { WebView } from 'react-native-webview';
import  ApiManager  from '../services/ApiManager';
import HumanSecurity from '@humansecurity/react-native-sdk';
import {HumanSecurityManager} from '../services/HumanSecurityManager.ts';

const login_url = 'https://sandysbundtcakes.com/app1/login-page.html';
const api_url = 'https://sandysbundtcakes.com/app1';
const web_site = 'https://sandysbundtcakes.com/';

export default function MainScreen() {
    const [apiResponse, setApiResponse] = useState<string | null>(null);
    const [eventLog, setEventLog] = useState<string[]>([]);
    const [loginResponse, setLoginResponse] = useState<string | null>(null);
    console.log('[MainScreen] vid: ', HumanSecurity.vid(HumanSecurityManager.appId));

    // Register event listener
    useEffect(() => {
      const subscription = HumanSecurity.BD.onBotDefenderEvent((event) => {
        console.log(`[HumanSdk] Event received: ${event.event} | AppID: ${event.appId}`);
        setEventLog((prevLog) => {
          const lastEvent = prevLog[prevLog.length - 1];
          if (!lastEvent || !lastEvent.includes(event.event)) {
            return [`Received event: ${event.event}`, ...prevLog];
          }
          return prevLog;
        });
      });

      return () => {
        subscription?.remove?.();
      };
    }, []);

    // Handle Login (API Call via Axios)
    const handleLogin = async () => {
        ApiManager.fetchDataWithAxios(login_url).then((response) => {
            // Optionally, set the user if using account defender:
            // HumanSecurityManager.setUserId('user123');
            setLoginResponse(response.status);
        }, (error) => {
            setLoginResponse(`Login Failed: ${error}`);
        });
    };

    // Handle API Call (via Fetch)
    const handleApiCall = async () => {
        ApiManager.fetchData(api_url).then((response) => {
            setApiResponse(response.status);
        }, (error) => {
            setApiResponse(`API Call Failed: ${error}`);
        });
    };

    return (
        <SafeAreaView style={styles.safeArea}>
            <View style={styles.mainContainer}>
                <ScrollView contentContainerStyle={styles.container}>
                    <Text style={styles.title}>Human Security Integration</Text>

                    {/* 🔹 Login (Axios API Call) */}
                    <TouchableOpacity style={styles.loginButton} onPress={handleLogin}>
                        <Text style={styles.buttonText}>Login</Text>
                    </TouchableOpacity>

                    {loginResponse && (
                        <Text style={styles.response}>Login Response: {loginResponse}</Text>
                    )}

                    {/* 🔹 API Call (Fetch) */}
                    <TouchableOpacity style={styles.apiButton} onPress={handleApiCall}>
                        <Text style={styles.buttonText}>Make API Call</Text>
                    </TouchableOpacity>

                    {apiResponse && (
                        <Text style={styles.response}>API Response: {apiResponse}</Text>
                    )}

                    <Text style={styles.subTitle}>Event Log:</Text>
                    <ScrollView style={styles.eventLog}>
                      {eventLog.map((event, index) => (
                        <Text key={index} style={styles.eventItem}>{event}</Text>
                      ))}
                    </ScrollView>

                    <View style={styles.webviewContainer}>
                        <WebView source={{ uri: web_site }} style={styles.webview} />
                    </View>
                </ScrollView>
            </View>
        </SafeAreaView>
    );
}

// 🔹 Styling
const styles = StyleSheet.create({
    safeArea: {
        flex: 1,
        backgroundColor: '#fff',
    },
    mainContainer: {
        flex: 1,
    },
    container: {
        padding: 16,
        flexGrow: 1,
    },
    title: {
        fontSize: 22,
        fontWeight: 'bold',
        marginBottom: 10,
        textAlign: 'center',
    },
    subTitle: {
        fontSize: 18,
        fontWeight: '600',
        marginTop: 20,
    },
    response: {
        marginTop: 10,
        padding: 10,
        borderWidth: 1,
        borderColor: '#ccc',
        borderRadius: 5,
    },
    eventLog: {
        marginTop: 10,
        maxHeight: 200,
    },
    eventItem: {
        fontSize: 14,
        paddingVertical: 5,
        borderBottomWidth: 1,
        borderBottomColor: '#ddd',
    },
    webviewContainer: {
        height: 400,
        borderTopWidth: 1,
        borderColor: '#ccc',
        marginTop: 20,
    },
    webview: {
        flex: 1,
    },
    loginButton: {
        backgroundColor: '#3498db',
        padding: 12,
        borderRadius: 5,
        alignItems: 'center',
        marginVertical: 10,
    },
    apiButton: {
        backgroundColor: '#2ecc71',
        padding: 12,
        borderRadius: 5,
        alignItems: 'center',
        marginVertical: 10,
    },
    buttonText: {
        color: '#fff',
        fontSize: 16,
        fontWeight: '600',
    },
});

