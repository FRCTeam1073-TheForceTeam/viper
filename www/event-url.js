var eventId = location.hash.replace(/^#/,'')
var eventYear = eventId.replace(/([0-9]{4}).*/,'$1')
var eventVenue = eventId.replace(/[0-9]{4}(.*)/,'$1')
var eventName = `${eventYear} ${eventVenue}`
var eventData = []
function loadEventData(callback){
    $.ajax({
        async: true,  
        beforeSend: function(xhr){
            xhr.overrideMimeType("text/plain;charset=UTF-8");
        },
        url: `/data/${eventId}.quals.csv`,
        timeout: 5000,
        type: "GET",
        success: function(text) {
            var lines = text.split(/[\r\n]+/)
            var bots = ['R1','R2','R3','B1','B2','B3']
            for(var i=0; i<lines.length; i++){
                if (/^([^,\t]*[,\t])?([0-9]+[,\t]){5}[0-9]+$/.test(lines[i])){
                    var teams = lines[i].split(/[,\t]/)
                    if (teams.length==7) teams.shift()
                    var match = {}
                    for (var j=0; j<teams.length; j++){
                        match[bots[j]] = parseInt(teams[j])
                    }
                    eventData.push(match)
                }
            }
            if (callback && eventData.length) callback(eventData)
        }
    })
}
function loadEventStats(callback){
    $.ajax({
        async: true,  
        beforeSend: function(xhr){
            xhr.overrideMimeType("text/plain;charset=UTF-8");
        },
        url: `/data/${eventId}.txt`,
        timeout: 5000,
        type: "GET",
        success: function(text) {
            if (callback) callback(eventData)
        }
    })
}
function loadEventElims(callback){
    $.ajax({
        async: true,  
        beforeSend: function(xhr){
            xhr.overrideMimeType("text/plain;charset=UTF-8");
        },
        url: `/data/${eventId}.elims`,
        timeout: 5000,
        type: "GET",
        success: function(text) {
            if (callback) callback(text.split(/[\n\r]+/))
        }
    })
}
function loadEventFiles(callback){
    $.ajax({
        async: true,  
        beforeSend: function(xhr){
            xhr.overrideMimeType("text/plain;charset=UTF-8");
        },
        url: `/event-files.cgi?event=${eventId}`,
        timeout: 5000,
        type: "GET",
        success: function(text) {
            if (callback) callback(text.split(/[\n\r]+/))
        }
    })
}