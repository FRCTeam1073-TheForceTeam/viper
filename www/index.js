"use strict"
addI18n({
	full_season_link:{
		en:'_SEASON_ full season stats',
		tr:'_SEASON_ tam sezon istatistikleri',
		pt:'Estatísticas completas da temporada _SEASON_',
		fr:'Statistiques de la saison complète de _SEASON_',
		zh_tw:'_SEASON_ 完整賽季統計數據',
		he:'_SEASON_ נתונים סטטיסטיים של העונה המלאה',
		es:'Estadísticas de temporada completa de _SEASON_',
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
	season_select_label:{
		en:'Season:',
		pt:'Temporada:',
		fr:'Saison :',
		tr:'Sezon:',
		zh_tw:'賽季：',
		he:'עונה:',
		es:'Temporada:',
	},
	index_h1:{
		en:'Viper — Scouting App',
		pt:'Viper — Scouting App',
		es:'Viper',
		fr:'Viper — Application de repérage',
		tr:'Viper — İzcilik Uygulaması',
		zh_tw:'Viper——偵察應用程式',
		he:'צפע - אפליקציית צופים',
	},
	date_range:{
		en:"_START_ to _END_",
		pt:'_START_ a _END_',
		es:'_START_ a _END_',
		he:'_START_ אל _END_',
		tr:'_START_ ile _END_',
		fr:'_START_ à _END_',
		zh_tw:'_START_ 至 _END_',
	},
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
				var parts = events[i].split(/,/),
				id = parts[0],
				name = parts[1] || id,
				place = (parts[2] || '').trim(),
				endDate = parts[4] || '',
				startDate = parts[7] || '',
				link = $('<a class=card>').attr('href', `/event.html#${id}`),
				start = startDate || endDate,
				end = endDate || startDate
				link.text(unescapeField(name))
				if (place)link.append($('<div class="event-location">').text(unescapeField(place)))
				if (start != end){
					var displayStart = toDisplayDate(start)
					var displayEnd = toDisplayDate(end)
					if (displayStart && displayEnd) {
						link.append($('<div class="event-dates" data-i18n="date_range">').attr('data-start', displayStart).attr('data-end', displayEnd))
					}
				} else if (start) {
					var displayDate = toDisplayDate(start)
					if (displayDate) {
						link.append($('<div class="event-dates">').text(displayDate))
					}
				}
				list.append($('<li>').append(link))
				eventsShown++
			}
		}
		$('#seasonStatsLink').toggle(/20[0-9]{2}(-[0-9]{2})?/.test(filter) && eventsShown > 1).find('a').attr('href',ssHref.replace(/YEAR/,filter))
		var ael = $('#add-event-link')
		ael.attr('href', ael.attr('href').replace(/#.*/,'') + '#' + (/-/.test(filter)?"ftc":"frc"))
		window.scrollTo(0,0)
		translationContext.season=filter
		applyTranslations()
	}
	$(window).on('hashchange', showEvents)
	$('#seasons').change(function(){
		var season = $('#seasons').val()
		if (/^[0-9]{4}(-[0-9]{2})?$/.test(season)){
			location.hash = `#${season}`
		}
	})
})

function unescapeField(s){
	return s
		.replace(/⏎/g, "\n")
		.replace(/״/g, "\"")
		.replace(/،/g, ",")
}

function toDisplayDate(d){
	if (!d) return ""
	try {
		var b = d.split(/\D/),
		date = new Date(b[0], b[1]-1, b[2]),
		locale=translate('date_locale')
		if(!/^[a-z]{2}-[A-Z]{2}/.test(locale))locale='en-US'
		return new Intl.DateTimeFormat(locale,{dateStyle:'full'}).format(date)
	} catch (x){
		return ""
	}
}
