window.addEventListener("load", () => {
    if ("serviceWorker" in navigator){
        navigator.serviceWorker.register("/offline-service-worker.cgi").then(function(reg) {
            //console.log('Registration succeeded. Scope is ' + reg.scope)
        })
    }
})

$(document).ready(function(){
    var hamburger = $('<div id=hamburger>☰</div>'),
    mainMenu = $('<div id=mainMenu>'),
    mainMenuBg = $('<div id=mainMenuBg>')
    hamburger.toggleClass("hasUploads", hasUploads())
    $('body').append(hamburger).append(mainMenu).append(mainMenuBg)
    hamburger.click(toggleMainMenu)
    mainMenuBg.click(toggleMainMenu)
    function toggleMainMenu(){
        mainMenu.toggle()
        mainMenuBg.toggle()    
    }
    $.get("/main-menu.html",function(data){
        mainMenu.html(
            data
                .replace(/EVENT_NAME/g, typeof eventName!=='undefined'?eventName:"")
                .replace(/EVENT_ID/g, typeof eventId!=='undefined'?eventId:"")
                .replace(/YEAR/g, typeof eventYear!=='undefined'?eventYear:"")
        )
        mainMenu.find('.dependEvent').toggle(typeof eventName!=='undefined')
        mainMenu.find('.dependUpload').toggle(hasUploads())
    })
})

function hasUploads(){
    for (i in localStorage){
        if (/^20.*_.*_/.test(i)) return true
    }
    return false
}
