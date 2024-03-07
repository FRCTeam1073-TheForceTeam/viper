"use strict"

var rawTitle="",rawH1=""
$(document).ready(function(){
	promiseEventStats(true).then(values => {
		[window.eventStats, window.eventStatsByTeam] = values
		fillPage()
	})
	$('#displayType').change(showStats)
})

$(window).on('hashchange',fillPage)

var team

function fillPage(){
	if (!rawTitle){
		rawTitle = $('title').text()
		rawH1 = $('h1').text()
	}
	window.scroll(0,0)
	team = parseInt((location.hash.match(/^\#(?:.*\&)?(?:team\=)([0-9]+)(?:\&.*)?$/)||["","0"])[1])||""
	$('#teamButtons').toggle(!team)
	$('#teamStats').toggle(!!team)
	if (!team){
		$('#teamButtons').html("")
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		teamList.forEach(function(team){
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
		})
	} else {
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
			$('a.pitScouting').attr('href', `#event=${eventId}&team=${team}&pit-scouting`)
			$('#pit-scouting').html("")
			window.showPitScouting($('#pit-scouting'),team)
			if (/pit-scouting/i.test(location.hash)){
				setTimeout(function(){
					window.scroll(0,$('#pit-scouting').position().top-100)
				},200)
			}
		} else {
			$('.pitScouting').hide()
		}

		if(typeof window.showSubjectiveScouting === 'function'){
			$('a.subjectiveScouting').attr('href', `#event=${eventId}&team=${team}&subjective-scouting`)
			$('#subjective-scouting').html("")
			window.showSubjectiveScouting($('#subjective-scouting'),team)
			if (/subjective-scouting/i.test(location.hash)){
				setTimeout(function(){
					window.scroll(0,$('#subjective-scouting').position().top-100)
				},200)
			}
		} else {
			$('.subjectiveScouting').hide()
		}
	}
}

function teamButtonClicked(){
	team = parseInt($(this).text())
	location.hash=`#event=${eventId}&team=${team}`
	fillPage()
}

function showStats(){
	var matchList = [],
	matchNames = []
	eventStats.forEach(function(stat){
		var match = stat.match
		if (stat.team==team && (statsIncludePractice || !/^pm/.test(match))){
			matchList.push(stat)
			matchNames.push(getMatchName(match))
		}
	})
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
		teamGraphs[section].data.forEach(function(field){
			var info = statInfo[field]||{},
			tr = $('<tr class=statRow>').append($('<th>').text(info.name||field))
			matchList.forEach(function(match){
				tr.append($('<td>').text(match[field]||0))
			})
			table.append(tr)
		})
	})
	$('#stats').html('').append(table)
}

function displayHeatMap(parent,imageUrl,aspectRatio,max,data){
	var width=Math.min($(document).width(),1000),
	height=Math.round(width/aspectRatio),
	points=[],
	chart = $('<div class="heatmap">')
	.css("width",width)
	.css("height",height)
	.css("background", `url(${imageUrl}) no-repeat center center / 100% 100%`)
	parent.append(chart)
	var heatmap = h337.create({
		container: chart[0],
	})
	data.forEach(function(row){
		(row.match(/[0-9]{1,2}x[0-9]{1,2}/g)||[]).forEach(function(point){
			var m = point.match(/^([0-9]{1,2})x([0-9]{1,2})$/)
			points.push({
				x:Math.round(parseInt(m[1]) * width / 100),
				y:Math.round(parseInt(m[2]) * height / 100),
				value:1
			})
		})
	})
	heatmap.setData({
		max:max,
		min:0,
		data:points
	})
}

function showGraphs(matchList, matchNames){
	Chart.defaults.color=window.getComputedStyle(document.body).getPropertyValue('--main-fg-color')
	var graphs = $('#stats').html('')
	Object.keys(teamGraphs).forEach(function(section){
		var graph=$('<div class=graph>')
		graphs.append(graph)
		graph.append($('<h2>').text(section))
		if (teamGraphs[section].graph=='heatmap'){
			var statName = teamGraphs[section].data[0],
			stat=statInfo[statName]
			displayHeatMap(graph,stat.image,stat.aspect_ratio,2,matchList.map(function(el){
				return (el[statName]||"")
			}))
		} else if (teamGraphs[section].graph=='timeline'){
			var height = (matchList.length+2)*50 + "px",
			chart = $('<canvas>').css('width', '100%').css('max-height',height).css('height',height),
			data = {
				timelines: [],
				colors: graphColors
			}
			graph.append($('<div class=chart>').css('height',height).append(chart))
			teamGraphs[section].data.forEach(function(field,j){
				var info = statInfo[field]||{}
				for (var k=0; k<matchList.length; k++){
					data.timelines.push({
						name: matchNames[k],
						data: Object.fromEntries(matchList[k][field].split(" ").map(t=>{
							var pair = t.split(/:/),
							field = pair[1]||"",
							info = statInfo[field]||{name:field}
							pair[1] = info.name
							return pair
						}))
					})
				}
			})
			drawTimeline(chart, data)
		} else {
			var chart = $('<canvas>'),
			boxplot = teamGraphs[section].graph=="boxplot",
			data=[]
			graph.append($('<div class=chart>').append(chart).css('min-width', (matchList.length*23+100) + 'px'))
			teamGraphs[section].data.forEach(function(field,j){
				var info = statInfo[field]||{},
				color = Array(matchList.length).fill(graphColors[j]),
				values = []
				for (var k=0; k<matchList.length; k++){
					values.push(matchList[k][field]||0)
				}
				data.push({
					label: info.name||field,
					data: values,
					backgroundColor: color,
					backgroundColor: color,
					borderColor: color,
					quantiles: 'nearest',
					coef: 0
				})
			})
			var stacked = teamGraphs[section].graph=="stacked"
			new Chart(chart,{
				type: boxplot?'boxplot':'bar',
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
	})
}

function showComments(matchList, matchNames){
	var comments = $('#comments').html("")
	for (var i=0; i<matchList.length; i++){
		comments
			.append($('<h3>').text(matchNames[i]))
			.append($('<p class=comments>').text(matchList[i].comments||""))
			.append($('<p class=scouter>').text(matchList[i].scouter||""))
	}
}
