var redirect = "/"
if (location.hash){
    var keys = location.hash.replace(/^\#/,"").split(/,/)
    for (var i=0; i<keys.length; i++){
        var key = keys[i]
        if (/^20\d\d/.test(key)){
            localStorage.removeItem(key)
            redirect = "/event.html#"+key.replace(/_.*/,"")
        }
    }
}
setTimeout(function(){
    location.href = redirect
},3000)
