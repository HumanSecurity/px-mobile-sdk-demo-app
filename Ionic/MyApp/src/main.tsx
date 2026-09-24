import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import { Human } from './human';

Human.addListener('hybridSyncDidFail', event => {
  console.log('hybridSyncDidFail', event.reason, event.isRecoverable);
});
Human.addListener('hybridSyncDidRecover', event => {
  console.log('hybridSyncDidRecover', event.channel);
});
Human.start({
  appId: 'PXj9y4Q8Em',
  webRootDomains: ['pxchk.net'],
}).then(() => Human.setupWebView());

const container = document.getElementById('root');
const root = createRoot(container!);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);