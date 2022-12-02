var rawTitle="",rawH1=""
$(document).ready(function(){
	rawTitle = $('title').text()
	rawH1 = $('h1').text()
	loadEventStats(fillPage)
})

$(window).on('hashchange',fillPage)

function fillPage(){
	window.scroll(0,0)
	var team = parseInt((location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["","0"])[1])||"",
	matchList = [],
	matchNames = []
	$('title').text(rawTitle.replace("EVENT", eventName).replace("TEAM", team))
	$('h1').text(rawH1.replace("EVENT", eventName).replace("TEAM", team))
	for (var i=0; i<eventStats.length; i++){
		if (eventStats[i]['team']==team){
			matchList.push(eventStats[i])
			matchNames.push(getMatchName(eventStats[i]['match']))
		}
	}

	var graphs = $('#statGraphs').html('')
	var comments = $('#comments').html("")
	if (!matchList.length) return;

	var sections = Object.keys(teamGraphs)
	for (var i=0; i<sections.length; i++){
		var section = sections[i],
		chart = $('<canvas>'),
		data=[],
		graph=$('<div class=graph>')
		graphs.append(graph)
		graph.append($('<h2>').text(section))
		graph.append($('<div class=chart>').append(chart).css('min-width', (matchList.length*23+100) + 'px'))
		for (var j=0; j<teamGraphs[section]['data'].length; j++){
			var field = teamGraphs[section]['data'][j],
			info = statInfo[field]||{}
			var values = []
			for (var k=0; k<matchList.length; k++){
				values.push(matchList[k][field]||0)
			}
			data.push({
				label: info['name']||field,
				data: values,
				backgroundColor: Array(matchList.length).fill(graphColors[j])
			})
		}
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
	}

	for (var i=0; i<matchList.length; i++){
		comments
			.append($('<h3>').text(matchNames[i]))
			.append($('<p class=comments>').text(matchList[i]['comments']||""))
			.append($('<p class=scouter>').text(matchList[i]['scouter']||""))
	}

}

function getMatchName(matchId){
	return matchId
		.replace(/^qm/, "Qualifier ")
		.replace(/^qf/, "Quarter-final ")
		.replace(/^sf/, "Semi-final ")
		.replace(/^f/, "Final ")
}
