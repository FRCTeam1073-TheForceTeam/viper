const cacheName = 'cache-v1'

self.addEventListener('install', (event) => {
    console.log('Service worker install')
    event.waitUntil(caches.open(cacheName))
})

self.addEventListener('activate', (event) => {
    console.log('Service worker activate')
    event.waitUntil(caches.open(cacheName))
})

// When there's an incoming fetch request, try and respond with a precached resource, otherwise fall back to the network
self.addEventListener('fetch', (event) => {
    console.log('Service worker fetch: ' + event.request.url)
    if (/\/(scout|admin)\//.test(event.request.url)){
        // Uploading data, these request 
        // have to go through to the server
        // Network only policy
        event.respondWith(fetch(event.request))
    }
    if (/\/20.*\.cgi/.test(event.request.url)){
        // Legacy CGI
        event.respondWith(fetch(event.request))
    }
})
