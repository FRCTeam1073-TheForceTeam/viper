var backForward = false

window.addEventListener('pageshow', function (event){
	backForward = event.persisted || performance.getEntriesByType("navigation")[0].type === 'back_forward'
})

function fetchJson(url){
	return fetch(url,{cache:'reload'}).then(x=>x.ok?x.json():{})
}

$(document).ready(function(){
	if (!eventId){
		$('body').prepend("<h1>No event specified</h1>")
		return
	}
	Promise.all([
		fetchJson(`/data/${eventId}.info.json`),
		fetchJson(`/data/${eventId}.schedule.practice.json`),
		fetchJson(`/data/${eventId}.schedule.qualification.json`),
		fetchJson(`/data/${eventId}.teams.json`)
	]).then(values => {
		var [info,practice,qual,teamsJson] = values,
		csv = ""
		info.Events = info.Events||info.events||[]
		if (info.Events.length){
			var ev = info.Events[0]
			$('#nameInp').val(ev.name)
			$('#locationInp').val(`${ev.venue} in ${ev.city}, ${ev.stateprov}, ${ev.country}`)
			$('#startInp').val(ev.dateStart.slice(0,10))
			$('#endInp').val(ev.dateEnd.slice(0,10))
		}
		$('#importData').toggle(backForward)
		$('#idInp').val(eventId)

		practice = practice||{}
		practice.Schedule = practice.Schedule||practice.schedule||[]
		practice.Schedule.forEach(function(match){
			csv+="pm"+match.matchNumber
			match.teams.forEach(function(team){
				csv+=","+(team.teamNumber||0)
			})
			csv+="\n"
		})
		qual = qual||{}
		qual.Schedule = qual.Schedule||qual.schedule||[]
		qual.Schedule.forEach(function(match){
			csv+="qm"+match.matchNumber
			match.teams.forEach(function(team){
				csv+=","+(team.teamNumber||0)
			})
			csv+="\n"
		})
		if (csv.length){
			csv = "Match," + BOT_POSITIONS.join(",") + "\n" + csv
			$('#csvInp').val(csv)
			if (!backForward) $('#importData').submit()
			return
		}
		var teams = []
		if (teamsJson.teams){
			teamsJson.teams.forEach(function(team){
				teams.push(team.teamNumber)
			})
			$('#csvInp').val(randomPracticeSchedule(teams))
			if (!backForward) $('#importData').submit()
		} else if (teamsJson.pageTotal){
			Promise.all(
				Array.from({length: teamsJson.pageTotal}, (_,i) => fetchJson(`/data/${eventId}.teams.${i+1}.json`))
			).then(function(results){
				results.forEach(teamsJson=>{
					teamsJson.teams.forEach(function(team){
						teams.push(team.teamNumber)
					})
				})
				$('#csvInp').val(randomPracticeSchedule(teams))
				if (!backForward) $('#importData').submit()
			})
		}
	})
})
