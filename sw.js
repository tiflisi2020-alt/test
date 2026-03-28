const CACHE = 'schedule-v14';
const BASE = self.location.pathname.replace(/\/sw\.js$/i, '') || '';
const asset = (p) => (BASE + (p.startsWith('/') ? p : '/' + p)).replace(/\/{2,}/g, '/');

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
    caches.open(CACHE).then(c => c.addAll(ASSETS))
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
  if(e.request.url.includes('supabase.co') ||
     e.request.url.includes('fonts.googleapis.com')){
    return;
  }
  e.respondWith(
    fetch(e.request)
      .then(res => {
        const clone = res.clone();
        caches.open(CACHE).then(c => c.put(e.request, clone));
        return res;
      })
      .catch(() => caches.match(e.request))
  );
});
