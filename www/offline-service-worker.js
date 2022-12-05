self.addEventListener('install', (event) => {
	//console.log('Service worker install')
})

self.addEventListener('activate', (event) => {
	// delete old caches
	caches.keys().then(function(names) {
		for (let name of names) if (names != CACHE_NAME) caches.delete(name)
	})
})

self.addEventListener('fetch', (event) => {
	if (
		!CACHE_NAME // Cache not configured
		|| /\.cgi/.test(event.request.url) // Uploads and dynamic data
		|| /\/heartbeat\.html/.test(event.request.url) // Connection test
		|| /\/data\//.test(event.request.url) // Uploaded data
	){
		// Network first, from cache if network failed
		event.respondWith(
			fetch(event.request).then(putCache).catch(() => {
				return caches.match(event.request)
			})
		)
	} else {
		// Cache first, but network if it isn't available
		event.respondWith(
			caches.match(event.request).then((cacheResponse) => {
				// If it is available in cache
				if (cacheResponse){
					return cacheResponse
				}
				// If it needs to be fetched and cached
				return fetch(event.request).then(putCache)
			})
		)
	}

	function putCache(networkResponse){
		// Only put successful responses into cache
		if (networkResponse.status != 200) return networkResponse
		return caches.open(CACHE_NAME).then((cache) => {
			cache.put(event.request, networkResponse.clone())
			return networkResponse
		})
	}
})
