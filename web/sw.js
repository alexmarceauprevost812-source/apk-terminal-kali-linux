// Service worker minimal : ne met RIEN en cache (les réponses de l'IA doivent
// toujours être fraîches). Il existe uniquement pour rendre la page
// installable sur l'écran d'accueil (icône, plein écran) si l'utilisateur le
// souhaite — l'installation reste toujours optionnelle.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
self.addEventListener("fetch", (event) => {
  event.respondWith(fetch(event.request));
});
