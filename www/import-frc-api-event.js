$(document).ready(function(){
	if (!eventId){
		$('body').prepend("<h1>No event specified</h1>")
		return
	}
	var csv="Match,R1,R2,R3,B1,B2,B3\n"
	$.getJSON(`/data/${eventId}.info.json`, function(json){
		var ev = json.Events[0]
		$('#nameInp').val(ev.name)
		$('#locationInp').val(`${ev.venue} in ${ev.city}, ${ev.stateprov}, ${ev.country}`)
		$('#startInp').val(ev.dateStart.substring(0,10))
		$('#endInp').val(ev.dateEnd.substring(0,10))
		$('#idInp').val(eventId)
	}).always(function(){
		$.getJSON(`/data/${eventId}.schedule.qualification.json`, function(json){
			json.Schedule.forEach(function(match){
				csv+="qm"+match.matchNumber
				match.teams.forEach(function(team){
					csv+=","+team.teamNumber
				})
				csv+="\n"
			})
			$('#csvInp').val(csv)
			$('#importData').submit()
		}).fail(function(){
			$.getJSON(`/data/${eventId}.teams.json`, function(json){
				var teams = []
				if (json.teams){
					json.teams.forEach(function(team){
						teams.push(team.teamNumber)
					})
					$('#csvInp').val(randomPracticeSchedule(teams))
					$('#importData').submit()
				} else if (json.pageTotal){
					var waitFor = []
					for (var i=1; i<=json.pageTotal; i++){
						waitFor.push($.getJSON(`/data/${eventId}.teams.${i}.json`, function(json){
							if (json.teams){
								json.teams.forEach(function(team){
									teams.push(team.teamNumber)
								})
							}
						}))
					}
					$.when(...waitFor).then(function() {
						$('#csvInp').val(randomPracticeSchedule(teams))
						$('#importData').submit()
					})
				}
			})
		})
	})
})
