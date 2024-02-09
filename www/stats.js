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
		teamList.forEach(x=>teamsPicked[x]=false)
		parseHash()
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
	$('.showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})

	sortable('#picklist', {
		acceptFrom: '#picklist, #donotpicklist'
	})[0].addEventListener('sortupdate', pickListReordered)
	sortable('#donotpicklist', {
		acceptFrom: '#picklist, #donotpicklist'
	})[0].addEventListener('sortupdate', pickListReordered)
	$('#teamlists h4').click(function(){
		$('.picklist-body').toggle()
	})
})

function getStatInfoName(field){
	var info = statInfo[field]||{}
	return info['name']||field
}

var teamList = []
var sortStat = 'score'
var teamsPicked = {}

function parseHash(){
	var pl=(location.hash.match(/^\#(?:.*\&)?pl\=([0-9]+(?:,[0-9]+)*)(?:\&.*)?$/)||["",""])[1].split(',').map(x=>parseInt(x)),
	dnp=(location.hash.match(/^\#(?:.*\&)?dnp\=([0-9]+(?:,[0-9]+)*)(?:\&.*)?$/)||["",""])[1].split(',').map(x=>parseInt(x))
	Object.keys(teamsPicked).forEach(x=>teamsPicked[x]=false)
	$('#teamlists li').remove()
	pl.forEach(x=>setTeamPicked(0,x))
	dnp.forEach(x=>setTeamPicked(0,x,1))
}

var lastHash = ""

function setHash(){
	var pl = $.map($('#picklist li'),x=>$(x).text()).join(","),
	dnp = $.map($('#donotpicklist li'),x=>$(x).text()).join(",")
	if (pl) pl = `&pl=${pl}`
	if (dnp) dnp = `&dnp=${dnp}`
	lastHash=`#event=${eventId}${pl}${dnp}`
	location.hash = lastHash
}

$(window).on('hashchange', function(){
	if(location.hash != lastHash){
		parseHash()
		showStats()
		lastHash=location.hash
	}
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
		var charts = {}
		for (var i=0; i<sections.length; i++){
			var section = sections[i],
			graph=$('<div class=graph>')
			graphs.append(graph)
			graph.append($('<h2>').text(section))
			if (aggregateGraphs[section]['graph']=='heatmap'){
				var statName = aggregateGraphs[section]['data'][0],
				stat=statInfo[statName],
				image=stat['image'],
				width=Math.min($(document).width(),1000),
				height=Math.round(width/stat['aspect_ratio']),
				points=[],
				chart = $('<div class="heatmap">')
				.css("width",width)
				.css("height",height)
				.css("background", `url(${image}) no-repeat center center / 100% 100%`)
				graph.append(chart)
				var heatmap = h337.create({
					container: chart[0],
				})
				for (var k=0; k<teamList.length; k++){
					stat = eventStatsByTeam[teamList[k]]
					if (stat && statName in stat){
						((stat[statName]||"").match(/[0-9]{1,2}x[0-9]{1,2}/g)||[]).forEach(function(point){
							var m = point.match(/^([0-9]{1,2})x([0-9]{1,2})$/)
							points.push({
								x:Math.round(parseInt(m[1]) * width / 100),
								y:Math.round(parseInt(m[2]) * height / 100),
								value:1
							})
						})
					}
				}
				heatmap.setData({
					max:3,
					min:0,
					data:points
				})
			} else {
				var canvas = $(`<canvas data-section="${section}">`),
				data=[],
				percent=false
				graph.append($('<div class=chart>').append(canvas).css('min-width', (teamList.length*23+100) + 'px'))
				var stackedPercent = aggregateGraphs[section]['graph']=="stacked_percent",
				boxplot = aggregateGraphs[section]['graph']=='boxplot'
				for (var j=0; j<aggregateGraphs[section]['data'].length; j++){
					var field = aggregateGraphs[section]['data'][j],
					info = statInfo[field]||{},
					values = []
					if (!boxplot || info['type']!='minmax'){
						for (var k=0; k<teamList.length; k++){
							values.push(getTeamValue(field, teamList[k],stackedPercent,boxplot))
						}
						data.push({
							field: field,
							label: (info['type']=='avg'&&!boxplot?'Average ':'') + (info['name']||field) + (info['type']=='%'?' %':''),
							data: values,
							backgroundColor: bgArr(graphColors[j]),
							borderColor: bgArr(graphColors[j]),
							lowerBackgroundColor: bgArr(darkenColor(graphColors[j])),
							quantiles: 'nearest',
							coef: 0
						})
						if (info['type']=='%'||stackedPercent) percent=true
					}
				}
				var stacked = aggregateGraphs[section]['graph'].includes("stacked")
				var yScale = {beginAtZero:true,stacked:stacked,bounds:percent?'data':'ticks'}
				if (percent)yScale['suggestedMax'] = 100
				charts[section] = new Chart(canvas,{
					type: boxplot?'boxplot':'bar',
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
				canvas.click(function(evt) {
					var section = $(this).attr('data-section'),
					myChart = charts[section],
					points = myChart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, true)
					if (points.length) {
						showStatClickMenu(
							evt,
							myChart.data.labels[points[0].index],
							aggregateGraphs[section].data
						)
					}
				})
			}
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
				hr.append($('<th class=team>').text(t).click(showStatClickMenu).toggleClass('picked',picked))
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
					tr.append($('<td>').toggleClass('picked',picked).toggleClass('best',!picked && value==best).attr('data-team',t).click(showStatClickMenu).text(Math.round(value)))
				}
				table.append(tr)
			}
		}
	}
}

function showStatClickMenu(e, team, fields){
	if (!team) team = $(this).attr('data-team')||$(this).text()
	if (!/^[0-9]+$/.test(team)) team=null
	if (!fields){
		var th = $(this).closest('tr').find('th')
		fields = th.attr('data-field')
	}
	if (!team && !fields)return
	var ca = $('#clickActions').html("")
	if (team) ca.append($('<p>').append("Mark picked: ").append($('<button>').text(team).click(setTeamPicked)))
	if (team) ca.append($('<p>').append("View stats: ").append($('<button>').text(team).click(showTeamStats)))
	if (fields){
		if (typeof fields === 'string') fields = [fields]
		fields.forEach(field=>{
			ca.append($('<p>').append("Sort by: ").append($('<button>').text(getStatInfoName(field)).attr('data-field',field).click(reSort)))
		})
	}
	showLightBox(ca)
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

function setTeamPicked(e, team, dnp){
	var y = window.scrollY
	if (!team) team = parseInt($(this).text())
	if (!teamsPicked.hasOwnProperty(team)) return
	teamsPicked[team] = !teamsPicked[team]
	if(teamsPicked[team]){
		var list = (dnp || getLocalTeam() == team)?'#donotpicklist':'#picklist'
		$(list).append($('<li>').attr('id',`pl${team}`).text(team).click(showStatClickMenu))
		sortable(list)
	} else {
		$(`#pl${team}`).remove()
	}
	setDnpStartNumber()
	$('#teamlists').toggle(Object.values(teamsPicked).filter(t=>t).length>0)
	if (e){
		setHash()
		closeLightBox()
		showStats()
		setTimeout(function(){
			window.scrollTo(0,y)
		},200)
	}
}

function pickListReordered(){
	setHash()
	setDnpStartNumber()
}

function setDnpStartNumber(){
	$('#donotpicklist').attr('start', $('#picklist li').length + 1)
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
	var y = window.scrollY
	sortStat=$($(this)).attr('data-field')
	$('#sortBy .name').text($(this).text())
	closeLightBox()
	setHash()
	showStats()
	setTimeout(function(){
		window.scrollTo(0,y)
	},200)
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

function getTeamValue(field, team, percent, boxplot){
	if (! team in eventStatsByTeam) return 0
	var stats = eventStatsByTeam[team]
	if (boxplot && (field+"_set") in stats) field+="_set"
	var info = statInfo[field]||{}
	percent = percent || info['type']=='%'
	if (! field in stats ||! 'count' in stats || !stats['count']) return boxplot?[]:0
	if (boxplot) return stats[field]||[]
	var divisor = (percent||"avg"==info['type'])?stats['count']:1
	return (stats[field]||0) / divisor * (percent?100:1)
}
