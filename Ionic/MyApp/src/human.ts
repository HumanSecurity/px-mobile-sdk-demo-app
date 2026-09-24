import { registerPlugin, PluginListenerHandle } from '@capacitor/core';

export type HSHybridSyncFailureReason =
  | 'hostNotCovered'
  | 'channelUnavailable'
  | 'ackTimeout'
  | 'ackMismatch'
  | 'cookieScopeMismatch'
  | 'pxhdConflict'
  | 'payloadRejected';

export type HSHybridChannel = 'cookies' | 'session_storage' | 'events' | 'legacy';

export type HSHybridSyncState = {
  kind: 'notApplicable' | 'pending' | 'healthy' | 'degraded' | 'failed';
  channel?: HSHybridChannel;
  reason?: HSHybridSyncFailureReason;
  isHealthy: boolean;
};

export interface HumanPlugin {
  start(options: {
    appId: string;
    webRootDomains: string[];
    supportExternalWebViews?: boolean;
  }): Promise<void>;
  vid(options: { appId?: string }): Promise<{ value: string }>;
  hybridSyncState(options: { appId?: string }): Promise<HSHybridSyncState>;
  setupWebView(): Promise<void>;
  readPxVid(options: { url: string }): Promise<{ value: string }>;
  getHttpHeaders(): Promise<Record<string, string>>;
  handleResponse(options: { value: string }): Promise<{ value: string }>;
  addListener(
    eventName: 'hybridSyncDidFail',
    listener: (event: {
      appId: string;
      host: string;
      reason: HSHybridSyncFailureReason;
      isRecoverable: boolean;
    }) => void,
  ): Promise<PluginListenerHandle>;
  addListener(
    eventName: 'hybridSyncDidRecover',
    listener: (event: { appId: string; host: string; channel: HSHybridChannel }) => void,
  ): Promise<PluginListenerHandle>;
}

export const Human = registerPlugin<HumanPlugin>('HUMAN');
