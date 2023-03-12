"use strict"

var pos = "",
team = "",
match = "",
orient = "",
matchName = "",
teamList=[],
scouting,
storeTime=0,
pitDataLoaded=false
parseHash()

function parseHash(){
	pos = (location.hash.match(/^\#(?:.*\&)?(?:pos\=)([RB][1-3])(?:\&.*)?$/)||["",""])[1]
	team = (location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["",""])[1]
	orient = (location.hash.match(/^\#(?:.*\&)?(?:orient\=)(left|right)(?:\&.*)?$/)||["",""])[1]
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)((?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+)(?:\&.*)?$/)||["",""])[1]
	teamList = (location.hash.match(/^\#(?:.*\&)?(?:teams\=)([0-9]+(?:,[0-9]+)*)(?:\&.*)?$/)||["",""])[1]
}

function showScreen(){
	if (!team && $('#select-team').length) showSelectPitScoutTeam()
	else if (team && $('#pit-scouting').length) showPitScouting()
	else if (!pos) showPosList()
	else if (!match) showMatchList()
	else if (!team) showTeamChange()
	else showScouting()
}

$(window).on('hashchange', function(){
	if (scouting.is(':visible') && formHasChanges(scouting)){
		if (confirm("Do you want to save your data?") && !store()) return false
	}
	parseHash()
	showScreen()
})

function showSelectPitScoutTeam(){
	$('.screen').hide()
	setHash(null,null,null,null,teamList)
	window.scrollTo(0,0)
	$('h1').text("Pit Scouting " + eventName)
	var el = $('#teamList').html(""),
	withData = getTeamsWithPitData(),
	showTeams = teamList?teamList.split(/,/).map(s=>parseInt(s)):eventTeams
	$('.location-pointer').remove()
	for (var i=0; i<showTeams.length;i++){
		var button = $('<button>').text(showTeams[i]).click(showPitScouting)
		if (withData.hasOwnProperty(showTeams[i])||eventPitData[showTeams[i]]) button.addClass('stored')
		el.append(button)
	}
	$('#select-team').show()
}

function showTeamChange(){
	$('.screen').hide()
	location.hash = `#event=${eventId}&pos=${pos}&match=${match}`
	window.scrollTo(0,0)
	$('h1').text(eventName)
	$('#teamChangeBtn').click(function(){
		team = $('#teamChange').val()
		showScouting()
		return false
	})
	$('#teamCancelBtn').click(function(){
		eventMatches.forEach(matchData=>{
			if (matchData.Match == match) team = matchData[pos]
		})
		if (team) showScouting()
		else showMatchList()
		return false
	})
	$('#change-team').show()
}

function showPosList(){
	$('.screen').hide()
	setHash()
	window.scrollTo(0,0)
	$('h1').text(eventName)
	$('.orientLeft,.orientRight').show()
	$('#select-bot button').each(function(){
		$(this).toggleClass("highlighted", $(this).text() == localStorage.getItem("last_pos"))
	})
	$('#select-bot button').click(function(){
		pos = $(this).text()
		if ($(this).closest('.orientLeft').length) orient='left'
		if ($(this).closest('.orientRight').length) orient='right'
		showMatchList()
	})
	$('#select-bot').show()
}

function showMatchList(){
	$('.screen').hide()
	setHash(pos,orient)
	window.scrollTo(0,0)
	$('#match-list').html('')
	$('h1').text(`${eventName} ${pos}`)
	var alreadyScouted = {}
	forEachTeamMatch(function(team,match){
		alreadyScouted[match]=1
	})
	alreadyScouted[localStorage.getItem("last_match_"+eventId)||""] = 1
	var lastDone
	for (var i=eventMatches.length-1; !lastDone && i>=0; i--){
		var m = eventMatches[i]['Match']
		if(alreadyScouted[m])lastDone=m
	}
	var seenLastDone = false;
	eventMatches.forEach(function(m){
		var matchTeam = m[pos],
		matchId = m['Match'],
		matchName = getShortMatchName(matchId),
		completeClass=(lastDone&&!seenLastDone)?"complete":"",
		storedClass = (localStorage.getItem(getScoutKey(matchTeam, matchId)))?"stored":""
		if (lastDone == matchId) seenLastDone = true;
		$('#match-list').append(
			$('<div class=match>')
			.append($(`<button class="teamColorBG ${completeClass} ${storedClass}" data-team=${matchTeam} data-match=${matchId}>`).text(matchTeam).click(function(){
				team = $(this).attr('data-team')
				match = $(this).attr('data-match')
				showScouting()
			})).append($('<span>').text(' ' + matchName))
		)
	})
	setTeamBG()
	$('#select-match').show()
}

function getScoutKey(t,m,e){
	if (!t) t = team
	if (!m) m = match
	if (!e) e = eventId
	return `${e}_${m}_${t}`
}

function getPitScoutKey(t,e){
	if (!t) t = team
	if (!e) e = eventId
	return `${e}_${t}`
}

function setHash(pos,orient,team,match,teamList){
	location.hash = buildHash(pos,orient,team,match,teamList)
}

function buildHash(pos,orient,team,match){
	return `#event=${eventId}`+
		(pos?`&pos=${pos}`:"")+
		(orient?`&orient=${orient}`:"")+
		(team?`&team=${team}`:"")+
		(match?`&match=${match}`:"")+
		(teamList?`&teams=${teamList}`:"")
}

function fillPreviousFormData(form,data){
	if (!data) return
	form.find('input,textarea').each(function(){
		var input = $(this),
		type = input.attr('type'),
		name = input.attr('name'),
		val = data[name]
		if (name){
			if (/^radio|checkbox$/.test(type)){
				if(input.attr('value')==val) input.attr('checked',"")
				else  input.removeAttr('checked')
				input.prop('checked',input.attr('value')==val)
			} else if (!/^submit$/.test(type) && val){
				input.val(val)
				input.attr('value',val)
			}
		}
	})
}

function storeOrigValues(form){
	form.find('input,textarea').each(function(){
		var input = $(this),
		type = input.attr('type'),
		orig = input.attr('data-orig-value')
		if (typeof orig === 'undefined' || orig === false) {
			if (/^radio|checkbox$/.test(type)){
				var checked = input.attr('checked')
				checked = typeof checked !== 'undefined' && checked !== false
				input.attr('data-orig-value',checked?"checked":"unchecked")
			} else if (!/^submit$/.test(type)){
				input.attr('data-orig-value',input.attr('value')||"")
			}
		}
	})
}
function resetOrigValues(form){
	form.find('input,textarea').each(function(){
		var input = $(this),
		type = input.attr('type'),
		orig = input.attr('data-orig-value')
		if (typeof orig !== 'undefined' && orig !== false) {
			if (/^radio|checkbox$/.test(type)){
				if(orig=='checked') input.attr('checked','checked')
				else input.removeAttr('checked')
			} else if (!/^submit$/.test(type)){
				input.attr('value',orig)
			}
		}
	})
}

function showPitScouting(t){
	if (t && typeof t != 'number') t = parseInt($(this).text())
	if (t) team = t
	$('.screen').hide()
	window.scrollTo(0,0)
	setHash(null,null,team,null,teamList)
	var pit = $('#pit-scouting')
	resetOrigValues(pit)
	pit[0].reset()
	$('.location-pointer').remove()
	storeOrigValues(pit)
	fillDefaultFormFields()
	fillPreviousFormData(pit, localPitScoutingData(team)||eventPitData[team])
	$('.count').each(countHandler)
	pit.show()
}

function countHandler(e){
	var count=$(this),
	clicked = e&&e.hasOwnProperty('type')&&e.type==='click',
	parent = count,
	src = count.attr('src')
	for(var i=0;parent.find('.count,input').length<3&&i<10;i++) parent = parent.parent()
	var input = parent.find('input'),
	val=parseInt(input.val())||0,
	max=parseInt(input.attr('max'))||999999,
	min=parseInt(input.attr('min'))||0
	if (!input.length) throw ("No input for counter")
	if (clicked){
		var toAdd = 0
		if(/up/.test(src))toAdd = 1
		else if(/down/.test(src))toAdd = -1
		else if(/three/.test(src))toAdd = 3
		else if(/five/.test(src))toAdd = 5
		val+=toAdd
		val = val<min?min:val
		val = val>max?max:val
		input.val(val)
		parent.find('.count').each(countHandler)
	} else {
		if(/down/.test(count.attr('src'))){
			count.css('visibility', val<=min?'hidden':'visible');
		} else {
			count.css('visibility', val>=max?'hidden':'visible');
		}
	}
}

function showScouting(){
	$('.screen').hide()
	setHash(pos,orient,team,match)
	window.scrollTo(0,0)
	resetOrigValues(scouting)
	scouting[0].reset()
	if (typeof beforeShowScouting == 'function') beforeShowScouting()
	matchName = getMatchName(match)
	setupButtons()
	storeOrigValues(scouting)
	$('.orientLeft').toggle(orient && orient=='left')
	$('.orientRight').toggle(orient && orient=='right')
	$('h1').text(`${eventName} ${pos}, ${matchName}, Team ${team}`)
	$('.teamColor').text(pos.startsWith('R')?"red":"blue")
	$('input[name="match"]').val(match).attr('value',match)
	fillDefaultFormFields()
	$('.match').text(matchName)
	setTeamBG()
	fillPreviousFormData(scouting, localScoutingData(team,match)||eventStatsByMatchTeam[`${match}-${team}`])
	$('.count').each(countHandler)
	scouting.show()
}

function fillDefaultFormFields(){
	$('.team').text(team)
	$('input[name="event"]').val(eventId).attr('value',eventId)
	$('input[name="team"]').val(team).attr('value',team)
	var lastScouter = localStorage.getItem("last_scouter")||""
	$('input[name="scouter"]').val(lastScouter).attr('value',lastScouter)
}

function setTeamBG(){
	$('.teamColorBG').toggleClass('redTeamBG', pos.startsWith('R')).toggleClass('blueTeamBG', pos.startsWith('B'))
}

function toggleChecked(o){
	o.each(function(){
		$(this).prop('checked', !$(this).prop('checked'))
	})
}

function toCSV(formId){
	var keys = [],
	values = {}
	$(`${formId} input,${formId} textarea`).each(function(){
		var el=$(this),name=el.attr('name'),val=el.val(),type=el.attr('type'),
		off=(type=='checkbox'||type=='radio')&&!el.prop('checked')
		if (!values.hasOwnProperty(name)){
			keys.push(name)
			values[name] = "0"
		}
		if (!off) values[name] = val
	})
	return [
		keys.map(safeCSV).join(",") + "\n",
		keys.map(function(v){return values[v]}).map(safeCSV).join(",") + "\n"
	]
}

window.addEventListener('beforeunload',(event) =>{
	if (formHasChanges(scouting) && new Date().getTime() - storeTime > 1000){
		event.preventDefault()
		return "Leave page without saving?"
	}
})

function formHasChanges(f){
	var changes = false
	f.find('input,textarea').each(function(){
		var el=$(this),name=el.attr('name'),val=el.val(),type=el.attr('type'),init=el.attr('value')||''
		if (type=='checkbox'||type=='radio'){
			val=el.prop('checked')
			init=el.attr('checked')!==undefined
		}
		if (val!==init)changes=true
	})
	return changes
}

var onStore = []

function store(){
	if (formHasChanges(scouting)){
		for (var i=0; i<onStore.length; i++){
			if(!onStore[i]()) return false
		}
		localStorage.setItem("last_match_"+eventId, match)
		localStorage.setItem("last_pos", pos)
		var csv = toCSV('#scouting')
		localStorage.setItem(`${eventYear}_headers`, csv[0])
		localStorage.setItem(getScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter($('#scouting'))
	}
	return true
}

function storeScouter(form){
	localStorage.setItem('last_scouter',form.find('input[name="scouter"]').val())
}

function storePitScouting(){
	if (formHasChanges($('#pit-scouting'))){
		var csv = toCSV('#pit-scouting')
		localStorage.setItem(`${eventYear}_pitheaders`, csv[0])
		localStorage.setItem(getPitScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter($('#pit-scouting'))
	}
}

function localPitScoutingData(t){
	var data = localStorage.getItem(getPitScoutKey(t))
	if (!data) return null
	return csvToArrayOfMaps(localStorage.getItem(`${eventYear}_pitheaders`)+"\n"+data)[0]
}

function localScoutingData(t,m){
	var data = localStorage.getItem(getScoutKey(t,m))
	if (!data) return null
	return csvToArrayOfMaps(localStorage.getItem(`${eventYear}_headers`)+"\n"+data)[0]
}

function safeCSV(s){
	return s
		.replace(/\t/g, " ")
		.replace(/\r|\n|\r\n/g, "⏎")
		.replace(/\"/g, "״")
		.replace(/,/g, "،")
}

function getTeamsWithData(){
	var teams = {}
	teams[team]=1
	for (var i in localStorage){
		if (/^20[0-9]{2}.*_.*_[0-9]+$/.test(i)){
			var t = parseInt(i.replace(/.*_/,""))
			teams[t]=1
		}
	}
	return teams
}


function getTeamsWithPitData(){
	var teams = {}
	for (var i in localStorage){
		if (/^20[0-9]{2}[a-zA-Z0-9\-]+_[0-9]+$/.test(i)){
			var t = parseInt(i.replace(/.*_/,""))
			teams[t]=1
		}
	}
	return teams
}

function setupButtons(){
	var next = getNextMatch()
	if (!next || haveDataForMatch(next) || haveAllDataForOurNextMatch()){
		setFeaturedButton($('#uploadBtn'))
		return
	}
	setFeaturedButton($('#nextBtn'))
}

function haveDataForMatch(m){
	if (!m) return 0
	var have = getTeamsWithData()
	return BOT_POSITIONS.reduce((sum,pos)=>sum+(have[m[pos]]?1:0),0)
}

function haveAllDataForOurNextMatch(){
	if (!window.ourTeam) return 0
	var seenCurrentMatch = 0
	var toBeCollected = {}
	for (var i=0; i<eventMatches.length; i++){
		var m = eventMatches[i]
		if (!seenCurrentMatch){
			if (match == m.Match) seenCurrentMatch = 1
		} else if (matchHasTeam(m, window.ourTeam)){
			if (!haveDataForMatch(m)) return 0
			return !(BOT_POSITIONS.reduce((sum,pos)=>sum|(toBeCollected[m[pos]]?1:0),0))
		} else {
			toBeCollected[m[pos]]=1
		}
	}
	return 0
}

function setFeaturedButton(btn){
	var featured = $('#featuredButton')
	var other = $('#otherButtons')
	other.append(featured.find('button').detach())
	featured.append(btn.detach())
}

function getNextMatch(){
	for (var i=0; i<eventMatches.length; i++){
		if (match == eventMatches[i]['Match']){
			if (i+1 >= eventMatches.length) return 0
			return eventMatches[i+1]
		}
	}
	return 0
}

var originalTitle

$(document).ready(function(){
	if (!eventYear || !eventVenue){
		$('h1').text("Event Not Found")
		return
	}

	if(!originalTitle) originalTitle = $('title').text()
	$('title').text(originalTitle.replace(/EVENT/g, eventName))

	scouting = $('#scouting')

	loadEventSchedule(function(){
		if ($('#pit-scouting').length) loadPitScouting(showScreen)
		else loadEventStats(showScreen)
	})

	$("label").click(function(e){
		e.preventDefault()
		var check=$(this).find(':checkbox,:radio')
		if (check.attr('disabled') && !check.prop('checked')) return
		toggleChecked(check)
	})

	$("img.count").click(countHandler)

	$("img.robot-location").click(function(e){
		var x = Math.round(1000 * (e.pageX - this.offsetLeft) / this.width)/10,
		y = Math.round(1000 * (e.pageY - this.offsetTop) / this.height)/10,
		inp = $(this).parent().find('input'),
		name = inp.attr('name')
		$(`.${name}`).remove()
		$('body').append($('<img class=location-pointer src=/pointer.png style="position:absolute;width:3em">').css('top',e.pageY).css('left',e.pageX).addClass(name))
		inp.val(`${x}%x${y}%`)
	})

	$("#nextBtn").click(function(e){
		if (!store()) return false
		var next = getNextMatch()
		if (!next){
			alert("Data saved and done. That was the last match!")
		} else {
			team = next[pos]
			match = next['Match']
			showScouting()
		}
		return false
	})
	$("#pitScoutNext").click(function(e){
		storePitScouting()
		showSelectPitScoutTeam()
		return false
	})
	$("#matchBtn").click(function(e){
		if (!store()) return false
		showMatchList()
		return false
	})
	$("#robotBtn").click(function(e){
		if (!store()) return false
		showPosList()
		return false
	})
	$("#teamBtn").click(function(e){
		if (!store()) return false
		showTeamChange()
		return false
	})
	$('.showInstructions').click(function(){
		showLightBox($(this).parent().find('.instructions'))
		return false
	})
	$("#uploadBtn").click(function(e){
		if (!store()) return false
		location.href="/upload.html"
		return false
	})

	$('img.expandable-image').click(function(){
		showLightBox($('#lightBoxImage').html("").append($('<img>').attr('src',$(this).attr('src')).addClass('full-image')))
	})
})
