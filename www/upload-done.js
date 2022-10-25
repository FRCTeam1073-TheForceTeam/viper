var redirect = "/"
if (location.hash){
    var keys = location.hash.replace(/^\#/,"").split(/,/)
    for (var i=0; i<keys.length; i++){
        localStorage.removeItem(keys[i])
        redirect = "/event.html#"+keys[i].replace(/_.*/,"")
    }
}
setTimeout(function(){
    location.href = redirect
},3000)
