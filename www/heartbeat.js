"use strict"

var hasHeartbeat = true

setInterval(function(){
	$.ajax({
		async: true,
		beforeSend: function(xhr){
			xhr.overrideMimeType("text/html;charset=UTF-8");
		},
		url: "/heartbeat.html",
		timeout: 5000,
		type: "GET",
		success: function(){
			hasHeartbeat = true
			$('.show-only-when-connected').show()
		},
		error: function(){
			hasHeartbeat = false
			$('.show-only-when-connected').hide()
		}
	})
}, 6*1000) // 6 seconds

window.addEventListener('beforeunload',(event)=>{
	if (!hasHeartbeat){
		event.preventDefault()
		return "You are not connected to the hub. Are you sure?"
	}
})
