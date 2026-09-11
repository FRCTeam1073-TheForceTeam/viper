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
	official_score_label:{
		en:'Official score',
		tr:'Resmi skor',
		pt:'Pontuação oficial',
		zh_tw:'官方分數',
		fr:'Score officiel',
		he:'ניקוד רשמי',
		es:'Puntuación oficial',
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
var bracketMatchupMap = {}
var officialScoreMap = {}
// Upper bound when walking a series, so a malformed schedule can't spin.
var MAX_SERIES_MATCHES = 16
// How far a roster may shrink before it is allowed to clip instead.
var MIN_ROSTER_SCALE = 0.6

function allianceDisplay(num, oppNum, showButton, column, teamColor, placeholder, mid){
	if (num == 0) return `<div class="${teamColor}TeamBG matchup placeholder">${placeholder||'?'}</div>`
	var a = eventAlliances[num-1],
	decided = /^[01]$/.test(a[column]),
	// Official scores settle the cell when they can. The recorded column is the
	// fallback, and "0" there means this alliance lost — a truthy string, so
	// compare it rather than testing truthiness.
	cellWinner = officialCellWinner(mid),
	winClass = (cellWinner ? cellWinner==num : a[column]=="1")?"winner":"",
	c = a['Captain'],
	p1 = a['First Pick'],
	p2 = a['Second Pick'],
	b = a['Backup'],
	roster = b ? `${c}, ${p1}, ${p2}, ${b}` : `${c}, ${p1}, ${p2}`,
	predictorLink = getPredictorLink(num,oppNum,teamColor),
	score = getPrediction(num),
	official = officialScores(mid, num),
	predBox = official.length
		? `<span class="predBox officialScore${official.length>1?' series':''}" title="${translate('official_score_label')}">${official.map(function(s){
			return `<span class="seriesScore${s.won?' seriesWin':''}">${s.points}</span>`
		}).join('<span class=seriesSep>/</span>')}</span>`
		: (decided ? "" : (predictorLink
			? `<a class=predBox href="${predictorLink}">${score}</a>`
			: `<span class=predBox>${score}</span>`))
	// View-only: never add clickable class or data attributes
	return `<div class="${teamColor}TeamBG matchup ${winClass}" data-alliance-badge="A${num}"><div class=matchupMain><span class=roster>${roster}</span></div>${predBox}</div>`
}

// Official scores posted by the FIRST API for one alliance in one bracket cell,
// as {points, won} per match played so far. A series cell (finals) returns one
// entry per match, however many were needed to settle it.
function officialScores(mid, num){
	return (officialScoreMap[mid]||{})[num] || []
}

// Who won a bracket cell according to the official scores, or 0 while it is
// undecided. A series needs a majority, so an in-progress finals doesn't crown
// whoever happens to be ahead.
function officialCellWinner(mid){
	var cell = bracketMatchupMap[mid],
	scores = officialScoreMap[mid]
	if (!cell || !scores) return 0
	var wins = cell.pair.map(function(num){
		return (scores[num]||[]).filter(function(s){ return s.won }).length
	})
	if (wins[0] == wins[1]) return 0
	var top = wins[0] > wins[1] ? 0 : 1
	return wins[top] >= cell.winsNeeded ? cell.pair[top] : 0
}

function allianceTeams(num){
	var a = eventAlliances[num-1]
	if (!a) return []
	return ['Captain','First Pick','Second Pick','Backup'].map(function(k){ return a[k] })
		.filter(function(t){ return t !== undefined && t !== null && t !== "" })
		.map(function(t){ return ""+t })
}

// Which alliance fielded these three teams? Two of three is enough so a match
// played with a backup robot still resolves.
function allianceForTeams(teams){
	var best = 0, bestOverlap = 0
	for (var i=1; i<=eventAlliances.length; i++){
		var roster = allianceTeams(i),
		overlap = teams.filter(function(t){ return roster.indexOf(t) >= 0 }).length
		if (overlap > bestOverlap){ bestOverlap = overlap; best = i }
	}
	return bestOverlap >= 2 ? best : 0
}

function matchTotalPoints(score){
	var totals = {}
	;(score.alliances||[]).forEach(function(alliance){
		totals[(alliance.alliance||"").toLowerCase()] = alliance.totalPoints
	})
	return totals
}

// Map each bracket cell onto the played matches that filled it, so the cards can
// show real FIRST API scores instead of predictions. Playoff matches are named
// <round abbreviation><ordinal>, numbered exactly the way showRoundSchedule
// numbers them, so the cell -> match mapping is positional, not guesswork.
function computeOfficialScores(){
	officialScoreMap = {}
	if (!window.eventMatches || !window.eventScores || !eventAlliances || !eventAlliances.length) return
	var matchesById = {}
	eventMatches.forEach(function(match){ matchesById[match.Match] = match })
	Object.keys(bracketMatchupMap).forEach(function(mid){
		var cell = bracketMatchupMap[mid],
		scores = {}
		var sides = null
		seriesMatchIds(cell, matchesById).forEach(function(id){
			var match = matchesById[id],
			score = eventScores[id]
			if (!score || !score.alliances) return
			var totals = matchTotalPoints(score)
			if (typeof totals.red != 'number' || typeof totals.blue != 'number') return
			// The schedule decides which alliance is red in a given match, so
			// resolve the sides by roster rather than by bracket order. Sides
			// hold for a whole series, so an unscheduled extra match reuses the
			// assignment we already worked out.
			if (match) sides = {
				red: allianceForTeams(['R1','R2','R3'].map(function(p){ return ""+match[p] })) || cell.pair[0],
				blue: allianceForTeams(['B1','B2','B3'].map(function(p){ return ""+match[p] })) || cell.pair[1]
			}
			if (!sides) return
			var red = sides.red, blue = sides.blue
			if (red == blue) return
			if (cell.pair.indexOf(red) < 0 || cell.pair.indexOf(blue) < 0) return
			;(scores[red] = scores[red]||[]).push({points:totals.red, won:totals.red > totals.blue})
			;(scores[blue] = scores[blue]||[]).push({points:totals.blue, won:totals.blue > totals.red})
		})
		extraSeriesScores(cell, matchesById).forEach(function(score){
			var totals = matchTotalPoints(score)
			if (!sides || typeof totals.red != 'number' || typeof totals.blue != 'number') return
			;(scores[sides.red] = scores[sides.red]||[]).push({points:totals.red, won:totals.red > totals.blue})
			;(scores[sides.blue] = scores[sides.blue]||[]).push({points:totals.blue, won:totals.blue > totals.red})
		})
		if (Object.keys(scores).length) officialScoreMap[mid] = scores
	})
}

// Every scheduled match id for this cell: its position in the round, then one
// id per repeat, a full round apart (f1/f2/f3, or qf1..qf4 then qf5..qf8).
function seriesMatchIds(cell, matchesById){
	var ids = []
	for (var j=0; j<MAX_SERIES_MATCHES; j++){
		var id = cell.abbreviation + (j*cell.perRep + cell.position)
		if (!matchesById[id]) break
		ids.push(id)
	}
	return ids
}

// Scores with no schedule row of their own. They continue the last scheduled
// playoff match, so they belong to the last cell of the bracket — a finals that
// ran long. When the schedule simply hasn't caught up (rounds still unposted)
// that match isn't the final one, and the leftovers aren't ours to place.
function extraSeriesScores(cell, matchesById){
	var extras = eventScores.extraPlayoffScores
	if (!extras || !extras.length || !cell.isLast) return []
	var scheduled = seriesMatchIds(cell, matchesById)
	if (scheduled.indexOf(eventScores.lastScheduledPlayoff) < 0) return []
	return extras
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
	var map = {}, num = 0, roundNum = {}
	bracketMatchupMap = {}
	rounds.forEach(function(round,r){
		var brackets = round.orderBrackets || ['upper','lower','matches']
		roundNum[r] = 0
		brackets.forEach(function(b){
			var matches = round[b] || [],
			order = matches.map(function(_,m){ return m })
			if (round.orderMatches == -1) order.reverse()
			order.forEach(function(m){
				if (!matches[m] || !matches[m].length) return
				var mid = r+'_'+b+'_'+m
				map[mid] = ++num
				if (matches[m][0] && matches[m][1])
					bracketMatchupMap[mid] = {
						pair:[matches[m][0],matches[m][1]],
						abbreviation:round.abbreviation,
						perRep:roundCellCount(round),
						position:++roundNum[r],
						winsNeeded:Math.floor((round.rounds||1)/2)+1,
						isLast:r == rounds.length-1
					}
			})
		})
	})
	return map
}

// How many cells a round has. Repeat matches of a series are numbered a full
// round apart (f1/f2/f3, or qf1..qf4 then qf5..qf8), the way showRoundSchedule
// numbers them, so this is the stride between one cell's matches.
function roundCellCount(round){
	var brackets = round.orderBrackets || ['upper','lower','matches'],
	n = 0
	brackets.forEach(function(b){
		(round[b]||[]).forEach(function(matchup){ if (matchup && matchup.length) n++ })
	})
	return n
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
	computeOfficialScores()
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
	fitRosterText()
	setTimeout(drawBracketLines, 0)
	if (wasHidden) setTimeout(animateBracketReveal, 0)
}

// Scale a roster down until it fits its tile on one line. Wrapping would make
// that tile taller than every other one, so the text gives way instead.
function fitRosterText(){
	document.querySelectorAll('#bracketWrap .roster').forEach(function(el){
		el.style.fontSize = ''
		var base = parseFloat(window.getComputedStyle(el).fontSize)
		if (!base || !el.clientWidth) return
		var size = base
		for (var i=0; i<10 && el.scrollWidth > el.clientWidth; i++){
			size = size * el.clientWidth / el.scrollWidth * 0.99
			if (size <= base*MIN_ROSTER_SCALE){
				el.style.fontSize = (base*MIN_ROSTER_SCALE)+'px'
				break
			}
			el.style.fontSize = size+'px'
		}
	})
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
	red = allianceDisplay(matchup[0], matchup[1], false, column, 'red', slotLabel(info[0]), mid),
	blue = allianceDisplay(matchup[1], matchup[0], false, column, 'blue', slotLabel(info[1]), mid),
	bar = '<div class=matchBar>'+(n ? 'Match '+n+' (M'+n+')' : '')+'</div>',
	// A series shows one score per match, so give the card room for the extras
	// rather than taking it out of the rosters.
	extra = Math.max(0, Math.max(officialScores(mid,matchup[0]).length, officialScores(mid,matchup[1]).length) - 1)
	td.html('<div class=matchupPair style="--extraScores:'+extra+'">'+red+bar+blue+'</div>')
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
		var col = roundToColumn(round.title)
		if (!/^[01]$/.test(eventAlliances[a1-1][col]) && !/^[01]$/.test(eventAlliances[a2-1][col])) return false
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
		if (eventAlliances && alliance>0 && eventAlliances.length > alliance-1 && eventAlliances[alliance-1][roundToColumn(title)]=="1") return alliance
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
		// Official scores are optional: the bracket still renders (with
		// predictions) if either the schedule or the score feed is missing.
		var officialData = Promise.all([
			promiseEventMatches().catch(()=>[]),
			promiseEventScores().catch(()=>({}))
		]).then(values => {
			[window.eventMatches, window.eventScores] = values
		}).catch(function(){
			window.eventMatches = []
			window.eventScores = {}
		})
		promiseEventStats(true).catch(function(){
			return [[], {}]
		}).then(values => {
			[window.eventStats, window.eventStatsByTeam] = values
			return officialData
		}).then(function(){
			syncFourTeam()
			showBracket(getBrackets())
		})
	}).catch(function(){
		$('#no-bracket-msg').show()
	})
	applyTranslations()
	$(window).on('resize', function(){ fitRosterText(); drawBracketLines() })
})
