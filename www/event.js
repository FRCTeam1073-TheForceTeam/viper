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
})
