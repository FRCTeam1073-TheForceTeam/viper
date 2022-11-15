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
		positions = ["R1","R2","R3","B1","B2","B3"]
		for (var i=1; i<data.length; i++){
			for (var j=0; j<positions.length; j++){
				t[data[i][positions[j]]] = 1
			}
		}
		teams = Object.keys(t);
		teams.sort((a,b) => {return a-b})
		for (var i=0; i<teams.length; i++){
			var team = teams[i]
			$('#teams').append($(`<button class=team id=t${team}>${team}</button>`).click(function(){
				$(this).addClass('picked')
				lf().val($(this).text())
				if (!focusNext()) computeSchedule()
			}))
		}
	})
	$('#alliance-selection').show()
}

function allianceDisplay(num, oppNum, column){
	if (num == 0) return '?'
	var a = eventAlliances[num-1]
	var c = a['Captain']
	var p1 = a['First Pick']
	var p2 = a['Second Pick']
	var button = column==dataLevel?`<br><button class=winnerBtn data-alliance=${num} data-opponent=${oppNum} data-column="${column}">Advance →</button>`:""
	return `<h4>Alliance ${num}</h4>${c}, ${p1}, ${p2}${button}`
}

function matchupDisplay(nums, column){
	var a1=allianceDisplay(nums[0],nums[1],column)
	var a2=allianceDisplay(nums[1],nums[0],column)
	return `<div class="redTeamBG matchup">${a1}</div><div class="blueTeamBG matchup">${a2}</div>`
}

const WQF = 'Won Quarter-Finals'
const WSF = 'Won Semi-Finals'
const WF = 'Won Finals'

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

function showBrackets(){
	$('.screen').hide()
	$('#bracketTable').html("")
	var qf = [[1,8],[4,5],[2,7],[3,6]]
	var sf = [[0,0],[0,0]]
	var f = [[0,0]]
	var w = 0
	for(var i=0; i<sf.length; i++){
		sf[i][0] = getWinner(qf,i*2,WQF)
		sf[i][1] = getWinner(qf,i*2+1,WQF)
	}
	f[0][0] = getWinner(sf,0,WSF)
	f[0][1] = getWinner(sf,1,WSF)
	w = getWinner(f,0,'Won Finals')
	if (!dataLevel && !filled(sf)) dataLevel = WQF
	if (!dataLevel && !filled(f)) dataLevel = WSF
	if (!dataLevel && !w) dataLevel = WF
	if (!dataLevel) dataLevel = "done"
	for(var i=0; i<qf.length; i++){
		var tr = $('<tr>').html('<td>' + matchupDisplay(qf[i],WQF) + "</td>")
		if (i%2==0) tr.append($("<td rowspan=2>"+matchupDisplay(sf[Math.floor(i/2)],WSF)+"</td>"))
		if (i==0){
			tr.append($("<td rowspan=4>"+matchupDisplay(f[Math.floor(i/4)],WF)+"</td>"))
			tr.append($("<td rowspan=4><div class=winner>"+allianceDisplay(w)+"</div></td>"))
		}
		$('#bracketTable').append(tr)
	}
	if (dataLevel == WQF && filled(sf)) buildAndShowSchedule(sf, "sf", "semiFinals")
	if (dataLevel == WSF && filled(f)) buildAndShowSchedule(f, "f", "finals")
	if (dataLevel == WF && w) $('#winnerSection').show()
	$('#brackets').show()
}

function buildAndShowSchedule(schedule, typeAbbr, typeFull){
	$(`#${typeFull}`).html('')
	for (var i=0; i<3; i++){
		for (var j=0; j<schedule.length; j++){
			var a1=schedule[j][0]-1, a2 = schedule[j][1]-1,
			html = $('template#matchRow').html().replace(/\$\#/g, i*schedule.length+j+1)
				.replace(/\$matchRound/, typeAbbr)
				.replace(/\$team1/, eventAlliances[a1]['Captain'])
				.replace(/\$team2/, eventAlliances[a1]['First Pick'])
				.replace(/\$team3/, eventAlliances[a1]['Second Pick'])
				.replace(/\$team4/, eventAlliances[a2]['Captain'])
				.replace(/\$team5/, eventAlliances[a2]['First Pick'])
				.replace(/\$team6/, eventAlliances[a2]['Second Pick'])
			$(`#${typeFull}`).append(html)
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
	for (var i=1; i<=allianceCount; i++){
		$('#alliances').append($('template#allianceRow').html().replace(/\$\#/g, i))
	}
	$('#alliances input').change(function(){
		$("#t" + $(this).val()).addClass('picked')
		if (!focusNext()) computeSchedule()
	}).focus(function(){
		focusInput($(this))
	})
	if (!focusNext()) computeSchedule()

	$('#saveQF').click(function(){
		$('#eventInput').val(eventId)
		$('#alliancesCsvInput').val(tableToCsv($('#alliances').closest('table')))
		$('#quarterFinalsCsvInput').val(tableToCsv($('#quarterFinals').closest('table')))
		$('#addAlliances').submit()
	})
	$('#saveSF').click(function(){
		$('#eventInput').val(eventId)
		$('#alliancesCsvInput').val(eventAlliancesToCsv())
		$('#semiFinalsCsvInput').val(tableToCsv($('#semiFinals').closest('table')))
		$('#addAlliances').submit()
	})
	$('#saveF').click(function(){
		$('#eventInput').val(eventId)
		$('#alliancesCsvInput').val(eventAlliancesToCsv())
		$('#finalsCsvInput').val(tableToCsv($('#finals').closest('table')))
		$('#addAlliances').submit()
	})
	$('#saveW').click(function(){
		$('#eventInput').val(eventId)
		$('#alliancesCsvInput').val(eventAlliancesToCsv())
		$('#addAlliances').submit()
	})

	loadAlliances(function(data){
		if (!data.length) showAllianceSelection()
		else showBrackets()
	})
	$('#brackets').click(function(e){
		var t = $(e.target)
		if (t.is(".winnerBtn")){
			var aInd=parseInt(t.attr('data-alliance'))-1
			var oppInd=parseInt(t.attr('data-opponent'))-1
			var column = t.attr('data-column')
			eventAlliances[aInd][column] = 1
			eventAlliances[oppInd][column] = 0
			showBrackets()
			return false
		}
	})
})

function computeSchedule(){
	$('#quarterFinalSection').show()
	$('#quarterFinals').html('')
	var schedule = [[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6]]
	for (var i=1; i<=schedule.length; i++){
		var a1=schedule[i-1][0], a2 = schedule[i-1][1],
		html = $('template#matchRow').html().replace(/\$\#/g, i)
			.replace(/\$matchRound/, 'qf')
			.replace(/\$team1/, $(`#A${a1}_captain`).val())
			.replace(/\$team2/, $(`#A${a1}_pick_1`).val())
			.replace(/\$team3/, $(`#A${a1}_pick_2`).val())
			.replace(/\$team4/, $(`#A${a2}_captain`).val())
			.replace(/\$team5/, $(`#A${a2}_pick_1`).val())
			.replace(/\$team6/, $(`#A${a2}_pick_2`).val())
		$('#quarterFinals').append(html)
	}
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
