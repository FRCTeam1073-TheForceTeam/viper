"use strict"

addI18n({
	error_label:{
		en:'Error:',
		zh_tw:'錯誤：',
		he:'שְׁגִיאָה:',
		fr:'Erreur :',
		pt:'Erro:',
		tr:'Hata:',
	},
	no_event_title:{
		en:'Event not specified',
		zh_tw:'未指定事件',
		he:'האירוע לא צוין',
		fr:'Événement non spécifié',
		pt:'Evento não especificado',
		tr:'Etkinlik belirtilmedi',
	},
	no_event_message:{
		en:'No event parameter found in URL',
		zh_tw:'URL 中未找到事件參數',
		he:'לא נמצא פרמטר אירוע ב-URL',
		fr:'Aucun paramètre d\'événement trouvé dans l\'URL',
		pt:'Nenhum parâmetro de evento encontrado na URL',
		tr:'URL\'de etkinlik parametresi bulunamadı',
	},
	js_error_title:{
		en:'_FILENAME_ not loaded',
		zh_tw:'_FILENAME_ 未載入',
		he:'_FILENAME_ לא נטען',
		fr:'_FILENAME_ non chargé',
		pt:'_FILENAME_ não carregado',
		tr:'_FILENAME_ yüklenmedi',
	},
	js_error_message:{
		en:'Maybe the season isn\'t implemented?',
		zh_tw:'也許這個季節還沒有實施？',
		he:'אולי העונה לא מיושמת?',
		fr:'Peut-être que la saison n\'est pas implémentée ?',
		pt:'Talvez a temporada não esteja implementada?',
		tr:'Belki de sezon uygulanmadı?',
	},
})

$.ajaxSetup({
	cache: true
});

var eventId,eventYear,eventVenue,eventName,eventCompetition,BOT_POSITIONS,
promiseCache={},
FRC_BOT_POSITIONS = ['R1','R2','R3','B1','B2','B3'],
FTC_BOT_POSITIONS = ['R1','R2','B1','B2'],
MATCH_TYPE_SORT = {
	'pm':'00',
	'qm':'01',
	'qf':'02',
	'sf':'03',
	'1p':'04',
	'2p':'05',
	'3p':'06',
	'4p':'07',
	'5p':'08',
	'sf':'09',
	'1sf':'10',
	'2sf':'11',
	'f':'12',
}

function eventFromHash(){
	eventId=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:file|event)\=))?(20[0-9]{2}(?:-[0-9]{2})?[a-zA-Z0-9\-]+)(?:\.[a-z\.]+)?(?:\&.*)?$/)||["",""])[1]
	eventYear = eventId.replace(/([0-9]{4}(?:-[0-9]{2})?).*/,'$1')
	eventVenue = eventId.replace(/[0-9]{4}(?:-[0-9]{2})?(.*)/,'$1')
	eventName = eventYear+(eventYear?" ":"")+eventVenue
	eventCompetition = (/^20[0-9]{2}$/.test(eventYear)||location.hash=='#frc')?"frc":"ftc"
	promiseCache = {}
	if (eventId && !/^20[0-9]{2}(-[0-9]{2})?combined$/.test(eventId)){
		if (localStorage.last_event_id==eventId)eventName=localStorage.last_event_name||eventName
		localStorage.last_event_id=eventId
		localStorage.last_event_year=eventYear
		localStorage.last_event_name=eventName
	}
	BOT_POSITIONS = eventCompetition=='frc'?FRC_BOT_POSITIONS:FTC_BOT_POSITIONS
}

$(window).on('hashchange', eventFromHash)
eventFromHash()

function promiseEventAjax(file){
	return fetch(file).then(response=>{
		if(!response.ok) return ''
		return response.text()
	})
}

function csvToArrayOfMaps(csv){
	var arr = []
	var lines = csv.split(/[\r\n]+/)
	if (lines.length>0){
		var headers = lines.shift().split(/,/)
		for(var i=0; i<lines.length; i++){
			if (lines[i]){
				var data = lines[i].split(/[,]/).map(s=>s.trim())
				var map = {}
				for (var j=0; j<data.length; j++){
					map[headers[j]] = /^[0-9]+$/.test(data[j])?parseInt(data[j]):unescapeField(data[j])
				}
				arr.push(map)
			}
		}
	}
	return arr
}

function unescapeField(s){
	return s
		.replace(/⏎/g, "\n")
		.replace(/״/g, "\"")
		.replace(/،/g, ",")
}

function scheduleSortKey(match){
	if(!match)return""
	var event,id
	if (typeof(match)==='string'){
		event=""
		id=match
	} else {
		event = match.event
		id = match.Match
	}
	var m = id.match(/^(pm|qm|qf|sf|(?:[1-5]p)|f)([0-9]+)$/)
	if (!m) return match
	return event + "---" + MATCH_TYPE_SORT[m[1]] + "---" + m[2].padStart(12,'0')
}

function promiseEventMatches(){
	if (!promiseCache.eventMatches) promiseCache.eventMatches = promiseEventAjax(`/data/${eventId}.schedule.csv`).then(function(text){
		var eventMatches=csvToArrayOfMaps(text)
		eventMatches.sort((a,b)=>scheduleSortKey(a).localeCompare(scheduleSortKey(b)))
		return eventMatches
	})
	return promiseCache.eventMatches
}

function promiseEventTeams(){
	if (!promiseCache.eventTeams) promiseCache.eventTeams = promiseEventMatches().then(function(eventMatches){
		var teams = {}
		for (var i=0; i<eventMatches.length; i++){
			for (var j=0; j<BOT_POSITIONS.length; j++){
				teams[eventMatches[i][BOT_POSITIONS[j]]] = 1
			}
		}
		return Object.keys(teams).map(t=>parseInt(t)).sort((a,b)=>{a-b})
	})
	return promiseCache.eventTeams
}

function promiseJson(file,defaultResponse){
	return fetch(file).then(response=>{
		if (response.ok) return response.text()
		return ""
	}).then(text=>{
		if (!text) return defaultResponse??{}
		try {
			return JSON.parse(text)
		} catch(e) {
			console.error(e)
			return defaultResponse??{}
		}
	})
}

function promiseTeamsInfo(){
	if (!promiseCache.teamsInfo) promiseCache.teamsInfo = promiseJson(`/data/${eventId}.teams.json`).then(function(json){
		var eventTeamsInfo={}
		json.teams = json.teams||[]
		json.teams.forEach(function(team){
			eventTeamsInfo[parseInt(team.teamNumber)] = team
		})
		return eventTeamsInfo
	})
	return promiseCache.teamsInfo
}

function promiseEventScores(){
	if (!promiseCache.eventScores) promiseCache.eventScores = Promise.all([
		promiseEventMatches(),
		promiseJson(`/data/${eventId}.scores.qualification.json`,{}),
		promiseJson(`/data/${eventId}.scores.playoff.json`,{})
	]).then(values => {
		var [matches, quals, playoffs] = values,
		scores = {}
		quals.MatchScores = quals.MatchScores||quals.matchScores||[]
		playoffs.MatchScores = playoffs.MatchScores||playoffs.matchScores||[]
		quals.MatchScores.forEach(score => scores[`qm${score.matchNumber}`] = score)
		matches.forEach(match => {
			if (!/^pm|qm/.test(match.Match)){
				scores[match.Match] = playoffs.MatchScores.shift()
			}
			var m = scores[match.Match]
			if (m){
				BOT_POSITIONS.forEach(pos => {
					var team = match[pos]
					m.alliances.forEach(alliance => {
						if (alliance.alliance.toLowerCase()[0] == pos.toLowerCase()[0]){
							if (!alliance.hasOwnProperty('teams')) alliance.teams=[]
							alliance.teams.push(team)
						}
					})
				})
			}
		})
		return scores
	})
	return promiseCache.eventScores
}

function promiseAlliances(){
	if (!promiseCache.eventAlliances) promiseCache.eventAlliances = promiseEventAjax(`/data/${eventId}.alliances.csv`).then(text=>{
		return csvToArrayOfMaps(text)
	})
	return promiseCache.eventAlliances
}

function promiseScouting(){
	if (!promiseCache.scouting) promiseCache.scouting = promiseEventAjax(`/data/${eventId}.scouting.csv`).then(text=>{
		return csvToArrayOfMaps(text)
	})
	return promiseCache.scouting
}

var statsIncludePractice=true,
statsStartMatch="pm1"
function promiseEventStats(startMatch){
	if(!eventYear) {
		showError('no_event_title','no_event_message')
		return Promise.reject(new Error("Event not specified"))
	}
	return Promise.all([
		promiseScouting(),
		promiseEventScores(),
		promiseSubjectiveScouting(),
		promisePitScouting(),
		promiseScript(`/${eventYear}/aggregate-stats.js`),
	]).then(values => {
		var [eventStats, eventScores, subjectiveData, pitData] = values
		if(typeof startMatch == "boolean"){
			startMatch=startMatch?"pm1":"qm1"
		}
		if(!startMatch){
			startMatch=haveNonPracticeMatchForEachTeam(eventStats)?"qm1":"pm1"
		}
		statsIncludePractice=/^pm/.test(startMatch)
		statsStartMatch=startMatch
		$('.aggregationIncludesPractice').text(statsIncludePractice?"include":"exclude")
		$('[data-include-practice]').each(function(){
			$(this).attr('data-i18n',$(this).attr(statsIncludePractice?"data-include-practice":"data-exclude-practice"))
			applyTranslations($(this).parent())
		})
		var eventStatsByTeam = {},
		eventStatsByMatchTeam = {}
		Object.keys(pitData).forEach(team=>{
			aggregateStats({},{},{},{},pitData[team]||{},{},{},"")
		})
		Object.keys(subjectiveData).forEach(team=>{
			aggregateStats({},{},{},subjectiveData[team]||{},{},{},{},"")
		})
		forEachTeamMatch(eventStats, function(team,match,scout){
			var apiScore = {}
			if (eventScores[match] && eventScores[match].alliances){
				eventScores[match].alliances.forEach(alliance=>{
					if (alliance.teams && alliance.teams.includes(team)) apiScore = alliance
				})
			}
			var subjective =  subjectiveData[team]||{},
			pit = pitData[team]||{},
			mt=`${match}-${team}`
			scout.old=eventStatsByMatchTeam[mt]
			if(scheduleSortKey(startMatch)<=scheduleSortKey(match)){
				var aggregate = eventStatsByTeam[team] || {}
				aggregateStats(scout,aggregate,apiScore,subjective,pit,eventStatsByMatchTeam,eventStatsByTeam,match)
				eventStatsByTeam[team] = aggregate
			} else {
				aggregateStats(scout,{},apiScore,subjective,pit,{},{},match)
			}
			eventStatsByMatchTeam[mt]=scout
		})
		return [eventStats, eventStatsByTeam, eventStatsByMatchTeam]
	})
}

function promiseScript(file) {
	if($(`script[src='${file}']`).length) return Promise.resolve()
	return new Promise((resolve,reject)=>{
		const script=document.createElement("script")
		script.onload=resolve
		script.onerror=reject
		script.setAttribute("src",file)
		document.head.appendChild(script)
	}).catch(error=>{
		console.error(error)
		addTranslationContext({fileName:file})
		showError('js_error_title', 'js_error_message')
	})
}

function showError(title, detail){
	if ($('body.error').length)return false
	$('body').addClass('error')
	$('#main,body').last().html('')
	.append($('<h2>').append($('<span>').attr('data-i18n','error_label')).append(" ").append($('<span>').attr('data-i18n',title)))
	.append($('<p>').attr('data-i18n',detail)).show()
	applyTranslations()
	return false
}

function haveNonPracticeMatchForEachTeam(eventStats){
	var practiceTeams = {}
	forEachTeamMatch(eventStats, function(team,match){
		if (/^pm[0-9]+$/.test(match))practiceTeams[team]=1
	})
	forEachTeamMatch(eventStats, function(team,match){
		if (!/^pm[0-9]+$/.test(match))delete practiceTeams[team]
	})
	return Object.keys(practiceTeams).length == 0
}

function forEachTeamMatch(eventStats, callback){
	eventStats.forEach(function(scout){
		callback(scout['team'],scout['match'],scout)
	})
}

function matchHasTeam(m,t){
	if (!m || !t) return false
	return !!(BOT_POSITIONS.reduce((sum,pos)=>sum+(m[pos]==t?1:0),0))
}

function promiseEventFiles(){
	if (!promiseCache.eventFiles) promiseCache.eventFiles = promiseEventAjax(`/event-files.cgi?event=${eventId}`).then(text => {
		var fileList = text.split(/[\n\r]+/).filter(x=>/\./.test(x))
		fileList.sort((a,b)=>{
			var aType = a.replace(/.*\./,"")
			var bType = b.replace(/.*\./,"")
			if(aType != bType) return aType.localeCompare(bType)
			return a.localeCompare(b)
		})
		return fileList
	})
	return promiseCache.eventFiles
}

function promiseEventInfo(){
	if (!promiseCache.eventInfo) promiseCache.eventInfo = promiseEventAjax(`/data/${eventId}.event.csv`).then(text => {
		if (text){
			var eventInfo = csvToArrayOfMaps(text)[0]
			if (eventInfo.name)	{
				eventName = (eventInfo.name.includes(eventYear)?"":`${eventYear} `)+eventInfo.name
				localStorage.last_event_name=eventName
			}
		} else {
			eventInfo = []
		}
		return eventInfo
	})
	return promiseCache.eventInfo
}


function promisePitScouting(){
	if (!promiseCache.pitScouting) promiseCache.pitScouting = promiseEventAjax(`/data/${eventId}.pit.csv`).then(text=>{
		var data = {}
		csvToArrayOfMaps(text).forEach(function(teamData){
			data[teamData.team]=teamData
		})
		return data
	}).catch(e=>{
		console.error(e)
		return Promise.resolve([])
	})
	return promiseCache.pitScouting
}

function promiseSubjectiveScouting(){
	if (!promiseCache.subjectiveScouting) promiseCache.subjectiveScouting = promiseEventAjax(`/data/${eventId}.subjective.csv`).then(text=>{
		var data = {}
		csvToArrayOfMaps(text).forEach(function(teamData){
			data[teamData.team]=teamData
		})
		return data
	}).catch(e=>{
		console.error(e)
		return Promise.resolve([])
	})
	return promiseCache.subjectiveScouting
}

function getUploads(){
	var uploads = []
	for (var i in localStorage){
		if (new RegExp(`^${eventYear}.*_.*_`).test(i)) {
			uploads.push(localStorage[i])
		}
	}
	return uploads
}

function getMatchNumber(matchId){
	return ((matchId||"").match(/[0-9]+$/)||[0])[0]
}

function getMatchTypeKey(matchId){
	return ((matchId||"").match(/^(pm|qm|qf|sf|(?:[1-5]p)|f)/)||[""])[0]
}

function getMatchNameKey(matchId){
	return 'mt_'+getMatchTypeKey(matchId)
}

function getMatchName(matchId){
	return translate(getMatchNameKey(matchId))+getMatchNumber(matchId)
}

function getShortMatchNameKey(matchId){
	return 'mts_'+getMatchTypeKey(matchId)
}

function getShortMatchName(matchId){
	return translate(getShortMatchNameKey(matchId))+getMatchNumber(matchId)
}
