"use strict"

$(document).ready(function(){
	$('#importData').submit(processInput)
	$('input[type=submit]').click(processInput)

	function processInput(){
		var src=$('#sourceInp').val(),csv="",m
		if (!csv) csv=getBlueAllianceMatchSchedule(src)
		if (!csv) csv=randomPracticeSchedule(getBlueAllianceTeamList(src))
		if (!csv) csv=randomPracticeSchedule(getGenericTeamList(src))
		if (!csv){
			alert("No data found!")
			return false
		}
		$('#idInp').val((src.match(/event_key=(20[0-9]+[a-z]+)/)||["",$('#idInp').val()])[1])
		$('#startInp').val((src.match(/itemprop\=\"startDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/)||["",$('#startInp').val()])[1])
		$('#endInp').val((src.match(/itemprop\=\"endDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/)||["",$('#endInp').val()])[1])
		$('#nameInp').val((src.match(/id\=\"event-name\"\>([^\<]+)\</)||["",$('#nameInp').val()])[1])
		$('#locationInp').val((src.match(/\<span itemprop\=\"location\"\>(.|[\r\n])*?\<\/span\>/m)||["",$('#locationInp').val()])[1])
		$('#csvInp').val(csv)
		if($('#autoFields input:empty').length){
			$('#autoFields').show()
			$('#csvInp').show()
			$('#sourceInp').hide()
		}
	}

	function venueNameToId(){
		$('#idInp').val($('#startInp').val().substr(0,4)+$('#nameInp').val().replace(/20[0-9]{2}/g,"").trim().toLowerCase().replace(/\s+/g,"-").replace(/[^0-9a-z\-]/g,""))
	}

	$('#nameInp').change(venueNameToId).keyup(venueNameToId)

	function getBlueAllianceTeamList(src){
		return (src.match(/\/team\/([0-9]+)\//g)||[]).map(s=>s.replace(/[^0-9]/g,""))
	}

	function getGenericTeamList(src){
		return src.match(/\b([0-9]+)\b/g)
	}

	function getBlueAllianceMatchSchedule(src){
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

	function randomPracticeSchedule(teams){
		if (!teams || !teams.length) return ""
		var match=0,
		matchTeams=0,
		csv="Match,R1,R2,R3,B1,B2,B3"
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

	// https://stackoverflow.com/a/46545530
	function shuffleArray(array){
		return array.map(value => ({value, sort: Math.random()}))
		.sort((a, b) => a.sort - b.sort)
		.map(({value}) => value)
	}
})
