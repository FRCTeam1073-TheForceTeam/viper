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
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)((?:qm|qf|sf|f)[0-9]+)(?:\&.*)?$/)||["",""])[1]
}

function showScreen(){
	if (!pos) showPosList()
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
			$('<li>').text(matchName+' ')
			.append($(`<button class="teamColorBG ${completeClass} ${storedClass}" data-team=${matchTeam} data-match=${matchId}>`).text(pos + " : " + matchTeam).click(function(){
				team = $(this).attr('data-team')
				match = $(this).attr('data-match')
				showScouting()
			}))
		)
	}
	setTeamBG()
	$('#select-match').show()
}

function getMatchName(matchId){
	return matchId
		.replace(/^qm/, "Qualifier ")
		.replace(/^qf/, "Quarter-final ")
		.replace(/^sf/, "Semi-final ")
		.replace(/^f/, "Final ")
}

function getScoutKey(t,m,e){
	if (!t) t = team
	if (!m) m = match
	if (!e) e = eventId
	return `${e}_${m}_${t}`
}

function setHash(pos,orient,team,match){
	location.hash = `#event=${eventId}`+
		(pos?`&pos=${pos}`:"")+
		(orient?`&orient=${orient}`:"")+
		(team?`&team=${team}`:"")+
		(match?`&match=${match}`:"")
}

function showScouting(){
	$('.screen').hide()
	setHash(pos,orient,team,match)
	window.scrollTo(0,0)
	scouting[0].reset()
	$('.toggle > *').hide()
	$('.toggle > *:first-child').show()
	matchName = getMatchName(match)
	setupButtons()
	$('.orientLeft').toggle(orient && orient=='left')
	$('.orientRight').toggle(orient && orient=='right')
	$('h1').text(`${eventName}, ${matchName}, Team ${team}`)
	$('.team').text(team)
	$('input[name="event"]').val(eventId)
	$('input[name="match"]').val(match)
	$('input[name="team"]').val(team)
	$('.match').text(matchName)
	setTeamBG()
	scouting.show()
}

function setTeamBG(){
	$('.teamColorBG').toggleClass('redTeamBG', pos.startsWith('R')).toggleClass('blueTeamBG', pos.startsWith('B'))
}

function toggleChecked(o){
	o.each(function(){
		$(this).prop('checked', !$(this).prop('checked'))
	})
}

function toCSV(){
	keys = []
	values = {}
	$('#scouting input,#scouting textarea').each(function(){
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
		if (type=='hidden') return
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
		var csv = toCSV()
		localStorage.setItem(`${eventYear}_headers`, csv[0])
		localStorage.setItem(getScoutKey(), csv[1])
		storeTime = new Date().getTime()
	}
}

function safeCSV(s){
	return s.replace(/[\r\n\t,]+ */g, " ")
}

function getTeamsWithData(){
	var teams = {}
	teams[team]=1

	for (i in localStorage){
		if (/^20[0-9]{2}.*_.*_[0-9]+$/.test(i)){
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
		check=$(this).find(':checkbox,:radio')
		if (check.attr('disabled') && !check.prop('checked')) return
		toggleChecked(check)
	})

	$(".toggle").click(function(e){
		e.preventDefault()
		var field = $(this).attr('data-field')
		var index = parseInt($(this).attr('data-index'))
		var children = $(this).children()
		var visible = 0
		for (var i=0; i<children.length; i++){
			if ($(children[i]).is(":visible"))	visible = i
			$(children[i]).hide()
		}
		visible++
		if (visible>=children.length) visible=0
		var value = $(children[visible]).show().attr('data-value')
		var input = $(`input[name="${field}"]`)
		input.val(input.val().replace(/./g, (c, i) => i == index? value: c))
		console.log(field + ": " + input.val())		
	})

	$("img.count").click(function(e){
		var src = $(this).attr('src')
		var toAdd = 0
		if(/up/.test(src))toAdd = 1
		else if(/down/.test(src))toAdd = -1
		else if(/three/.test(src))toAdd = 3
		else if(/five/.test(src))toAdd = 5
		var input = $(this).closest('td').find('input')
		var val = input.val()
		val = /^[0-9]+$/.test(val)?parseInt(val):0
		val = val+toAdd
		val = val<0?0:val
		input.val(val)
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
	$("#uploadBtn").click(function(e){
		store()
		location.href="/upload.html"
		return false
	})
})
