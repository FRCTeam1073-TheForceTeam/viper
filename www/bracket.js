"use strict"

addI18n({
	bracket_page_title:{
		en:'Playoff Bracket',
		tr:'Playoff Grubu',
		pt:'Chave dos Playoffs',
		zh_tw:'季後賽對戰表',
		fr:'Tableau des Playoffs',
		he:'סוגר פלייאוף',
		es:'Cuadro de Playoff',
	},
	no_bracket_message:{
		en:'No bracket has been generated for this event yet.',
		tr:'Bu etkinlik için henüz bir grup oluşturulmadı.',
		pt:'Nenhuma chave foi gerada para este evento ainda.',
		zh_tw:'此賽事尚未產生對戰表。',
		fr:'Aucun tableau n\'a encore été généré pour cet événement.',
		he:'טרם נוצר סוגר לאירוע זה.',
		es:'Aún no se ha generado un cuadro para este evento.',
	},
	round_1_title:{
		en:'Playoffs Round 1',
		tr:'Playofflar 1. Tur',
		pt:'Playoffs Rodada 1',
		zh_tw:'季後賽第一輪',
		fr:'1er tour des Playoffs',
		he:'סיבוב 1 בפלייאוף',
		es:'Ronda de Playoff 1',
	},
	round_2_title:{
		en:'Playoffs Round 2',
		tr:'Playofflar 2. Tur',
		pt:'Playoffs Rodada 2',
		zh_tw:'季後賽第二輪',
		fr:'2e tour des Playoffs',
		he:'סיבוב 2 בפלייאוף',
		es:'Ronda de Playoff 2',
	},
	round_3_title:{
		en:'Playoffs Round 3',
		tr:'Playofflar 3. Tur',
		pt:'Playoffs Rodada 3',
		zh_tw:'季後賽第三輪',
		fr:'3e tour des Playoffs',
		he:'פלייאוף סיבוב 3',
		es:'Ronda de Playoff 3',
	},
	round_4_title:{
		en:'Playoffs Round 4',
		tr:'Playofflar 4. Tur',
		pt:'Playoffs Rodada 4',
		zh_tw:'季後賽第四輪',
		fr:'4e tour des Playoffs',
		he:'פלייאוף סיבוב 4',
		es:'Ronda de Playoff 4',
	},
	round_5_title:{
		en:'Playoffs Round 5',
		tr:'Playofflar 5. Tur',
		pt:'Playoffs Rodada 5',
		zh_tw:'季後賽第五輪',
		fr:'5e tour des Playoffs',
		he:'סיבוב 5 בפלייאוף',
		es:'Ronda de Playoff 5',
	},
	finals_title:{
		en:'Finals',
		tr:'Finaller',
		pt:'Finais',
		zh_tw:'決賽',
		fr:'Finales',
		he:'מִשְׂחָקֵי הָגְמָר',
		es:'Finales',
	},
	quarter_finals_title:{
		en:'Quarter-Finals',
		tr:'Çeyrek Finaller',
		pt:'Quartas de final',
		zh_tw:'四分之一決賽',
		fr:'Quarts de finale',
		he:'רבע גמר',
		es:'Cuartos de final',
	},
	semi_finals_title:{
		en:'Semi-Finals',
		tr:'Yarı Finaller',
		pt:'Semifinais',
		zh_tw:'準決賽',
		fr:'Demi-finales',
		he:'חצי גמר',
		es:'Semifinales',
	},
	alliance_name:{
		en:'Alliance _ALLIANCENUM_',
		tr:'İttifak _ALLIANCENUM_',
		pt:'Aliança _ALLIANCENUM_',
		zh_tw:'聯盟 _ALLIANCENUM_',
		fr:'Alliance _ALLIANCENUM_',
		he:'ברית _ALLIANCENUM_',
		es:'Alianza _ALLIANCENUM_',
	},
	prediction_label:{
		en:'Prediction: ',
		tr:'Tahmin:',
		pt:'Previsão:',
		zh_tw:'預言：',
		fr:'Pronostic :',
		he:'נְבוּאָה:',
		es:'Predicción:',
	},
	upper_bracket_label:{
		en:'Upper Bracket',
		tr:'Üst Grup',
		pt:'Chave Superior',
		zh_tw:'勝部',
		fr:'Tableau Supérieur',
		he:'בית עליון',
		es:'Llave Superior',
	},
	lower_bracket_label:{
		en:'Lower Bracket',
		tr:'Alt Grup',
		pt:'Chave Inferior',
		zh_tw:'敗部',
		fr:'Tableau Inférieur',
		he:'בית תחתון',
		es:'Llave Inferior',
	},
})

var fourTeam = false
var dataLevel = ""
var bracketMatchNumMap = {}
var bracketSlotInfoMap = {}

function allianceDisplay(num, oppNum, showButton, column, teamColor, placeholder){
	if (num == 0) return `<div class="${teamColor}TeamBG matchup placeholder">${placeholder||'?'}</div>`
	var a = eventAlliances[num-1],
	decided = /^[01]$/.test(a[column]),
	winClass = a[column]?"winner":"",
	c = a['Captain'],
	p1 = a['First Pick'],
	p2 = a['Second Pick'],
	b = a['Backup'],
	roster = b ? `${c}, ${p1}, ${p2}, ${b}` : `${c}, ${p1}, ${p2}`,
	predictorLink = getPredictorLink(num,oppNum,teamColor),
	score = getPrediction(num),
	predBox = decided ? "" : (predictorLink
		? `<a class=predBox href="${predictorLink}">${score}</a>`
		: `<span class=predBox>${score}</span>`)
	// View-only: never add clickable class or data attributes
	return `<div class="${teamColor}TeamBG matchup ${winClass}" data-alliance-badge="A${num}"><div class=matchupMain><span class=roster>${roster}</span></div>${predBox}</div>`
}

function getPredictorLink(num, oppNum, teamColor){
	var red=eventAlliances[(teamColor=='red'?num:oppNum)-1],
	blue=eventAlliances[(teamColor=='red'?oppNum:num)-1]
	if (!red||!blue) return ""
	return `/predictor.html#event=${eventId}&mode=playoff&ra=${red['Alliance']}&ba=${blue['Alliance']}`
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

function bracketMatchNumbers(rounds){
	var map = {}, num = 0
	rounds.forEach(function(round,r){
		var brackets = round.orderBrackets || ['upper','lower','matches']
		brackets.forEach(function(b){
			var matches = round[b] || [],
			order = matches.map(function(_,m){ return m })
			if (round.orderMatches == -1) order.reverse()
			order.forEach(function(m){
				if (!matches[m] || !matches[m].length) return
				map[r+'_'+b+'_'+m] = ++num
			})
		})
	})
	return map
}

function showBracket(rounds){
	var wasHidden = $('#bracketWrap').is(':hidden')
	dataLevel = ""
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
	}
	if (maxUpper+maxLower>maxMatches) maxMatches=maxUpper+maxLower
	bracketMatchNumMap = bracketMatchNumbers(rounds)
	bracketSlotInfoMap = bracketSlotInfo()
	tr = $('<tr>')
	if (maxLower>0) tr.append($('<th>').addClass('bracketSideHead'))
	for (var i=0; i<rounds.length; i++){
		tr.append($('<th>').attr('data-i18n',rounds[i].title))
	}
	table.append(tr)
	tr = $('<tr>')
	if (maxLower>0) tr.append($('<td>').addClass('bracketSide').attr('rowspan',maxUpper).html('<span class=bracketSideText data-i18n=upper_bracket_label></span>'))
	for (var i=0; i<rounds.length; i++){
		var round = rounds[i],
		rs = maxMatches,
		matchup = [],
		mid = null
		if (round.hasOwnProperty('upper')){
			rs = maxUpper/Math.max(1,round['upper'].length)
			if (round['upper'].length){ matchup=round['upper'][0]; mid=i+'_upper_0' }
		} else {
			matchup = round['matches'][0]
			mid = i+'_matches_0'
		}
		// View-only: always pass false so no alliance is clickable
		tr.append(bracketTd(rs, matchup, false, roundToColumn(round.title), mid))
	}
	table.append(tr)
	for (var j=1; j<maxUpper; j++){
		tr = $('<tr>')
		for (var i=0; i<rounds.length; i++){
			var round = rounds[i]
			if (round.hasOwnProperty('upper') && round['upper'].length && j % (maxUpper/round['upper'].length) == 0){
				var rs = maxUpper/round['upper'].length,
				matchup = round['upper'][j/rs]
				tr.append(bracketTd(rs, matchup, false, roundToColumn(round.title), i+'_upper_'+(j/rs)))
			}
		}
		table.append(tr)
	}
	for (var j=0; j<maxLower; j++){
		tr = $('<tr>')
		if (j==0) tr.append($('<td>').addClass('bracketSide').attr('rowspan',maxLower).html('<span class=bracketSideText data-i18n=lower_bracket_label></span>'))
		for (var i=0; i<rounds.length; i++){
			var round = rounds[i]
			if (round.hasOwnProperty('lower') && j % (maxLower/Math.max(1,round['lower'].length)) == 0){
				var rs = maxLower/Math.max(1,round['lower'].length),
				matchup = round['lower'].length?round['lower'][j/rs]:[]
				tr.append(bracketTd(rs, matchup, false, roundToColumn(round.title), round['lower'].length?i+'_lower_'+(j/rs):null))
			}
		}
		table.append(tr)
	}
	applyTranslations()
	$('#bracketWrap').show()
	table.show()
	setTimeout(drawBracketLines, 0)
	if (wasHidden) setTimeout(animateBracketReveal, 0)
}

function animateBracketReveal(){
	var wrap = document.getElementById('bracketWrap')
	if (!wrap) return
	var svg = document.getElementById('bracketLines'),
	maxDelay = 0
	wrap.querySelectorAll('.matchCell').forEach(function(td){
		var round = parseInt(td.getAttribute('data-mid')) || 0,
		delay = round * 0.12,
		pair = td.querySelector('.matchupPair')
		if (delay > maxDelay) maxDelay = delay
		if (pair) pair.style.animation = 'bracketCardReveal .5s cubic-bezier(.2,.7,.3,1) ' + delay + 's both'
	})
	if (svg) svg.style.animation = 'bracketLinesFade .7s ease ' + (maxDelay*0.5) + 's both'
	setTimeout(function(){
		wrap.querySelectorAll('.matchupPair').forEach(function(pair){ pair.style.animation = '' })
		if (svg) svg.style.animation = ''
	}, (maxDelay + 1.5) * 1000)
}

function bracketTd(rs, matchup, isData, column, mid){
	var td = $('<td>').attr('rowspan',rs)
	if (!(mid && matchup && matchup.length)) return td
	td.addClass('matchCell').attr('data-mid', mid)
	var n = bracketMatchNumMap[mid],
	info = bracketSlotInfoMap[mid] || [null,null],
	red = allianceDisplay(matchup[0], matchup[1], false, column, 'red', slotLabel(info[0])),
	blue = allianceDisplay(matchup[1], matchup[0], false, column, 'blue', slotLabel(info[1])),
	bar = '<div class=matchBar>'+(n ? 'Match '+n+' (M'+n+')' : '')+'</div>'
	td.html('<div class=matchupPair>'+red+bar+blue+'</div>')
	return td
}

function bracketSlotInfo(){
	var realWinner = winnerOf, realLoser = loserOf
	winnerOf = function(rounds,r,b,m){ return {__src:r+'_'+b+'_'+m, __t:'W'} }
	loserOf  = function(rounds,r,b,m){ return {__src:r+'_'+b+'_'+m, __t:'L'} }
	var rounds
	try { rounds = getBracketBuilder()() }
	finally { winnerOf = realWinner; loserOf = realLoser }
	var map = {}
	rounds.forEach(function(round,r){
		;['upper','lower','matches'].forEach(function(b){
			(round[b]||[]).forEach(function(pair,m){
				var slots = [null,null]
				for (var s=0; s<2; s++) if (pair[s] && pair[s].__src) slots[s] = {src:pair[s].__src, type:pair[s].__t}
				if (slots[0] || slots[1]) map[r+'_'+b+'_'+m] = slots
			})
		})
	})
	return map
}

function slotLabel(info){
	if (!info) return null
	var n = bracketMatchNumMap[info.src]
	if (!n) return null
	return (info.type=='W' ? 'Winner of M' : 'Loser of M') + n
}

function drawBracketLines(){
	var wrap = document.getElementById('bracketWrap'),
	svg = document.getElementById('bracketLines')
	if (!wrap || !svg || wrap.style.display === 'none') return
	while (svg.firstChild) svg.removeChild(svg.firstChild)
	var w = wrap.scrollWidth, h = wrap.scrollHeight
	svg.setAttribute('width',w); svg.setAttribute('height',h)
	svg.style.width = w+'px'; svg.style.height = h+'px'
	var wr = wrap.getBoundingClientRect(),
	sources = bracketSlotInfoMap
	Object.keys(sources).forEach(function(dest){
		var destEl = wrap.querySelector('[data-mid="'+dest+'"]')
		if (!destEl) return
		var dr = destEl.getBoundingClientRect(),
		destBracket = dest.split('_')[1],
		x2 = dr.left - wr.left + wrap.scrollLeft,
		y2 = dr.top - wr.top + wrap.scrollTop + dr.height/2
		sources[dest].forEach(function(info,slot){
			if (!info) return
			if (destBracket !== 'matches' && info.src.split('_')[1] !== destBracket) return
			var srcEl = wrap.querySelector('[data-mid="'+info.src+'"]')
			if (!srcEl) return
			var sr = srcEl.getBoundingClientRect(),
			x1 = sr.right - wr.left + wrap.scrollLeft,
			y1 = sr.top - wr.top + wrap.scrollTop + sr.height/2,
			midx = (x1+x2)/2,
			path = document.createElementNS('http://www.w3.org/2000/svg','path')
			path.setAttribute('d','M'+x1+' '+y1+' H'+midx+' V'+y2+' H'+x2)
			path.setAttribute('class','bracketLine')
			svg.appendChild(path)
		})
	})
	var upperCells = wrap.querySelectorAll('[data-mid*="_upper_"]'),
	lowerCells = wrap.querySelectorAll('[data-mid*="_lower_"]')
	if (upperCells.length && lowerCells.length){
		var upperBottom = -Infinity, lowerTop = Infinity
		upperCells.forEach(function(el){ upperBottom = Math.max(upperBottom, el.getBoundingClientRect().bottom - wr.top + wrap.scrollTop) })
		lowerCells.forEach(function(el){ lowerTop = Math.min(lowerTop, el.getBoundingClientRect().top - wr.top + wrap.scrollTop) })
		var dy = Math.round((upperBottom + lowerTop) / 2),
		divider = document.createElementNS('http://www.w3.org/2000/svg','path')
		divider.setAttribute('d','M0 '+dy+' H'+w)
		divider.setAttribute('class','bracketDivider')
		svg.appendChild(divider)
	}
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

function getBrackets(){
	return getBracketBuilder()()
}

function getBracketBuilder(){
	var single
	if (eventAlliances && eventAlliances.length > 0 && eventAlliances[0].hasOwnProperty('Won Quarter-Finals')) single = true
	else if (eventAlliances && eventAlliances.length > 0 && eventAlliances[0].hasOwnProperty('Won Playoffs Round 1')) single = false
	else single = true
	return single ? getSingleEliminationBrackets : getDoubleEliminationBrackets
}

function syncFourTeam(){
	if (eventAlliances && eventAlliances.length && eventAlliances[0].hasOwnProperty('Backup')) fourTeam = true
}

$(document).ready(function(){
	addTranslationContext({event:eventName})
	$('title,h1').text(eventName ? eventName + ' — Playoff Bracket' : 'Playoff Bracket')
	promiseAlliances().then(ea => {
		window.eventAlliances = ea
		if (!ea.length){
			$('#no-bracket-msg').show()
			return
		}
		promiseEventStats(true).then(values => {
			[window.eventStats, window.eventStatsByTeam] = values
			syncFourTeam()
			showBracket(getBrackets())
		}).catch(function(){
			// Show bracket without predictions if stats fail
			window.eventStats = []
			window.eventStatsByTeam = {}
			syncFourTeam()
			showBracket(getBrackets())
		})
	}).catch(function(){
		$('#no-bracket-msg').show()
	})
	applyTranslations()
	$(window).on('resize', drawBracketLines)
})
