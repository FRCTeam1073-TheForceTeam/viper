"use strict"

addI18n({
	mark_picked_header:{
		en:'Change Whether Team Has Been Picked',
		fr:'Modifier si l\'équipe a été sélectionnée',
		zh_tw:'更改是否已選定球隊',
		pt:'Alterar se a equipe foi escolhida',
		he:'שנה אם צוות נבחר',
		tr:'Takımın Seçilip Seçilmediğini Değiştir',
	},
	view_team_header:{
		en:'Show Team Stats',
		fr:'Afficher les statistiques de l\'équipe',
		zh_tw:'顯示球隊統計數據',
		pt:'Mostrar estatísticas da equipe',
		he:'הצג סטטיסטיקות של צוות',
		tr:'Takım İstatistiklerini Göster',
	},
	pick_list_heading:{
		en:'Pick List',
		fr:'Liste de sélection',
		zh_tw:'選擇清單',
		pt:'Lista de seleção',
		he:'רשימת בחירה',
		tr:'Seçim Listesi',
	},
	no_pick_heading:{
		en:'No Pick',
		fr:'Aucune sélection',
		zh_tw:'沒有選擇',
		pt:'Sem seleção',
		he:'אין בחירה',
		tr:'Seçim Yok',
	},
	mark_picked_label:{
		en:'Mark picked:',
		fr:'Marquer comme sélectionné :',
		zh_tw:'馬克選擇：',
		pt:'Marcar como escolhido:',
		he:'מארק בחר:',
		tr:'Seçildi olarak işaretle:',
	},
	view_team_label:{
		en:'View stats:',
		fr:'Afficher les statistiques :',
		zh_tw:'查看統計數據：',
		pt:'Exibir estatísticas:',
		he:'צפה בסטטיסטיקה:',
		tr:'İstatistikleri görüntüle:',
	},
	sort_by_label:{
		en:'Sort by:',
		fr:'Trier par :',
		zh_tw:'排序方式：',
		pt:'Classificar por:',
		he:'מיין לפי:',
		tr:'Sırala:',
	},
	stats_title:{
		en:'_EVENT_ Stats',
		he:'_EVENT_ סטטיסטיקות',
		pt:'_EVENT_ Estatísticas',
		tr:'_EVENT_ İstatistikleri',
		zh_tw:'_EVENT_ 統計訊息',
		fr:'Statistiques _EVENT_',
	},
	mark_picked_button:{
		en:'Mark team as picked',
		he:'סמן את הצוות כנבחר',
		pt:'Marcar time como escolhido',
		tr:'Takımı seçilmiş olarak işaretle',
		zh_tw:'將團隊標記為已選',
		fr:'Marquer l\'équipe comme sélectionnée',
	},
	view_team_button:{
		en:'View team info',
		he:'צפה בפרטי הצוות',
		pt:'Exibir informações do time',
		tr:'Takım bilgilerini görüntüle',
		zh_tw:'查看團隊資訊',
		fr:'Voir les informations sur l\'équipe',
	},
	sort_label:{
		en:'Sort:',
		he:'סוּג:',
		pt:'Classificar:',
		tr:'Sırala:',
		zh_tw:'種類：',
		fr:'Trier :',
	},
	starting_match_label:{
		en:'Starting:',
		he:'מתחיל:',
		pt:'Começando:',
		tr:'Başlangıç:',
		zh_tw:'開始：',
		fr:'Début :',
	},
})
onApplyTranslation.push(showStats)
var teamList = [],
sortStat = 'score',
teamsPicked = {},
graphList = {},
myTeamsGraphs,
downloadBlobs={},
statsConfig = new StatsConfig({
	statsConfigKey:`${eventYear}AggregateGraphs`,
	getStatsConfig:function(){
		var s = statsConfig.getLocalStatsConfig()
		if (s) return s
		if (myTeamsGraphs && Object.keys(myTeamsGraphs).length) return myTeamsGraphs
		if (window.aggregateGraphs && Object.keys(window.aggregateGraphs).length) return window.aggregateGraphs
		return {}
	},
	hasSections:true,
	hasGraphs:true,
	drawFunction:showStats,
	fileName:"stats",
	defaultConfig:window.aggregateGraphs,
	downloadBlobs:downloadBlobs,
	mode:"aggregate"
})

addTranslationContext({event:eventName})

$(document).ready(function(){
	if(/^[0-9]{4}(-[0-9]{2})?combined$/.test(eventId))$('#startingControls').hide()
	Promise.all([
		promiseEventStats(),
		promisePitScouting(),
		promiseSubjectiveScouting(),
		promiseEventMatches(),
		promiseTeamsInfo(),
		promiseJson(`/data/${eventYear}/stats.json`)
	]).then(values => {
		[[window.eventStats, window.eventStatsByTeam], window.pitData, window.subjectiveData, window.eventMatches, window.eventTeamsInfo, window.myTeamsGraphs] = values
		eventMatches.forEach(match => $('#startingMatch').append($('<option>').attr('value',match.Match).text(getMatchName(match.Match))).val(statsStartMatch))
		if (!eventStats.some(match => match.review_requested == 1)) {
			$('#reviewControls').hide()
		}
		$('#sortBy').click(showSortOptions)
		$('#markPicked').click(function(){
			showTeamPicker(setTeamPicked, "mark_picked_header")
		})
		$('#viewTeam').click(function(){
			showTeamPicker(showTeamStats, "view_team_header")
		})
		teamList = Object.keys(eventStatsByTeam)
		teamList.forEach(x=>teamsPicked[x]=false)
		parseHash()
		showStats()
		applyTranslations()
	})
	$('#teamStats iframe').attr('src',`/team.html#event=${eventId}`)
	$('#lightBoxBG').click(function(){
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
	$('#startingMatch,#includeReviewRequested').change(function(){
		promiseEventStats($('#startingMatch').val(),$('#includeReviewRequested').is(':checked')).then(value=>{
			[window.eventStats, window.eventStatsByTeam]=value
			showStats()
		})
	})
})

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

function footer(tooltipItems){
	if(!tooltipItems||!tooltipItems.length)return ""
	return getTeamInfo(tooltipItems[0].label)
}

var lastStatsLocale=''
function showStats(){
	if (!window.eventStatsByTeam)return
	graphList = statsConfig.getStatsConfig()
	for (var i=0; i<teamList.length; i++){
		var t = teamList[i]
		teamsPicked[t] = teamsPicked[t]||false
	}
	teamList.sort((a,b)=>{
		if (teamsPicked[a] != teamsPicked[b]) return teamsPicked[b]?-1:1
		if (statInfo[sortStat]?.good??'' == 'low') return getTeamValue(sortStat,a)-getTeamValue(sortStat,b)
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
			downloadBlobs[section]=new Blob([csv], {type: 'text/csv;charset=utf-8'})
			graph.append($('<h2>').append($('<span>').attr('data-i18n', section))
			.append(" ").append($('<button>🛠️</button>').attr('data-section',section).click(statsConfig.showConfigDialog.bind(statsConfig))))
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
							label: (info.type=='avg'&&!boxplot?'Average ':'') + translate(field) + (info.type=='%'?' %':''),
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
						},
						plugins: {
							tooltip: {
								callbacks: {
									footer: footer,
								}
							}
						},
						animation: {
							duration: 0
						},
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
				hr.append($('<th class=borderless>').append($('<h4>').text(section)))
				for (var j=0; j<teamList.length; j++){
					var t = teamList[j],
					picked = teamsPicked[t]
					hr.append($('<th class=team>').text(t).attr('data-tooltip',getTeamInfo(t)).click(showStatClickMenu).toggleClass('picked',picked))
				}
				table.append(hr)
				for (var j=0; j<graphList[section].data.length; j++){
					var field = graphList[section].data[j],
					info = statInfo[field]||{},
					highGood = (info.good||"high")=='high',
					statName = (info.type=='avg'?"Average ":"") + translate(field) + (info.type=='%'?" %":""),
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
						tr.append($('<td>').toggleClass('picked',picked).toggleClass('best',!picked && value==best).attr('data-team',t).attr('data-tooltip',t+" "+getTeamInfo(t)).click(showStatClickMenu).text(Math.round(value)))
					}
					table.append(tr)
				}
			}
		}
	}
	if(locale!=lastStatsLocale){
		lastStatsLocale=locale
		applyTranslations()
	}
}

function getTeamInfo(teamNum){
	var info=eventTeamsInfo[teamNum]
	if (!info)return""
	var name=info.nameShort||""
	if (info.city)name+=`, ${info.city}`
	if (info.stateProv)name+=`, ${info.stateProv}`
	if (info.country)name+=`, ${info.country}`
	return name
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
	if (team){
		var info = getTeamInfo(team)
		if(info)ca.append($('<p>').text(info))
		ca.append($('<p>').append("<span data-i18n=mark_picked_label></span> ").append($('<button>').text(team).click(setTeamPicked)))
		ca.append($('<p>').append("<span data-i18n=view_team_label></span> ").append($('<button>').text(team).click(showTeamStats)))
	}
	if (fields){
		if (typeof fields === 'string') fields = [fields]
		fields.forEach(field=>{
			ca.append($('<p>').append("<span data-i18n=sort_by_label></span> ").append($('<button>').text(translate(field)).attr('data-field',field).click(reSort)))
		})
	}
	applyTranslations(ca)
	showLightBox(ca)
}

function showSortOptions(){
	var picker = $('#sortChooser').html(`<h2 data-i18n=choose_sort_heading></h2>`)
	var allStats = []
	graphList=statsConfig.getStatsConfig()
	Object.keys(graphList).forEach(x=>{
		graphList[x].data.forEach(y=>allStats.push(y))
	})
	allStats.sort((a,b)=>{return translate(a).localeCompare(translate(b))})
	for (var i=0; i<allStats.length; i++){
		var field = allStats[i],
		info = statInfo[field]||{},
		active = sortStat==field?" active":""
		if(!/^(text|enum)$/.test(info.type)) picker.append($(`<button class="sortByBtn${active}">`).attr('data-field',field).attr('data-i18n',translate(field)).click(reSort))
	}
	applyTranslations(picker)
	showLightBox(picker)
}

function showTeamPicker(callback, heading){
	var picker = $('#teamPicker').html($('<h2>').attr('data-i18n',heading))
	teamList.sort((a,b)=>{return a-b})
	for (var i=0; i<teamList.length; i++){
		var team = teamList[i]
		picker.append($('<button class=team>').text(team).addClass(teamsPicked[team]?"picked":"not-picked").click(callback))
	}
	applyTranslations(picker)
	showLightBox(picker)
}

function setTeamPicked(e, team, dnp){
	var y = window.scrollY
	if (!team) team = parseInt($(this).text())
	if (!teamsPicked.hasOwnProperty(team)) return
	teamsPicked[team] = !teamsPicked[team]
	if(teamsPicked[team]){
		var list = (dnp || getLocalTeam() == team)?'#donotpicklist':'#picklist'
		$(list).append($('<li>').attr('id',`pl${team}`).text(team).click(showStatClickMenu).attr('data-tooltip',getTeamInfo(team)||null).addClass('tooltip-before'))
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
	percent = percent || info.type=='%' || info.type=='ratio'
	if (! field in stats) return defaultVal
	var value = stats[field]
	if (heatmap||boxplot) return value||defaultVal
	var divisor = (!/^(total|ratio)$/.test(info.type)&&(percent||"avg"==info.type))?stats.count||1:1
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
