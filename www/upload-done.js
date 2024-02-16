"use strict"

if (location.hash){
	var keys = location.hash.replace(/^\#/,"").replace(/\#.*/,"").split(/,/)
	for (var i=0; i<keys.length; i++){
		var key = keys[i]
		if (/^20\d\d/.test(key)){
			var d = localStorage.getItem(key)
			localStorage.removeItem(key)
			if (d) localStorage.setItem(`uploaded_${key}`, d)
		}
	}
}
redirect()

function redirect(){
	var eId = localStorage.getItem('last_event_id'),
	eYear = localStorage.getItem('last_event_year'),
	ePos = localStorage.getItem('last_pos'),
	eType = localStorage.getItem("last_scout_type")
	if (!eId) return delayRedirect(`/`)
	if (!eYear || !eType) return delayRedirect(`/event.html#event=${eId}`)
	if (eType=='scout' && ePos) return delayRedirect(`/${eYear}/scout.html#event=${eId}&pos=${ePos}`)
	delayRedirect(`/${eYear}/${eType}.html#event=${eId}`)
}

function delayRedirect(url){
	setTimeout(function(){
		location.href = url
	},3000)
}
