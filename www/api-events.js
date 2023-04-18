var year=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:year)\=))?(20[0-9]{2})(?:\&.*)?$/)||["",""])[1]
var eventFilters={
	all:[],
	upcoming:[]
}

$(document).ready(function(){
	if (!year){
		$('h1').text("No year specified")
		return
	}
	$('h1').text(`${year} FRC Events`)
	$('a').each(function(){
		href=$(this).attr('href')
		if (/YEAR/.test(href)) $(this).attr('href', href.replace(/YEAR/g,year))
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
		}
		showEvents(toShow)
	}).fail(function(){
		location.href=`/admin/frc-api-season.cgi?year=${year}`
	})
	$('#filter').change(function(){
		showEvents(eventFilters[$(this).val()])
	})
})

function showEvents(events){
	var div = $('#events').html("")
	events.forEach(function(event){
		$(div)
		.append($('<h2>').append($(`<a href="/admin/frc-api-event.cgi?event=${year}${event.code}">`).text(event.name)))
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
