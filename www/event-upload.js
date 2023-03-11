"use strict"

$(document).ready(function(){
	$('#blueAllianceSource').submit(function(){
		var src=$('textarea').val(),csv="",m,
		eventId=src.match(/event_key=(20[0-9]+[a-z]+)/)[1]
		if (!eventId){
			alert("No event ID found")
			return false
		}
		if (!csv) csv=getMatchSchedule(src)
		if (!csv) csv=getPracticeSchedule(src)
		if (!csv){
			alert("No data found!")
			return false
		}
		if (m = /itemprop\=\"startDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/.exec(src)){
			if (m[1].length>1) $('#startInp').val(m[1])
		}
		if (m = /itemprop\=\"endDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/.exec(src)){
			if (m[1].length>1) $('#endInp').val(m[1])
		} else {
			if (m[1].length>1) $('#endInp').val($('#startInp').val())
		}
		if (m = /id\=\"event-name\"\>([^\<]+)\</.exec(src)){
			if (m[1].length>1) $('#nameInp').val(m[1])
		}
		if (m = /\<span itemprop\=\"location\"\>(.|[\r\n])*?\<\/span\>/m.exec(src)){
			if (m[1].length) $('#locationInp').val($(m[0]).text().trim())
		}
		$('#eventInp').val(eventId)
		$('#csvInp').val(csv)
		$('#csvForm').submit()
		return false
	})

	function getPracticeSchedule(src){
		var teams = src.match(/\/team\/([0-9]+)\//g).map(s=>s.replace(/[^0-9]/g,"")),
		match=0,
		matchTeams=0,
		csv="Match,R1,R2,R3,B1,B2,B3"
		if (!teams.length) return ""
		teams = shuffleArray([...new Set(teams)])
		teams.forEach(function(team){
			if (matchTeams >= 6) matchTeams = 0
			if (matchTeams == 0){
				match++
				csv+="\npm"+match
			}
			csv+=","+team
			matchTeams++
		})
		while (matchTeams < 6){
			teams = shuffleArray(teams)
			csv+=","+teams[0]
			matchTeams++
		}
		csv+="\n"
		return csv
	}

	function getMatchSchedule(src){
		var re= /(?:\/match\/(20[0-9]{2}[a-zA-Z0-9]+)_qm([0-9]+))|(?:\/team\/([0-9]+)\/20)/g,
		m, qual, schedule = [["Match","R1","R2","R3","B1","B2","B3"]]
		do {
			m = re.exec(src);
			if (m) {
				if (m[1]){
					qual = parseInt(m[2])
					if (!schedule[qual]) schedule[qual] = ["qm"+qual]
				} else if (qual && schedule[qual].length < 7){
					schedule[qual].push(m[3])
				}
			}
		} while (m);
		if (schedule.length == 1){
			return ""
		}
		var csv = ""
		for (var i=0; i<schedule.length; i++){
			var row = schedule[i]
			if (row.length != 7){
				alert("Could not find six teams for match: " + row[0])
				return ""
			}
			csv += row.join(",") + "\n"
		}
		return csv
	}

	// https://stackoverflow.com/a/46545530
	function shuffleArray(array){
		return array.map(value => ({value, sort: Math.random()}))
		.sort((a, b) => a.sort - b.sort)
		.map(({value}) => value)
	}
})
