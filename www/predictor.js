"use strict"

addI18n({
	predictor_title:{
		en:'Match Predictor for _EVENT_',
		tr:'Previsor de Partida para _EVENT_',
		he:'מנבא התאמה עבור _EVENT_',
		zh_tw:'_EVENT_ 的匹配預測器',
		pt:'Previsor de Partida para _EVENT_',
		fr:'Prédicteur de match pour _EVENT_',
		es:'Predictor de coincidencias para _EVENT_',
	},
	predictor_match_title:{
		en:'_MATCH_ Match Predictor for _EVENT_',
		tr:'_MATCH_ Previsor de Partida para _EVENT_',
		he:'_MATCH_ מנבא התאמה עבור _EVENT_',
		zh_tw:'_MATCH_ _EVENT_ 的比賽預測器',
		pt:'_MATCH_ Previsor de Partida para _EVENT_',
		fr:'_MATCH_ Prédicteur de match pour _EVENT_',
		es:'Predicción de partida',
	},
	change_teams_button:{
		en:'Clear',
		es:'Limpiar',
		tr:'Temizle',
		he:'נקה',
		zh_tw:'清除',
		pt:'Limpar',
		fr:'Effacer',
	},
	match_label:{
		en:'Match:',
		es:'Partida:',
		tr:'Maç:',
		he:'משחק:',
		zh_tw:'比賽：',
		pt:'Partida:',
		fr:'Match :',
	},
	team_pool_label:{
		en:'Available Teams',
		es:'Equipos disponibles',
		tr:'Uygun Takımlar',
		he:'קבוצות זמינות',
		zh_tw:'可選隊伍',
		pt:'Equipes disponíveis',
		fr:'Équipes disponibles',
	},
	stat_breakdown_label:{
		en:'Stat breakdown',
		es:'Desglose de estadísticas',
		tr:'İstatistik dökümü',
		he:'פירוט נתונים',
		zh_tw:'數據明細',
		pt:'Detalhamento de estatísticas',
		fr:'Détail des statistiques',
	},
	slot_hint:{
		en:'Drop or tap a team',
		es:'Suelta o toca un equipo',
		tr:'Bir takım bırakın veya dokunun',
		he:'גרור או הקש על קבוצה',
		zh_tw:'拖放或點選隊伍',
		pt:'Solte ou toque numa equipe',
		fr:'Déposez ou touchez une équipe',
	},
	qual_mode:{
		en:'Qualifications',
		es:'Clasificación',
		tr:'Sıralama',
		he:'מוקדמות',
		zh_tw:'資格賽',
		pt:'Classificatórias',
		fr:'Qualifications',
	},
	playoff_mode:{
		en:'Playoffs',
		es:'Eliminatorias',
		tr:'Eleme',
		he:'פלייאוף',
		zh_tw:'季後賽',
		pt:'Playoffs',
		fr:'Séries',
	},
	alliance_pool_label:{
		en:'Alliances',
		es:'Alianzas',
		tr:'İttifaklar',
		he:'בריתות',
		zh_tw:'聯盟',
		pt:'Alianças',
		fr:'Alliances',
	},
	drop_alliance_hint:{
		en:'Drop or tap an alliance',
		es:'Suelta o toca una alianza',
		tr:'Bir ittifak bırakın veya dokunun',
		he:'גרור או הקש על ברית',
		zh_tw:'拖放或點選聯盟',
		pt:'Solte ou toque numa aliança',
		fr:'Déposez ou touchez une alliance',
	},
	no_alliances:{
		en:'No alliance selection data for this event',
		es:'No hay datos de selección de alianzas para este evento',
		tr:'Bu etkinlik için ittifak seçim verisi yok',
		he:'אין נתוני בחירת בריתות לאירוע זה',
		zh_tw:'此賽事沒有聯盟選擇資料',
		pt:'Sem dados de seleção de alianças para este evento',
		fr:'Aucune donnée de sélection d\'alliance pour cet événement',
	},
	use_playoff_stats:{
		en:'Use playoff stats',
		es:'Usar estadísticas de eliminatorias',
		tr:'Eleme istatistiklerini kullan',
		he:'השתמש בנתוני פלייאוף',
		zh_tw:'使用季後賽數據',
		pt:'Usar estatísticas de playoffs',
		fr:'Utiliser les stats des séries',
	},
})

onApplyTranslation.push(function(){
	addTranslationContext({
		event:eventName,
		match:getShortMatchName(match),
	})
})

var statsConfig,
activePos = null,
playoffMode = false,
usePlayoffStats = localStorage.predictorUsePlayoffStats != '0',
activeSide = 'red',
sideAlliance = {red:null, blue:null}

$(document).ready(function(){
	Promise.all([
		promiseEventMatches(),
		promiseEventStats(),
		fetch(`/data/${eventYear}/predictor.json`).then(response=>{if(response.ok)return response.json()}),
		fetch(`/data/${eventId}.alliances.json`).then(response=>response.ok?response.json():null).catch(()=>null)
	]).then(values =>{
		[window.eventMatches, [{}, window.eventStatsByTeam, {}], window.myTeamsStats, window.allianceData] = values
		window.alliances = (window.allianceData && window.allianceData.Alliances) || []
		statsConfig= new StatsConfig({
			statsConfigKey:`${eventYear}PredictorStats`,
			getStatsConfig:function(){
				var conf = statsConfig.getLocalStatsConfig()
				if (!conf && window.myTeamsStats && Object.keys(window.myTeamsStats).length)conf=window.myTeamsStats
				if (!conf && window.matchPredictorSections)conf=window.matchPredictorSections
				conf==conf||{}
				Object.entries(conf).forEach(([k,v])=>{
					if(Array.isArray(v)){
						conf[k]={}
						conf[k].data=v
					}
				})
				return conf
			},
			drawFunction:setPickedTeams,
			fileName:"predictor",
			defaultConfig:window.matchPredictorSections,
			mode:"aggregate",
			hasSections:true,
		})
		window.teamList = Object.keys(eventStatsByTeam).sort((a,b) => a-b)
		$('#matchList').append($('<option selected=1>')).change(function(){
			var bots = $(this).val().split(",")
			BOT_POSITIONS.forEach((pos,i)=>$(`#${pos}`).val(bots[i]||""))
			activePos = null
			setPickedTeams()
		})
		window.eventMatches.forEach(match=>{
			$('#matchList').append($('<option>').text(getMatchName(match.Match)).attr('value',BOT_POSITIONS.map(pos=>match[pos]).join(",")))
		})
		// Playoff-only stats: aggregate from the first playoff match onward (teams
		// fall back to general/qual stats when they have no playoff data).
		var firstPlayoff = (window.eventMatches.find(m=>!/^(pm|qm)/.test(m.Match))||{}).Match
		window.playoffStatsByTeam = {}
		var statsReady = firstPlayoff
			? promiseEventStats(firstPlayoff).then(v=>{ window.playoffStatsByTeam = v[1]||{} }).catch(()=>{})
			: Promise.resolve()
		statsReady.then(function(){
			loadFromLocationHash()
			$(window).on('hashchange', loadFromLocationHash)
			if (match) $('title,h1').attr('data-i18n','predictor_match_title')
			applyTranslations()
		})
	})
	if (eventCompetition=='ftc') $('.noftc').hide()
	$('#modeToggle button').click(function(){
		var po = $(this).data('mode') == 'playoff'
		if (po == playoffMode) return
		playoffMode = po
		BOT_POSITIONS.forEach(pos=>$(`#${pos}`).val(""))   // start the new mode clean
		sideAlliance = {red:null, blue:null}
		activePos = null
		activeSide = 'red'
		updateModeUI()
		setPickedTeams()
	})
	$('#change-teams').click(function(){
		BOT_POSITIONS.forEach(pos=>$(`#${pos}`).val(""))
		sideAlliance = {red:null, blue:null}
		activePos = null
		activeSide = 'red'
		setPickedTeams()
	})
	$('#usePlayoffStats').prop('checked', usePlayoffStats).change(function(){
		usePlayoffStats = this.checked
		localStorage.predictorUsePlayoffStats = usePlayoffStats ? '1' : '0'
		setPickedTeams()
	})
	// Pool is a drop target for removing a team from an alliance
	var pool = $('#teamPool')
	pool.on('dragover', function(e){ e.preventDefault(); pool.addClass('dragover') })
	pool.on('dragleave', function(){ pool.removeClass('dragover') })
	pool.on('drop', function(e){
		pool.removeClass('dragover')
		var data = getDrag(e)
		if (!data) return
		if (data.alliance != null && (data.from == 'red' || data.from == 'blue')) removeSide(data.from)
		else if (data.from != null){ $(`#${data.from}`).val(""); setPickedTeams() }
	})
	updateModeUI()
})

function updateModeUI(){
	$('#modeToggle button').each(function(){
		$(this).toggleClass('active', $(this).data('mode') == (playoffMode?'playoff':'qual'))
	})
	$('.matchPick').toggle(!playoffMode)
	$('#playoffStatsToggle').toggle(playoffMode)
	$('#usePlayoffStats').prop('checked', usePlayoffStats)
	$('#poolLabel').attr('data-i18n', playoffMode?'alliance_pool_label':'team_pool_label')
}

// ===== Render =====
function setPickedTeams(){
	var half = BOT_POSITIONS.length/2,
	redPos = BOT_POSITIONS.slice(0,half),
	bluePos = BOT_POSITIONS.slice(half)
	if (playoffMode){
		if (sideAlliance[activeSide]) activeSide = !sideAlliance.red?'red':(!sideAlliance.blue?'blue':activeSide)
		renderPlayoffSide('redAlliance', 'red')
		renderPlayoffSide('blueAlliance', 'blue')
		renderAlliancePool()
	} else {
		var assigned = {}
		BOT_POSITIONS.forEach(pos=>{ var v=$(`#${pos}`).val(); if(v) assigned[v]=pos })
		// active slot: keep the user's choice if still empty, else the first empty slot
		if (!activePos || $(`#${activePos}`).val()) activePos = BOT_POSITIONS.find(pos=>!$(`#${pos}`).val()) || null
		renderAlliance('redAlliance', redPos)
		renderAlliance('blueAlliance', bluePos)
		renderPool(assigned)
	}
	updateScoreboard(redPos, bluePos)
	renderBreakdown()
	setLocationHash()
	applyTranslations()
}

// ===== Playoffs mode =====
function allianceByNumber(num){ return (window.alliances||[]).find(a=>a.number==num) }
function allianceTeams(a){
	if (!a) return []
	return [a.captain, a.round1, a.round2, a.round3]
		.filter(t=>t!=null && t!=="")
		.map(String)
		.slice(0, BOT_POSITIONS.length/2)
}
function setSideTeams(side, teams){
	var positions = side=='red' ? BOT_POSITIONS.slice(0,BOT_POSITIONS.length/2) : BOT_POSITIONS.slice(BOT_POSITIONS.length/2)
	positions.forEach((pos,i)=>$(`#${pos}`).val(teams[i]||""))
}
function removeSide(side){
	sideAlliance[side] = null
	setSideTeams(side, [])
	activeSide = side
	setPickedTeams()
}
function addAlliance(num){
	if (sideAlliance.red==num || sideAlliance.blue==num) return
	var side = !sideAlliance[activeSide] ? activeSide : (!sideAlliance.red ? 'red' : (!sideAlliance.blue ? 'blue' : null))
	if (!side) return   // both sides full — click does nothing
	sideAlliance[side] = num
	setSideTeams(side, allianceTeams(allianceByNumber(num)))
	activeSide = !sideAlliance.red ? 'red' : (!sideAlliance.blue ? 'blue' : side)
	setPickedTeams()
}
function allianceCard(a, fromSide){
	var card = $('<div class=allianceCard>').attr('draggable',true)
		.append($('<div class=allianceName>').text(a.name || `Alliance ${a.number}`))
		.append($('<div class=allianceTeams>').text(allianceTeams(a).join(' · ')))
	card.on('dragstart', function(e){ setDrag(e, {alliance:a.number, from:fromSide==null?null:fromSide}); card.addClass('dragging') })
	card.on('dragend', function(){ card.removeClass('dragging') })
	if (fromSide != null){
		card.addClass('placed')
		card.on('click', function(){ removeSide(fromSide) })
	} else {
		card.on('click', function(){ addAlliance(a.number) })
	}
	return card
}
function renderPlayoffSide(containerId, side){
	var c = $(`#${containerId}`).html(""),
	num = sideAlliance[side],
	a = num ? allianceByNumber(num) : null,
	target
	if (a){
		target = allianceCard(a, side)
	} else {
		target = $('<div class="alliance-slot empty">')
		if (side == activeSide) target.addClass('active')
		target.append($('<span class=slotHint>').attr('data-i18n','drop_alliance_hint'))
		target.on('click', function(){ activeSide = side; setPickedTeams() })
	}
	// handlers live on the freshly-created element each render (no accumulation)
	target.on('dragover', function(e){ e.preventDefault(); target.addClass('dragover') })
	target.on('dragleave', function(){ target.removeClass('dragover') })
	target.on('drop', function(e){
		e.preventDefault()
		target.removeClass('dragover')
		var data = getDrag(e)
		if (!data || data.alliance == null) return
		if (data.from && data.from != side) sideAlliance[data.from] = null   // moved from the other side
		sideAlliance[side] = data.alliance
		setSideTeams(side, allianceTeams(allianceByNumber(data.alliance)))
		if (data.from && data.from != side) setSideTeams(data.from, [])
		setPickedTeams()
	})
	c.append(target)
}
function renderAlliancePool(){
	var pool = $('#teamPool').html("")
	if (!window.alliances || !window.alliances.length){
		pool.append($('<div class=poolEmpty>').attr('data-i18n','no_alliances'))
		return
	}
	window.alliances.forEach(a=>{
		if (sideAlliance.red==a.number || sideAlliance.blue==a.number) return
		pool.append(allianceCard(a, null))
	})
}

function renderAlliance(containerId, positions){
	var c = $(`#${containerId}`).html("")
	positions.forEach(pos=>{
		var team = $(`#${pos}`).val(),
		slot = $('<div class=alliance-slot>').attr('data-pos',pos)
		if (team){
			slot.append(teamCard(team, pos))
		} else {
			slot.addClass('empty')
			if (pos == activePos) slot.addClass('active')
			slot.append($('<span class=slotHint>').attr('data-i18n','slot_hint'))
			slot.on('click', function(){ activePos = pos; setPickedTeams() })
		}
		slot.on('dragover', function(e){ e.preventDefault(); slot.addClass('dragover') })
		slot.on('dragleave', function(){ slot.removeClass('dragover') })
		slot.on('drop', function(e){ slot.removeClass('dragover'); dropOnSlot(e, pos) })
		c.append(slot)
	})
}

function renderPool(assigned){
	var pool = $('#teamPool').html("")
	teamList.forEach(team=>{
		if (assigned[team]) return
		pool.append(teamCard(team, null))
	})
}

function teamCard(team, fromPos){
	var card = $('<div class=teamCard>').attr('draggable',true).attr('data-team',team).text(team)
	card.on('dragstart', function(e){ setDrag(e, {team:team, from:fromPos==null?null:fromPos}); card.addClass('dragging') })
	card.on('dragend', function(){ card.removeClass('dragging') })
	if (fromPos != null){
		card.addClass('placed')
		card.on('click', function(){ $(`#${fromPos}`).val(""); activePos = fromPos; setPickedTeams() })
	} else {
		card.on('click', function(){ addTeam(team) })
	}
	return card
}

function addTeam(team){
	if (BOT_POSITIONS.some(pos=>$(`#${pos}`).val()==team)) return   // already on an alliance
	var pos = (activePos && !$(`#${activePos}`).val()) ? activePos : BOT_POSITIONS.find(p=>!$(`#${p}`).val())
	if (!pos) return   // alliances full
	$(`#${pos}`).val(team)
	activePos = BOT_POSITIONS.find(p=>!$(`#${p}`).val()) || null
	setPickedTeams()
}

function dropOnSlot(e, pos){
	e.preventDefault()
	var data = getDrag(e)
	if (!data) return
	var current = $(`#${pos}`).val()
	if (data.from != null) $(`#${data.from}`).val(current||"")   // swap with the source slot
	$(`#${pos}`).val(data.team)
	setPickedTeams()
}

function setDrag(e, obj){ (e.originalEvent||e).dataTransfer.setData('text/plain', JSON.stringify(obj)) }
function getDrag(e){ try { return JSON.parse((e.originalEvent||e).dataTransfer.getData('text/plain')) } catch(x){ return null } }

// ===== Scoreboard =====
function updateScoreboard(redPos, bluePos){
	var r = allianceScore(redPos), b = allianceScore(bluePos)
	$('#redScore').text(r)
	$('#blueScore').text(b)
	$('#scoreboard').toggleClass('redWin', r>b).toggleClass('blueWin', b>r)
	$('#scoreboard').toggleClass('playoff', playoffMode)
	renderBreakout('redBreakout', redPos)
	renderBreakout('blueBreakout', bluePos)
}
// Per-team score contribution shown beside the alliance score box (playoffs)
function renderBreakout(containerId, positions){
	var c = $(`#${containerId}`)
	var teams = positions.map(pos=>$(`#${pos}`).val())
	// Collapse the breakout (no formatting) outside playoffs or when this side is empty.
	// Keep stale rows in place so the slide-out animation has content to show.
	if (!playoffMode || !teams.some(t=>t)){ c.removeClass('show'); return }
	c.html("")
	teams.forEach(function(t){
		var row = $('<div class=sbBreakoutRow>')
		row.append($('<span class=sbbTeam>').text(t || "—"))
		row.append($('<span class=sbbScore>').text(t ? Math.round(getTeamValue('score', parseInt(t))) : ""))
		c.append(row)
	})
	c.addClass('show')
}
function allianceScore(positions){
	return Math.round(positions.reduce((sum,pos)=>{
		var t = $(`#${pos}`).val()
		return sum + (t ? getTeamValue('score', parseInt(t)) : 0)
	}, 0))
}

// ===== Stat breakdown table (live) =====
function renderBreakdown(){
	BOT_POSITIONS.forEach(pos=>$(`#th-${pos}`).text($(`#${pos}`).val()||""))
	var table = $('#prediction tbody').html(""),
	stats = statsConfig.getStatsConfig(),
	first = true
	Object.keys(stats).forEach(function(section){
		table.append(
			$('<tr>').append(
				$(`<th colspan=${BOT_POSITIONS.length+3}>`).append(
					$('<h4>').append($('<span>').attr('data-i18n',section))
					.append(" ").append($(' <button>🛠️</button>').attr('data-section',section).click(statsConfig.showConfigDialog.bind(statsConfig)))
				)
			)
		)
		stats[section].data.forEach(function(field){
			statInfo[field] = statInfo[field]||{}
			if ((statInfo[field]['type']||"") != 'avg') return
			var teamScores = [],
			allianceScores = [0,0]
			BOT_POSITIONS.forEach(function(pos, i){
				var team = parseInt($(`#${pos}`).val())
				teamScores[i] = getTeamValue(field, team)
				allianceScores[Math.floor(i/(BOT_POSITIONS.length/2))] += teamScores[i]
			})
			teamScores = teamScores.map(Math.round)
			allianceScores = allianceScores.map(Math.round)
			var compare = statInfo[field].good=='low'?Math.min:Math.max,
			teamBest = compare(...teamScores),
			allianceBest = compare(...allianceScores),
			tr = $('<tr>').addClass(first?"first":"")
			BOT_POSITIONS.forEach(function(pos, i){
				tr.append($('<td>').addClass(i<(BOT_POSITIONS.length/2)?'redTeamBG':'blueTeamBG').append($('<div>').text(teamScores[i]).addClass(teamScores[i]==teamBest?"winner":"")))
				if(i==(BOT_POSITIONS.length/2-1)){
					tr.append($('<td>').addClass('redTeamBG').addClass('alliance').append($('<div>').text(allianceScores[0]).addClass(allianceScores[0]==allianceBest?("winner"):"")))
					tr.append($('<td>').append($('<div>').attr('data-i18n',field)))
					tr.append($('<td>').addClass('blueTeamBG').addClass('alliance').append($('<div>').text(allianceScores[1]).addClass(allianceScores[1]==allianceBest?"winner":"")))
				}
			})
			table.append(tr)
			first=false
		})
	})
}

// ===== URL hash sync =====
var match = ""

function setLocationHash(){
	var hash = `event=${eventId}`
	if (match) hash += `&match=${match}`
	if (playoffMode){
		hash += `&mode=playoff`
		if (sideAlliance.red) hash += `&ra=${sideAlliance.red}`
		if (sideAlliance.blue) hash += `&ba=${sideAlliance.blue}`
	}
	BOT_POSITIONS.forEach(function(pos){
		var val = $(`#${pos}`).val()
		if (/^[0-9]+$/.test(val)) hash += `&${pos}=${val}`
	})
	location.hash = hash
}

function loadFromLocationHash(){
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)([a-z0-9]+)(?:\&.*)?$/)||["",""])[1]
	playoffMode = /[#&]mode=playoff(&|$)/.test(location.hash)
	BOT_POSITIONS.forEach(function(pos){
		var val = (location.hash.match(new RegExp(`^\\#(?:.*\\&)?(?:${pos}\\=)([0-9]+)(?:\\&.*)?$`))||["",""])[1]
		$(`#${pos}`).val(val)
	})
	activePos = null
	activeSide = 'red'
	sideAlliance = {red:null, blue:null}
	if (playoffMode){
		sideAlliance.red = (location.hash.match(/[#&]ra=([0-9]+)/)||[])[1] || null
		sideAlliance.blue = (location.hash.match(/[#&]ba=([0-9]+)/)||[])[1] || null
		if (sideAlliance.red) setSideTeams('red', allianceTeams(allianceByNumber(sideAlliance.red)))
		if (sideAlliance.blue) setSideTeams('blue', allianceTeams(allianceByNumber(sideAlliance.blue)))
	}
	updateModeUI()
	setPickedTeams()
}

// In playoff mode use playoff-only stats for a team, falling back to general/qual
// stats when that team has no playoff data scouted yet.
function teamStats(team){
	if (playoffMode && usePlayoffStats){
		var p = window.playoffStatsByTeam && window.playoffStatsByTeam[team]
		if (p && p.count) return p
	}
	return window.eventStatsByTeam && window.eventStatsByTeam[team]
}

function getTeamValue(field, team){
	var stats = teamStats(team)
	if (!stats || !stats['count']) return 0
	return (stats[field]||0) / stats['count']
}
