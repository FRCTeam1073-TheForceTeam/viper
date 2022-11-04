window.addEventListener("load", () => {
    if ("serviceWorker" in navigator){ //&& /^https\:\/\//.test(location.href)) {
        navigator.serviceWorker.register("/offline-service-worker.cgi").then(function(reg) {
            //console.log('Registration succeeded. Scope is ' + reg.scope)
        })
    }
})