"use strict"

var rawTitle="",rawH1=""
$(document).ready(function(){
	rawTitle = $('title').text()
	rawH1 = $('h1').text()
	loadEventStats(fillPage)
	$('#displayType').change(showStats)
})

$(window).on('hashchange',fillPage)

var team

function fillPage(){
	window.scroll(0,0)
	team = parseInt((location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["","0"])[1])||""
	$('title').text(rawTitle.replace("EVENT", eventName).replace("TEAM", team))
	$('h1').text(rawH1.replace("EVENT", eventName).replace("TEAM", team))
	if(team){
		$('#sidePhoto').html(`<img src="/data/${eventYear}/${team}.jpg">`)
		$('#topPhoto').html(`<img src="/data/${eventYear}/${team}-top.jpg">`)
	}
	$('.imagePreview img').click(function(){
		showLightBox($('#fullPhoto').attr('src',$(this).attr('src')))
	})
	$('#fullPhoto').click(closeLightBox)

	showStats()

	if(typeof window.showPitScouting === 'function'){
		window.showPitScouting($('#pit-scouting'),team)
	}
}

function showStats(){
	var matchList = [],
	matchNames = []
	for (var i=0; i<eventStats.length; i++){
		if (eventStats[i]['team']==team){
			matchList.push(eventStats[i])
			matchNames.push(getMatchName(eventStats[i]['match']))
		}
	}
	if (!matchList.length) return;

	if ($('#displayType').val() == 'graph')	showGraphs(matchList, matchNames)
	else showTables(matchList, matchNames)
	showComments(matchList, matchNames)
}

function showTables(matchList, matchNames){
	var table = $('<table>')
	Object.keys(teamGraphs).forEach(function(section){
		table.append($('<tr><td class=blank></td></tr>'))
		var hr = $('<tr>')
		hr.append($(`<th class=borderless><h4>${section}</h4></th>`))
		for (var j=0; j<matchList.length; j++){
			hr.append($('<th class=match>').text(matchNames[j]))
		}
		table.append(hr)
		teamGraphs[section]['data'].forEach(function(field){
			var info = statInfo[field]||{},
			tr = $('<tr class=statRow>').append($('<th>').text(info['name']||field))
			matchList.forEach(function(match){
				tr.append($('<td>').text(match[field]||0))
			})
			table.append(tr)
		})
	})
	$('#stats').html('').append(table)
}

function showGraphs(matchList, matchNames){
	var graphs = $('#stats').html('')
	Object.keys(teamGraphs).forEach(function(section){
		var chart = $('<canvas>'),
		data=[],
		graph=$('<div class=graph>')
		graphs.append(graph)
		graph.append($('<h2>').text(section))
		graph.append($('<div class=chart>').append(chart).css('min-width', (matchList.length*23+100) + 'px'))
		teamGraphs[section]['data'].forEach(function(field,j){
			var info = statInfo[field]||{},
			values = []
			for (var k=0; k<matchList.length; k++){
				values.push(matchList[k][field]||0)
			}
			data.push({
				label: info['name']||field,
				data: values,
				backgroundColor: Array(matchList.length).fill(graphColors[j])
			})
		})
		var stacked = teamGraphs[section]['graph']=="stacked"
		new Chart(chart,{
			type: 'bar',
			data: {
				labels: matchNames,
				datasets: data
			},
			options: {
				scales: {
					y: {beginAtZero: true,stacked: stacked},
					x: {stacked: stacked}
				}
			}
		})
	})
}

function showComments(matchList, matchNames){
	var comments = $('#comments').html("")
	for (var i=0; i<matchList.length; i++){
		comments
			.append($('<h3>').text(matchNames[i]))
			.append($('<p class=comments>').text(matchList[i]['comments']||""))
			.append($('<p class=scouter>').text(matchList[i]['scouter']||""))
	}
}
