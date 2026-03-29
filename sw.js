const CACHE = 'schedule-v24';
const BASE = self.location.pathname.replace(/\/sw\.js$/i, '') || '';
const asset = (p) => (BASE + (p.startsWith('/') ? p : '/' + p)).replace(/\/\/+/g, '/');

const ASSETS = [
  asset('/'),
  asset('/index.html'),
  asset('/waiters.html'),
  asset('/chefs.html'),
  asset('/cleaning.html'),
  asset('/cashier.html'),
  asset('/hostess.html'),
  asset('/manifest.json'),
  asset('/icon-192.png'),
  asset('/icon-512.png'),
  asset('/assets/logo-tiflisi.pdf')
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c =>
      Promise.all(
        ASSETS.map(url =>
          c.add(url).catch(err => {
            console.warn('[SW] cache skip', url, err && err.message);
            return null;
          })
        )
      )
    )
  );
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  const url = e.request.url;
  if (url.includes('supabase.co') ||
      url.includes('fonts.googleapis.com')) {
    return;
  }

  const req = e.request;
  const isNavigate = req.mode === 'navigate' || req.destination === 'document';

  if (isNavigate) {
    e.respondWith(
      fetch(req, { cache: 'no-store' })
        .then(res => {
          if (res && res.ok) {
            const copy = res.clone();
            caches.open(CACHE).then(c => c.put(req, copy));
          }
          return res;
        })
        .catch(() => caches.match(req))
    );
    return;
  }

  e.respondWith(
    fetch(req)
      .then(res => {
        if (res && res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy));
        }
        return res;
      })
      .catch(() => caches.match(req))
  );
});
