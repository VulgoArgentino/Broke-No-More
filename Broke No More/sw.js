var CACHE_NAME='bnm-v3';
var URLS_TO_CACHE=[
  'dashboard-financas.html',
  'https://cdn.jsdelivr.net/npm/chart.js',
  'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js'
];
self.addEventListener('install',function(e){
  e.waitUntil(caches.open(CACHE_NAME).then(function(cache){return cache.addAll(URLS_TO_CACHE)}));
  self.skipWaiting();
});
self.addEventListener('activate',function(e){
  e.waitUntil(caches.keys().then(function(names){
    return Promise.all(names.filter(function(n){return n!==CACHE_NAME}).map(function(n){return caches.delete(n)}));
  }));
});
self.addEventListener('fetch',function(e){
  e.respondWith(fetch(e.request).catch(function(){return caches.match(e.request)}));
});
