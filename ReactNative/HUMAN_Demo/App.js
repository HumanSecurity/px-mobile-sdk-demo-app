import React from 'react';

import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  Button,
  Alert,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';

const {HumanModule} = NativeModules;

/* Create new native event emitter */
const humanEventEmitter = new NativeEventEmitter(HumanModule);

var humanHeaders = null;

/* Add new headers listener */
const onAddNewHeaders = headers => {
  const obj = JSON.parse(headers);
  console.log(`[HUMAN] got new headers from event: ${JSON.stringify(obj)}`);
  humanHeaders = obj;
};

/* challenge solved listener */
const onChallengeResult = result => {
  if (result === 'solved') {
    console.log('[HUMAN] got challenge solved event');
  } else if (result === 'cancelled') {
    console.log('[HUMAN] got challenge cancelled event');
  }
};

const subscriptionHumanNewHeaders = humanEventEmitter.addListener(
  'HumanNewHeaders',
  onAddNewHeaders,
);

const subscriptionHumanChallengeResult = humanEventEmitter.addListener(
  'HumanChallengeResult',
  onChallengeResult,
);

const App = () => {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? '#222' : '#f5f5f5',
  };

  const sendRequest = async () => {
    if (humanHeaders == null) {
      const raw = await HumanModule.getHTTPHeaders();
      const obj = JSON.parse(raw);
      console.log(`[HUMAN] got headers from getter: ${JSON.stringify(obj)}`);
      await sentRequest(obj);
    } else {
      await sentRequest(humanHeaders);
    }
  };

  async function sentRequest(headers) {
    console.log(`[HUMAN] sending request with headers: ${JSON.stringify(headers)}`);
    try {
      const url = 'https://sample-ios.pxchk.net/login';
      const response = await fetch(url, {
        method: 'GET',
        headers: headers,
      });

      const json = await response.json();
      console.log(`[HUMAN] response status: ${response.status}, body: ${JSON.stringify(json)}`);

      const result = await HumanModule.handleResponse(
        JSON.stringify(json),
        response.status,
        url,
      );

      console.log(`[HUMAN] result: ${result}`);
      if (result === 'solved') {
        console.log('[HUMAN] challenge solved');
        wait(5000);
        await sendRequest();
      } else if (result === 'false') {
        console.log('[HUMAN] request finished successfully');
        Alert.alert('request finished successfully');
      } else if (result === 'cancelled') {
        console.log('[HUMAN] challenge cancelled');
      }
    } catch (error) {
      console.error(error);
    }
  }

  function wait(ms) {
    const start = new Date().getTime();
    let end = start;
    while (end < start + ms) {
      end = new Date().getTime();
    }
  }

  return (
    <SafeAreaView style={[backgroundStyle, styles.container]}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <View style={styles.content}>
        <Text style={styles.title}>HUMAN Demo</Text>
        <Button
          onPress={() => {
            sendRequest();
          }}
          title="Login"
        />
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 30,
  },
});

export default App;
