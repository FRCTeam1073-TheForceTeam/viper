var year=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:year)\=))?(20[0-9]{2})(?:\&.*)?$/)||["",""])[1]

$(document).ready(function(){
	if (!year){
		$('h1').text("No year specified")
		return
	}
	$.getJSON(`/data/${year}.events.json`, function(json){
		$('h1').text(`${year} FRC Events`)
		$('body').append("<p>Click on an event to download the official data for it.</p>")
		var events = json.Events.sort((a,b)=>a.dateStart.localeCompare(b.dateStart))
		events.forEach(function(event){
			$('body')
			.append($('<h2>').append($(`<a href="/admin/frc-api-event.cgi?event=${year}${event.code}">`).text(event.name)))
			.append($('<span>').text(toDisplayDate(event.dateStart))).append("<br>")
			.append($('<span>').text(event.venue)).append("<br>")
			.append($('<span>').text(event.address)).append("<br>")
			.append($('<span>').text(`${event.city}, ${event.stateprov}, ${event.country}`))
		})
	}).fail(function(){
		location.href=`/admin/frc-api-season.cgi?year=${year}`
	})
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
