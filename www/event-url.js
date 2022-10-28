var eventId=(location.hash.match(/^\#(?:(?:.*\&)?(?:event\=))?(20[0-9]{2}[a-zA-Z0-9_\-]+)(?:\&.*)?$/)||["",""])[1]
var eventYear = eventId.replace(/([0-9]{4}).*/,'$1')
var eventVenue = eventId.replace(/[0-9]{4}(.*)/,'$1')
var eventName = `${eventYear} ${eventVenue}`
var eventMatches = []
function loadEventSchedule(callback){
    $.ajax({
        async: true,  
        beforeSend: function(xhr){
            xhr.overrideMimeType("text/plain;charset=UTF-8");
        },
        url: `/data/${eventId}.schedule.csv`,
        timeout: 5000,
        type: "GET",
        success: function(text) {
            var lines = text.split(/[\r\n]+/)
            if (lines.length>0 && lines[0] == "Match,R1,R2,R3,B1,B2,B3"){
                var headers = lines.shift().split(/,/)
                for(var i=0; i<lines.length; i++){
                    if (/^(qm|qf|sf|f)([0-9]+,){6}[0-9]+$/.test(lines[i])){
                        var data = lines[i].split(/[,\t]/)
                        var match = {}
                        for (var j=0; j<data.length; j++){
                            match[headers[j]] = /^[0-9]+$/.test(data[j])?parseInt(data[j]):data[j]
                        }
                        eventMatches.push(match)
                    }
                }
                if (callback && eventMatches.length) callback(eventMatches)
            }
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
            if (callback) callback(text)
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