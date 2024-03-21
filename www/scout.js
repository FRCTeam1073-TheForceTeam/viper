"use strict"

var pos = "",
team = "",
match = "",
orient = "",
matchName = "",
teamList=[],
scouting,
pitScouting,
subjectiveScouting,
storeTime=0
parseHash()

function parseHash(){
	pos = (location.hash.match(/^\#(?:.*\&)?(?:pos\=)([RB][1-3])(?:\&.*)?$/)||["",""])[1]
	team = (location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["",""])[1]
	orient = (location.hash.match(/^\#(?:.*\&)?(?:orient\=)(left|right)(?:\&.*)?$/)||["",""])[1]
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)((?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+)(?:\&.*)?$/)||["",""])[1]
	teamList = (location.hash.match(/^\#(?:.*\&)?(?:teams\=)([0-9]+(?:,[0-9]+)*)(?:\&.*)?$/)||["",""])[1]
}

function showScreen(){
	if (!team && $('#select-team').length && pitScouting.length) showSelectPitScoutTeam()
	else if (!team && $('#select-team').length && $('#subjective-scouting').length) showSelectSubjectiveScoutTeam()
	else if (team && $(pitScouting).length) showPitScoutingForm()
	else if (team && $('#subjective-scouting').length) showSubjectiveScoutingForm()
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
	window.scrollTo(0,0)
})

function showSelectPitScoutTeam(){
	Promise.all([
		promiseEventTeams(),
		promisePitScouting()
	]).then(values=>{
		var [eventTeams, pitData] = values
		$('.screen,.init-hide').hide()
		resetInitialValues(pitScouting)
		setHash(null,null,null,null,teamList)
		window.scrollTo(0,0)
		$('h1').text("Pit Scouting " + eventName)
		var el = $('#teamList').html(""),
		withData = getTeamsWithPitData(),
		showTeams = teamList?teamList.split(/,/).map(s=>parseInt(s)):eventTeams
		$('.location-pointer').remove()
		for (var i=0; i<showTeams.length;i++){
			var button = $('<button>').text(showTeams[i]).click(showPitScoutingForm)
			if (withData.hasOwnProperty(showTeams[i])||pitData[showTeams[i]]) button.addClass('stored')
			el.append(button)
		}
		$('#select-team').show()
	})
}

function showSelectSubjectiveScoutTeam(){
	Promise.all([
		promiseEventTeams(),
		promiseSubjectiveScouting()
	]).then(values=>{
		var [eventTeams, subjectiveData] = values
		$('.screen,.init-hide').hide()
		resetInitialValues(subjectiveScouting)
		setHash(null,null,null,null,teamList)
		window.scrollTo(0,0)
		$('h1').text("Subjective Scouting " + eventName)
		var el = $('#teamList').html(""),
		withData = getTeamsWithSubjectiveData(),
		showTeams = teamList?teamList.split(/,/).map(s=>parseInt(s)):eventTeams
		$('.location-pointer').remove()
		for (var i=0; i<showTeams.length;i++){
			var button = $('<button>').text(showTeams[i]).click(showSubjectiveScoutingForm)
			if (withData.hasOwnProperty(showTeams[i])||subjectiveData[showTeams[i]]) button.addClass('stored')
			el.append(button)
		}
		$('#select-team').show()
	})
}

function showTeamChange(){
	$('.screen,.init-hide').hide()
	location.hash = `#event=${eventId}&pos=${pos}&match=${match}`
	resetInitialValues(scouting)
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
	$('.screen,.init-hide').hide()
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
	promiseEventStats().then(resolve=>{
		var [eventStats] = resolve
		$('.screen,.init-hide').hide()
		setHash(pos,orient)
		window.scrollTo(0,0)
		$('#match-list').html('')
		$('h1').text(`${eventName} ${pos}`)
		var alreadyScouted = {}
		forEachTeamMatch(eventStats, function(team,match){
			alreadyScouted[match]=1
		})
		alreadyScouted[localStorage.getItem("last_match_"+eventId)||""] = 1
		var lastDone
		for (var i=eventMatches.length-1; !lastDone && i>=0; i--){
			var m = eventMatches[i]['Match']
			if(alreadyScouted[m])lastDone=m
		}
		var seenLastDone = false;
		eventMatches.forEach(m => {
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
	})
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

function getSubjectiveScoutKey(t,e){
	if (!t) t = team
	if (!e) e = eventId
	return `${e}_subjective_${t}`
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
				var checked = input.attr('value')==val
				if(checked) input.attr('checked',"")
				else  input.removeAttr('checked')
				input.prop('checked',checked)
				input.attr('data-at-scout-start',checked?"checked":"unchecked")
			} else if (!/^submit$/.test(type) && val){
				input.attr('data-at-scout-start',val)
				input.val(val)
			}
		}
	})
}

function getValueAttrOrChecked(input){
	if (/^radio|checkbox$/.test(input.attr('type'))){
		var checked = input.attr('checked')
		return (typeof checked !== 'undefined' && checked !== false)?"checked":"unchecked"
	}
	return input.attr('value')||""
}

function getValOrChecked(input){
	if (/^radio|checkbox$/.test(input.attr('type'))) return input.prop('checked')?"checked":"unchecked"
	return input.val()||""
}

function storeInitialValues(form){
	form.find('input,textarea').each(function(){
		var input = $(this),
		atLoad = input.attr('data-at-page-load')
		if (typeof atLoad === 'undefined' || atLoad === false){
			var val = getValueAttrOrChecked(input)
			input.attr('data-at-page-load', val)
			input.attr('data-at-scout-start', val)
		}
	})
}
function resetInitialValues(form){
	form.find('input,textarea').each(function(){
		var input = $(this),
		type = input.attr('type'),
		atLoad = input.attr('data-at-page-load')
		if (typeof atLoad !== 'undefined' && atLoad !== false){
			if (/^radio|checkbox$/.test(type)){
				input.prop('checked',atLoad=='checked')
				input.attr('data-at-scout-start', atLoad)
			} else if (!/^submit$/.test(type)){
				input.val(atLoad)
				input.attr('data-at-scout-start', atLoad)
			}
		}
	})
}

function showPitScoutingForm(t){
	promisePitScouting().then(pitData=>{
		if (t && typeof t != 'number') t = parseInt($(this).text())
		if (t) team = t
		$('.screen,.init-hide').hide()
		$('h1').text("Pit Scouting " + eventName + " Team " + team)
		window.scrollTo(0,0)
		setHash(null,null,team,null,teamList)
		resetInitialValues(pitScouting)
		$('.location-pointer').remove()
		fillDefaultFormFields()
		fillPreviousFormData(pitScouting, localPitScoutingData(team)||pitData[team])
		promiseTeamsInfo().then(ti => {
			if (ti[team]){
				$('input[name="team_name"]').val(ti[team].nameShort).attr('value',ti[team].nameShort)
				var loc = `${ti[team].city}, ${ti[team].stateProv}, ${ti[team].country}`
				$('input[name="team_location"]').val(loc).attr('value',loc)
			}
		})
		resetSequentialInputSeries()
		$('.count').each(countHandler)
		for (var i=0; i<onShowPitScouting.length; i++){
			if(!onShowPitScouting[i]()) return false
		}
		pitScouting.show()
		localStorage.setItem("last_scout_type", "pit-scout")
	})
}


function showSubjectiveScoutingForm(t){
	promiseSubjectiveScouting().then(subjectiveData=>{
		if (t && typeof t != 'number') t = parseInt($(this).text())
		if (t) team = t
		$('.screen,.init-hide').hide()
		$('h1').text("Subjective Scouting " + eventName + " Team " + team)
		window.scrollTo(0,0)
		setHash(null,null,team,null,teamList)
		var form = $('#subjective-scouting')
		resetInitialValues(form)
		$('.location-pointer').remove()
		fillDefaultFormFields()
		fillPreviousFormData(form, localSubjectiveScoutingData(team)||subjectiveData[team])
		resetSequentialInputSeries()
		$('.count').each(countHandler)
		for (var i=0; i<onShowSubjectiveScouting.length; i++){
			if(!onShowSubjectiveScouting[i]()) return false
		}
		form.show()
		localStorage.setItem("last_scout_type", "subjective-scout")
	})
}

function findParentFromButton(button){
	var parent = button
	for(var i=0;!parent.find('input').length&&i<10;i++) parent = parent.parent()
	return parent
}

function findInputInEl(parent){
	var input = findParentFromButton(parent).find('input')
	if (!input.length) throw ("No input for counter")
	return input
}

var lastClickTimeOnCounter = 0
function countHandler(e){
	var clicked = e&&e.hasOwnProperty('type')&&e.type==='click'&&Math.abs(lastClickTimeOnCounter-e.timeStamp)>100,
	parent = findParentFromButton($(this)),
	count = $(this).is('.count')?$(this):$(this).find('.count').first(),
	input = findInputInEl(parent),
	src = count.attr('src'),
	val=parseInt(input.val())||0,
	max=parseInt(input.attr('max'))||999999,
	min=parseInt(input.attr('min'))||0
	if (clicked){
		lastClickTimeOnCounter=e.timeStamp
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
	promiseEventStats().then(resolve=>{
		var [eventStats, eventStatsByTeam, eventStatsByMatchTeam] = resolve
		$('.screen,.init-hide').hide()
		resetInitialValues(scouting)
		setHash(pos,orient,team,match)
		window.scrollTo(0,0)
		if (typeof beforeShowScouting == 'function') beforeShowScouting()
		matchName = getMatchName(match)
		setupButtons()
		$('.orientLeft').toggle(orient && orient=='left')
		$('.orientRight').toggle(orient && orient=='right')
		$('h1').text(`${eventName} ${pos}, ${matchName}, Team ${team}`)
		$('.teamColor').text(pos.startsWith('R')?"red":"blue")
		$('input[name="match"]').val(match).attr('data-at-scout-start',match)
		fillDefaultFormFields()
		$('.match').text(matchName)
		setTeamBG()
		fillPreviousFormData(scouting, localScoutingData(team,match)||eventStatsByMatchTeam[`${match}-${team}`])
		$('.count').each(countHandler)
		resetSequentialInputSeries()
		$('#scouting-comments').toggle(!!window.showScoutingComments)
		for (var i=0; i<onShowScouting.length; i++){
			if(!onShowScouting[i]()) return false
		}
		showTab(null, $('.default-tab'))
		scouting.show()
		localStorage.setItem("last_scout_type", "scout")
	})
}

function fillDefaultFormFields(){
	$('.team').text(team)
	$('input[name="event"]').val(eventId).attr('data-at-scout-start',eventId)
	$('input[name="team"]').val(team).attr('data-at-scout-start',team)
	var lastScouter = localStorage.getItem("last_scouter")||""
	$('input[name="scouter"]').val(lastScouter).attr('data-at-scout-start',lastScouter)
}

function setTeamBG(){
	$('.teamColorBG').toggleClass('redTeamBG', pos.startsWith('R')).toggleClass('blueTeamBG', pos.startsWith('B'))
	$('.otherTeamBG').toggleClass('blueTeamBG', pos.startsWith('R')).toggleClass('redTeamBG', pos.startsWith('B'))
	$('body').toggleClass('redTeam', pos.startsWith('R')).toggleClass('blueTeam', pos.startsWith('B'))
}

function toggleChecked(o){
	o.each(function(){
		$(this).prop('checked', !$(this).prop('checked'))
	})
}

function toCSV(form){
	var keys = [],
	values = {}
	form.find("input,textarea").each(function(){
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
		var el=$(this),
		val=getValOrChecked(el),
		start=el.attr('data-at-scout-start')
		if (start !== undefined && val!==start)	changes=true
	})
	return changes
}

var onStore = []
var onShowScouting = []
var onShowPitScouting = []
var onShowSubjectiveScouting = []

function setTimeStamps(form){
	var time = new Date().toISOString().replace(/\..*/,"+00:00"),
	created = form.find('input[name="created"]')
	if (created.length && !created.val()) created.val(time)
	form.find('input[name="modified"]').val(time)
}

function store(){
	if (formHasChanges(scouting)){
		for (var i=0; i<onStore.length; i++){
			if(!onStore[i]()) return false
		}
		setTimeStamps(scouting)
		localStorage.setItem("last_match_"+eventId, match)
		localStorage.setItem("last_pos", pos)
		var csv = toCSV(scouting)
		localStorage.setItem(`${eventYear}_headers`, csv[0])
		localStorage.setItem(getScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter(scouting)
	}
	return true
}

function storeScouter(form){
	localStorage.setItem('last_scouter',form.find('input[name="scouter"]').val())
}

function storePitScouting(){
	var f=$('#pit-scouting')
	if (formHasChanges(f)){
		setTimeStamps(f)
		var csv = toCSV(pitScouting)
		localStorage.setItem(`${eventYear}_pitheaders`, csv[0])
		localStorage.setItem(getPitScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter(f)
	}
}
function storeSubjectiveScouting(){
	var f=subjectiveScouting
	if (formHasChanges(f)){
		setTimeStamps(f)
		var csv = toCSV(subjectiveScouting)
		localStorage.setItem(`${eventYear}_subjectiveheaders`, csv[0])
		localStorage.setItem(getSubjectiveScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter(f)
	}
}

function localPitScoutingData(t){
	var data = localStorage.getItem(getPitScoutKey(t))
	if (!data) return null
	return csvToArrayOfMaps(localStorage.getItem(`${eventYear}_pitheaders`)+"\n"+data)[0]
}

function localSubjectiveScoutingData(t){
	var data = localStorage.getItem(getSubjectiveScoutKey(t))
	if (!data) return null
	return csvToArrayOfMaps(localStorage.getItem(`${eventYear}_subjectiveheaders`)+"\n"+data)[0]
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

function getTeamsWithSubjectiveData(){
	var teams = {}
	for (var i in localStorage){
		if (/^20[0-9]{2}[a-zA-Z0-9\-]+_subjective_[0-9]+$/.test(i)){
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

function showTab(event, tab){
	var button = (tab||$(this)),
	name = button.attr('data-content'),
	tab=$(`.tab[data-content="${name}"]`)
	$('.tab').removeClass("redTeamBG").removeClass("blueTeamBG")
	tab.addClass(pos.startsWith('R')?"redTeamBG":"blueTeamBG")
	$('.tab-content').hide()
	$(`.${name}`).show()
	if(button.is('.tab-button')) window.scrollTo(tab.offset())
	return false
}

var eventMatches

$(document).ready(function(){
	if (!eventYear || !eventVenue){
		$('h1').text("Event Not Found")
		return
	}

	scouting = $('#scouting')
	pitScouting = $('#pit-scouting')
	subjectiveScouting = $('#subjective-scouting')

	storeInitialValues(scouting)
	storeInitialValues(pitScouting)
	storeInitialValues(subjectiveScouting)

	$('.tab,.tab-button').click(showTab)

	$('title').text($('title').text().replace(/EVENT/g, eventName))


	promiseEventMatches().then(em => {
		eventMatches = em
		if (pitScouting.length) showScreen()
		if (subjectiveScouting.length) showScreen()
		else showScreen()
	})

	$("label").click(function(e){
		e.preventDefault()
		var check=$(this).find(':checkbox,:radio')
		if (check.attr('disabled') && !check.prop('checked')) return
		toggleChecked(check)
	})

	$("input,textarea").focus(function(){
		// Select pre-filled input values
		if ($(this).attr('disabled')) return
		if (!$(this).attr('value')) return
		if (/^radio|checkbox|submit$/i.test($(this).attr('type'))) return
		if ($(this).attr('value') != $(this).val()) return
		$(this).one('mouseup',function(){
			$(this).select()
			return false
		}).select()
	})

	$("img.count").click(countHandler).each(function(){
		findParentFromButton($(this)).click(countHandler)
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
	$("#pitScoutNext,#pitTeamButton").click(function(e){
		storePitScouting()
		showSelectPitScoutTeam()
		return false
	})
	$("#subjectiveScoutNext,#subjectiveTeamButton").click(function(e){
		storeSubjectiveScouting()
		showSelectSubjectiveScoutTeam()
		return false
	})
	$("#matchBtn").click(function(e){
		if (!store()) return false
		showMatchList()
		return false
	})
	$(".robotBtn").click(function(e){
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

	$('.sequential-input-series textarea,.sequential-input-series input[type="text"]').change(function(){
		var name = $(this).attr('name'),
		n = /[0-9]/.exec(name),
		next = name.replace(n,parseInt(n)+1)
		$('textarea[name='+next+'],input[name='+next+']').closest('.sequential-input-series').show()
	})
})

function resetSequentialInputSeries(){
	$('.sequential-input-series textarea,.sequential-input-series input[type="text"]').each(function(){
		var name = $(this).attr('name'),
		n = /[0-9]/.exec(name),
		next = name.replace(n,parseInt(n)+1)
		$('textarea[name='+next+'],input[name='+next+']').closest('.sequential-input-series').toggle($(this).val()!="")
	})
}
