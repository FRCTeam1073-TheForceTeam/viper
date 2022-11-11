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
        },
        error: function(){
            hasHeartbeat = false
        }
    })
}, 10000) // 10 seconds (*1000 ms)

window.onbeforeunload = function() {
    if (!hasHeartbeat){
        return "You are not connected to the hub. Are you sure?"
    }
}
