"use strict"

$(document).ready(function(){
	if (!eventYear || !eventVenue){
		$('h1').text("Event Not Found")
		return
	}
	var title = $('title')
	var uploadCount = getUploads().length
	$('.initHid').hide()
	var extensionMap = {
		"event.csv": ['.dependInfo','Event Info CSV'],
		"schedule.csv": ['.dependSchedule','Sched&shy;ule CSV'],
		"scouting.csv": ['.dependScouting','Scout&shy;ing CSV'],
		"alliances.csv": ['.dependAlliances','All&shy;ianc&shy;es CSV'],
		"pit.csv": ['.dependPit','Pit Scout&shy;ing CSV'],
		"info.json": ['','API Event Info JSON'],
		"teams.json": ['','API Team List JSON'],
		"schedule.qualification.json": ['','API Qual&shy;if&shy;ic&shy;a&shy;tion Sched&shy;ule JSON'],
		"schedule.playoff.json": ['','API Play&shy;off Schedule JSON'],
		"scores.qualification.json": ['.dependScores','API Qual&shy;if&shy;ic&shy;a&shy;tion Scores JSON'],
		"scores.playoff.json": ['.dependScores','API Play&shy;off Scores JSON'],
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
	loadEventFiles(function(fileList){
		fileList.sort((a,b)=>{
			var aType = a.replace(/.*\./,"")
			var bType = b.replace(/.*\./,"")
			if(aType != bType) return aType.localeCompare(bType)
			return a.localeCompare(b)
		})
		fileList.forEach(file=>{
			var extension = file.replace(/[^\.]+\./,"").replace(/\.[0-9]+\./,"."),
			title = extension,
			fileNum = (file.match(/\.([0-9])+\./)||['',''])[1]
			if (extensionMap[extension]){
				var depend = extensionMap[extension][0]
				title = extensionMap[extension][1]
				if (depend) $(depend).show().parents('.initHid').show()
			}
			title+=fileNum?(" "+fileNum):""
			if (extension!="jpg") $('#dataList').append($('<li>').append($('<a>').attr('href',file).click(showDataActions).html(title))).parents('.initHid').show()
		})
		if (uploadCount) $('.dependUploads').show().parents('.initHid').show()
	})
	function setName(){
		title.text(title.text().replace(/EVENT/, eventName))
		$('h1').text(eventName)
	}
	loadEventInfo(function(){
		setName()
		if (eventInfo['blue_alliance_id']) blueAllianceId = eventInfo['blue_alliance_id']
		if (eventInfo['first_inspires_id']) firstInspiresId = eventInfo['first_inspires_id']
		if (!/^20[0-9]{2}[a-z0-9]+/.test(blueAllianceId)) $('#blueAllianceLinks').hide()
		if (!/^20[0-9]{2}\/[A-Za-z0-9]+/.test(firstInspiresId)) $('#firstInspiresLinks').hide()
		$('a').each(function(){
			$(this).attr(
				'href',$(this).attr('href')
				.replace('YEAR', eventYear)
				.replace('EVENT', eventId)
				.replace('FIID', firstInspiresId)
				.replace('BAID', blueAllianceId)
				.replace('UPLOAD_COUNT', uploadCount)
			)
			$(this).text(
				$(this).text()
				.replace('YEAR', eventYear)
				.replace('EVENT', eventId)
				.replace('UPLOAD_COUNT', uploadCount)
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
	})
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
	loadEventSchedule(eventData=>{
		if (!eventData.length) return $('body').html("Match not found")
		loadEventStats((eventStats,eventStatsByTeam)=>{
			loadEventScores(eventScores=>{
				var lastDone,
				lastFullyDone,
				ourNext
				for (var i=eventMatches.length-1; !lastFullyDone && i>=0; i--){
					var m = eventMatches[i]
					if (matchScoutingDataCount(m)==6) lastFullyDone = m
					if (!lastDone && matchScoutingDataCount(m)) lastDone = m
					if (!lastDone && matchHasTeam(m,getLocalTeam())) ourNext=m
				}
				var seenOurNext = false,
				seenLastFullyDone = false
				eventData.forEach(match=>{
					if(ourNext && ourNext.Match==match.Match) seenOurNext=true
					if(lastFullyDone && lastFullyDone.Match==match.Match) seenLastFullyDone=true
					var row = $($('template#matchRow').html()),
					redPrediction = 0, bluePrediction=0
					BOT_POSITIONS.forEach(pos=>{
						if(/^R/.test(pos)){
							redPrediction += getScore(match[pos])
						} else {
							bluePrediction += getScore(match[pos])
						}
						var scouted=eventStatsByMatchTeam[`${match.Match}-${match[pos]}`]||0
						row.find(`.${pos}`).text(match[pos])
							.toggleClass("scouted",!!scouted)
							.toggleClass("needed",!scouted&&seenLastFullyDone&&!seenOurNext&&matchHasTeam(ourNext,match[pos]))
							.toggleClass("error",!!scouted.old)
							.toggleClass("ourTeam",""+match[pos]==""+getLocalTeam())
					})
					redPrediction=Math.round(redPrediction)
					bluePrediction=Math.round(bluePrediction)
					if (eventScores[match.Match]){
						var redScore,blueScore
						eventScores[match.Match].alliances.forEach(function(alliance){
							if (alliance.alliance == "Blue"){
								blueScore = alliance.totalPoints
							} else {
								redScore = alliance.totalPoints
							}
						})
						row.find('.redScore').addClass('score').toggleClass('winner',redScore>blueScore).text(redScore).attr('title',"Prediction: " + redPrediction)
						row.find('.blueScore').addClass('score').toggleClass('winner',redScore<blueScore).text(blueScore).attr('title',"Prediction: " + bluePrediction)
					} else {
						row.find('.redScore').addClass('prediction').toggleClass('winner',redPrediction>bluePrediction).text(redPrediction)
						row.find('.blueScore').addClass('prediction').toggleClass('winner',redPrediction<bluePrediction).text(bluePrediction)
					}
					row.find('.match-id').text(getShortMatchName(match.Match)).attr('data-match-id',match.Match)
					row.click(showLinks)
					$('#matches').append(row)
				})
				$('#extendedScoutingData')
					.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStats)], {type: 'text/csv;charset=utf-8'})))
					.attr('download',`${eventId}.scouting.extended.csv`)
					.attr('data-source','eventStats')
					.click(showDataActions)
				$('#aggregatedScoutingData')
					.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStatsByTeam)], {type: 'text/csv;charset=utf-8'})))
					.attr('download',`${eventId}.scouting.aggregated.csv`)
					.attr('data-source','eventStatsByTeam')
					.click(showDataActions)
			})
		})
	})

	function getScore(team){
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
		var squad = parseInt($(this).text())-1
		var perSquad = Math.floor(eventTeams.length/(pitScoutSetupButtonCount)),
		extras = eventTeams.length%(pitScoutSetupButtonCount),
		start = squad*perSquad+Math.min(squad,extras),
		end = start+perSquad+((squad+1>extras)?0:1),
		teamList=eventTeams.slice(start,end).join(",")
		window.open(`/bot-photos.html#event=${eventId}&teams=${teamList}`)
		location.href=(`/${eventYear}/pit-scout.html#event=${eventId}&teams=${teamList}`)
	}
})

var blueAllianceId = eventId
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
	team,pos,
	row=el.closest('tr'),
	match=row.find('.match-id'),
	matchId=match.attr('data-match-id'),
	matchName=match.text(),
	r1=row.find('.R1').text(),
	r2=row.find('.R2').text(),
	r3=row.find('.R3').text(),
	b1=row.find('.B1').text(),
	b2=row.find('.B2').text(),
	b3=row.find('.B3').text()
	if (/^[0-9]+$/.test(el.text())){
		if (el.attr('class') && /\b[RB][1-3]\b/.test(el.attr('class'))){
			pos=el.attr('class').match(/\b[RB][1-3]\b/)[0]
			team=el.text()
		}
	}
	var html = $('#matchActionsTemplate').html()
		.replace(/\$TEAM/g, team)
		.replace(/\$POS/g, pos)
		.replace(/\$MATCH_ID/g, matchId)
		.replace(/\$MATCH_NAME/g, matchName)
		.replace(/\$R1/g, r1)
		.replace(/\$R2/g, r2)
		.replace(/\$R3/g, r3)
		.replace(/\$B1/g, b1)
		.replace(/\$B2/g, b2)
		.replace(/\$B3/g, b3)
		.replace(/\$EVENT/g, eventId)
		.replace(/\$YEAR/g, eventYear),
	ma = $('#matchActions')
	ma.html(html).find('.dependTeam').toggle(!!team)
	showLightBox(ma)
}
