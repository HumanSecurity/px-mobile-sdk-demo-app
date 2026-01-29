import { IonContent, IonHeader, IonPage, IonTitle, IonToolbar } from '@ionic/react';
import * as React from 'react';
import ExploreContainer from '../components/ExploreContainer';
import './Tab1.css';
import { registerPlugin } from '@capacitor/core';


const Tab1: React.FC = () => {
  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Tab 1</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">Tab 1</IonTitle>
          </IonToolbar>
        </IonHeader>
        <ExploreContainer name="Tab 1 page" />
        <div>
          <button type="button" onClick={sendUrlRequest}>
            Click Me
          </button>
        </div>
      </IonContent>
    </IonPage>
  );
};

export interface HumanPlugin {
  getHttpHeaders(): Promise<{ value: string }>;
  handleResponse(response: { value: string }): Promise<{ value: string }>;
}

const Human = registerPlugin<HumanPlugin>('HUMAN');

const sendUrlRequestAndSimulateBlock = async () => {
  const result = await Human.getHttpHeaders()
  const json = JSON.parse(JSON.stringify(result))
  const map = new Map(Object.entries(json))
  console.log(map)

  var xhr = new XMLHttpRequest()
  xhr.addEventListener('load', () => {
    console.log(xhr.responseText)
  })
  xhr.open('GET', 'https://sample-ios.pxchk.net/login')
  for (const [key, value] of map) {
    xhr.setRequestHeader(key, value as string)
  }
  xhr.send()

  const response = '{"vid":"","uuid":"0fcd0e5b-31dc-11ee-a7dd-435757654a74","page":"PCFET0NUWVBFIGh0bWw+CjxodG1sIGxhbmc9ImVuIj4KPGhlYWQ+CiAgICA8bWV0YSBjaGFyc2V0PSJ1dGYtOCI+CiAgICA8bWV0YSBuYW1lPSJ2aWV3cG9ydCIgY29udGVudD0id2lkdGg9ZGV2aWNlLXdpZHRoLCBpbml0aWFsLXNjYWxlPTEiPgogICAgPHRpdGxlPkFjY2VzcyB0byB0aGlzIHBhZ2UgaGFzIGJlZW4gZGVuaWVkLjwvdGl0bGU+CiAgICA8bGluayBocmVmPSJodHRwczovL2ZvbnRzLmdvb2dsZWFwaXMuY29tL2Nzcz9mYW1pbHk9T3BlbitTYW5zOjMwMCIgcmVsPSJzdHlsZXNoZWV0Ij4KICAgIDxzdHlsZT4KICAgICAgICBodG1sLCBib2R5IHsKICAgICAgICAgICAgbWFyZ2luOiAwOwogICAgICAgICAgICBwYWRkaW5nOiAwOwogICAgICAgICAgICBmb250LWZhbWlseTogJ09wZW4gU2FucycsIHNhbnMtc2VyaWY7CiAgICAgICAgICAgIGNvbG9yOiAjMDAwOwogICAgICAgIH0KCiAgICAgICAgYSB7CiAgICAgICAgICAgIGNvbG9yOiAjYzVjNWM1OwogICAgICAgICAgICB0ZXh0LWRlY29yYXRpb246IG5vbmU7CiAgICAgICAgfQoKICAgICAgICAuY29udGFpbmVyIHsKICAgICAgICAgICAgYWxpZ24taXRlbXM6IGNlbnRlcjsKICAgICAgICAgICAgZGlzcGxheTogZmxleDsKICAgICAgICAgICAgZmxleDogMTsKICAgICAgICAgICAganVzdGlmeS1jb250ZW50OiBzcGFjZS1iZXR3ZWVuOwogICAgICAgICAgICBmbGV4LWRpcmVjdGlvbjogY29sdW1uOwogICAgICAgICAgICBoZWlnaHQ6IDEwMCU7CiAgICAgICAgfQoKICAgICAgICAuY29udGFpbmVyID4gZGl2IHsKICAgICAgICAgICAgd2lkdGg6IDEwMCU7CiAgICAgICAgICAgIGRpc3BsYXk6IGZsZXg7CiAgICAgICAgICAgIGp1c3RpZnktY29udGVudDogY2VudGVyOwogICAgICAgIH0KCiAgICAgICAgLmNvbnRhaW5lciA+IGRpdiA+IGRpdiB7CiAgICAgICAgICAgIGRpc3BsYXk6IGZsZXg7CiAgICAgICAgICAgIHdpZHRoOiA4MCU7CiAgICAgICAgfQoKICAgICAgICAuY3VzdG9tZXItbG9nby13cmFwcGVyIHsKICAgICAgICAgICAgcGFkZGluZy10b3A6IDJyZW07CiAgICAgICAgICAgIGZsZXgtZ3JvdzogMDsKICAgICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogI2ZmZjsKICAgICAgICAgICAgdmlzaWJpbGl0eTogaGlkZGVuOwogICAgICAgIH0KCiAgICAgICAgLmN1c3RvbWVyLWxvZ28gewogICAgICAgICAgICBib3JkZXItYm90dG9tOiAxcHggc29saWQgIzAwMDsKICAgICAgICB9CgogICAgICAgIC5jdXN0b21lci1sb2dvID4gaW1nIHsKICAgICAgICAgICAgcGFkZGluZy1ib3R0b206IDFyZW07CiAgICAgICAgICAgIG1heC1oZWlnaHQ6IDUwcHg7CiAgICAgICAgICAgIG1heC13aWR0aDogMTAwJTsKICAgICAgICB9CgogICAgICAgIC5wYWdlLXRpdGxlLXdyYXBwZXIgewogICAgICAgICAgICBmbGV4LWdyb3c6IDI7CiAgICAgICAgfQoKICAgICAgICAucGFnZS10aXRsZSB7CiAgICAgICAgICAgIGZsZXgtZGlyZWN0aW9uOiBjb2x1bW4tcmV2ZXJzZTsKICAgICAgICB9CgogICAgICAgIC5jb250ZW50LXdyYXBwZXIgewogICAgICAgICAgICBmbGV4LWdyb3c6IDU7CiAgICAgICAgfQoKICAgICAgICAuY29udGVudCB7CiAgICAgICAgICAgIGZsZXgtZGlyZWN0aW9uOiBjb2x1bW47CiAgICAgICAgfQoKICAgICAgICAucGFnZS1mb290ZXItd3JhcHBlciB7CiAgICAgICAgICAgIGFsaWduLWl0ZW1zOiBjZW50ZXI7CiAgICAgICAgICAgIGZsZXgtZ3JvdzogMC4yOwogICAgICAgICAgICBiYWNrZ3JvdW5kLWNvbG9yOiAjMDAwOwogICAgICAgICAgICBjb2xvcjogI2M1YzVjNTsKICAgICAgICAgICAgZm9udC1zaXplOiA3MCU7CiAgICAgICAgfQoKICAgICAgICBAbWVkaWEgKG1pbi13aWR0aDogNzY4cHgpIHsKICAgICAgICAgICAgaHRtbCwgYm9keSB7CiAgICAgICAgICAgICAgICBoZWlnaHQ6IDEwMCU7CiAgICAgICAgICAgIH0KICAgICAgICB9CiAgICA8L3N0eWxlPgogICAgPCEtLSBDdXN0b20gQ1NTIC0tPgo8L2hlYWQ+Cgo8Ym9keT4KPHNlY3Rpb24gY2xhc3M9ImNvbnRhaW5lciI+CiAgICA8ZGl2IGNsYXNzPSJjdXN0b21lci1sb2dvLXdyYXBwZXIiPgogICAgICAgIDxkaXYgY2xhc3M9ImN1c3RvbWVyLWxvZ28iPgogICAgICAgICAgICA8aW1nIHNyYz0iIiBhbHQ9IkxvZ28iLz4KICAgICAgICA8L2Rpdj4KICAgIDwvZGl2PgogICAgPGRpdiBjbGFzcz0icGFnZS10aXRsZS13cmFwcGVyIj4KICAgICAgICA8ZGl2IGNsYXNzPSJwYWdlLXRpdGxlIj4KICAgICAgICAgICAgPGgxPlBsZWFzZSB2ZXJpZnkgeW91IGFyZSBhIGh1bWFuPC9oMT4KICAgICAgICA8L2Rpdj4KICAgIDwvZGl2PgogICAgPGRpdiBjbGFzcz0iY29udGVudC13cmFwcGVyIj4KICAgICAgICA8ZGl2IGNsYXNzPSJjb250ZW50Ij4KICAgICAgICAgICAgPGRpdiBpZD0icHgtY2FwdGNoYSI+CiAgICAgICAgICAgIDwvZGl2PgogICAgICAgICAgICA8cD4KICAgICAgICAgICAgICAgIEFjY2VzcyB0byB0aGlzIHBhZ2UgaGFzIGJlZW4gZGVuaWVkIGJlY2F1c2Ugd2UgYmVsaWV2ZSB5b3UgYXJlIHVzaW5nIGF1dG9tYXRpb24gdG9vbHMgdG8gYnJvd3NlIHRoZQogICAgICAgICAgICAgICAgd2Vic2l0ZS4KICAgICAgICAgICAgPC9wPgogICAgICAgICAgICA8cD4KICAgICAgICAgICAgICAgIFRoaXMgbWF5IGhhcHBlbiBhcyBhIHJlc3VsdCBvZiB0aGUgZm9sbG93aW5nOgogICAgICAgICAgICA8L3A+CiAgICAgICAgICAgIDx1bD4KICAgICAgICAgICAgICAgIDxsaT4KICAgICAgICAgICAgICAgICAgICBKYXZhc2NyaXB0IGlzIGRpc2FibGVkIG9yIGJsb2NrZWQgYnkgYW4gZXh0ZW5zaW9uIChhZCBibG9ja2VycyBmb3IgZXhhbXBsZSkKICAgICAgICAgICAgICAgIDwvbGk+CiAgICAgICAgICAgICAgICA8bGk+CiAgICAgICAgICAgICAgICAgICAgWW91ciBicm93c2VyIGRvZXMgbm90IHN1cHBvcnQgY29va2llcwogICAgICAgICAgICAgICAgPC9saT4KICAgICAgICAgICAgPC91bD4KICAgICAgICAgICAgPHA+CiAgICAgICAgICAgICAgICBQbGVhc2UgbWFrZSBzdXJlIHRoYXQgSmF2YXNjcmlwdCBhbmQgY29va2llcyBhcmUgZW5hYmxlZCBvbiB5b3VyIGJyb3dzZXIgYW5kIHRoYXQgeW91IGFyZSBub3QgYmxvY2tpbmcKICAgICAgICAgICAgICAgIHRoZW0gZnJvbSBsb2FkaW5nLgogICAgICAgICAgICA8L3A+CiAgICAgICAgICAgIDxwPgogICAgICAgICAgICAgICAgUmVmZXJlbmNlIElEOiAjMGZjZDBlNWItMzFkYy0xMWVlLWE3ZGQtNDM1NzU3NjU0YTc0CiAgICAgICAgICAgIDwvcD4KICAgICAgICA8L2Rpdj4KICAgIDwvZGl2PgogICAgPGRpdiBjbGFzcz0icGFnZS1mb290ZXItd3JhcHBlciI+CiAgICAgICAgPGRpdiBjbGFzcz0icGFnZS1mb290ZXIiPgogICAgICAgICAgICA8cD4KICAgICAgICAgICAgICAgIFBvd2VyZWQgYnkKICAgICAgICAgICAgICAgIDxhIGhyZWY9Imh0dHBzOi8vd3d3LnBlcmltZXRlcnguY29tL3doeXdhc2libG9ja2VkIj5QZXJpbWV0ZXJYPC9hPgogICAgICAgICAgICAgICAgLCBJbmMuCiAgICAgICAgICAgIDwvcD4KICAgICAgICA8L2Rpdj4KICAgIDwvZGl2Pgo8L3NlY3Rpb24+CjwhLS0gUHggLS0+CjxzY3JpcHQ+CiAgICB3aW5kb3cuX3B4QXBwSWQgPSAnUFhqOXk0UThFbSc7CiAgICB3aW5kb3cuX3B4SnNDbGllbnRTcmMgPSAnLy9jbGllbnQucGVyaW1ldGVyeC5uZXQvUFhqOXk0UThFbS9tYWluLm1pbi5qcyc7CiAgICB3aW5kb3cuX3B4Rmlyc3RQYXJ0eUVuYWJsZWQgPSBmYWxzZTsKICAgIHdpbmRvdy5fcHhWaWQgPSAnJzsKICAgIHdpbmRvdy5fcHhVdWlkID0gJzBmY2QwZTViLTMxZGMtMTFlZS1hN2RkLTQzNTc1NzY1NGE3NCc7CiAgICB3aW5kb3cuX3B4SG9zdFVybCA9ICcvL2NvbGxlY3Rvci1QWGo5eTRROEVtLnBlcmltZXRlcngubmV0JzsKPC9zY3JpcHQ+CjwhLS0gQ2FwdGNoYSAtLT4KPHNjcmlwdD4KICAgIHZhciBzID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnc2NyaXB0Jyk7CiAgICBzLnNyYyA9ICcvL2NhcHRjaGEucGVyaW1ldGVyeC5uZXQvUFhqOXk0UThFbS9jYXB0Y2hhLmpzP2E9YyZtPTEmdT0wZmNkMGU1Yi0zMWRjLTExZWUtYTdkZC00MzU3NTc2NTRhNzQmdj0nOwogICAgdmFyIHAgPSBkb2N1bWVudC5nZXRFbGVtZW50c0J5VGFnTmFtZSgnaGVhZCcpWzBdOwogICAgcC5pbnNlcnRCZWZvcmUocywgbnVsbCk7CiAgICBpZiAoZmFsc2UpIHsKICAgICAgICBzLm9uZXJyb3IgPSBmdW5jdGlvbiAoKSB7CiAgICAgICAgICAgIHMgPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdzY3JpcHQnKTsKICAgICAgICAgICAgdmFyIHN1ZmZpeEluZGV4ID0gJy8vY2FwdGNoYS5wZXJpbWV0ZXJ4Lm5ldC9QWGo5eTRROEVtL2NhcHRjaGEuanM\/YT1jJm09MSZ1PTBmY2QwZTViLTMxZGMtMTFlZS1hN2RkLTQzNTc1NzY1NGE3NCZ2PScuaW5kZXhPZignY2FwdGNoYS5qcycpOwogICAgICAgICAgICB2YXIgdGVtcGVyZWRCbG9ja1NjcmlwdCA9ICcvL2NhcHRjaGEucGVyaW1ldGVyeC5uZXQvUFhqOXk0UThFbS9jYXB0Y2hhLmpzP2E9YyZtPTEmdT0wZmNkMGU1Yi0zMWRjLTExZWUtYTdkZC00MzU3NTc2NTRhNzQmdj0nLnN1YnN0cmluZyhzdWZmaXhJbmRleCk7CiAgICAgICAgICAgIHMuc3JjID0gJy8vY2FwdGNoYS5weC1jZG4ubmV0L1BYajl5NFE4RW0vJyArIHRlbXBlcmVkQmxvY2tTY3JpcHQ7CiAgICAgICAgICAgIHAucGFyZW50Tm9kZS5pbnNlcnRCZWZvcmUocywgcCk7CiAgICAgICAgfTsKICAgIH0KPC9zY3JpcHQ+CjwhLS0gQ3VzdG9tIFNjcmlwdCAtLT4KPC9ib2R5Pgo8L2h0bWw+Cg==","appId":"PXj9y4Q8Em","action":"captcha","collectorUrl":"https:\/\/collector-pxj9y4q8em.perimeterx.net"}'
  const challengeResult = await Human.handleResponse({ value: response })
  console.log("result = ", JSON.parse(JSON.stringify(challengeResult)))
};

const sendUrlRequest = async () => {
  const result = await Human.getHttpHeaders()
  const json = JSON.parse(JSON.stringify(result))
  const map = new Map(Object.entries(json))
  console.log(map)

  var xhr = new XMLHttpRequest()
  xhr.addEventListener('load', async () => {
    const challengeResult = await Human.handleResponse({ value: xhr.responseText })
    console.log("result = ", JSON.parse(JSON.stringify(challengeResult)))
  })
  xhr.open('GET', 'https://sample-ios.pxchk.net/login')
  for (const [key, value] of map) {
    xhr.setRequestHeader(key, value as string)
  }
  xhr.send()
};

export default Tab1;
