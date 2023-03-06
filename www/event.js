"use strict"

function hyphenate(s){
	return s.replace(/-/g,'\u2010')
}

$(document).ready(function(){
	if (!eventYear || !eventVenue){
		$('h1').text("Event Not Found")
		return
	}
	var title = $('title')
	var uploadCount = getUploads().length
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
	$('.initHid').hide()
	loadEventFiles(function(fileList){
		for (var i=0; i<fileList.length; i++){
			var extension = fileList[i].replace(/[^\.]+\./,"")
			switch (extension){
				case "event.csv":
					$('.dependInfo').show().parents().show()
					break;
				case "schedule.csv":
					$('.dependSchedule').show().parents().show()
					break;
				case "scouting.csv":
					$('.dependScouting').show().parents().show()
					break;
				case "alliances.csv":
					$('.dependAlliances').show().parents().show()
					break;
				case "pit.csv":
					$('.dependPit').show().parents().show()
					break;
			}
		}
		if (uploadCount) $('.dependUploads').show().parents().show()
	})
	function setName(){
		title.text(title.text().replace(/EVENT/, eventName))
		$('h1').text(eventName)
	}
	loadEventInfo(function(){
		setName()
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
			console.log("Could not parse " + d)
			console.log(x)
			return ""
		}
	}
	loadEventSchedule(eventData=>{
		if (!eventData.length) return $('body').html("Match not found")
		loadEventStats((eventStats,eventStatsByTeam)=>{
			var lastDone,
			lastFullyDone,
			ourNext
			for (var i=eventMatches.length-1; !lastFullyDone && i>=0; i--){
				var m = eventMatches[i]
				if (matchScoutingDataCount(m)==6) lastFullyDone = m
				if (!lastDone && matchScoutingDataCount(m)) lastDone = m
				if (!lastDone && matchHasTeam(m,window.ourTeam)) ourNext=m
				console.log(m)
				console.log(matchScoutingDataCount(m))
			}
			var seenOurNext = false,
			seenLastFullyDone = false
			eventData.forEach(match=>{
				if(ourNext && ourNext.Match==match.Match) seenOurNext=true
				if(lastFullyDone && lastFullyDone.Match==match.Match) seenLastFullyDone=true
				var row = $($('template#matchRow').html())
				BOT_POSITIONS.forEach(pos=>{
					var scouted=eventStatsByMatchTeam[`${match.Match}-${match[pos]}`]||0
					row.find(`.${pos}`).text(match[pos])
						.toggleClass("scouted",!!scouted)
						.toggleClass("needed",!scouted&&seenLastFullyDone&&!seenOurNext&&matchHasTeam(ourNext,match[pos]))
						.toggleClass("error",scouted>1)
						.toggleClass("ourTeam",""+match[pos]==""+window.ourTeam)
				})
				row.find('.match-id').text(hyphenate(getMatchName(match.Match))).attr('data-match-id',match.Match)
				row.click(showLinks)
				$('#matches').append(row)
			})
			$('#extendedScoutingData')
				.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStats)], {type: 'text/csv;charset=utf-8'})))
				.attr('download',`${eventId}.scouting.extended.csv`)
			$('#aggregatedScoutingData')
				.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStatsByTeam)], {type: 'text/csv;charset=utf-8'})))
				.attr('download',`${eventId}.scouting.aggregated.csv`)
		})
	})

	function escapeExcelCsvField(s){
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

	$('#extendedScoutingDataView').click(function(){
		showLightBox(toTable(eventStats))
		return false
	})
	$('#aggregatedScoutingDataView').click(function(){
		showLightBox(toTable(eventStatsByTeam))
		return false
	})
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
		team=el.text()
		pos=el.attr('class').match(/\b[RB][1-3]\b/)[0]
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
