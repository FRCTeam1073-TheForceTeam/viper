"use strict"

addI18n({
	playoffs_page_title:{
		en:'Alliances, Playoffs, Finals',
		tr:'İttifaklar, Playofflar, Finaller',
		pt:'Alianças, Playoffs, Finais',
		zh_tw:'聯盟、季後賽、總決賽',
		fr:'Alliances, Playoffs, Finales',
		he:'בריתות, פלייאוף, גמר',
	},
	playoffs_event_title:{
		en:'_EVENT_',
		tr:'_EVENT_',
		pt:'_EVENT_',
		zh_tw:'_EVENT_',
		fr:'_ÉVENT_',
		he:'_EVENT_',
	},
	bracket_type_heading:{
		en:'Playoff Brackets',
		tr:'Playoff Grupları',
		pt:'Chaves dos Playoffs',
		zh_tw:'季後賽對上表',
		fr:'Tableau des Playoffs',
		he:'סוגרי פלייאוף',
	},
	bracket_type_double:{
		en:'Double elimination',
		tr:'Çift eleme',
		pt:'Eliminação dupla',
		zh_tw:'雙重淘汰制',
		fr:'Double élimination',
		he:'חיסול כפול',
	},
	bracket_type_single:{
		en:'Single elimination',
		tr:'Tek eleme',
		pt:'Eliminação simples',
		zh_tw:'單淘汰制',
		fr:'Élimination simple',
		he:'חיסול בודד',
	},
	alliance_selection_heading:{
		en:'Alliance Selection',
		tr:'İttifak Seçimi',
		pt:'Seleção da Aliança',
		zh_tw:'聯盟選擇',
		fr:'Sélection de l\'Alliance',
		he:'בחירת ברית',
	},
	alliance_heading:{
		en:'Alliance',
		tr:'İttifak',
		pt:'Aliança',
		zh_tw:'聯盟',
		fr:'Alliance',
		he:'בְּרִית',
	},
	captain_heading:{
		en:'Captain',
		tr:'Kaptan',
		pt:'Capitão',
		zh_tw:'隊長',
		fr:'Capitaine',
		he:'סֶרֶן',
	},
	first_pick_heading:{
		en:'First Pick',
		tr:'İlk Seçim',
		pt:'Primeira escolha',
		zh_tw:'首選',
		fr:'Premier choix',
		he:'בחירה ראשונה',
	},
	second_pick_heading:{
		en:'Second Pick',
		tr:'İkinci Seçim',
		pt:'Segunda escolha',
		zh_tw:'第二選擇',
		fr:'Deuxième choix',
		he:'בחירה שניה',
	},
	team_number_placeholder:{
		en:'team #',
		tr:'takım #',
		pt:'time n.º',
		zh_tw:'團隊 ＃',
		fr:'Numéro d\'équipe',
		he:'צוות #',
	},
	round_1_title:{
		en:'Playoffs Round 1',
		tr:'Playofflar 1. Tur',
		pt:'Playoffs Rodada 1',
		zh_tw:'季後賽第一輪',
		fr:'1er tour des Playoffs',
		he:'סיבוב 1 בפלייאוף',
	},
	round_2_title:{
		en:'Playoffs Round 2',
		tr:'Playofflar 2. Tur',
		pt:'Playoffs Rodada 2',
		zh_tw:'季後賽第二輪',
		fr:'2e tour des Playoffs',
		he:'סיבוב 2 בפלייאוף',
	},
	round_3_title:{
		en:'Playoffs Round 3',
		tr:'Playofflar 3. Tur',
		pt:'Playoffs Rodada 3',
		zh_tw:'季後賽第三輪',
		fr:'3e tour des Playoffs',
		he:'פלייאוף סיבוב 3',
	},
	round_4_title:{
		en:'Playoffs Round 4',
		tr:'Playofflar 4. Tur',
		pt:'Playoffs Rodada 4',
		zh_tw:'季後賽第四輪',
		fr:'4e tour des Playoffs',
		he:'פלייאוף סיבוב 4',
	},
	round_5_title:{
		en:'Playoffs Round 5',
		tr:'Playofflar 5. Tur',
		pt:'Playoffs Rodada 5',
		zh_tw:'季後賽第五輪',
		fr:'5e tour des Playoffs',
		he:'סיבוב 5 בפלייאוף',
	},
	finals_title:{
		en:'Finals',
		tr:'Finaller',
		pt:'Finais',
		zh_tw:'決賽',
		fr:'Finales',
		he:'מִשְׂחָקֵי הָגְמָר',
	},
	quarter_finals_title:{
		en:'Quarter-Finals',
		tr:'Çeyrek Finaller',
		pt:'Quartas de final',
		zh_tw:'四分之一決賽',
		fr:'Quarts de finale',
		he:'רבע גמר',
	},
	semi_finals_title:{
		en:'Semi-Finals',
		tr:'Yarı Finaller',
		pt:'Semifinais',
		zh_tw:'準決賽',
		fr:'Demi-finales',
		he:'חצי גמר',
	},
	schedule_heading:{
		en:'_ROUND_ Schedule',
		tr:'_ROUND_ Program',
		pt:'_ROUND_ Cronograma',
		zh_tw:'_ROUND_ 時間表',
		fr:'_ROUND_ Calendrier',
		he:'_ROUND_ לוח זמנים',
	},
	alliance_name:{
		en:'Alliance _ALLIANCENUM_',
		tr:'İttifak _ALLIANCENUM_',
		pt:'Aliança _ALLIANCENUM_',
		zh_tw:'聯盟 _ALLIANCENUM_',
		fr:'Alliance _ALLIANCENUM_',
		he:'ברית _ALLIANCENUM_',
	},
	prediction_label:{
		en:'Prediction: ',
		tr:'Tahmin:',
		pt:'Previsão:',
		zh_tw:'預言：',
		fr:'Pronostic :',
		he:'נְבוּאָה:',
	},
	set_winner_button:{
		en:'Set Winner',
		tr:'Set Kazananı',
		pt:'Definir vencedor',
		zh_tw:'勝者組',
		fr:'Vainqueur du set',
		he:'מנצח סט',
	},
})

var teams = []
var allianceCount = 8;

function tableToCsv(table){
	var csv=""
	table.find('tr').each(function(){
		var line=""
		$(this).find('th,td').each(function(){
			if (line) line += ","
			line += $(this).attr('data-csv') || $(this).text() || $(this).find('input').val() || ""
		})
		csv += line + "\n"
	})
	return csv
}

function showAllianceSelection(){
	$('.screen').hide()
	promiseEventTeams().then(eventTeams => {
		eventTeams.forEach(team => {
			$('#teams').append($(`<button class=team id=t${team}>${team}</button>`).click(function(){
				$(this).addClass('picked')
				lf().val($(this).text())
				if (!focusNext()) computeStartingSchedule()
			}))
		})
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
	button=showButton?`<div><button class=winnerBtn data-alliance=${num} data-opponent=${oppNum} data-column="${column}" data-i18n=set_winner_button></button></div>`:"",
	predictorLink = getPredictorLink(num,oppNum,teamColor),
	score=getPrediction(num),
	prediction=""
	if (!/^[01]$/.test(a[column])){
		if (predictorLink) prediction =`<div class=prediction><a href="${predictorLink}"><span data-i18n=prediction_label></span> <div>${score}</div></a></div>`
		else prediction = `<div class=prediction><span data-i18n=prediction_label></span> <div>${score}</div></div>`
	}
	return `<div class="${teamColor}TeamBG matchup ${winClass}"><h4 data-alliance-num=${num} data-i18n=alliance_name></h4>${c}, ${p1}, ${p2}${prediction}${button}</div>`
}

function getPredictorLink(num, oppNum, teamColor){
	var red=eventAlliances[(teamColor=='red'?num:oppNum)-1],
	blue=eventAlliances[(teamColor=='red'?oppNum:num)-1]
	if (!red||!blue) return ""
	return `/predictor.html#event=${eventId}&R1=${red['Captain']}&R2=${red['First Pick']}&R3=${red['Second Pick']}&B1=${blue['Captain']}&B2=${blue['First Pick']}&B3=${blue['Second Pick']}`
}

function getPrediction(num){
	var score = 0,
	alliance = eventAlliances[num-1]
	if (!alliance) return 0
	score += getScore(alliance['Captain'])
	score += getScore(alliance['First Pick'])
	score += getScore(alliance['Second Pick'])
	return Math.round(score)
}

function getScore(team){
	var stats = eventStatsByTeam[team]
	if (!stats) return 0
	return (stats.score||0)/(stats.count||1)
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
		tr.append($('<th>').attr('data-i18n',rounds[i].title))
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
		tr.append($('<td>').attr('rowspan',rs).html(matchupDisplay(matchup, dataLevel===i, roundToColumn(round.title))))
	}
	table.append(tr)
	for (var j=1; j<maxUpper; j++){
		tr = $('<tr>')
		for (var i=0; i<rounds.length; i++){
			var round = rounds[i]
			if (round.hasOwnProperty('upper') && round['upper'].length && j % (maxUpper/round['upper'].length) == 0){
				var rs = maxUpper/round['upper'].length,
				matchup = round['upper'][j/rs]
				tr.append($('<td>').attr('rowspan',rs).html(matchupDisplay(matchup, dataLevel===i, roundToColumn(round.title))))
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
				tr.append($('<td>').attr('rowspan',rs).html(matchupDisplay(matchup, dataLevel===i, roundToColumn(round.title))))
			}
		}
		table.append(tr)
	}
	applyTranslations()
	table.show()

}

function showRoundSchedule(round){
	$('#schedule').html("")
	var num = 0
	$('#scheduleSection h2').attr('data-translate-round',round.title).attr('data-i18n','schedule_heading')
	var numRounds = (round.rounds)||1
	for (var j=0; j<numRounds; j++){
		var brackets = (round.orderBrackets)||['upper','lower','matches']
		for (var k=0; k<brackets.length; k++){
			var matches = (round[brackets[k]])||[]
			if (round.orderMatches == -1){
				for (var n=matches.length-1; n>=0; n--){
					num++
					$('#schedule').append(scheduleRowHtml(matches[n][0],matches[n][1],round.abbreviation,num))
				}
			} else {
				for (var n=0; n<matches.length; n++){
					num++
					$('#schedule').append(scheduleRowHtml(matches[n][0],matches[n][1],round.abbreviation,num))
				}
			}
		}
	}
	$('#scheduleSection').show()
	applyTranslations()
}

function getDoubleEliminationBrackets(){
	var rounds = [{
		title: "round_1_title",
		upper: [[1,8],[4,5],[2,7],[3,6]],
		lower: [],
		abbreviation: '1p'
	}]
	rounds.push({
		title: "round_2_title",
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
		title: "round_3_title",
		upper: [],
		lower: [
			[loserOf(rounds,1,'upper',1),winnerOf(rounds,1,'lower',0)],
			[loserOf(rounds,1,'upper',0),winnerOf(rounds,1,'lower',1)]
		],
		orderMatches: -1,
		abbreviation: '3p'
	})
	rounds.push({
		title: "round_4_title",
		upper: [[winnerOf(rounds,1,'upper',0),winnerOf(rounds,1,'upper',1)]],
		lower: [[winnerOf(rounds,2,'lower',0),winnerOf(rounds,2,'lower',1)]],
		abbreviation: '4p'
	})
	rounds.push({
		title: "round_5_title",
		upper: [],
		lower: [[loserOf(rounds,3,'upper',0),winnerOf(rounds,3,'lower',0)]],
		abbreviation: '5p'
	})
	rounds.push({
		title: "finals_title",
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
		if (!eventAlliances[a1-1][roundToColumn(round.title)] && !eventAlliances[a2-1][roundToColumn(round.title)]) return false
	}
	return true
}

function roundToColumn(title){
	return 'Won ' + translate(title,{},'en')
}

function winnerOf(rounds,roundNum,bracket,matchNum){
	var round = rounds[roundNum],
	title = round['title']
	for (var i=0; i<=1; i++){
		var alliance = round[bracket][matchNum][i]
		if (eventAlliances && alliance>0 && eventAlliances.length > alliance-1 && eventAlliances[alliance-1][roundToColumn(title)]) return alliance
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
		title: "quarter_finals_title",
		upper: [[1,8],[4,5],[2,7],[3,6]],
		rounds: 3,
		abbreviation: 'qf'
	}]
	rounds.push({
		title: "semi_finals_title",
		upper: [
			[winnerOf(rounds,0,'upper',0),winnerOf(rounds,0,'upper',1)],
			[winnerOf(rounds,0,'upper',2),winnerOf(rounds,0,'upper',3)]
		],
		rounds: 3,
		abbreviation: 'sf'
	})
	rounds.push({
		title: "finals_title",
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
		headings.push(translate($(this).attr('data-i18n'),{},'en')||$(this).text())
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
	addTranslationContext({event:eventName})
	$('title,h1').attr('data-i18n','playoffs_event_title')
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
	promiseAlliances().then(ea => {
		window.eventAlliances = ea
		showContent()
	})
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
	focusNext()
	applyTranslations()
})

function showContent(ea){
	if (!eventAlliances.length) showAllianceSelection()
	else promiseEventStats(true).then(values => {
		[window.eventStats, window.eventStatsByTeam] = values
		showBracket(getBrackets())
	})
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
		trh.append($('<th class=hidden>').text(roundToColumn(rounds[i])))
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
