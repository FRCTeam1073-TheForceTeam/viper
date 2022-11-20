var pos = ""
var team = ""
var match = ""
var orient = ""
var matchName = ""
var scouting
parseHash()

function parseHash(){
	pos = (location.hash.match(/^\#(?:.*\&)?(?:pos\=)([RB][1-3])(?:\&.*)?$/)||["",""])[1]
	team = (location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["",""])[1]
	orient = (location.hash.match(/^\#(?:.*\&)?(?:orient\=)(left|right)(?:\&.*)?$/)||["",""])[1]
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)((?:qm|qf|sf|f)[0-9]+)(?:\&.*)?$/)||["",""])[1]
}

function showScreen(){
	if (!pos) showPosList()
	else if (!team || !match) showMatchList()
	else showScouting()
}

$(window).on('hashchange', function(){
	if (scouting.is(':visible') && formHasChanges(scouting)){
		if (confirm("Do you want to save your data?")) store()
	}
	parseHash()
	showScreen()
})

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
	if (formHasChanges(scouting)){
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
	}
}

function safeCSV(s){
	return s.replace(/[\r\n\t,]+ */g, " ")
}

$(document).ready(function(){
	if (!eventYear || !eventVenue){
		$('h1').text("Event Not Found")
		return
	}

	var title = $('title')
	title.text(eventName + " " + title.text())

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
		var toAdd = /up/.test($(this).attr('src'))?1:-1
		var input = $(this).closest('td').find('input')
		var val = input.val()
		val = /^[0-9]+$/.test(val)?parseInt(val):0
		val = val+toAdd
		val = val<0?0:val
		input.val(val)
	})

	$("#nextBtn").click(function(e){
		store()
		var i = parseInt(match.replace(/[^0-9]/g,""))
		if (i >= eventMatches.length){
			alert("Data saved and done. That was the last match!")
		} else {
			team = eventMatches[i][pos]
			match = "qm" + (i+1)
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
	$("#showUploadsBtn").click(function(e){
		store()
		location.href="/upload.html"
		return false
	})
	$("#backMatchBtn").click(function(e){
		if (!formHasChanges(scouting) || confirm("Discard data and go back?")) showMatchList()
		return false
	})
	$("#backRobotBtn").click(function(e){
		if (!formHasChanges(scouting) || confirm("Discard data and go back?")) showPosList()
		return false
	})
})
