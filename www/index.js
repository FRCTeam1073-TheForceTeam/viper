"use strict"

$(document).ready(function(){
	var seasonStatsLinkHtml,
	events = []
	$.ajax({
		url:"/event-list.cgi",
		dataType:"text",
		success:function(data){
			events = data.split(/[\r\n]/)
			var seasons = {}
			for (var i=0; i<events.length; i++){
				var m = events[i].match(/^[0-9]{4}(-[0-9]{2})?/)
				if(m) seasons[m[0]] = 1
			}
			seasons = Object.keys(seasons)
			seasons.sort((a,b) => {return b.localeCompare(a)})
			for (var i=0; i<seasons.length; i++){
				var season = seasons[i],
				comp = /-/.test(season)?"FTC":"FRC"
				$('#seasons').append($(`<option value=${season}>${season} ${comp}</option>`))
			}
			$('#seasons').toggle(seasons.length > 1)
			events = events.sort(dateCompare)
			showEvents()
		}
	})
	function showEvents(){
		var list = $('#events-list')
		list.html('');
		var filter = location.hash.replace(/^\#/,""),
		eventsShown = 0
		if (!filter) filter = $('#years option:last').attr('value')
		for (var i=0; i<events.length; i++){
			var season = ((events[i].match(/^[0-9]{4}(-[0-9]{2})?/))||[""])[0]
			if (season == filter){
				var [id, name] = events[i].split(/,/)
				if (!name) name = id
				list.append($(`<li><a href=/event.html#${id}>${name}</a></li>`))
				eventsShown++
			}
		}
		if (!seasonStatsLinkHtml) seasonStatsLinkHtml = $('#seasonStatsLink').html()
		$('#seasonStatsLink').html(seasonStatsLinkHtml.replace(/YEAR/g,filter)).toggle(/20[0-9]{2}/.test(filter) && eventsShown > 1)
		window.scrollTo(0,0)
	}
	$(window).on('hashchange', showEvents)
	$('#seasons').change(function(){
		var season = $('#seasons').val()
		if (/^[0-9]{4}(-[0-9]{2})?$/.test(season)){
			location.hash = `#${season}`
		}
		$('#seasons').val('-')
	})
})
