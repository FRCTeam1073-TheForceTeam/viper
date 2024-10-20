var season=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:season)\=))?(20[0-9]{2}(?:-[0-9]{2})?)(?:\&.*)?$/)||["",""])[1]
var comp = /-/.test(season)?"ftc":"frc"
var eventFilters

$(document).ready(function(){
	if (!season) season = "" + new Date().getFullYear()
	var seasonSelect = $('#season')
	for (var y=new Date().getFullYear(); y>=2019; y--){
		if (y >= 2024 && (y<=new Date().getFullYear() || new Date().geMonth()>=8)){
			var v = y+"-"+(y+1+"").slice(-2)
			seasonSelect.append($("<option>").attr('value',v).text(v + " FTC"))
		}
		seasonSelect.append($("<option>").attr('value',y).text(y + " FRC"))
	}
	seasonSelect.val(season)
	seasonSelect.change(function(){
		season=seasonSelect.val()
		comp = /-/.test(season)?"ftc":"frc"
		location.hash=season
		showSeason(season, comp)
	})
	showSeason(season, comp)
	$('#filter').change(function(){
		showEvents(eventFilters[$(this).val()])
	})
})

function showSeason(season, comp){
	$('#events').html("")
	eventFilters={
		all:[],
		upcoming:[]
	}
	$('a').each(function(){
		$(this).attr('href', $(this).attr('href').replace(/COMP|ftc|frc/g,comp).replace(/SEASON|YEAR|(20[0-9]{2}(-[0-9]{2})?)/g,season))
	})
	$.ajaxSetup({
		cache: false
	})
	$.getJSON(`/data/${season}.events.json`, function(json){
		var events = (json.Events||json.events).sort((a,b)=>a.dateStart.localeCompare(b.dateStart))
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
		location.href=`/admin/${comp}-api-season.cgi?season=${season}`
	})
}

function clickOnEvent(){
	var href = $(this).attr('href'),
	eventId = href.replace(/^.*[\?\&]event=([^\&]+).*$/, "$1").toLowerCase()
	Promise.all([
		fetch(`/data/${eventId}.teams.json`),
		fetch(`/data/${eventId}.schedule.csv`)
	]).then(responses=>{
		var [teams, schedule] = responses
		if (!teams.ok) return location.href=href
		$('#fetchLink').attr('href', href)
		$('#importLink').attr('href',schedule.ok?`/event-downloaded.html#event=${eventId}`:`/import-${comp}-api-event.html#event=${eventId}`)
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
		.append($('<h2>').append($(`<a href="/admin/${comp}-api-event.cgi?event=${season}${event.code}">`).click(clickOnEvent).text(event.name)))
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
