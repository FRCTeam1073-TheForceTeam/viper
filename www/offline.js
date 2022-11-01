window.addEventListener("load", () => {
    if ("serviceWorker" in navigator) {
        navigator.serviceWorker.register("/offline-service-worker.js").then(function(reg) {
            //console.log('Registration succeeded. Scope is ' + reg.scope)
        })
    }
})