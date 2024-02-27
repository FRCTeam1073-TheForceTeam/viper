"use strict"

$(document).ready(function(){
	$('h1').text(`${eventName} Scouting Stats`)
	$('title').text($('title').text().replace("EVENT", eventName))
	promiseScoutScoreCompare().then(values=>{
		var [scouterStats, matchStats] = values,
		allianceStats = []
		matchStats.forEach(match=>{
			if (match.Red) allianceStats.push(match.Red)
			if (match.Blue) allianceStats.push(match.Blue)
		})
		allianceStats = allianceStats.sort((a,b)=>b.diff-a.diff)
		allianceStats.forEach(alliance=>{
			var details = $('<table>'),
			dh1 = $('<tr>'),
			dh2 = $('<tr>')
			dh1.append($('<td rowspan=2>').text("Diff"))
			dh1.append($('<td colspan=2>').text("FMS"))
			dh1.append($('<td colspan=5>').text("Scouting"))
			dh2.append($('<td>').text("Name"))
			dh2.append($('<td>').text("Value"))
			dh2.append($('<td>').text("Name"))
			dh2.append($('<td>').text("Value"))
			alliance.teams.forEach((team,i)=>{
				dh2.append($('<td>').append($(`<a target=_blank href="/${eventYear}/scout.html#event=${eventId}&pos=${alliance.alliance.charAt(0)}${i+1}&team=${team}&match=${alliance.match}">`).text(`${team} - ${alliance.scouters[i]}`))
				)
			})
			details.append(dh1).append(dh2)
			alliance.dat.forEach(stat=>{
				var fmsFields = Object.keys(stat.fms),
				scoutFields = Object.keys(stat.scout),
				rowCount = Math.max(fmsFields.length,scoutFields.length)
				var row = $('<tr>')
				row.append($(`<td rowspan=${rowCount}>`).text(stat.diff))
				for(var i=0; i<rowCount; i++){
					if(i>0){
						details.append(row)
						row = $('<tr>')
					}
					if (i>=fmsFields.length){
						row.append("<td>").append("<td>")
					} else {
						row.append($("<td>").text(fmsFields[i]))
						.append($('<td>').text(stat.fms[fmsFields[i]]))
					}
					if (i>=scoutFields.length){
						row.append("<td>").append("<td>").append("<td>").append("<td>").append("<td>")
					} else {
						row.append($("<td>").text(scoutFields[i]))
						.append($('<td>').text(stat.scout[scoutFields[i]].total))
						stat.scout[scoutFields[i]].teams.forEach(team=>{
							row.append($('<td>').text(team.points))
						})
					}
				}
				details.append(row)
			})
			$('#allianceStats').append(
				$('<tr>')
					.append(
						$('<td>')
						.append(document.createTextNode(`${alliance.match} - ${alliance.alliance}`))
						.append('<br>')
						.append(`<span class=mainDiff>${alliance.diff}</span>`)
					)
					.append(details)

			)
		})
	})
})
