"use strict"

var pos = "",
team = "",
match = "",
orient = "right",
matchName = "",
teamList=[],
go,
scouting,
pitScouting,
subjectiveScouting,
storeTime=0
parseHash()

function parseHash(){
	pos = (location.hash.match(/^\#(?:.*\&)?(?:pos\=)([RB][1-3])(?:\&.*)?$/)||["",""])[1]
	team = (location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["",""])[1]
	orient = (location.hash.match(/^\#(?:.*\&)?(?:orient\=)(left|right)(?:\&.*)?$/)||["","right"])[1]
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)((?:pm|qm|qf|sf|([1-5]p)|f)[0-9]+)(?:\&.*)?$/)||["",""])[1]
	teamList = (location.hash.match(/^\#(?:.*\&)?(?:teams\=)([0-9]+(?:,[0-9]+)*)(?:\&.*)?$/)||["",""])[1]
	go = (location.hash.match(/^\#(?:.*\&)?(?:go\=)(back)(?:\&.*)?$/)||["",""])[1]
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
	if(go=='back')history.back()
}

function maybeSaveFirst(){
	if (changedNotStored(getActiveForm())){
		if (confirm("Do you want to save your data?")) store()
	}
}

$(window).on('hashchange', function(){
	var current = buildHash(pos,orient,team,match,teamList)
	if (location.hash==current) return
	maybeSaveFirst()
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
	location.hash=buildHash(pos,orient,null,match)
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

function getKey(t,m,e){
	var form=getActiveForm()
	if (form === scouting) return getScoutKey(t,m,e)
	if (form === pitScouting) return getPitScoutKey(t,e)
	if (form === subjectiveScouting) return getSubjectiveScoutKey(t,e)
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
	if(go=='back')return
	location.hash = buildHash(pos,orient,team,match,teamList)
	return false
}

function buildHash(pos,orient,team,match,teamList){
	return `#event=${eventId}`+
		(pos?`&pos=${pos}`:"")+
		(orient&&$('.orientLeft').length?`&orient=${orient}`:"")+
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

function storeInitialValues(form, type){
	if (!form.length)return
	localStorage.setItem(`${eventYear}_${type}headers`, toCSV(form)[0])
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
		for (var i=0; i<window.onShowPitScouting.length; i++){
			if(!window.onShowPitScouting[i]()) return false
		}
		pitScouting.show()
		setupButtons()
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
		for (var i=0; i<window.onShowSubjectiveScouting.length; i++){
			if(!window.onShowSubjectiveScouting[i]()) return false
		}
		form.show()
		setupButtons()
		localStorage.setItem("last_scout_type", "subjective-scout")
	})
}

function findParentFromButton(button){
	var name=button.attr('data-input'),
	parent = button,
	found = parent
	if (name){
		found = $(`input[name=${name}]`).parent('td')
	} else {
		for(var i=0;i<10;i++){
			if (parent.find('input').length == 1) found = parent
			parent = parent.parent()
		}
	}
	return found
}

function findInputInEl(parent){
	var input = findParentFromButton(parent).find('input')
	//if (!input.length) throw ("No input for counter")
	return input
}

var changeFloater = $('<div id=change-floater>')

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
	if (parent.find('.disabledOverlay').is(':visible')) return
	if (clicked){
		lastClickTimeOnCounter=e.timeStamp
		var toAdd=1,
		oldVal=val
		if(/down/.test(src))toAdd = -1
		else if(/three/.test(src))toAdd = 3
		else if(/five/.test(src))toAdd = 5
		val+=toAdd
		val = val<min?min:val
		val = val>max?max:val
		var change = val-oldVal
		animateChangeFloater(change, e)
		inputChanged(input.val(val),change)
		parent.find('.count').each(countHandler)
	} else {
		if(/down/.test(count.attr('src'))){
			count.css('visibility', val<=min?'hidden':'visible');
		} else {
			count.css('visibility', val>=max?'hidden':'visible');
		}
	}
	return false
}

function animateChangeFloater(change, relative){
	if (change!=0){
		var x = relative.pageX?relative.pageX:(relative.offset().left+relative.width()/2),
		y = relative.pageY?relative.pageY:(relative.offset().top+relative.height()/2)
		changeFloater.text(change<0?change:"+"+change).toggleClass("negative",change<0).css({top:y-changeFloater.height()/2,left:x-changeFloater.width()/2}).show()
		$('body').append(changeFloater)
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
		$('h1').text(`${eventName} ${pos}, ${matchName}, Team ${team}`)
		$('.teamColor').text(pos.startsWith('R')?"red":"blue")
		$('.teamColorCaps').text(pos.startsWith('R')?"Red":"Blue")
		$('input[name="match"]').val(match).attr('data-at-scout-start',match)
		fillDefaultFormFields()
		$('.match').text(matchName)
		setTeamBG()
		fillPreviousFormData(scouting, localScoutingData(team,match)||eventStatsByMatchTeam[`${match}-${team}`])
		$('.count').each(countHandler)
		resetSequentialInputSeries()
		$('#scouting-comments').toggle(!!window.showScoutingComments)
		for (var i=0; i<window.onShowScouting.length; i++){
			if(!window.onShowScouting[i]()) return false
		}
		showTab(null, $('.default-tab'))
		scouting.show()
		setupButtons()
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
	$('.orientLeft').toggle(orient && orient=='left')
	$('.orientRight').toggle(orient && orient=='right')
	$('.teamColorBG').toggleClass('redTeamBG', pos.startsWith('R')).toggleClass('blueTeamBG', pos.startsWith('B'))
	$('.otherTeamBG').toggleClass('blueTeamBG', pos.startsWith('R')).toggleClass('redTeamBG', pos.startsWith('B'))
	$('body').toggleClass('redTeam', pos.startsWith('R')).toggleClass('blueTeam', pos.startsWith('B')).toggleClass('leftField', orient=='left').toggleClass('rightField', orient=='right')
}

function toggleChecked(o){
	o.each(function(){
		inputChanged($(this).prop('checked', !$(this).prop('checked')))
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
		keys.map(k=>safeCSV(values[k])).join(",") + "\n"
	]
}

function getActiveForm(){
	if (scouting.length && scouting.is(':visible')) return scouting
	if (pitScouting.length && pitScouting.is(':visible')) return pitScouting
	if (subjectiveScouting.length && subjectiveScouting.is(':visible')) return subjectiveScouting
	return null
}

function changedNotStored(form){
	if (!form) return false
	return formHasChanges(form) && new Date().getTime() - storeTime > 1000
}

window.addEventListener('beforeunload',(event) =>{
	if (changedNotStored(getActiveForm())){
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

window.onStore = window.onStore || []
window.onShowScouting = window.onShowScouting || []
window.onShowPitScouting = window.onShowPitScouting || []
window.onShowSubjectiveScouting = window.onShowSubjectiveScouting || []
window.onInputChanged = window.onInputChanged || []

function setTimeStamps(form){
	var time = new Date().toISOString().replace(/\..*/,"+00:00"),
	created = form.find('input[name="created"]')
	if (created.length && !created.val()) created.val(time)
	form.find('input[name="modified"]').val(time)
}

function inputChanged(input, change){
	for (var i=0; i<window.onInputChanged.length; i++){
		if(!window.onInputChanged[i](input, change)) return false
	}
}

function storeScouter(form){
	localStorage.setItem('last_scouter',form.find('input[name="scouter"]').val())
}

function store(uploaded){
	var form = getActiveForm()
	if (form === scouting) return storeScouting(uploaded)
	if (form === pitScouting) return storePitScouting(uploaded)
	if (form === subjectiveScouting) return storeSubjectiveScouting(uploaded)
}

function getUploadedPrefix(uploaded){
	return uploaded=="uploaded"?"uploaded_":""
}

function storeScouting(uploaded){
	if (formHasChanges(scouting)){
		for (var i=0; i<window.onStore.length; i++){
			if(!window.onStore[i]()) return false
		}
		setTimeStamps(scouting)
		localStorage.setItem("last_match_"+eventId, match)
		localStorage.setItem("last_pos", pos)
		var csv = toCSV(scouting)
		localStorage.setItem(`${eventYear}_headers`, csv[0])
		localStorage.setItem(getUploadedPrefix(uploaded)+getScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter(scouting)
	}
	return true
}

function storePitScouting(uploaded){
	var f=pitScouting
	if (formHasChanges(f)){
		setTimeStamps(f)
		var csv = toCSV(pitScouting)
		localStorage.setItem(`${eventYear}_pitheaders`, csv[0])
		localStorage.setItem(getUploadedPrefix(uploaded)+getPitScoutKey(), csv[1])
		storeTime = new Date().getTime()
		storeScouter(f)
	}
}
function storeSubjectiveScouting(uploaded){
	var f=subjectiveScouting
	if (formHasChanges(f)){
		setTimeStamps(f)
		var csv = toCSV(subjectiveScouting)
		localStorage.setItem(`${eventYear}_subjectiveheaders`, csv[0])
		localStorage.setItem(getUploadedPrefix(uploaded)+getSubjectiveScoutKey(), csv[1])
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

function pitScoutNext(uploaded){
	if (uploaded!="uploaded") localStorage.setItem("last_scout_action","next")
	storePitScouting(uploaded)
	showSelectPitScoutTeam()
	return false
}

function subjectiveScoutNext(uploaded){
	if (uploaded!="uploaded") localStorage.setItem("last_scout_action","next")
	storeSubjectiveScouting(uploaded)
	showSelectSubjectiveScoutTeam()
	return false
}

function goChooseMatch(){
	localStorage.setItem("last_scout_action","match")
	maybeSaveFirst()
	showMatchList()
	return false
}

function goChooseRobot(){
	localStorage.setItem("last_scout_action","robot")
	maybeSaveFirst()
	showPosList()
	return false
}

function rotateField(){
	orient=orient=='right'?"left":"right"
	setTeamBG()
	setHash(pos,orient,team,match)
	return false
}

function goChangeTeam(){
	localStorage.setItem("last_scout_action","team")
	maybeSaveFirst()
	showTeamChange()
	return false
}

function goNext(uploaded){
	if (uploaded!="uploaded") localStorage.setItem("last_scout_action","next")
	var form=getActiveForm()
	if (form===scouting)return goNextMatch(uploaded)
	if (form===pitScouting)return pitScoutNext(uploaded)
	if (form===subjectiveScouting)return subjectiveScoutNext(uploaded)
}

function goNextMatch(uploaded){
	if (!store(uploaded)) return false
	var next = getNextMatch()
	if (!next){
		alert("Data saved and done. That was the last match!")
	} else {
		team = next[pos]
		match = next['Match']
		showScouting()
	}
	return false
}

function goUploadData(){
	localStorage.setItem("last_scout_action","upload")
	if (!store()) return false
	location.href="/upload.html"
	return false
}

var qrNum=0,
qrUrls=[]
function nextQrCode(){
	showQrCode(qrNum+1)
}

function getQrUrls(){
	var csv=toCSV(getActiveForm())[1].trim(),
	csvIndex=0,
	urls=[]
	csv=csv.replace(/,0(?=,)/g,",")
	for (var i=1;csvIndex<csv.length;i++){
		var parts=[location.origin,"/qr.html?"]
		if(i>1)parts.push(`${i}...`)
		parts.push(getKey(),",")
		var len=parts.reduce((sum,v)=>sum+v.length,0)
		while(csvIndex<csv.length && len<1000){
			var next=encodeURIComponent(csv[csvIndex])
			len+=next.length
			parts.push(next)
			csvIndex++
		}
		if (csvIndex<csv.length) parts.push(`...${i+1}`)
		urls.push(parts.join(''))
	}
	return urls
}

function showQrCode(num){
	localStorage.setItem("last_scout_action","qr")
	if (typeof num == 'object'){
		qrUrls = getQrUrls()
		num=1
	}
	qrNum=num
	if (num>qrUrls.length){
		closeLightBox()
		goNext("uploaded")
		return false
	}
	var dialog=$('#qr-code-dialog')
	if (!dialog.length){
		dialog=$('<div id=qr-code-dialog class=lightBoxCenterContent>')
		.append($('<h2 id=qr-code-title>'))
		.append($('<div id=qr-code style="border:.5em solid white">'))
		.append($('<p>')
			.append($('<button>').text("Cancel").click(closeLightBox))
			.append(" ")
			.append($('<button style=float:right>').text('Next').click(nextQrCode))
		)
        $('body').append(dialog)
	}
	$('#qr-code-title').text(`QR Code ${qrNum} of ${qrUrls.length}`)
	var size = Math.min($('body').innerWidth()-20,$('body').innerHeight()-20,700)
	new QRCode($("#qr-code").html("").click(copyTitleAttr)[0],{
		text:qrUrls[num-1],
		width:size,
		height:size,
		correctLevel:QRCode.CorrectLevel.L,
	})
	showLightBox(dialog)
	return false
}

function copyTitleAttr(){
	navigator.clipboard.writeText($(this).attr('title'))
}

function setupButtons(){
	var featured='next',
	doneButtons=$('#doneButtons'),
	featuredButton=$('<div id=featuredButton>'),
	otherButtons=$('<div id=otherButtons>')
	if("qr"==localStorage.getItem("last_scout_action")) featured="qr"
	else if(getActiveForm()===scouting){
		var next = getNextMatch()
		if(!next || haveDataForMatch(next) || haveAllDataForOurNextMatch()) featured='upload'
	}
	addButtons(featuredButton,featured,true)
	addButtons(otherButtons,featured,false)
	doneButtons.html("").append(featuredButton).append(otherButtons)
}

function addButtons(div, featured, isFeatured){
	if (getActiveForm()===scouting){
		if((featured=='next')==isFeatured) div.append($('<button>').text('Next Match').click(goNext)).append(" ")
		if((featured=='upload')==isFeatured) div.append($('<button>').text('Upload Data').click(goUploadData)).append(" ")
		if((featured=='qr')==isFeatured) div.append($('<button>').text('QR Code').click(showQrCode)).append(" ")
		if($('#matchBtn').length==0 && !isFeatured) div.append($('<button>').text('Choose Match').click(goChooseMatch)).append(" ")
		if($('.robotBtn').length==0 && !isFeatured) div.append($('<button>').text('Change Robot').click(goChooseRobot)).append(" ")
	} else {
		if((featured=='next')==isFeatured) div.append($('<button>').text('Save').click(goNext)).append(" ")
		if((featured=='qr')==isFeatured) div.append($('<button>').text('QR Code').click(showQrCode)).append(" ")
	}
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

function toggleCollapse(_,c){
	c = c||$(this)
	var content=$(`#${c.attr('data-content')}`)
	content.toggle()
	c.attr('data-before',content.is(':visible')?'🞃':'🞂')
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

	storeInitialValues(scouting,"")
	storeInitialValues(pitScouting,"pit")
	storeInitialValues(subjectiveScouting,"subjective")

	$('.tab,.tab-button').click(showTab)
	$('.collapse').attr('data-before','🞂').click(toggleCollapse)

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

	$("img.count,button.count").click(countHandler).each(function(){
		findParentFromButton($(this)).click(countHandler)
	})

	$("img.robot-location").click(function(e){
		var x = Math.round(1000 * (e.pageX - this.offsetLeft) / this.width)/10,
		y = Math.round(1000 * (e.pageY - this.offsetTop) / this.height)/10,
		inp = $(this).parent().find('input'),
		name = inp.attr('name')
		$(`.${name}`).remove()
		$('body').append($('<img class=location-pointer src=/pointer.png style="position:absolute;width:3em">').css('top',e.pageY).css('left',e.pageX).addClass(name))
		inputChanged(inp.val(val), `${x}%x${y}%`)
	})
	$("#nextBtn,#pitScoutNext,#pitTeamButton,#subjectiveScoutNext,#subjectiveTeamButton").click(goNext)
	$("#matchBtn").click(goChooseMatch)
	$(".robotBtn").click(goChooseRobot)
	$(".fieldRotateBtn").click(rotateField)
	$("#teamBtn").click(goChangeTeam)
	$('.showInstructions').click(function(){
		showLightBox($(this).parent().find('.instructions'))
		return false
	})
	$("#uploadBtn").click(goUploadData)

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
