$(document).ready(function(){
    $.ajax({
        url:"/event-list.cgi",
        dataType:"text",
        success:function(data){
            var events = data.split(/[\r\n]/)
            var list = $('#events-list')
            var filter = location.hash.replace(/^\#/,"")
            console.log(filter)
            for (var i=0; i<events.length; i++){
                if (events[i] && events[i].startsWith(filter)){
                    var event = events[i]
                    var year = event.substring(0,4)
                    var venue = event.substring(4)
                    list.append($(`<li><a href=/event.html#${event}>${year} ${venue}</a></li>`))
                }
            }
        }
    })
})