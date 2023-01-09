"use strict"

var teams = []
var allianceCount = 8;

function tableToCsv(table){
	var csv=""
	table.find('tr').each(function(){
		var line=""
		$(this).find('th,td').each(function(){
			if (line) line += ","
			line += $(this).text() || $(this).find('input').val() || ""
		})
		csv += line + "\n"
	})
	return csv
}

function showAllianceSelection(){
	$('.screen').hide()
	loadEventSchedule(function(data){
		var t = {}
		for (var i=1; i<data.length; i++){
			for (var j=0; j<BOT_POSITIONS.length; j++){
				t[data[i][BOT_POSITIONS[j]]] = 1
			}
		}
		teams = Object.keys(t);
		teams.sort((a,b) => {return a-b})
		for (var i=0; i<teams.length; i++){
			var team = teams[i]
			$('#teams').append($(`<button class=team id=t${team}>${team}</button>`).click(function(){
				$(this).addClass('picked')
				lf().val($(this).text())
				if (!focusNext()) computeStartingSchedule()
			}))
		}
	})
	$('#alliance-selection').show()
}

function allianceDisplay(num, oppNum, showButton, column, teamColor){
	if (num == 0) return `<div class="${teamColor}TeamBG matchup">?</div>`
	var a = eventAlliances[num-1],
	winClass = a[column]?"winner":"",
	c = a['Captain'],
	p1 = a['First Pick'],
	p2 = a['Second Pick'],
	button = showButton?`<br><button class=winnerBtn data-alliance=${num} data-opponent=${oppNum} data-column="${column}">Set Winner</button>`:""
	return `<div class="${teamColor}TeamBG matchup ${winClass}"><h4>Alliance ${num}</h4>${c}, ${p1}, ${p2}${button}</div>`
}

function matchupDisplay(nums, showButton, column){
	if (!nums || !nums.length) return ""
	return (
		allianceDisplay(nums[0],nums[1],showButton,column,"red") +
		allianceDisplay(nums[1],nums[0],showButton,column,"blue")
	)
}

function getWinner(schedule, match, winField){
	var a1=schedule[match][0],a2=schedule[match][1]
	if (a1 && eventAlliances[a1-1][winField]) return a1
	if (a2 && eventAlliances[a2-1][winField]) return a2
	return 0
}

var dataLevel = ""

function filled(arr2d){
	for (var i=0; i<arr2d.length; i++){
		for (var j=0; j<arr2d[i].length; j++){
			if (!arr2d[i][j]) return false
		}
	}
	return true
}

function showBracket(rounds){
	$('.screen').hide()
	var table = $('#playoff-bracket').html(""),
	tr,
	maxUpper=0,
	maxLower=0,
	maxMatches=0
	for (var i=0; i<rounds.length; i++){
		rounds[i].filled = roundFilled(rounds[i])
		rounds[i].played = roundPlayed(rounds[i])
		if (rounds[i].upper && rounds[i].upper.length > maxUpper) maxUpper = rounds[i].upper.length
		if (rounds[i].lower && rounds[i].lower.length > maxLower) maxLower = rounds[i].lower.length
		if (rounds[i].matches && rounds[i].matches.length > maxMatches) maxMatches = rounds[i].matches.length
		if (dataLevel===""){
			if (!rounds[i].filled) dataLevel = i-1
			if (rounds[i].filled && !rounds[i].played && i==rounds.length-1) dataLevel = i
		} else if (i>dataLevel && rounds[i].filled){
			showRoundSchedule(rounds[i])
		}
	}
	if (maxUpper+maxLower>maxMatches)maxMatches=maxUpper+maxLower
	tr = $('<tr>')
	for (var i=0; i<rounds.length; i++){
		tr.append($('<th>').text(rounds[i]['title']))
	}
	table.append(tr)
	tr = $('<tr>')
	for (var i=0; i<rounds.length; i++){
		var round = rounds[i],
		rs = maxMatches,
		matchup = []
		if (round.hasOwnProperty('upper')){
			rs = maxUpper/Math.max(1,round['upper'].length)
			if (round['upper'].length) matchup=round['upper'][0]
		} else {
			matchup = round['matches'][0]
		}
		tr.append($('<td>').attr('rowspan',rs).html(matchupDisplay(matchup, dataLevel===i, 'Won ' + round['title'])))
	}
	table.append(tr)
	for (var j=1; j<maxUpper; j++){
		tr = $('<tr>')
		for (var i=0; i<rounds.length; i++){
			var round = rounds[i]
			if (round.hasOwnProperty('upper') && round['upper'].length && j % (maxUpper/round['upper'].length) == 0){
				var rs = maxUpper/round['upper'].length,
				matchup = round['upper'][j/rs]
				tr.append($('<td>').attr('rowspan',rs).html(matchupDisplay(matchup, dataLevel===i, 'Won ' + round['title'])))
			}
		}
		table.append(tr)
	}
	for (var j=0; j<maxLower; j++){
		tr = $('<tr>')
		for (var i=0; i<rounds.length; i++){
			var round = rounds[i]
			if (round.hasOwnProperty('lower') && j % (maxLower/Math.max(1,round['lower'].length)) == 0){
				var rs = maxLower/Math.max(1,round['lower'].length),
				matchup = round['lower'].length?round['lower'][j/rs]:[]
				tr.append($('<td>').attr('rowspan',rs).html(matchupDisplay(matchup, dataLevel===i, 'Won ' + round['title'])))
			}
		}
		table.append(tr)
	}
	table.show()

}

function showRoundSchedule(round){
	$('#schedule').html("")
	var num = 0
	$('#scheduleSection h2').text(round.title + ' Schedule')
	var numRounds = (round.rounds)||1
	for (var j=0; j<numRounds; j++){
		var brackets = (round.orderBrackets)||['upper','lower','matches']
		for (var k=0; k<brackets.length; k++){
			var matches = (round[brackets[k]])||[]
			for (var n=0; n<matches.length; n++){
				num++
				$('#schedule').append(scheduleRowHtml(matches[n][0],matches[n][1],round.abbreviation,num))
			}
		}
	}
	$('#scheduleSection').show()
}

function getDoubleEliminationBrackets(){
	var rounds = [{
		title: "Playoffs Round 1",
		upper: [[1,8],[4,5],[2,7],[3,6]],
		lower: [],
		abbreviation: '1p'
	}]
	rounds.push({
		title: "Playoffs Round 2",
		upper: [
			[winnerOf(rounds,0,'upper',0),winnerOf(rounds,0,'upper',1)],
			[winnerOf(rounds,0,'upper',2),winnerOf(rounds,0,'upper',3)]
		],
		lower: [
			[loserOf(rounds,0,'upper',0),loserOf(rounds,0,'upper',1)],
			[loserOf(rounds,0,'upper',2),loserOf(rounds,0,'upper',3)]
		],
		orderBrackets:["lower","upper"],
		abbreviation: '2p'
	})
	rounds.push({
		title: "Playoffs Round 3",
		upper: [],
		lower: [
			[loserOf(rounds,1,'upper',0),winnerOf(rounds,1,'lower',0)],
			[loserOf(rounds,1,'upper',1),winnerOf(rounds,1,'lower',1)]
		],
		orderMatches: -1,
		abbreviation: '3p'
	})
	rounds.push({
		title: "Playoffs Round 4",
		upper: [[winnerOf(rounds,1,'upper',0),winnerOf(rounds,1,'upper',1)]],
		lower: [[winnerOf(rounds,2,'lower',0),winnerOf(rounds,2,'lower',1)]],
		abbreviation: '4p'
	})
	rounds.push({
		title: "Playoffs Round 5",
		upper: [],
		lower: [[loserOf(rounds,3,'upper',0),winnerOf(rounds,3,'lower',0)]],
		abbreviation: '5p'
	})
	rounds.push({
		title: "Finals",
		matches: [[winnerOf(rounds,3,'upper',0),winnerOf(rounds,4,'lower',0)]],
		rounds: 3,
		abbreviation: 'f'
	})
	return rounds
}

function roundFilled(round){
	var arr = (round['upper']||[]).concat(round['lower']||[]).concat(round['matches']||[])
	for (var i=0; i<arr.length; i++){
		if (arr[i][0] == 0) return false
		if (arr[i][1] == 0) return false
	}
	return true
}


function roundPlayed(round){
	var arr = (round['upper']||[]).concat(round['lower']||[]).concat(round['matches']||[])
	for (var i=0; i<arr.length; i++){
		var a1 = arr[i][0], a2 = arr[i][1]
		if (a1 == 0) return false
		if (a2 == 0) return false
		if (!eventAlliances[a1-1]['Won ' + round.title] && !eventAlliances[a2-1]['Won ' + round.title]) return false
	}
	return true
}

function winnerOf(rounds,roundNum,bracket,matchNum){
	var round = rounds[roundNum],
	title = round['title']
	for (var i=0; i<=1; i++){
		var alliance = round[bracket][matchNum][i]
		if (eventAlliances && alliance>0 && eventAlliances.length > alliance-1 && eventAlliances[alliance-1]['Won ' + title]) return alliance
	}
	return 0
}

function loserOf(rounds,roundNum,bracket,matchNum){
	var winner = winnerOf(rounds, roundNum,bracket,matchNum)
	if (winner==0) return 0
	var round = rounds[roundNum],
	title = round['title']
	for (var i=0; i<=1; i++){
		var alliance = round[bracket][matchNum][i]
		if (alliance != winner) return alliance
	}
	return 0
}

function getSingleEliminationBrackets(){
	var rounds = [{
		title: "Quarter-Finals",
		upper: [[1,8],[4,5],[2,7],[3,6]],
		rounds: 3,
		abbreviation: 'qf'
	}]
	rounds.push({
		title: "Semi-Finals",
		upper: [
			[winnerOf(rounds,0,'upper',0),winnerOf(rounds,0,'upper',1)],
			[winnerOf(rounds,0,'upper',2),winnerOf(rounds,0,'upper',3)]
		],
		rounds: 3,
		abbreviation: 'sf'
	})
	rounds.push({
		title: "Finals",
		upper: [[winnerOf(rounds,1,'upper',0),winnerOf(rounds,1,'upper',1)]],
		rounds: 3,
		abbreviation: '3p'
	})
	return rounds
}

function buildAndShowSchedule(schedule, typeAbbr, typeFull){
	$(`#${typeFull}`).html('')
	for (var i=0; i<3; i++){
		for (var j=0; j<schedule.length; j++){
			$(`#${typeFull}`).append(scheduleRowHtml(schedule[j][0],schedule[j][1]),typeAbbr,i*schedule.length+j+1)
		}
	}
	$(`#${typeFull}Section`).show()
}
function eventAlliancesToCsv(){
	var headings = []
	$('#alliancesHead th').each(function(){
		headings.push($(this).text())
	})
	var csv = headings.join(',')+"\n"
	for (var i=0; i<eventAlliances.length; i++){
		for (var j=0; j<headings.length; j++){
			if (j>0) csv += ","
			csv += eventAlliances[i][headings[j]]
		}
		csv += "\n"
	}
	return csv
}

$(document).ready(function(){
	$('h1').text(eventName)
	$('#scheduleSection').hide()
	for (var i=1; i<=allianceCount; i++){
		$('#alliances').append($('template#allianceRow').html().replace(/\$\#/g, i))
	}
	$('#alliances input').change(function(){
		$("#t" + $(this).val()).addClass('picked')
		if (!focusNext()) computeStartingSchedule()
	}).focus(function(){
		focusInput($(this))
	})

	$('#save').click(function(){
		$('#eventInput').val(eventId)
		addAlliancesHiddenFields()
		$('#alliancesCsvInput').val($('#alliances').is(':visible')?tableToCsv($('#alliances').closest('table')):eventAlliancesToCsv())
		if ($('#scheduleTable').is(':visible')){
			$('#scheduleCsvInput').val(tableToCsv($('#scheduleTable')))
		}
		$('#addAlliances').submit()
		return false
	})
	loadAlliances(showContent)
	$('#playoff-bracket').click(function(e){
		var t = $(e.target)
		if (t.is(".winnerBtn")){
			var aInd=parseInt(t.attr('data-alliance'))-1
			var oppInd=parseInt(t.attr('data-opponent'))-1
			var column = t.attr('data-column')
			if (column == 'Won Finals'){
				$('#scheduleTable').hide()
				$('#scheduleSection').show()
			}
			eventAlliances[aInd][column] = 1
			eventAlliances[oppInd][column] = 0
			showContent()
			return false
		}
	})
})

function showContent(){
	if (!eventAlliances.length) showAllianceSelection()
	else showBracket(getBrackets())
}

function getBrackets(){
	if (eventAlliances && eventAlliances.length > 0){
		if (eventAlliances[0].hasOwnProperty('Won Playoffs Round 1')) return getDoubleEliminationBrackets()
		if (eventAlliances[0].hasOwnProperty('Won Quarter-Finals'))return getSingleEliminationBrackets()
	}
	if ($('#bracket-type').val()=='double') return getDoubleEliminationBrackets()
	return getSingleEliminationBrackets()
}

function getBracketTitles(){
	var rounds = getBrackets(),
	headings = []
	for (var i=0; i<rounds.length; i++){
		headings.push(rounds[i].title)
	}
	return headings
}

function addAlliancesHiddenFields(){
	var trh = $('#alliancesHead tr'),
	tr = $('.allianceTr'),
	rounds = getBracketTitles()
	trh.find('.hidden').remove()
	tr.find('.hidden').remove()
	for (var i=0; i<rounds.length; i++){
		trh.append($('<th class=hidden>').text('Won ' + rounds[i]))
		tr.append($('<td class=hidden>'))
	}
}

function computeStartingSchedule(){
	$('#schedule').html('')
	eventAlliances = csvToArrayOfMaps(tableToCsv($('#alliances').closest('table')))
	showRoundSchedule(getBrackets()[0])
}

function scheduleRowHtml(a1, a2, round, num){
	a1 = eventAlliances[a1-1]
	a2 = eventAlliances[a2-1]
	return $('template#matchRow').html().replace(/\$\#/g, num)
	.replace(/\$matchRound/, round)
	.replace(/\$team1/, a1['Captain'])
	.replace(/\$team2/, a1['First Pick'])
	.replace(/\$team3/, a1['Second Pick'])
	.replace(/\$team4/, a2['Captain'])
	.replace(/\$team5/, a2['First Pick'])
	.replace(/\$team6/, a2['Second Pick'])
}

function focusInput(input){
	if (input[0]==lf()[0]) return
	$('#alliances input').removeClass('lastFocus')
	input.addClass('lastFocus')
}

function lf(){
	return $('#alliances input.lastFocus')
}

function withoutValues(i,el){
	return $(el).val() == ''
}

function focusNext(){
	var next = $('#alliances .captain, #alliances .pick_1').filter(withoutValues).first()
	if (!next.length) next = $('#alliances .pick_2').filter(withoutValues).last()
	if (next.length) focusInput(next)
	return next.length > 0
}
