const CACHE = 'schedule-v13';
const ASSETS = [
  '/test/',
  '/test/index.html',
  '/test/waiters.html',
  '/test/chefs.html',
  '/test/cleaning.html',
  '/test/cashier.html',
  '/test/hostess.html',
  '/test/manifest.json',
  '/test/icon-192.png',
  '/test/icon-512.png',
  '/test/assets/logo-tiflisi.pdf'
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
