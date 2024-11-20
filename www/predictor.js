"use strict"

function lf(){
	return $('#prediction .lastFocus')
}

$(document).ready(function(){
	Promise.all([
		promiseEventMatches(),
		promiseEventStats()
	]).then(values =>{
		var [eventMatches, [{}, eventStatsByTeam, {}]] = values,
		teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		for (var i=0; i<teamList.length; i++){
			var team = teamList[i]
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
		}
		$('#matchList').append($('<option selected=1>')).change(function(){
			$(this).val().split(",").forEach((bot,i)=>{
				$(`#${BOT_POSITIONS[i]}`).val(bot)
			})
			setPickedTeams()
		})
		eventMatches.forEach(match=>{
			$('#matchList').append($('<option>').text(getMatchName(match.Match)).attr('value',BOT_POSITIONS.map(pos=>match[pos]).join(",")))
		})
		loadFromLocationHash()
		$(window).on('hashchange', loadFromLocationHash)
		var title = "Match Predictor"
		if (eventId) title = `${eventName} ${title}`
		if (match) title = `${match} ${title}`
		$('title,h1').text(title)
	})
	$('#prediction input').focus(focusInput).change(setPickedTeams)
	if (eventCompetition=='ftc') $('.noftc').hide()
	$('#change-teams').click(function(){
		$('#prediction input').val("")
		setPickedTeams()
	})
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
	promiseEventStats().then(resolve=>{
		var [{}, eventStatsByTeam, {}] = resolve
		$('#teamButtons button').removeClass("picked")
		var teamCount = 0
		$('#prediction input').each(function(){
			var val = $(this).val()
			if (val){
				$(`#team-${val}`).addClass("picked")
				teamCount++
			}
		})
		if (teamCount == BOT_POSITIONS.length){
			$('#change-teams').show()
			$('input').removeClass('lastFocus')
			$('.teamDataEntry').hide()
			var table = $('#prediction tbody'),
			red = [parseInt($('#R1').val()),parseInt($('#R2').val()),parseInt($('#R3').val())],
			blue = [parseInt($('#B1').val()),parseInt($('#B2').val()),parseInt($('#B3').val())],
			first=true
			table.html("")
			Object.keys(matchPredictorSections).forEach(function(section){
				table.append($('<tr>').append($(`<th colspan=${BOT_POSITIONS.length+3}>`).append($('<h4>').text(section))))
				matchPredictorSections[section].forEach(function(field){
					statInfo[field] = statInfo[field]||{}
					var statName = statInfo[field]['name']||field,
					statType = statInfo[field]['type']||""
					if (statType=='avg'){
						var teamNumbers = [],
						teamScores = [],
						allianceScores = [0,0]
						BOT_POSITIONS.forEach(function(pos, i){
							teamNumbers[i]=parseInt($(`#${pos}`).val())
							teamScores[i]=getTeamValue(eventStatsByTeam, field,teamNumbers[i])
							allianceScores[Math.floor(i/(BOT_POSITIONS.length/2))]+=teamScores[i]
						})
						teamScores=teamScores.map(Math.round)
						allianceScores=allianceScores.map(Math.round)
						var compare=statInfo[field].good=='low'?Math.min:Math.max,
						teamBest=compare(...teamScores),
						allianceBest=compare(...allianceScores),
						tr=$('<tr>').addClass(first?"first":"")
						BOT_POSITIONS.forEach(function(pos, i){
							tr.append($('<td>').addClass(i<(BOT_POSITIONS.length/2)?'redTeamBG':'blueTeamBG').append($('<div>').text(teamScores[i]).addClass(teamScores[i]==teamBest?"winner":"")))
							if(i==(BOT_POSITIONS.length/2-1)){
								tr.append($('<td>').addClass('redTeamBG').addClass('alliance').append($('<div>').text(allianceScores[0]).addClass(allianceScores[0]==allianceBest?("winner"):"")))
								tr.append($('<td>').append($('<div>').text(statName)))
								tr.append($('<td>').addClass('blueTeamBG').addClass('alliance').append($('<div>').text(allianceScores[1]).addClass(allianceScores[1]==allianceBest?"winner":"")))
							}
						})
						table.append(tr)
						first=false
					}
				})
			})
		} else {
			$('.teamDataEntry').show()
			$('#prediction tbody').html("")
			$('#change-teams').hide()
		}
		setLocationHash()
	})
}

var match = ""

function setLocationHash(){
	var hash = `event=${eventId}`
	if (match) hash += `&match=${match}`
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
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)([a-z0-9]+)(?:\&.*)?$/)||["",""])[1]
	$('#prediction input').each(function(){
		var name = $(this).attr('id')
		var val = (location.hash.match(new RegExp(`^\\#(?:.*\\&)?(?:${name}\\=)([0-9]+)(?:\\&.*)?$`))||["",""])[1]
		$(this).val(val)
	})
	setPickedTeams()
	focusNext()
}

function getTeamValue(eventStatsByTeam, field, team){
	if (! team in eventStatsByTeam) return 0
	var stats = eventStatsByTeam[team]
	if (! stats || ! field in stats ||! 'count' in stats || !stats['count']) return 0
	return (stats[field]||0) / stats['count']
}

function teamButtonClicked(){
	lf().val($(this).text())
	focusNext()
	setPickedTeams()
}
