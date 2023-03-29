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
			if (json.Schedule.length){
				$('#csvInp').val(csv)
				$('#importData').submit()
			} else {
				$.getJSON(`/data/${eventId}.teams.json`, function(json){
					var teams = []
					json.teams.forEach(function(team){
						teams.push(team.teamNumber)
					})
					$('#csvInp').val(randomPracticeSchedule(teams))
					$('#importData').submit()
				})
			}
		})
	})
})
