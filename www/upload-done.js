"use strict"

if (location.hash){
	var keys = location.hash.replace(/^\#/,"").replace(/\#.*/,"").split(/,/)
	for (var i=0; i<keys.length; i++){
		var key = keys[i]
		if (/^20\d\d/.test(key)){
			localStorage.removeItem(key)
		}
	}
}
redirect()

function redirect(){
	var eId = localStorage.getItem('last_event_id'),
	eYear = localStorage.getItem('last_event_year'),
	ePos = localStorage.getItem('last_pos')
	if (!eId) return delayRedirect(`/`)
	if (eYear && ePos) return delayRedirect(`/${eYear}/scout.html#event=${eId}&pos=${ePos}`)
	delayRedirect(`/event.html#event=${eId}`)
}

function delayRedirect(url){
	setTimeout(function(){
		location.href = url
	},3000)
}
