"use strict"

$(document).ready(function(){
	var yearStatsLinkHtml,
	events = []
	$.ajax({
		url:"/event-list.cgi",
		dataType:"text",
		success:function(data){
			events = data.split(/[\r\n]/)
			var years = {}
			for (var i=0; i<events.length; i++){
				var m = events[i].match(/^[0-9]{4}/)
				if(m) years[m[0]] = 1
			}
			years = Object.keys(years)
			years.sort((a,b) => {return a-b})
			for (var i=0; i<years.length; i++){
				var year = years[i]
				$('#years').append($(`<option value=${year}>${year}</option>`))
			}
			$('#years').toggle(years.length > 1)
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
			if (events[i] && events[i].startsWith(filter)){
				var event = events[i],
				fields = event.split(/,/),
				id = fields[0],
				year = id.substring(0,4),
				venue = (fields.length>1&&fields[1])?fields[1]:id.substring(4)
				list.append($(`<li><a href=/event.html#${id}>${year} ${venue}</a></li>`))
				eventsShown++
			}
		}
		if (!yearStatsLinkHtml) yearStatsLinkHtml = $('#yearStatsLink').html()
		$('#yearStatsLink').html(yearStatsLinkHtml.replace(/YEAR/g,filter)).toggle(/20[0-9]{2}/.test(filter) && eventsShown > 1)
	}
	$(window).on('hashchange', showEvents)
	$('#years').change(function(){
		var year = $('#years').val()
		if (/^[0-9]{4}$/.test(year)){
			location.hash = `#${year}`
		}
		$('#years').val('-')
	})
})
