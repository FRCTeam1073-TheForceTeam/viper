"use strict"

var redirect = "/"
if (location.hash){
	var keys = location.hash.replace(/^\#/,"").replace(/\#.*/,"").split(/,/)
	for (var i=0; i<keys.length; i++){
		var key = keys[i]
		if (/^20\d\d/.test(key)){
			localStorage.removeItem(key)
			redirect = "/event.html#"+key.replace(/_.*/,"")
		}
	}
	var next = location.hash.replace(/^\#[^\#]*\#/,"")
	if (/^\/[a-z0-9\-\.\/]+\#[a-zA-Z0-9\=\&]+$/.test(next)) redirect = next
}
setTimeout(function(){
	location.href = redirect
},3000)
