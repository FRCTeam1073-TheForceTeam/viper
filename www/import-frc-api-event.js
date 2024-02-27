$(document).ready(function(){
	if (!eventId){
		$('body').prepend("<h1>No event specified</h1>")
		return
	}
	var csv="Match,R1,R2,R3,B1,B2,B3\n"
	Promise.all([
		promiseJson(`/data/${eventId}.info.json`),
		promiseJson(`/data/${eventId}.schedule.practice.json`),
		promiseJson(`/data/${eventId}.schedule.qualification.json`)
	]).then(values => {
		var [info,prac,qual,teams] = values,
		ev = info.Events[0],
		csv = ""
		console.log(prac)
		$('#nameInp').val(ev.name)
		$('#locationInp').val(`${ev.venue} in ${ev.city}, ${ev.stateprov}, ${ev.country}`)
		$('#startInp').val(ev.dateStart.substring(0,10))
		$('#endInp').val(ev.dateEnd.substring(0,10))
		$('#idInp').val(eventId)

		if (prac && prac.Schedule){
			prac.Schedule.forEach(function(match){
				csv+="pm"+match.matchNumber
				match.teams.forEach(function(team){
					csv+=","+team.teamNumber
				})
				csv+="\n"
			})
		}
		if (qual && qual.Schedule){
			qual.Schedule.forEach(function(match){
				csv+="qm"+match.matchNumber
				match.teams.forEach(function(team){
					csv+=","+team.teamNumber
				})
				csv+="\n"
			})
		}
		if (csv.length){
			csv = "Match,R1,R2,R3,B1,B2,B3\n" + csv
			$('#csvInp').val(csv)
			$('#importData').submit()
			return
		}
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
