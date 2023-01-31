"use strict"

function lf(){
	return $('#prediction .lastFocus')
}

$(document).ready(function(){
	loadEventStats(function(){
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		for (var i=0; i<teamList.length; i++){
			var team = teamList[i]
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
		}
		loadFromLocationHash()
		$(window).on('hashchange', loadFromLocationHash)
	})
	$('#prediction input').focus(focusInput).change(setPickedTeams)
})

function focusInput(input){
	if ('target' in input) input = $(input.target)
	if (input[0]==lf()[0]) return
	$('#prediction input').removeClass('lastFocus')
	input.addClass('lastFocus')
}

function lf(){
	return $('#prediction input.lastFocus')
}

function withoutValues(i,el){
	return $(el).val() == ''
}

function focusNext(){
	var next = $('#prediction .redTeamBG input').filter(withoutValues).first()
	if (!next.length) next = $('#prediction .blueTeamBG input').filter(withoutValues).first()
	if (next.length) focusInput(next)
	return next.length > 0
}

function setPickedTeams(){
	$('#teamButtons button').removeClass("picked")
	var teamCount = 0
	$('#prediction input').each(function(){
		var val = $(this).val()
		if (val){
			$(`#team-${val}`).addClass("picked")
			teamCount++
		}
	})
	if (teamCount == 6){
		$('input').removeClass('lastFocus')
		$('#teamButtons').hide()
		var table = $('#prediction'),
		red = [parseInt($('#R1').val()),parseInt($('#R2').val()),parseInt($('#R3').val())],
		blue = [parseInt($('#B1').val()),parseInt($('#B2').val()),parseInt($('#B3').val())],
		first=true
		Object.keys(matchPredictorSections).forEach(function(section){
			table.append($('<tr>').append($('<th colspan=9>').append($('<h4>').text(section))))
			matchPredictorSections[section].forEach(function(field){
				statInfo[field] = statInfo[field]||{}
				var statName = statInfo[field]['name']||field,
				statType = statInfo[field]['type']||""
				if (statType=='avg'){
					var r1Val = Math.round(getTeamValue(field,red[0])),
					r2Val = Math.round(getTeamValue(field,red[1])),
					r3Val = Math.round(getTeamValue(field,red[2])),
					rVal = Math.round(getAllianceValue(field,red)),
					bVal = Math.round(getAllianceValue(field,blue)),
					b1Val = Math.round(getTeamValue(field,blue[0])),
					b2Val = Math.round(getTeamValue(field,blue[1])),
					b3Val = Math.round(getTeamValue(field,blue[2])),
					bWinner=(first&&bVal>rVal)?" winner":"",
					rWinner=(first&&rVal>bVal)?" winner":""
					if (first){
						bVal = `<h2 class="blueTeamBG${bWinner}">${bVal}</h2>`
						rVal = `<h2 class="redTeamBG${rWinner}">${rVal}</h2>`
						first = false
					}
					table.append($(`<tr><td class=redTeamBG>${r1Val}</td><td class=redTeamBG>${r2Val}</td><td class=redTeamBG>${r3Val}</td><td class="redTeamBG${rWinner}">${rVal}</td><td>${statName}</td><td class="blueTeamBG${bWinner}">${bVal}</td><td class=blueTeamBG>${b1Val}</td><td class=blueTeamBG>${b2Val}</td><td class=blueTeamBG>${b3Val}</td></tr>`))
				}
			})
		})
	} else {
		$('#teamButtons').show()
	}
	setLocationHash()
}

function setLocationHash(){
	var hash = `event=${eventId}`
	$('#prediction input').each(function(){
		var val = $(this).val()
		if (/^[0-9]+$/.test(val)){
			var name = $(this).attr('id')
			hash += `&${name}=${val}`
		}
	})
	location.hash = hash
}

function loadFromLocationHash(){
	$('#prediction input').each(function(){
		var name = $(this).attr('id')
		var val = (location.hash.match(new RegExp(`^\\#(?:.*\\&)?(?:${name}\\=)([0-9]+)(?:\\&.*)?$`))||["",""])[1]
		$(this).val(val)
	})
	setPickedTeams()
	focusNext()
}

function getTeamValue(field, team){
	if (! team in eventStatsByTeam) return 0
	var stats = eventStatsByTeam[team]
	if (! stats || ! field in stats ||! 'count' in stats || !stats['count']) return 0
	return (stats[field]||0) / stats['count']
}

function getAllianceValue(field, teams){
	var value = 0
	for (var i = 0; i<teams.length; i++){
		value += getTeamValue(field, teams[i])
	}
	return value
}

function teamButtonClicked(){
	lf().val($(this).text())
	focusNext()
	setPickedTeams()
}
