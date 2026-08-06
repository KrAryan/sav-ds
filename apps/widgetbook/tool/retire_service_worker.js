// Retires the service worker this catalog used to register.
//
// Copied over `build/web/flutter_service_worker.js` after the web build, by
// `.github/workflows/deploy-catalog.yaml`. It cannot live in `web/` — the
// Flutter tool overwrites that path with an empty file when built with
// `--pwa-strategy=none`.
//
// ## Why an empty file is not enough
//
// The catalog used to ship Flutter's service worker. A browser that registered
// it keeps it until told otherwise, and a registered worker re-fetches its own
// script to check for updates. Serving an empty file there does update the
// registration — an empty worker is valid — but it never calls `skipWaiting`,
// so the *old* worker stays in control and keeps serving its cached copy of the
// app until every tab is closed. A reviewer opening the catalog after a deploy
// sees the previous build and reasonably concludes nothing shipped.
//
// This script is the standard retirement pattern: take over immediately, throw
// away the caches, unregister, then reload whatever is open so the visitor
// lands on the current build without knowing any of this happened.
//
// Once no browser holds a registration this is dead weight, but it is a few
// hundred bytes and there is no way to know when that is true. Leave it.

self.addEventListener('install', () => {
  // Do not wait for existing tabs to close before taking over.
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      // Drop every cache the old worker populated.
      const keys = await caches.keys();
      await Promise.all(keys.map((key) => caches.delete(key)));

      // Take control of pages the old worker was serving, then step aside.
      await self.clients.claim();
      await self.registration.unregister();

      // Reload open windows so they pick up the real, uncached app.
      const clients = await self.clients.matchAll({ type: 'window' });
      for (const client of clients) {
        client.navigate(client.url);
      }
    })(),
  );
});
