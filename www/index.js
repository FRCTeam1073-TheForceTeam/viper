"use strict"
addI18n({
	full_season_link:{
		en:'_YEAR_ full season stats',
		tr:'_YEAR_ tam sezon istatistikleri',
		pt:'Estatísticas completas da temporada _YEAR_',
		fr:'Statistiques de la saison complète de _YEAR_',
		zh_tw:'_YEAR_ 完整賽季統計數據',
		he:'_YEAR_ נתונים סטטיסטיים של העונה המלאה',
		es:'Estadísticas de temporada completa de _YEAR_',
	},
	add_event_button:{
		en:'+ Add an event',
		pt:'+ Adicionar um evento',
		fr:'+ Ajouter un événement',
		tr:'+ Bir etkinlik ekle',
		zh_tw:'+ 新增活動',
		he:'+ הוסף אירוע',
		es:'+ Añadir un evento',
	},
	choose_season_option:{
		en:'Choose season…',
		pt:'Escolha a temporada…',
		es:'Elige una temporada',
		fr:'Choisir la saison…',
		tr:'Sezonu seç...',
		zh_tw:'選擇季節…',
		he:'בחר עונה…',
	},
	index_h1:{
		en:'Viper — Scouting App',
		pt:'Viper — Scouting App',
		es:'Viper',
		fr:'Viper — Application de repérage',
		tr:'Viper — İzcilik Uygulaması',
		zh_tw:'Viper——偵察應用程式',
		he:'צפע - אפליקציית צופים',
	}
})
var ssHref
$(document).ready(function(){
	var events = []
	ssHref=$('#seasonStatsLink a').attr('href')

	fetch("/event-list.cgi").then(response=>{
		return response.text()
	}).then(data=>{
		events = data.split(/[\r\n]/)
		var seasons = {}
		for (var i=0; i<events.length; i++){
			var m = events[i].match(/^[0-9]{4}(-[0-9]{2})?/)
			if(m) seasons[m[0]] = 1
		}
		seasons = Object.keys(seasons)
		seasons.sort((a,b) => {return b.localeCompare(a)})
		var hasFrc = false, hasFtc = false,
		latestFrc = new Date().getFullYear(),
		latestFtc = new Date().getMonth() >= 9 ? new Date().getFullYear() + "-"+(new Date().getFullYear()+1).toString().slice(2) : (new Date().getFullYear()-1) + "-"+(new Date().getFullYear()).toString().slice(2)
		var recentSeason = ''
		for (var i=0; i<seasons.length; i++){
			var season = seasons[i],
			comp = /-/.test(season)?"FTC":"FRC"
			if(!recentSeason) recentSeason = season
			if (comp == "FRC") hasFrc = true
			else hasFtc = true
			if (season == latestFrc) latestFrc = ''
			if (season == latestFtc) latestFtc = ''
			$('#seasons').append($(`<option value=${season}>${season} ${comp}</option>`))
		}
		var firstOption = $('#seasons option:first')
		if (hasFrc && latestFrc) {
			firstOption.after($(`<option value=${latestFrc}>${latestFrc} FRC</option>`))
		}
		if (hasFtc && latestFtc) {
			firstOption.after($(`<option value=${latestFtc}>${latestFtc} FTC</option>`))
		}
		$('#seasons').toggle(seasons.length > 1)
		events = events.sort(dateCompare)
		showEvents(recentSeason)
	})
	function showEvents(recentSeason){
		var list = $('#events-list')
		list.html('');
		var filter = location.hash.replace(/^\#/,""),
		eventsShown = 0
		if (!filter) filter = recentSeason
		for (var i=0; i<events.length; i++){
			var season = ((events[i].match(/^[0-9]{4}(-[0-9]{2})?/))||[""])[0]
			if (season && season == filter){
				var [id, name] = events[i].split(/,/)
				if (!name) name = id
				list.append($(`<li><a href=/event.html#${id}>${unescapeField(name)}</a></li>`))
				eventsShown++
			}
		}
		$('#seasonStatsLink').toggle(/20[0-9]{2}(-[0-9]{2})?/.test(filter) && eventsShown > 1).find('a').attr('href',ssHref.replace(/YEAR/,filter))
		var ael = $('#add-event-link')
		ael.attr('href', ael.attr('href').replace(/#.*/,'') + '#' + (/-/.test(filter)?"ftc":"frc"))
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

function unescapeField(s){
	return s
		.replace(/⏎/g, "\n")
		.replace(/״/g, "\"")
		.replace(/،/g, ",")
}
