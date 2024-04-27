var year=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:year)\=))?(20[0-9]{2})(?:\&.*)?$/)||["",""])[1]
var eventFilters

$(document).ready(function(){
	if (!year) year = "" + new Date().getFullYear()
	var yearSelect = $('#year')
	for (var y = new Date().getFullYear(); y>=2019; y--){
		yearSelect.append($('<option>').attr('value',y).text(y))
	}
	yearSelect.val(year)
	yearSelect.change(function(){
		year=yearSelect.val()
		location.hash=year
		showYear(year)
	})
	showYear(year)
	$('#filter').change(function(){
		showEvents(eventFilters[$(this).val()])
	})
})

function showYear(year){
	$('#events').html("")
	eventFilters={
		all:[],
		upcoming:[]
	}
	$('a').each(function(){
		$(this).attr('href', $(this).attr('href').replace(/YEAR|(20[0-9]{2})/g,year))
	})
	$('h1').text(`${year} FRC Events`)
	$.ajaxSetup({
		cache: false
	})
	$.getJSON(`/data/${year}.events.json`, function(json){
		var events = json.Events.sort((a,b)=>a.dateStart.localeCompare(b.dateStart))
		events.forEach(function(event){
			eventFilters.all.push(event)
			if (new Date().toISOString()<event.dateEnd) eventFilters.upcoming.push(event)
		})
		var toShow = eventFilters.all
		if (eventFilters.upcoming.length){
			toShow=eventFilters.upcoming
			$('#filter').val('upcoming')
		} else {
			$('#filter').val('all')
		}
		showEvents(toShow)
	}).fail(function(){
		location.href=`/admin/frc-api-season.cgi?year=${year}`
	})
}

function clickOnEvent(){
	var href = $(this).attr('href'),
	eventId = href.replace(/^.*[\?\&]event=([^\&]+).*$/, "$1").toLowerCase()
	console.log(eventId)
	Promise.all([
		fetch(`/data/${eventId}.teams.json`),
		fetch(`/data/${eventId}.schedule.csv`)
	]).then(responses=>{
		var [teams, schedule] = responses
		if (!teams.ok) return location.href=href
		$('#fetchLink').attr('href', href)
		$('#importLink').attr('href',schedule.ok?`/frc-event-downloaded.html#event=${eventId}`:`/import-frc-api-event.html#event=${eventId}`)
		showLightBox($('#importOptions'))
	}).catch(()=>{
		location.href=href
	})
	return false
}

function showEvents(events){
	var div = $('#events').html("")
	events.forEach(function(event){
		$(div)
		.append($('<h2>').append($(`<a href="/admin/frc-api-event.cgi?event=${year}${event.code}">`).click(clickOnEvent).text(event.name)))
		.append($('<span>').text(toDisplayDate(event.dateStart))).append("<br>")
		.append($('<span>').text(event.venue)).append("<br>")
		.append($('<span>').text(event.address)).append("<br>")
		.append($('<span>').text(`${event.city}, ${event.stateprov}, ${event.country}`))
	})
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
