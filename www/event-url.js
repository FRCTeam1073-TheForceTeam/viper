$.ajaxSetup({
	cache: true
});

var eventId=(location.hash.match(/^\#(?:(?:.*\&)?(?:event\=))?(20[0-9]{2}[a-zA-Z0-9\-]+)(?:\&.*)?$/)||["",""])[1]
var eventYear = eventId.replace(/([0-9]{4}).*/,'$1')
var eventVenue = eventId.replace(/[0-9]{4}(.*)/,'$1')
var eventName = eventYear+(eventYear?" ":"")+eventVenue
var eventMatches = []
var eventAlliances = []
var eventStats = []
var eventStatsByTeam = {}
var eventFiles = []
var eventTeams = []
var eventInfo = {}
var eventPitData = {}
const BOT_POSITIONS = ['R1','R2','R3','B1','B2','B3']

function eventAjax(file,callback){
	$.ajax({
		async: true,
		beforeSend: function(xhr){
			xhr.overrideMimeType("text/plain;charset=UTF-8");
		},
		url: file,
		timeout: 5000,
		type: "GET",
		success: callback,
		error: function(xhr,status,err){
			console.log(err)
			callback("")
		}
	})
}

function csvToArrayOfMaps(csv){
	var arr = []
	var lines = csv.split(/[\r\n]+/)
	if (lines.length>0){
		var headers = lines.shift().split(/,/)
		for(var i=0; i<lines.length; i++){
			if (lines[i]){
				var data = lines[i].split(/[,]/)
				var map = {}
				for (var j=0; j<data.length; j++){
					map[headers[j]] = /^[0-9]+$/.test(data[j])?parseInt(data[j]):unescapeField(data[j])
				}
				arr.push(map)
			}
		}
	}
	return arr
}

function unescapeField(s){
	return s
		.replace(/⏎/g, "\n")
		.replace(/״/g, "\"")
		.replace(/،/g, ",")
}

function loadEventSchedule(callback){
	eventAjax(`/data/${eventId}.schedule.csv`,function(text){
		eventMatches=csvToArrayOfMaps(text)
		var teams = {}
		for (var i=0; i<eventMatches.length; i++){
			for (j=0; j<BOT_POSITIONS.length; j++){
				teams[eventMatches[i][BOT_POSITIONS[j]]] = 1
			}
		}
		eventTeams = Object.keys(teams)
		eventTeams.sort((a,b)=>{parseInt(a)-parseInt(b)})
		if (callback) callback(eventMatches)
	})
}

function loadAlliances(callback){
	eventAjax(`/data/${eventId}.alliances.csv`,function(text){
		eventAlliances=csvToArrayOfMaps(text)
		if (callback) callback(eventAlliances)
	})
}

function loadEventStats(callback){
	if (eventYear && eventId){
		$.getScript(`/${eventYear}/aggregate-stats.js`, function(){
			eventAjax(`/data/${eventId}.scouting.csv`,function(text){
				eventStats=csvToArrayOfMaps(text)
				for (var i=0; i<eventStats.length; i++){
					var scout = eventStats[i]
					var team = scout['team']
					var aggregate = eventStatsByTeam[team] || {}
					aggregateStats(scout, aggregate)
					eventStatsByTeam[team] = aggregate
				}
				if (callback) callback(eventStats, eventStatsByTeam)
			})
		})
	}
}

function loadEventFiles(callback){
	eventAjax(`/event-files.cgi?event=${eventId}`,function(text){
		eventFiles=text.split(/[\n\r]+/)
		if (callback) callback(eventFiles)
	})
}

function loadEventInfo(callback){
	eventAjax(`/data/${eventId}.event.csv`,function(text){
		if (text){
			eventInfo = csvToArrayOfMaps(text)[0]
			if (eventInfo.name) eventName = `${eventYear} ${eventInfo.name}`
			if (callback) callback(eventInfo)
		}
	})
}

function loadPitScouting(callback){
	eventAjax(`/data/${eventId}.pit.csv`,function(text){
		if (text){
			eventPitData = csvToArrayOfMaps(text)[0]
			if (callback) callback(eventPitData)
		}
	})
}

function getUploads(){
	var uploads = []
	var year = eventId.substring(0,4)
	for (i in localStorage){
		if (new RegExp(`^${year}.*_.*_`).test(i)) {
			uploads.push(localStorage.getItem(i))
		}
	}
	return uploads
}

function getMatchName(matchId){
	return matchId
		.replace(/^pm/, "Practice ")
		.replace(/^qm/, "Qualification ")
		.replace(/^qf/, "Quarter-final ")
		.replace(/^sf/, "Semi-final ")
		.replace(/^1p/, "Playoffs first round ")
		.replace(/^2p/, "Playoffs second round ")
		.replace(/^3p/, "Playoffs third round ")
		.replace(/^4p/, "Playoffs fourth round ")
		.replace(/^5p/, "Playoffs fifth round ")
		.replace(/^f/, "Final ")
}
