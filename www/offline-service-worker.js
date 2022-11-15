self.addEventListener('install', (event) => {
	//console.log('Service worker install')
})

self.addEventListener('activate', (event) => {
	// delete old caches
	caches.keys().then(function(names) {
		for (let name of names)
			if (names != CACHE_NAME) caches.delete(name)
	});
})

self.addEventListener('fetch', (event) => {
	//console.log(event.request.url)
	if (!CACHE_NAME){
		// Not configured with a cache
		event.respondWith(fetch(event.request))
	} else if (/\/(scout|admin)\//.test(event.request.url)){
		// Uploading data, these request
		// have to go through to the server
		// Network only policy
		//console.log('From network (scout, admin): ' + event.request.url)
		event.respondWith(fetch(event.request))
	} else if (/\/20.*\.cgi/.test(event.request.url)){
		// Legacy CGI
		//console.log('From network (legacy cgi): ' + event.request.url)
		event.respondWith(fetch(event.request))
	} else if (/\/heartbeat\.html/.test(event.request.url)){
		// Heartbeat connection test
		//console.log('From network (legacy cgi): ' + event.request.url)
		event.respondWith(fetch(event.request))
	} else if (/\.(cgi|csv)/.test(event.request.url)){
		event.respondWith(
			// network first
			fetch(event.request).then((networkResponse) => {
				return caches.open(CACHE_NAME).then((cache) => {
					// to cache after fetching from network
					//console.log('From network to cache (data): ' + event.request.url)
					cache.put(event.request, networkResponse.clone())
					return networkResponse
				})
			}).catch(() => {
				//console.log('From cache (data): ' + event.request.url)
				// from cache if network failed
				return caches.match(event.request)
			})
		)
	} else {
		// Everything else is static files
		// Cache first, but network if it isn't available
		event.respondWith(
			caches.match(event.request).then((cacheResponse) => {
				// If it is available in cache
				if (cacheResponse){
					//console.log('From cache (static): ' + event.request.url)
					return cacheResponse
				}
				// If it needs to be fetched and cached
				return fetch(event.request).then((networkResponse) => {
					//console.log('From network to cache (static): ' + event.request.url)
					return caches.open(CACHE_NAME).then((cache) => {
						cache.put(event.request, networkResponse.clone())
						return networkResponse
					})
				})
			})
		)
	}
})
