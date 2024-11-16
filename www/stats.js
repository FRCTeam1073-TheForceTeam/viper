"use strict"

$(document).ready(function(){
	Promise.all([
		promiseEventStats(),
		promisePitScouting(),
		promiseSubjectiveScouting()
	]).then(values => {
		;[window.eventStatsValues, window.pitData, window.subjectiveData] = values
		;[window.eventStats, window.eventStatsByTeam] = eventStatsValues
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
	return info.name||field
}

var teamList = []
var sortStat = 'score'
var teamsPicked = {}
var graphList = {}

function getGraphListKey(){
	return eventYear + "AggregateGraphs"
}

var myTeamsGraphs
fetch(`/data/${eventYear}/stats.json`).then(response=>response.json()).then(json=>myTeamsGraphs=json)

function getGraphList(){
	var s = localStorage.getItem(getGraphListKey())
	if (s) return JSON.parse(s)
	if (myTeamsGraphs) return myTeamsGraphs
	return aggregateGraphs
}

var gTypes = {
	"bar":{
		name: "Bar chart",
		types: ['%','avg','count','capability','fraction','minmax','num','ratio']
	},
	"boxplot":{
		name: "Box plot",
		types: ['%','avg','count','capability','fraction','minmax','num','ratio']
	},
	"heatmap":{
		name: "Heatmap",
		types: ['heatmap']
	},
	"stacked":{
		name: "Stacked bars",
		types: ['%','avg','count','capability','fraction','minmax','num','ratio']
	},
	"stacked_percent":{
		name: "Stacked percents",
		types: ['%','avg','count','capability','fraction','minmax','num','ratio']
	},
	"timeline":{
		name: "Timeline",
		types: ['timeline']
	},
}

function populateAddFields(){
	var s = $('#graph-builder-add-field'),
	types = new Set(gTypes[$('#graph-builder-type').val()].types),
	statNames = Object.keys(statInfo)
	statNames.sort((a,b)=>statInfo[a].name.localeCompare(statInfo[b].name))
	s.html("")
	s.append($('<option>').attr('value',"").attr('selected','true'))
	statNames.forEach(function(stat){
		if (types.has(statInfo[stat].type)){
			s.append($('<option>').attr('value',stat).text(`${statInfo[stat].name} (${statInfo[stat].type})`))
		}
	})
}

function addFieldToGraphBuilder(field){
	$('#graph-builder-fields').append(
		$('<li>')
		.attr('data-field',field)
		.text(" " + statInfo[field].name).prepend(
			$('<button style=color:red>').text('✘').click(function(){
				$(this).closest('li').remove()
			})
		)
	)
}

function showGraphConfig(name){
	var g = getGraphList()[name]||{graph:'bar',data:[]},
	d = $('#graph-builder')
	if (!d.length){
		var type = $('<select id=graph-builder-type>').change(function(){
			var types = new Set(gTypes[$('#graph-builder-type').val()].types)
			$('#graph-builder-fields li').each(function(){
				var field = $(this).attr('data-field')
				if (!types.has(statInfo[field].type)) $(this).remove()
			})
			populateAddFields()
		})
		d = $('<div id=graph-builder class=lightBoxCenterContent style=display:none>')
		.append($('<p><input id=graph-builder-name type=text placeholder="Name of graph"></p>'))
		.append($('<p>').append(type))
		Object.keys(gTypes).forEach(function(gType){
			type.append($('<option>').attr('value',gType).text(gTypes[gType].name))
		})
		type.val(g.graph)
		d.append($('<ul id=graph-builder-fields>'))
		.append('Add stat: ').append($('<select id=graph-builder-add-field>').change(function(){
			var field = $(this).val()
			if (field) addFieldToGraphBuilder(field)
			$(this).val('')
		}))
		.append($('<p>').append($('<button>Save</button>').click(function(){
			var nameField = $('#graph-builder-name'),
			oldName = nameField.attr('old-name'),
			newName = nameField.val(),
			fields = $("#graph-builder-fields li").map(function(){return $(this).attr("data-field")}).get(),
			graphList = getGraphList()
			if (!fields.length) return alert("Error: No fields for graph")
			if (!newName) return alert("Error: Name not specified")
			if (oldName != newName) graphList[oldName]
			graphList[newName]={
				graph: $('#graph-builder-type').val(),
				data: fields
			}
			localStorage.setItem(getGraphListKey(), JSON.stringify(graphList))
			closeLightBox()
			showStats()
		})).append(" ").append($('<button>Cancel</button>').click(closeLightBox)))
		$('body').append(d)
	}
	$('#graph-builder-name').attr('old-name',name).val(name)
	$('#graph-builder-fields').html("")
	g.data.forEach(function(field){
		addFieldToGraphBuilder(field)
	})
	populateAddFields()
	showLightBox(d)
}

function removeGraph(name){
	var g = getGraphList()
	delete g[name]
	localStorage.setItem(getGraphListKey(), JSON.stringify(g))
	closeLightBox()
	showStats()
}

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
	graphList = getGraphList()
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
	var sections = Object.keys(graphList)

	if ($('#displayType').val() == 'graph'){
		Chart.defaults.color=window.getComputedStyle(document.body).getPropertyValue('--main-fg-color')
		var charts = {}
		for (var i=0; i<sections.length; i++){
			var section = sections[i],
			statName = graphList[section].data[0],
			stat=statInfo[statName],
			graphType=graphList[section].graph,
			source=stat.source||"",
			dataSource = source=='subjective'?subjectiveData:(source=='pit'?pitData:eventStatsByTeam),
			graph=$('<div class=graph>')
			graphs.append(graph)
			var csv = [["team", ...teamList]]
			for (var j=0; j<graphList[section].data.length; j++){
				var field = graphList[section].data[j]
				csv.push([field,...teamList.map(team=>getTeamValue(field, team, graphType=='boxplot'?"":graphType, dataSource))])
			}
			csv = csv[0].map((_, colIndex) => csv.map(row => row[colIndex]))
			csv = csv.map(row=>row.map(String).join(',')).join('\n')
			var sectionFile = section.toLowerCase().replace(/ ?\(.*/,"").replace(" ","_")
			const graphConfig = $('<div class=lightBoxCenterContent style=display:none>').append(
				$('<h2>').text(section)
			).append(
				$('<ul>').append(
					$('<li>').append(
						$('<a>Download Data</a>').attr('href',
							window.URL.createObjectURL(new Blob([csv], {type: 'text/csv;charset=utf-8'}))
						).attr('download',`${eventId}.${sectionFile}.csv`)
					)
				).append(
					$('<li>').append(
						$('<a href=#>Edit</a>').attr('data-name',section).click(function(){
							showGraphConfig($(this).attr('data-name'))
							return false
						})
					)
				).append(
					$('<li>').append(
						$('<a href=#>Remove</a>').attr('data-name',section).click(function(){
							if (confirm("Are you sure you want to remove this graph?")){
								removeGraph($(this).attr('data-name'))
							}
							return false
						})
					)
				)
			).append(
				$('<h2>').text("Manage Graphs")
			).append(
				$('<ul>').append(
					$('<li>').append(
						$('<a href=#>Add Another</a>').attr('data-name',section).click(function(){
							showGraphConfig()
							return false
						})
					)
				).append(
					$('<li>').append(
						$('<a href=#>Edit JSON</a>').click(function(){
							var g = getGraphList(),
							d = $('#graph-export')
							if (!d.length){
								d = $('<div id=graph-export class=lightBoxCenterContent>')
								.append(
									$('<textarea id=graph-export-json style=width:98vw;max-width:30em;height:90vh;max-height:60em>')
								).append($('<button>Save</button>').click(function(){
									try{
										var json = JSON.parse($('#graph-export-json ').val())
										Object.keys(json).forEach(function(graph){
											var graphConf = json[graph]
											if (typeof graphConf !== 'object') throw (`Expected :{ following "${graph}"`)
											if (typeof graphConf.graph !== 'string') throw (`${graph}.graph is not a string`)
											if (typeof graphConf.data !== 'object' || (!(graphConf.data instanceof Array))) throw (`${graph}.data is not an array`)
											if (graphConf.data.length==0) throw (`${graph}.data is empty`)
											graphConf.data.forEach(function(graphField){
												if (typeof graphField !== 'string') throw (`${graph}.data is not all strings`)
												if (!statInfo[graphField]) throw (`Unknown data: ${graphField}`)
											})
											if (Object.keys(graphConf).length != 2) throw (`Expected only graph and data in "${graph}"`)
										})
										localStorage.setItem(getGraphListKey(), JSON.stringify(json))
										closeLightBox()
										showStats()
									} catch(e){
										alert(e)
									}
									return false
								})).append($('<button>Cancel</button>').click(function(){
									closeLightBox()
									return false
								}))
								$('body').append(d)
							}
							$('#graph-export-json').val(JSON.stringify(g,null,2))
							showLightBox(d)
							return false
						})
					)
				).append(
					$('<li>').append(
						$('<a href=#>Save to Server</a>').click(function(){
							var g = getGraphList(),
							d = $('#graph-save')
							if (!d.length){
								d = $('<form method=POST action=/admin/graph-save.cgi id=graph-save>')
								.append($('<input type=hidden name=return id=graph-save-return>'))
								.append($('<input type=hidden name=season id=graph-save-season>'))
								.append($('<input type=hidden name=type value=stats>'))
								.append($('<input type=hidden name=conf id=graph-save-conf>'))
								$('body').append(d)
							}
							$('#graph-save-season').val(eventYear)
							$('#graph-save-conf').val(JSON.stringify(g))
							$('#graph-save-return').val(location.pathname+location.search+location.hash)
							$('#graph-save').submit()
							return false
						})
					)
				).append(
					$('<li>').append(
						$('<a href=#>Revert All Customizations</a>').click(function(){
							if (confirm("Are you sure you want delete ALL your custom graph configuration?")){
								localStorage.removeItem(getGraphListKey())
								closeLightBox()
								showStats()
							}
							return false
						})
					)
				)
			)
			graph.append(graphConfig).append($('<h2>').text(section).append(" ").append($('<button>🛠️</button>').attr('data-section',section).click(function(){
				showLightBox(graphConfig)
			})))
			if (graphType=='heatmap'){
				var image=stat.image,
				width=Math.min($(document).width(),1000),
				height=Math.round(width/stat.aspect_ratio),
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
					stat = dataSource[teamList[k]]
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
				var stackedPercent = graphType=="stacked_percent",
				boxplot = graphType=='boxplot'
				for (var j=0; j<graphList[section].data.length; j++){
					var field = graphList[section].data[j],
					info = statInfo[field]||{},
					values = []
					if (!boxplot || info.type!='minmax'){
						for (var k=0; k<teamList.length; k++){
							values.push(getTeamValue(field, teamList[k],graphType))
						}
						data.push({
							field: field,
							label: (info.type=='avg'&&!boxplot?'Average ':'') + (info.name||field) + (info.type=='%'?' %':''),
							data: values,
							backgroundColor: bgArr(graphColors[j]),
							borderColor: bgArr(graphColors[j]),
							lowerBackgroundColor: bgArr(darkenColor(graphColors[j])),
							quantiles: 'nearest',
							coef: 0
						})
						if (info.type=='%'||stackedPercent) percent=true
					}
				}
				var stacked = graphType.includes("stacked")
				var yScale = {beginAtZero:true,stacked:stacked,bounds:percent?'data':'ticks'}
				if (percent)yScale.suggestedMax = 100
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
							graphList[section].data
						)
					}
				})
			}
		}
	} else {
		var sections = Object.keys(graphList)
		for (var i=0; i<sections.length; i++){
			var section = sections[i]
			if (graphType!='heatmap'){
				table.append($('<tr><td class=blank></td></tr>'))
				var hr = $('<tr>')
				hr.append($(`<th class=borderless><h4>${section}</h4></th>`))
				for (var j=0; j<teamList.length; j++){
					var t = teamList[j],
					picked = teamsPicked[t]
					hr.append($('<th class=team>').text(t).click(showStatClickMenu).toggleClass('picked',picked))
				}
				table.append(hr)
				for (var j=0; j<graphList[section].data.length; j++){
					var field = graphList[section].data[j],
					info = statInfo[field]||{},
					highGood = (info.good||"high")=='high',
					statName = (info.type=='avg'?"Average ":"") + (info.name||field) + (info.type=='%'?" %":""),
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
	Object.keys(graphList).forEach(x=>{
		graphList[x].data.forEach(y=>allStats.push(y))
	})
	allStats.sort((a,b)=>{return getStatInfoName(a).localeCompare(getStatInfoName(b))})
	for (var i=0; i<allStats.length; i++){
		var field = allStats[i],
		info = statInfo[field]||{},
		name = getStatInfoName(field),
		active = sortStat==field?" active":""
		if(!/^(text|enum)$/.test(info.type)) picker.append($(`<button class="sortByBtn${active}">`).attr('data-field',field).text(name).click(reSort))
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
	var m = (color||"").match(/^\#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/)
	if(m){
		return "#" +
		(Math.round(parseInt(m[1],16)/2)).toString(16).padStart(2,'0') +
		(Math.round(parseInt(m[2],16)/2)).toString(16).padStart(2,'0') +
		(Math.round(parseInt(m[3],16)/2)).toString(16).padStart(2,'0')
	}
	return "darkGray"

}

function getTeamValue(field, team, graphType, source){
	if (!source) source = eventStatsByTeam
	var heatmap = graphType=='heatmap',
	percent = graphType=="stacked_percent",
	boxplot = graphType=='boxplot',
	defaultVal = heatmap?"":(boxplot?[]:0)
	if (! team in source) return defaultVal
	var stats = source[team] || {}
	if (boxplot && (field+"_set") in stats) field+="_set"
	var info = statInfo[field]||{}
	percent = percent || info.type=='%'
	if (! field in stats) return defaultVal
	var value = stats[field]
	if (heatmap||boxplot) return value||defaultVal
	if (! 'count' in stats || !stats.count) return defaultVal
	var divisor = (percent||"avg"==info.type)?stats.count:1
	if (info.type=='int-list'){
		if (value.length){
			divisor = value.length
			value = value.reduce((a, b) => a + b)
		} else {
			value = info.good=='low'?999:0
		}
	}
	return (value||(info.good=='low'?999:0)) / divisor * (percent?100:1)
}
