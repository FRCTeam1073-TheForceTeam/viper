"use strict"

$(document).ready(function(){
	loadEventStats(function(){
		$('#sortBy').click(showSortOptions)
		$('#markPicked').click(function(){
			showTeamPicker(setTeamPicked, "Change Whether Team Has Been Picked")
		})
		$('#viewTeam').click(function(){
			showTeamPicker(showTeamStats, "Show Team Stats")
		})
		teamList = Object.keys(eventStatsByTeam)
		showStats()
	})
	$('h1').text($('h1').text().replace("EVENT", eventName))
	$('title').text($('title').text().replace("EVENT", eventName))
	$('#teamStats iframe').attr('src',`/team.html#event=${eventId}`)
	$('#lightBoxBG').click(function(){
		team=""
		$('#teamStats iframe').attr('src',`/team.html#event=${eventId}`)
	})
	$('#displayType').change(showStats)
})

function getStatInfoName(field){
	var info = statInfo[field]||{}
	return info['name']||field
}

var teamList = []
var sortStat = 'score'
var teamsPicked = {}
parseHash()

function parseHash(){
}

function setHash(){
	location.hash = `#event=${eventId}`
}

$(window).on('hashchange', function(){
	parseHash()
	showStats()
})

function showStats(){
	for (var i=0; i<teamList.length; i++){
		var t = teamList[i]
		teamsPicked[t] = teamsPicked[t]||false
	}
	teamList.sort((a,b)=>{
		if (teamsPicked[a] != teamsPicked[b]) return teamsPicked[b]?-1:1
		if (statInfo[sortStat].good == 'low') return getTeamValue(sortStat,a)-getTeamValue(sortStat,b)
		return getTeamValue(sortStat,b)-getTeamValue(sortStat,a)
	})
	var graphs = $('#statGraphs').html(''),
	table = $('#statsTable').html('')
	var sections = Object.keys(aggregateGraphs)

	if ($('#displayType').val() == 'graph'){
		Chart.defaults.color=window.getComputedStyle(document.body).getPropertyValue('--main-fg-color')
		for (var i=0; i<sections.length; i++){
			var section = sections[i],
			chart = $('<canvas>'),
			data=[],
			percent=false,
			graph=$('<div class=graph>')
			graphs.append(graph)
			graph.append($('<h2>').text(section))
			graph.append($('<div class=chart>').append(chart).css('min-width', (teamList.length*23+100) + 'px'))
			for (var j=0; j<aggregateGraphs[section]['data'].length; j++){
				var field = aggregateGraphs[section]['data'][j],
				info = statInfo[field]||{}
				var values = []
				for (var k=0; k<teamList.length; k++){
					values.push(getTeamValue(field, teamList[k]))
				}
				data.push({
					label: (info['type']=='avg'?'Average ':'') + (info['name']||field) + (info['type']=='%'?' %':''),
					data: values,
					backgroundColor: bgArr(graphColors[j])
				})
				if (info['type']=='%') percent=true
			}
			var stacked = aggregateGraphs[section]['graph']=="stacked"
			var yScale = {beginAtZero:true,stacked:stacked,bounds:percent?'data':'ticks'}
			if (percent)yScale['suggestedMax'] = 100
			new Chart(chart,{
				type: 'bar',
				data: {
					labels: teamList,
					datasets: data
				},
				options: {
					scales: {
						y: yScale,
						x: {stacked: stacked}
					}
				}
			})
		}
	} else {
		var tableWidth = teamList.length + 1
		var sections = Object.keys(aggregateGraphs)
		for (var i=0; i<sections.length; i++){
			var section = sections[i]
			table.append($('<tr><td class=blank></td></tr>'))
			var hr = $('<tr>')
			hr.append($(`<th class=borderless><h4>${section}</h4></th>`))
			for (var j=0; j<teamList.length; j++){
				var t = teamList[j],
				picked = teamsPicked[t]
				hr.append($('<th class=team>').text(t).click(setTeamPicked).toggleClass('picked',picked))
			}
			table.append(hr)
			for (var j=0; j<aggregateGraphs[section]['data'].length; j++){
				var field = aggregateGraphs[section]['data'][j],
				info = statInfo[field]||{},
				highGood = (info['good']||"high")=='high',
				statName = (info['type']=='avg'?"Average ":"") + (info['name']||field) + (info['type']=='%'?" %":""),
				tr = $('<tr class=statRow>').append($('<th>').text(statName + " ").attr('data-field',field).click(reSort)),
				best = (highGood?-1:1)*99999999
				for (var k=0; k<teamList.length; k++){
					var t = teamList[k],
					picked = teamsPicked[t],
					value = getTeamValue(field, t)
					if (!picked && ((highGood && value > best) || (!highGood && value < best))) best = value
				}
				for (var k=0; k<teamList.length; k++){
					var t = teamList[k]
					picked = teamsPicked[t],
					value = getTeamValue(field, t)
					tr.append($('<td>').toggleClass('picked',picked).toggleClass('best',!picked && value==best).attr('data-team',t).click(showTeamStats).text(Math.round(value)))
				}
				table.append(tr)
			}
		}
	}
}

function showSortOptions(){
	var picker = $('#sortChooser').html(`<h2>Choose Sorting</h2>`)
	var allStats = []
	Object.keys(aggregateGraphs).forEach(x=>{
		aggregateGraphs[x].data.forEach(y=>allStats.push(y))
	})
	allStats.sort((a,b)=>{return getStatInfoName(a).localeCompare(getStatInfoName(b))})
	for (var i=0; i<allStats.length; i++){
		var field = allStats[i],
		info = statInfo[field]||{},
		name = getStatInfoName(field),
		active = sortStat==field?" active":""
		if(!/^(text|enum)$/.test(info['type'])) picker.append($(`<button class="sortByBtn${active}">`).attr('data-field',field).text(name).click(reSort))
	}
	showLightBox(picker)
}

function showTeamPicker(callback, heading){
	var picker = $('#teamPicker').html(`<h2>${heading}</h2>`)
	teamList.sort((a,b)=>{return a-b})
	for (var i=0; i<teamList.length; i++){
		var team = teamList[i]
		picker.append($('<button class=team>').text(team).addClass(teamsPicked[team]?"picked":"not-picked").click(callback))
	}
	showLightBox(picker)
}

function setTeamPicked(){
	var team = parseInt($(this).text())
	closeLightBox()
	teamsPicked[team] = !teamsPicked[team]
	showStats()
}

function showTeamStats(){
	var team = parseInt($(this).attr('data-team')||$(this).text())
	$('#teamPicker').hide()
	$('#teamStats iframe').attr('src',`/team.html#event=${eventId}&team=${team}`)
	window.scrollTo(0,0)
	showLightBox($('#teamStats'))
}

function bgArr(color){
	var arr = [],
	picked = 0
	for (var i=0; i<teamList.length; i++){
		if (teamsPicked[teamList[i]]) picked++
	}
	for (var i=0; i<teamList.length; i++){
		arr.push(i<teamList.length-picked?color:darkenColor(color))
	}
	return arr
}

function reSort(){
	sortStat=$($(this)).attr('data-field')
	$('#sortBy .name').text($(this).text())
	closeLightBox()
	setHash()
	showStats()
}

function darkenColor(color){
	var m = color.match(/^\#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/)
	if(m){
		return "#" +
		(Math.round(parseInt(m[1],16)/2)).toString(16).padStart(2,'0') +
		(Math.round(parseInt(m[2],16)/2)).toString(16).padStart(2,'0') +
		(Math.round(parseInt(m[3],16)/2)).toString(16).padStart(2,'0')
	}
	return "darkGray"

}

function getTeamValue(field, team){
	if (! team in eventStatsByTeam) return 0
	var stats = eventStatsByTeam[team],
	info = statInfo[field]||{}
	if (! field in stats ||! 'count' in stats || !stats['count']) return 0
	var divisor = /(avg|\%)$/.test(info['type'])?stats['count']:1
	return (stats[field]||0) / divisor * (info['type']=='%'?100:1)
}
