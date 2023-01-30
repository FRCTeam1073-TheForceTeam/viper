"use strict"

var pos = "",
team = "",
match = "",
orient = "",
matchName = "",
scouting,
storeTime=0
parseHash()

function parseHash(){
	pos = (location.hash.match(/^\#(?:.*\&)?(?:pos\=)([RB][1-3])(?:\&.*)?$/)||["",""])[1]
	team = (location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["",""])[1]
	orient = (location.hash.match(/^\#(?:.*\&)?(?:orient\=)(left|right)(?:\&.*)?$/)||["",""])[1]
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)((?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+)(?:\&.*)?$/)||["",""])[1]
}

function showScreen(){
	if (!team && $('#select-team').length) showSelectTeam()
	else if (team && $('#pit-scouting').length) showPitScouting()
	else if (!pos) showPosList()
	else if (!match) showMatchList()
	else if (!team) showTeamChange()
	else showScouting()
}

$(window).on('hashchange', function(){
	if (scouting.is(':visible') && formHasChanges(scouting)){
		if (confirm("Do you want to save your data?")) store()
	}
	parseHash()
	showScreen()
})

function showSelectTeam(){
	$('.screen').hide()
	location.hash = `#event=${eventId}`
	window.scrollTo(0,0)
	var el = $('#teamList').html(""),
	withData = getTeamsWithPitData()
	$('.location-pointer').remove()
	for (var i=0; i<eventTeams.length;i++){
		var button = $('<button>').text(eventTeams[i]).click(showPitScouting)
		if (withData.hasOwnProperty(eventTeams[i])) button.addClass('stored')
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
		showPosList()
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
	var lastDone = localStorage.getItem("last_match_"+eventId)
	var seenLastDone = false;
	for (var i=0; i<eventMatches.length; i++){
		var matchTeam = eventMatches[i][pos]
		var matchId = eventMatches[i]['Match']
		var matchName = getMatchName(matchId)
		var completeClass=(lastDone&&!seenLastDone)?"complete":""
		var storedClass = (localStorage.getItem(getScoutKey(matchTeam, matchId)))?"stored":""
		if (lastDone == matchId) seenLastDone = true;
		$('#match-list').append(
			$('<div class=match>')
			.append($(`<button class="teamColorBG ${completeClass} ${storedClass}" data-team=${matchTeam} data-match=${matchId}>`).text(matchTeam).click(function(){
				team = $(this).attr('data-team')
				match = $(this).attr('data-match')
				showScouting()
			})).append($('<span>').text(' ' + matchName))
		)
	}
	setTeamBG()
	$('#select-match').show()
}

function getScoutKey(t,m,e){
	if (!t) t = team
	if (!m) m = match
	if (!e) e = eventId
	return `${e}_${m}_${t}`
}

function getPitScoutKey(t,m,e){
	if (!t) t = team
	if (!e) e = eventId
	return `${e}_${t}`
}

function setHash(pos,orient,team,match){
	location.hash = buildHash(pos,orient,team,match)
}

function buildHash(pos,orient,team,match){
	return `#event=${eventId}`+
		(pos?`&pos=${pos}`:"")+
		(orient?`&orient=${orient}`:"")+
		(team?`&team=${team}`:"")+
		(match?`&match=${match}`:"")
}

function showPitScouting(t){
	if (t && typeof t != 'number') t = parseInt($(this).text())
	if (t) team = t
	$('.screen').hide()
	window.scrollTo(0,0)
	setHash(null,null,team,null)
	var pit = $('#pit-scouting')
	pit[0].reset()
	$('.location-pointer').remove()
	fillDefaultFormFields()
	pit.show()
}

function showScouting(){
	$('.screen').hide()
	setHash(pos,orient,team,match)
	window.scrollTo(0,0)
	scouting[0].reset()
	if (typeof beforeShowScouting == 'function') beforeShowScouting()
	matchName = getMatchName(match)
	setupButtons()
	$('.orientLeft').toggle(orient && orient=='left')
	$('.orientRight').toggle(orient && orient=='right')
	$('h1').text(`${eventName}, ${matchName}, Team ${team}`)
	$('.teamColor').text(pos.startsWith('R')?"red":"blue")
	$('input[name="match"]').val(match).attr('value',match)
	fillDefaultFormFields()
	$('.match').text(matchName)
	setTeamBG()
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
	keys = []
	values = {}
	$(`${formId} input,${formId} textarea`).each(function(){
		var el=$(this),name=el.attr('name'),val=el.val(),type=el.attr('type')
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

function store(){
	if (formHasChanges(scouting)){
		localStorage.setItem("last_match_"+eventId, match)
		var csv = toCSV('#scouting')
		localStorage.setItem(`${eventYear}_headers`, csv[0])
		localStorage.setItem(getScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter($('#scouting'))
	}
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

function haveDataForMatch(m){
	if (!m) return 0
	var have = getTeamsWithData();
	if (have[m['R1']]) return 1
	if (have[m['R2']]) return 1
	if (have[m['R3']]) return 1
	if (have[m['B1']]) return 1
	if (have[m['B2']]) return 1
	if (have[m['B3']]) return 1
	return 0
}

function setupButtons(){
	var next = getNextMatch()
	if (!next || haveDataForMatch(next)){
		setFeaturedButton($('#uploadBtn'))
		return
	}
	setFeaturedButton($('#nextBtn'))
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

	loadEventSchedule(showScreen)

	$("label").click(function(e){
		e.preventDefault()
		var check=$(this).find(':checkbox,:radio')
		if (check.attr('disabled') && !check.prop('checked')) return
		toggleChecked(check)
	})

	$("img.count").click(function(e){
		var src = $(this).attr('src')
		var toAdd = 0
		if(/up/.test(src))toAdd = 1
		else if(/down/.test(src))toAdd = -1
		else if(/three/.test(src))toAdd = 3
		else if(/five/.test(src))toAdd = 5
		var input = $(this).closest('td').find('input'),
		val = input.val(),
		max = parseInt(input.attr('max')||"9999999"),
		min = parseInt(input.attr('min')||"0")
		val = /^[0-9]+$/.test(val)?parseInt(val):0
		val = val+toAdd
		val = val<min?min:val
		val = val>max?max:val
		input.val(val)
	})

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
		store()
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
		showSelectTeam()
		return false
	})
	$("#matchBtn").click(function(e){
		store()
		showMatchList()
		return false
	})
	$("#robotBtn").click(function(e){
		store()
		showPosList()
		return false
	})
	$("#teamBtn").click(function(e){
		store()
		showTeamChange()
		return false
	})
	$('.showInstructions').click(function(){
		showLightBox($(this).parent().find('.instructions'))
		return false
	})
	$("#uploadBtn").click(function(e){
		store()
		var returnTo = "",
		nextTeam = team,
		nextMatch = match,
		next = getNextMatch()
		if (next){
			returnTo = "#" + location.pathname
			if (formHasChanges(scouting)){
				nextTeam = next[pos]
				nextMatch = next['Match']
			}
			returnTo += buildHash(pos,orient,nextTeam,nextMatch)
		}
		location.href="/upload.html" + returnTo
		return false
	})

	$('img.expandable-image').click(function(){
		showLightBox($('#lightBoxImage').html("").append($('<img>').attr('src',$(this).attr('src')).addClass('full-image')))
	})
})
