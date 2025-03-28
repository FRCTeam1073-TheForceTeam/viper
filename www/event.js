"use strict"

$(document).ready(function(){
	if (!eventYear || !eventVenue) return showError('Event Not Specified')
	if ("ftc"==eventCompetition) $('.noftc').hide()
	var title = $('title')
	var uploadCount = getUploads().length
	$('.initHid').hide()
	var extensionMap = {
		"event.csv": ['dependInfo','Event Info CSV'],
		"schedule.csv": ['dependSchedule','Sched&shy;ule CSV'],
		"scouting.csv": ['dependScouting','Scout&shy;ing CSV'],
		"alliances.csv": ['dependAlliances','All&shy;ianc&shy;es CSV'],
		"pit.csv": ['dependPit','Pit Scout&shy;ing CSV'],
		"subjective.csv": ['dependSubjective','Sub&shy;ject&shy;ive Scout&shy;ing CSV'],
		"info.json": ['','API Event Info JSON'],
		"teams.json": ['','API Team List JSON'],
		"schedule.practice.json": ['','API Prac&shy;tice Sched&shy;ule JSON'],
		"schedule.qualification.json": ['','API Qual&shy;if&shy;ic&shy;a&shy;tion Sched&shy;ule JSON'],
		"schedule.playoff.json": ['','API Play&shy;off Schedule JSON'],
		"scores.qualification.json": ['dependScores','API Qual&shy;if&shy;ic&shy;a&shy;tion Scores JSON'],
		"scores.playoff.json": ['dependScores','API Play&shy;off Scores JSON'],
	}
	function showDataActions(){
		var url = $(this).attr('href'),
		da = $('#dataActions'),
		file = url.replace(/.*\//,""),
		list = da.find('ul').html(""),
		download = $('<a>').attr('href',url).text('Download')
		da.find('h2').text($(this).attr('download')?$(this).attr('download'):file)
		if ($(this).attr('download')) download.attr('download', $(this).attr('download'))
		list.append($('<li>').append(download))
		if (/\.csv/.test(file)){
			list.append($('<li>').append($('<a>').attr('href',`/edit.html#file=${file}`).text('Edit')))
			list.append($('<li>').append($('<a>').attr('href',`/revisions.html#file=${file}`).text('History')))
		}
		if (/\.json/.test(file)){
			list.append($('<li>').append($('<a>').attr('href',url).text('View').click(viewJson)))
		}
		if (/^blob/.test(url)){
			list.append($('<li>').append($('<a>').attr('href',url).attr('data-source',$(this).attr('data-source')).text('View').click(viewDataAsTable)))
		}
		showLightBox(da)
		return false
	}
	$('.show-more').click(function(){
		$('.more').show()
		$(this).hide()

	})
	function setName(){
		title.text(title.text().replace(/EVENT/, eventName))
		$('h1').text(eventName)
	}
	function toDisplayDate(d){
		if (!d) return ""
		try {
			var b = d.split(/\D/)
			var date = new Date(b[0], b[1]-1, b[2])
			return new Intl.DateTimeFormat('en-US', {dateStyle: 'full'}).format(date)
		} catch (x){
			console.error("Could not parse",d,x)
			return ""
		}
	}

	$('a').each(function(){
		$(this).attr(
			'href',$(this).attr('href')
			.replace('YEAR', eventYear)
			.replace('EVENT', eventId)
			.replace('UPLOAD_COUNT', uploadCount)
		)
		$(this).text(
			$(this).text()
			.replace('YEAR', eventYear)
			.replace('EVENT', eventId)
			.replace('UPLOAD_COUNT', uploadCount)
		)
	})
	if (uploadCount) dependencySatisfied('dependUploads')

	function dependencySatisfied(depend){
		$(`.${depend}`).each(function(){
			$(this).removeClass(depend)
			var dependCount = 0
			$(this).attr('class').split(/ /).forEach(c=> {
				if (/^depend/.test(c)) dependCount++
			})
			if (dependCount == 0){
				$(this).show().removeClass('initHid').parents('.initHid').show().removeClass('initHid')
			}
		})
	}

	function matchScoutingDataCount(eventStatsByMatchTeam, m){
		if (!m) return false
		return BOT_POSITIONS.reduce((sum,pos)=>sum+(eventStatsByMatchTeam[`${m.Match}-${m[pos]}`]?1:0),0)
	}
	Promise.all([
		promiseEventMatches(),
		promiseEventStats(),
		promiseEventScores(),
		promiseEventFiles(),
		promiseEventInfo(),
		promiseSubjectiveScouting(),
		promisePitScouting(),
		promiseTeamsInfo(),
		fetch(`/season-files.cgi?season=${eventYear}`).then(response=>response.text()),
	]).then(values =>{
		var [eventMatches, [eventStats, eventStatsByTeam, eventStatsByMatchTeam], eventScores, fileList, eventInfo, subjectiveData, pitData, eventTeamsInfo, seasonFiles] = values,
		lastDone,
		nextToScout,
		lastMatch,
		lastFullyDone,
		ourNext,
		haveScouting=false
		if (!fileList.length) return showError('Event Not Found')
		if (window.importFunctions&&Object.keys(window.importFunctions).length) dependencySatisfied('dependImport')
		fileList.forEach(file=>{
			var extension = file.replace(/[^\.]+\./,"").replace(/\.[0-9]+\./,"."),
			title = extension,
			fileNum = (file.match(/\.([0-9])+\./)||['',''])[1]
			if (extensionMap[extension]){
				var depend = extensionMap[extension][0]
				title = extensionMap[extension][1]
				if (depend) dependencySatisfied(depend)
			}
			if(extension=='scouting.csv')haveScouting=true
			title+=fileNum?(" "+fileNum):""
			if (extension!="jpg") $('#dataList').append($('<li>').append($('<a>').attr('href',file).click(showDataActions).html(title))).parents('.initHid').show()
		})
		if(!haveScouting)$('#scout-link').after($('#photo-scout-link,#pit-scout-link'))
		seasonFiles.split(/[\r\n]+/).forEach(file=>{
			if (/\/subjective-scout\.html$/.test(file)) dependencySatisfied('dependSubjective')
			if (/\/pit-scout\.html$/.test(file)) dependencySatisfied('dependPit')
			if (/\/field-whiteboard\.png$/.test(file))dependencySatisfied('dependWhiteboard')
		})

		setName()
		if (eventInfo['blue_alliance_id']) blueAllianceId = eventInfo['blue_alliance_id']
		if (eventInfo['orange_alliance_id']) orangeAllianceId = eventInfo['orange_alliance_id']
		if (eventInfo['first_inspires_id']) firstInspiresId = eventInfo['first_inspires_id']
		if ("frc"==eventCompetition && /^20[0-9]{2}[a-z0-9]+/.test(blueAllianceId)) dependencySatisfied('dependBlueAlliance')
		if ("ftc"==eventCompetition && /^[0-9]{4}[A-Za-z0-9\-]+/.test(orangeAllianceId)) dependencySatisfied('dependOrangeAlliance')
		if ("frc"==eventCompetition && /^20[0-9]{2}\/?[A-Za-z0-9]+/.test(firstInspiresId)) dependencySatisfied('dependFirstFrc')
		if ("ftc"==eventCompetition && /^20[0-9]{2}\/?[A-Za-z0-9]+/.test(firstInspiresId)) dependencySatisfied('dependFirstFtc')
		$('a').each(function(){
			$(this).attr(
				'href',$(this).attr('href')
				.replace('FIID', firstInspiresId)
				.replace('BAID', blueAllianceId)
				.replace('OAID', orangeAllianceId)
			)
		})
		var info = $('#eventInfo').html('')
		if (eventInfo.location) info.append($('<div>').text(eventInfo.location))
		if (eventInfo.start || eventInfo.end){
			var start = eventInfo.start || eventInfo.end,
			end = eventInfo.end || eventInfo.start
			if (start != end){
				start = toDisplayDate(start)
				end = toDisplayDate(end)
				info.append($('<div>').text(`${start} to ${end}`))
			} else {
				start = toDisplayDate(start)
				info.append($('<div>').text(`${start}`))
			}
		}

		for (var i=eventMatches.length-1; !lastFullyDone && i>=0; i--){
			var m=eventMatches[i]
			if(matchScoutingDataCount(eventStatsByMatchTeam,m)==6)lastFullyDone=m
			if(!lastDone&&matchScoutingDataCount(eventStatsByMatchTeam,m))lastDone=m
			if(!lastDone&&matchHasTeam(m,getLocalTeam()))ourNext=m
			if(!lastDone&&!matchScoutingDataCount(eventStatsByMatchTeam,m))nextToScout=m
			if(!lastMatch)lastMatch=m
		}
		if((!nextToScout||!/^(pm|qm)/.test(nextToScout.Match))&&lastMatch&&!/^f/.test(lastMatch.Match)){
			$('#edit-event-section').prepend($('#edit-event-header'))
			$('#edit-event-section>ul').append($('#edit-playoffs-link'))
		}
		if(lastMatch&&/^pm/.test(lastMatch.Match)){
			$('#edit-event-section').prepend($('#edit-event-header'))
			$('#edit-event-section>ul').append($('#edit-match-link,#fetch-api-link'))
		}
		function getTeamInfo(teamNum){
			var info=eventTeamsInfo[teamNum]
			if (!info)return""
			var name=info.nameShort||""
			if (info.city)name+=`, ${info.city}`
			if (info.stateProv)name+=`, ${info.stateProv}`
			if (info.country)name+=`, ${info.country}`
			return name
		}
		var seenOurNext = false,
		seenLastFullyDone = false
		eventMatches.forEach(match=>{
			if(ourNext && ourNext.Match==match.Match) seenOurNext=true
			if(lastFullyDone && lastFullyDone.Match==match.Match) seenLastFullyDone=true
			var row = $($('template#matchRow').html()),
			redPrediction = 0, bluePrediction=0,
			redScouting = 0, blueScouting=0,
			isRedScouted = true, isBlueScouted = true
			if ("ftc"==eventCompetition) row.find('.noftc').hide()
			BOT_POSITIONS.forEach(pos=>{
				var scouted=eventStatsByMatchTeam[`${match.Match}-${match[pos]}`]||0,
				isScouted=((typeof scouted.score)!=='undefined')
				if(/^R/.test(pos)){
					if (!isScouted){
						isRedScouted=false
					} else {
						redScouting += scouted.score
					}
					redPrediction += getScore(eventStatsByTeam, match[pos])
				} else {
					if (!isScouted){
						isBlueScouted=false
					} else {
						blueScouting += scouted.score
					}
					bluePrediction += getScore(eventStatsByTeam, match[pos])
				}
				row.find(`.${pos}`).text(match[pos])
					.toggleClass("scouted",isScouted)
					.toggleClass("needed",(!isScouted)&&seenLastFullyDone&&!seenOurNext&&matchHasTeam(ourNext,match[pos]))
					.toggleClass("error",!!scouted&&!!scouted.old&&(typeof scouted.old.score)!=='undefined')
					.toggleClass("ourTeam",""+match[pos]==""+getLocalTeam())
					.attr('data-tooltip',getTeamInfo(match[pos])||null)
			})
			redPrediction=Math.round(redPrediction)
			bluePrediction=Math.round(bluePrediction)
			var hasScores = !!eventScores[match.Match],
			redScore=0, blueScore=0
			if (hasScores){
				eventScores[match.Match].alliances.forEach(function(alliance){
					if (alliance.alliance == "Blue"){
						blueScore = alliance.totalPoints
					} else {
						redScore = alliance.totalPoints
					}
				})
			}
			var redPoints=hasScores?redScore:(isRedScouted?redScouting:redPrediction),
			bluePoints=hasScores?blueScore:(isBlueScouted?blueScouting:bluePrediction),
			redTooltip=(hasScores?`Score: ${redScore}\n`:"")+(isRedScouted?`Scouted: ${redScouting}\n`:"")+`Prediction: ${redPrediction}`,
			blueTooltip=(hasScores?`Score: ${blueScore}\n`:"")+(isBlueScouted?`Scouted: ${blueScouting}\n`:"")+`Prediction: ${bluePrediction}`
			row.find('.redScore').addClass(hasScores?'score':(isRedScouted?'scouted':'prediction')).toggleClass('winner',redPoints>bluePoints).text(redPoints).attr('data-tooltip',redTooltip).attr('data-score',hasScores?redScore:"").attr('data-scouted',isRedScouted?redScouting:"").attr('data-prediction',redPrediction)
			row.find('.blueScore').addClass(hasScores?'score':(isBlueScouted?'scouted':'prediction')).toggleClass('winner',redPoints<bluePoints).text(bluePoints).attr('data-tooltip',blueTooltip).attr('data-score',hasScores?blueScore:"").attr('data-scouted',isBlueScouted?blueScouting:"").attr('data-prediction',bluePrediction)
			row.find('.match-id').text(getShortMatchName(match.Match)).attr('data-match-id',match.Match)
			row.click(showLinks)
			$('#matches').append(row)
			$('#main').show()
		})
		window.eventStats = eventStats
		$('#extendedScoutingData')
			.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStats)], {type: 'text/csv;charset=utf-8'})))
			.attr('download',`${eventId}.scouting.extended.csv`)
			.attr('data-source','eventStats')
			.click(showDataActions)
		window.eventStatsByTeam = eventStatsByTeam
		$('#aggregatedScoutingData')
			.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStatsByTeam)], {type: 'text/csv;charset=utf-8'})))
			.attr('download',`${eventId}.scouting.aggregated.csv`)
			.attr('data-source','eventStatsByTeam')
			.click(showDataActions)
		if (!window.analyticsOptOut){
			fetch('https://stats.viperscout.com/collect',{
				method:'POST',
				headers:{'Content-Type': 'application/x-www-form-urlencoded'},
				body: new URLSearchParams({
					pitscouted:Object.keys(pitData).length,
					subjectivescouted:Object.keys(subjectiveData).length,
					scouters:new Set([...eventStats, ...Object.values(subjectiveData), ...Object.values(pitData)].map(x=>(((x.scouter||"")+"").toLowerCase().trim().replace(/\s+/,' '))).filter(x=>x!="")).size,
					scouted:eventStats.length,
					team:window.ourTeam||"",
					viewerteam:localStorage.getItem('my-team')||"",
					host:location.hostname,
					event:eventId
				})
			}).then(response => {
				return response.text()
			}).then(body => {
				body=body.trim()
				if (body!='OK') console.error("Error sending stats: " + body)
			})
		}
	})

	function getScore(eventStatsByTeam, team){
		var stats = eventStatsByTeam[team]
		if (!stats) return 0
		return (stats.score||0)/(stats.count||1)
	}

	function escapeExcelCsvField(s){
		if (Array.isArray(s)) s = s.join(" ")
		if (/[\",\r\n\t]/.test(s)){
			s = '"'+s.replace(/"/g,"")+'"'
		}
		return s
	}

	function excelCsv(dat){
		var csv=Object.keys(statInfo).map(escapeExcelCsvField).join(",")+"\n"
		csv+=Object.keys(statInfo).map(name=>statInfo[name].name).map(escapeExcelCsvField).join(",")+"\n"
		if (!dat.forEach) dat = Object.keys(dat).map(team=>dat[team])
		dat.forEach(row=>{
			csv+=Object.keys(statInfo).map(name=>row[name]!=null?row[name]:"").map(escapeExcelCsvField).join(",")+"\n"
		})
		return csv
	}
	function viewDataAsTable(){
		showLightBox(toTable(window[$(this).attr('data-source')]))
		return false
	}
	function toTable(dat){
		var table = $('<table border=1>')
		toTableRow(table,Object.keys(statInfo),"th")
		toTableRow(table,Object.keys(statInfo).map(name=>statInfo[name].name),"th")
		if (!dat.forEach) dat = Object.keys(dat).map(team=>dat[team])
		dat.forEach(row=>{
			toTableRow(table,Object.keys(statInfo).map(name=>row[name]!=null?row[name]:""),"td")
		})
		var div = $('<div class=lightBoxFullContent style=overflow:auto>').append(table)
		$('body').append(div)
		return div
	}
	function toTableRow(table,dat,cell){
		var tr = $('<tr>')
		dat.forEach(field=>{
			var el = $(`<${cell}>`).text(field)
			el.html(el.html().replace(/_/g,'_<wbr>'))
			tr.append(el)
		})
		table.append(tr)
	}
	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
	})
	var pitScoutSetupButtonCount=6
	function drawPitScoutSetupButtons(){
		$('#pitScoutSetupButtons').html("")
		for (var i=1; i<=pitScoutSetupButtonCount; i++){
			$('#pitScoutSetupButtons').append($(`<button>${i}</button>`).click(openPitBotScout))
		}
	}
	drawPitScoutSetupButtons()
	$('#pitScoutSetup img').click(function(){
		pitScoutSetupButtonCount+=/up/.test($(this).attr('src'))?1:-1
		if (pitScoutSetupButtonCount < 1) pitScoutSetupButtonCount = 1
		if (pitScoutSetupButtonCount > 10) pitScoutSetupButtonCount = 10
		drawPitScoutSetupButtons()
	})
	function openPitBotScout(){
		promiseEventTeams().then(eventTeams => {
			var squad = parseInt($(this).text())-1
			var perSquad = Math.floor(eventTeams.length/(pitScoutSetupButtonCount)),
			extras = eventTeams.length%(pitScoutSetupButtonCount),
			start = squad*perSquad+Math.min(squad,extras),
			end = start+perSquad+((squad+1>extras)?0:1),
			teamList=eventTeams.slice(start,end).join(",")
			window.open(`/bot-photos.html#event=${eventId}&teams=${teamList}`)
			location.href=(`/${eventYear}/pit-scout.html#event=${eventId}&teams=${teamList}`)
		})
	}
})

var blueAllianceId = eventId
var orangeAllianceId = eventId.replace(/^20([0-9]){2}-([0-9]){2}-(.*)/,"$1$2$3/")
var firstInspiresId = eventId.replace(/^(20[0-9]{2})/,"$1/")

function viewJson(){
	var jv = $('#jsonViewer').html(""),
	lb = $('#jsonLightBox')
	var href=$(this).attr('href')
	lb.find('h2').text(href.replace(/.*\//,""))
	$.getJSON(href, function(json){
		jv.jsonViewer(json, {
			collapsed:false,
			rootCollapsable:false,
			withQuotes:false,
			withLinks:false
		})
	})
	showLightBox(lb)
	return false
}
function showLinks(e){
	var el = $(e.target),
	team,teamName="",pos,
	row=el.closest('tr'),
	match=row.find('.match-id'),
	matchId=match.attr('data-match-id'),
	matchName=match.text(),
	positions="",
	redScore=row.find('.redScore'),
	blueScore=row.find('.blueScore')
	BOT_POSITIONS.forEach(function(pos){
		var t = row.find(`.${pos}`).text()
		if (positions) positions+="&"
		positions += `${pos}=${t}`
	})
	if (/^[0-9]+$/.test(el.text())){
		if (el.attr('class') && /\b[RB][1-3]\b/.test(el.attr('class'))){
			pos=el.attr('class').match(/\b[RB][1-3]\b/)[0]
			team=el.text()
			teamName=el.attr('data-tooltip')
		}
	}
	var html = $('#matchActionsTemplate').html()
		.replace(/TEAM_ID/g, team)
		.replace(/POS/g, pos)
		.replace(/MATCH_ID/g, matchId)
		.replace(/BOTS/g, positions)
		.replace(/MATCH_NAME/g, matchName)
		.replace(/TEAM_NAME/g, teamName)
		.replace(/RED_SCORE/g, redScore.attr('data-score'))
		.replace(/BLUE_SCORE/g, blueScore.attr('data-score'))
		.replace(/RED_SCOUTED/g, redScore.attr('data-scouted'))
		.replace(/BLUE_SCOUTED/g, blueScore.attr('data-scouted'))
		.replace(/RED_PREDICTION/g, redScore.attr('data-prediction'))
		.replace(/BLUE_PREDICTION/g, blueScore.attr('data-prediction')),
	ma = $('#matchActions')
	ma.html(html).find('.dependTeam').toggle(!!team)
	showLightBox(ma)
}
