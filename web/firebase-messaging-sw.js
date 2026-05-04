/* eslint-disable no-restricted-globals */
// Required by Firebase Messaging on web. A valid JS service worker file must
// exist at /firebase-messaging-sw.js, otherwise registration fails and the app
// receives HTML (index rewrite) with an unsupported MIME type.

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});
