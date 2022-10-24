if (location.hash){
    var keys = location.hash.replace(/^\#/,"").split(/,/)
    for (var i=0; i<keys.length; i++){
        localStorage.removeItem(keys[i])
    }
}
setTimeout(function(){
    location.href = "/"
},5000)
