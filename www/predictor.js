"use strict"

addI18n({
	predictor_title:{
		en:'Match Predictor for _EVENT_',
		tr:'Previsor de Partida para _EVENT_',
		he:'מנבא התאמה עבור _EVENT_',
		zh_tw:'_EVENT_ 的匹配預測器',
		pt:'Previsor de Partida para _EVENT_',
		fr:'Prédicteur de match pour _EVENT_',
	},
	predictor_match_title:{
		en:'_MATCH_ Match Predictor for _EVENT_',
		tr:'_MATCH_ Previsor de Partida para _EVENT_',
		he:'_MATCH_ מנבא התאמה עבור _EVENT_',
		zh_tw:'_MATCH_ _EVENT_ 的比賽預測器',
		pt:'_MATCH_ Previsor de Partida para _EVENT_',
		fr:'_MATCH_ Prédicteur de match pour _EVENT_',
	},
	change_teams_button:{
		en:'Change Teams',
		tr:'Alterar Equipes',
		he:'שנה צוותים',
		zh_tw:'更換團隊',
		pt:'Alterar Equipes',
		fr:'Changer d\'équipe',
	},
})

onApplyTranslation.push(function(){
	addTranslationContext({
		event:eventName,
		match:getShortMatchName(match),
	})
})

function lf(){
	return $('#prediction .lastFocus')
}

var statsConfig = new StatsConfig({
	statsConfigKey:`${eventYear}PredictorStats`,
	getStatsConfig:function(){
		var conf = statsConfig.getLocalStatsConfig()
		if (!conf && window.myTeamsStats && window.myTeamsStats.length)conf=window.myTeamsStats
		if (!conf && window.matchPredictorSections)conf=window.matchPredictorSections
		conf==conf||{}
		Object.entries(conf).forEach(([k,v])=>{
			if(Array.isArray(v)){
				conf[k]={}
				conf[k].data=v
			}
		})
		return conf
	},
	drawFunction:setPickedTeams,
	fileName:"predictor",
	defaultConfig:window.matchPredictorSections,
	mode:"aggregate",
	hasSections:true,
})

$(document).ready(function(){
	Promise.all([
		promiseEventMatches(),
		promiseEventStats(),
		fetch(`/data/${eventYear}/predictor.json`).then(response=>{if(response.ok)return response.json()})
	]).then(values =>{
		[window.eventMatches, [{}, window.eventStatsByTeam, {}], window.myTeamsStats] = values
		var teamList = Object.keys(eventStatsByTeam)
		teamList.sort((a,b) => a-b)
		for (var i=0; i<teamList.length; i++){
			var team = teamList[i]
			$('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
		}
		$('#matchList').append($('<option selected=1>')).change(function(){
			$(this).val().split(",").forEach((bot,i)=>{
				$(`#${BOT_POSITIONS[i]}`).val(bot)
			})
			setPickedTeams()
		})
		window.eventMatches.forEach(match=>{
			$('#matchList').append($('<option>').text(getMatchName(match.Match)).attr('value',BOT_POSITIONS.map(pos=>match[pos]).join(",")))
		})
		loadFromLocationHash()
		$(window).on('hashchange', loadFromLocationHash)
		if (match) $('title,h1').attr('data-i18n','predictor_match_title')
		applyTranslations()
	})
	$('#prediction input').focus(focusInput).change(setPickedTeams)
	if (eventCompetition=='ftc') $('.noftc').hide()
	$('#change-teams').click(function(){
		$('#prediction input').val("")
		setPickedTeams()
	})
})

function focusInput(input){
	if ('target' in input) input = $(input.target)
	if (input[0]==lf()[0]) return
	$('#prediction input').removeClass('lastFocus')
	input.addClass('lastFocus')
}

function lf(){
	return $('#prediction input.lastFocus')
}

function withoutValues(i,el){
	return $(el).val() == ''
}

function focusNext(){
	var next = $('#prediction .redTeamBG input').filter(withoutValues).first()
	if (!next.length) next = $('#prediction .blueTeamBG input').filter(withoutValues).first()
	if (next.length) focusInput(next)
	return next.length > 0
}

function setPickedTeams(){
	$('#teamButtons button').removeClass("picked")
	var teamCount = 0
	$('#prediction input').each(function(){
		var val = $(this).val()
		if (val){
			$(`#team-${val}`).addClass("picked")
			teamCount++
		}
	})
	if (teamCount == BOT_POSITIONS.length){
		$('#change-teams').show()
		$('input').removeClass('lastFocus')
		$('.teamDataEntry').hide()
		var table = $('#prediction tbody'),
		stats = statsConfig.getStatsConfig(),
		first=true
		table.html("")
		Object.keys(stats).forEach(function(section){
			table.append(
				$('<tr>').append(
					$(`<th colspan=${BOT_POSITIONS.length+3}>`)
					.append(
						$('<h4>').append($('<span>').attr('data-i18n',section))
						.append(" ").append($(' <button>🛠️</button>').attr('data-section',section).click(statsConfig.showConfigDialog.bind(statsConfig)))
					)
				)
			)
			stats[section].data.forEach(function(field){
				statInfo[field] = statInfo[field]||{}
				var statName = statInfo[field]['name']||field,
				statType = statInfo[field]['type']||""
				if (statType=='avg'){
					var teamNumbers = [],
					teamScores = [],
					allianceScores = [0,0]
					BOT_POSITIONS.forEach(function(pos, i){
						teamNumbers[i]=parseInt($(`#${pos}`).val())
						teamScores[i]=getTeamValue(window.eventStatsByTeam, field,teamNumbers[i])
						allianceScores[Math.floor(i/(BOT_POSITIONS.length/2))]+=teamScores[i]
					})
					teamScores=teamScores.map(Math.round)
					allianceScores=allianceScores.map(Math.round)
					var compare=statInfo[field].good=='low'?Math.min:Math.max,
					teamBest=compare(...teamScores),
					allianceBest=compare(...allianceScores),
					tr=$('<tr>').addClass(first?"first":"")
					BOT_POSITIONS.forEach(function(pos, i){
						tr.append($('<td>').addClass(i<(BOT_POSITIONS.length/2)?'redTeamBG':'blueTeamBG').append($('<div>').text(teamScores[i]).addClass(teamScores[i]==teamBest?"winner":"")))
						if(i==(BOT_POSITIONS.length/2-1)){
							tr.append($('<td>').addClass('redTeamBG').addClass('alliance').append($('<div>').text(allianceScores[0]).addClass(allianceScores[0]==allianceBest?("winner"):"")))
							tr.append($('<td>').append($('<div>').attr('data-i18n',field)))
							tr.append($('<td>').addClass('blueTeamBG').addClass('alliance').append($('<div>').text(allianceScores[1]).addClass(allianceScores[1]==allianceBest?"winner":"")))
						}
					})
					table.append(tr)
					first=false
				}
			})
		})
	} else {
		$('.teamDataEntry').show()
		$('#prediction tbody').html("")
		$('#change-teams').hide()
	}
	setLocationHash()
	applyTranslations()
}

var match = ""

function setLocationHash(){
	var hash = `event=${eventId}`
	if (match) hash += `&match=${match}`
	$('#prediction input').each(function(){
		var val = $(this).val()
		if (/^[0-9]+$/.test(val)){
			var name = $(this).attr('id')
			hash += `&${name}=${val}`
		}
	})
	location.hash = hash
}

function loadFromLocationHash(){
	match = (location.hash.match(/^\#(?:.*\&)?(?:match\=)([a-z0-9]+)(?:\&.*)?$/)||["",""])[1]
	$('#prediction input').each(function(){
		var name = $(this).attr('id')
		var val = (location.hash.match(new RegExp(`^\\#(?:.*\\&)?(?:${name}\\=)([0-9]+)(?:\\&.*)?$`))||["",""])[1]
		$(this).val(val)
	})
	setPickedTeams()
	focusNext()
}

function getTeamValue(eventStatsByTeam, field, team){
	if (! team in eventStatsByTeam) return 0
	var stats = eventStatsByTeam[team]
	if (! stats || ! field in stats ||! 'count' in stats || !stats['count']) return 0
	return (stats[field]||0) / stats['count']
}

function teamButtonClicked(){
	lf().val($(this).text())
	focusNext()
	setPickedTeams()
}
