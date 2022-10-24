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
        url: `/data/${eventId}.dat`,
        timeout: 5000,
        type: "GET",
        success: function(text) {
            var lines = text.split(/[\r\n]+/)
            var bots = ['R1','R2','R3','B1','B2','B3']
            if (/_qm/.test(text)){
                for(var i=0; i<lines.length; i++){
                    var m = /_qm([0-9]+)_([0-9]+) *= *([0-9]+)$/.exec(lines[i])
                    if (m){
                        matchNum = parseInt(m[1]) - 1
                        bot = bots[parseInt(m[2]) - 1] || '?'
                        team = parseInt(m[3])
                        eventData[matchNum] = eventData[matchNum] || {}
                        eventData[matchNum][bot] = team
                    }
                }
            } else {
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