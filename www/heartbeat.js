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
			$('#hamburger').show()
		},
		error: function(){
			hasHeartbeat = false
			$('#hamburger').hide()
		}
	})
}, 6*1000) // 6 seconds

window.addEventListener('beforeunload',(event) =>{
	if (!hasHeartbeat){
		event.preventDefault()
		return "You are not connected to the hub. Are you sure?"
	}
})
