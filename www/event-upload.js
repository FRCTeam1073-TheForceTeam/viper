"use strict"

$(document).ready(function(){
	$('#importData').submit(processInput)
	$('input[type=submit]').click(processInput)

	function processInput(){
		var src=$('#sourceInp').val(),csv=""
		if (!csv) csv=getBlueAllianceMatchSchedule(src)
		if (!csv) csv=getFirstInpsiresMatchSchedule(src)
		if (!csv) csv=randomPracticeSchedule(getBlueAllianceTeamList(src))
		if (!csv) csv=randomPracticeSchedule(getGenericTeamList(src))
		if (!csv){
			alert("No data found!")
			return false
		}
		$('#csvInp').val(csv)
		var newEventId = src.match(/event_key=(20[0-9]+[a-z0-9]+)/)
		console.log(newEventId)
		if (!newEventId || !newEventId.length) newEventId = src.match(/href\=\"\/(20[0-9]{2}\/[A-Z0-9]+)\"\>Event Info/)
		console.log(newEventId)
		if (!newEventId || !newEventId.length) newEventId = ["",$('#idInp').val()]
		console.log(newEventId)
		newEventId = newEventId[1].replace(/\//g,"").toLowerCase()
		console.log(newEventId)
		if (newEventId != eventId){
			eventInfo=null
			eventId=newEventId
			$('#idInp').val(eventId)
			loadEventInfo(function(){
				if (srcToField(src)){
					$('#importData').submit()
				}
			})
			return false
		}
		srcToField(src)
	}

	function srcToField(src){
		$('#startInp').val((src.match(/itemprop\=\"startDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/)||["",eventInfo.start||$('#startInp').val()])[1])
		$('#endInp').val((src.match(/itemprop\=\"endDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/)||["",eventInfo.end||$('#endInp').val()])[1])
		$('#nameInp').val((src.match(/id\=\"event-name\"\>([^\<]+)\</)||src.match(/\<span class\=\"hidden-xs hidden-sm align-middle\"\> - ([^\<]+)\</)||["",eventInfo.name||$('#nameInp').val()])[1].replace(/ Event$/,""))
		$('#locationInp').val((src.match(/\<span itemprop\=\"location\"\>(.|[\r\n])*?\<\/span\>/m)||["",eventInfo.location||$('#locationInp').val()])[1])
		var empty = false
		$('#autoFields input:empty').each(function(){
			if (!$(this).val()) empty = true
		})
		if(empty){
			$('#autoFields').show()
			$('#csvInp').show()
			$('#sourceInp').hide()
			return false
		}
		return true
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

	function getFirstInpsiresMatchSchedule(src){
		var isPractice = /Official practice match schedule/.test(src),
		re= /\/20[0-9]{2}\/team\/([0-9]+)/g,
		m, matchNum=1, match=[], schedule = [["Match","R1","R2","R3","B1","B2","B3"]]
		while(m = re.exec(src)){
			if(!match.length){
				match.push((isPractice?"pm":"qm")+matchNum)
				matchNum++
			}
			match.push(m[1])
			if (match.length==7){
				schedule.push(match)
				match=[]
			}
		}
		if (schedule.length==1) return ""
		return schedule.map(a=>a.join(",")).join("\n")+"\n"
	}

	function getBlueAllianceMatchSchedule(src){
		var re= /(?:\/match\/(20[0-9]{2}[a-zA-Z0-9]+)_qm([0-9]+))|(?:\/team\/([0-9]+)\/20)/g,
		m, qual, schedule = [["Match","R1","R2","R3","B1","B2","B3"]]
		do {
			m = re.exec(src)
			if (m) {
				if (m[1]){
					qual = parseInt(m[2])
					if (!schedule[qual]) schedule[qual] = ["qm"+qual]
				} else if (qual && schedule[qual].length < 7){
					schedule[qual].push(m[3])
				}
			}
		} while (m)
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
})
