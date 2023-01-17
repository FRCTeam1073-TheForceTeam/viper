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
		title.text(eventName + " " + title.text())
		$('h1').text(eventName)
	}
	setName()
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
			return new Intl.DateTimeFormat('en-US', {dateStyle: 'full'}).format(Date.parse(d))
		} catch (x){
			console.log("Could not parse " + d)
			return ""
		}
	}
	loadEventSchedule(function(data){
		if (!data.length) return $('body').html("Match not found")
		for (var i=0; i<data.length; i++){
			var row = $($('template#matchRow').html())
			row.find('.R1').text(data[i]['R1'])
			row.find('.R2').text(data[i]['R2'])
			row.find('.R3').text(data[i]['R3'])
			row.find('.B1').text(data[i]['B1'])
			row.find('.B2').text(data[i]['B2'])
			row.find('.B3').text(data[i]['B3'])
			row.find('.match-id').text(hyphenate(getMatchName(data[i]['Match']))).attr('data-match-id',data[i]['Match'])
			row.click(showLinks)
			$('#matches').append(row)
		}
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
		toTableRow(table,Object.keys(statInfo).map(s=>s.replace(/_/g,"_\u00AD")),"th")
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
			tr.append($(`<${cell}>`).text(field))		
		})
		table.append(tr)
	}
	
	loadEventStats(function(eventStats, eventStatsByTeam){
		$('#extendedScoutingData')
			.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStats)], {type: 'text/csv;charset=utf-8'})))
			.attr('download',`${eventId}.scouting.extended.csv`)
		$('#aggregatedScoutingData')
			.attr('href', window.URL.createObjectURL(new Blob([excelCsv(eventStatsByTeam)], {type: 'text/csv;charset=utf-8'})))
			.attr('download',`${eventId}.scouting.aggregated.csv`)
	})
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

