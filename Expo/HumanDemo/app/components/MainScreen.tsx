import React, { useState, useEffect } from "react";
import { View, Button, StyleSheet, Text, ScrollView } from "react-native";
import { HumanSecurity, HS_EVENTS } from "@humansecurity/expo-mobile-sdk";
import { ApiManager }  from "@/src/utils/ApiManager";
// Uncomment the next line if you plan to use the WebView in hybrid mode:
//  import { WebView } from "react-native-webview";

const login_url = "https://sandysbundtcakes.com/app1/login-page.html";
const api_url = "https://sandysbundtcakes.com/app1";

const MainScreen = () => {
    const [apiResult, setApiResult] = useState<string>("");
    const [eventLogs, setEventLogs] = useState<string[]>([]);

    // One-liner formatting function: always replaces underscores and handles camelCase.
    const formatEventName = (eventName: string) =>
        eventName
            .replace(/_/g, " ")
            .replace(/([a-z])([A-Z])/g, "$1 $2")
            .split(" ")
            .map((word) =>
                word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
            )
            .join(" ");

    // Adds a new log entry without duplicates.
    const addEventLog = (log: string) => {
        setEventLogs((prevLogs) =>
            prevLogs.includes(log) ? prevLogs : [...prevLogs, log]
        );
    };

    // Function to handle login using axios-based API call with then/catch syntax.
    const handleLogin = () => {
        ApiManager.callApiWithAxios(login_url)
            .then((result) => {
                if (result.challengeResult) {
                    setApiResult(`Block handled: ${result.challengeResult}`);
                } else {
                    setApiResult(`Success: ${result.status}`);
                    // Optionally, set the user if using account defender:
                    // HumanSecurityManager.setUserId(userId);
                }
            })
            .catch((error: any) => {
                const statusCode = error.response?.status || "unknown";
                setApiResult(`Fail: ${statusCode}`);
            });
    };

    // Function to handle a standalone API call using fetch with then/catch syntax.
    const handleApiCall = () => {
        ApiManager.callApiWithFetch(api_url)
            .then((result) => {
                if (result.challengeResult) {
                    setApiResult(`Block handled: ${result.challengeResult}`);
                } else {
                    setApiResult(`Success: ${result.status}`);
                }
            })
            .catch((error: any) => {
                const statusCode = error.response?.status || "unknown";
                setApiResult(`Fail: ${statusCode}`);
            });
    };

    // Register event listeners for all HS_EVENTS.
    useEffect(() => {
        const subscriptions = Object.values(HS_EVENTS).map((eventName) =>
            HumanSecurity.BD.addListener(eventName, (data: any) => {
                const formattedEvent = formatEventName(eventName);
                addEventLog(formattedEvent);
                console.log(`Event Received: ${eventName} -> ${formattedEvent}`, data);
            })
        );
        return () => subscriptions.forEach((subscription) => subscription.remove());
    }, []);

    return (
        <View style={styles.container}>
            {/* SDK Version */}
            <Text style={styles.versionText}>SDK Version: {HumanSecurity.sdkVersion()}</Text>

            {/* Buttons Container */}
            <View style={styles.buttonContainer}>
                <Button title="Login" onPress={handleLogin} />
                <View style={styles.spacer} />
                <Button title="Make API Call" onPress={handleApiCall} />
            </View>

            {/* API Call Result Box */}
            <View style={styles.resultContainer}>
                <Text>{apiResult}</Text>
            </View>

            {/* Event Logs Box */}
            <View style={styles.eventContainer}>
                <Text style={styles.header}>Event Logs:</Text>
                <ScrollView style={styles.textBox}>
                    {eventLogs.map((log, index) => (
                        <Text key={index} style={styles.logText}>
                            {log}
                        </Text>
                    ))}
                </ScrollView>
            </View>

            {/* WebView Section - Uncomment for hybrid mode usage */}

            {/*<View style={styles.webviewContainer}>*/}
            {/*  <WebView*/}
            {/*    source={{ uri: "https://sandysbundtcakes.com/" }}*/}
            {/*    style={styles.webview}*/}
            {/*  />*/}
            {/*</View>*/}

        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 16,
        paddingTop: 100,
        backgroundColor: "#fff",
    },
    versionText: {
        fontSize: 14,
        color: "#666",
        marginBottom: 20,
        textAlign: "center",
    },
    buttonContainer: {
        marginVertical: 20,
    },
    spacer: {
        marginVertical: 10,
    },
    resultContainer: {
        height: 40,
        justifyContent: "center",
        paddingHorizontal: 10,
        borderWidth: 1,
        borderColor: "#ccc",
        marginBottom: 10,
    },
    eventContainer: {
        height: 150,
        borderWidth: 1,
        borderColor: "#ccc",
        padding: 10,
        marginBottom: 10,
    },
    header: {
        fontWeight: "bold",
        marginBottom: 10,
        fontSize: 16,
    },
    textBox: {
        flex: 1,
    },
    logText: {
        marginBottom: 5,
    },
    webviewContainer: {
        flex: 1,
        borderWidth: 1,
        borderColor: "#ccc",
    },
    webview: {
        flex: 1,
    },
});

export default MainScreen;
