"use strict"

addI18n({
	api_events_title:{
		en:'FIRST API Event List',
		he:'רשימת אירועי API ראשונה',
		pt:'Lista de eventos da FIRST API',
		tr:'İLK API Etkinlik Listesi',
		zh_tw:'FIRST API 事件列表',
		fr:'Liste des événements API FIRST',
	},
	api_events_instruction:{
		en:'Click on an event to download the official data for it.',
		he:'לחץ על אירוע כדי להוריד את הנתונים הרשמיים עבורו.',
		pt:'Clique em um evento para baixar os dados oficiais dele.',
		tr:'Resmi verilerini indirmek için bir etkinliğe tıklayın.',
		zh_tw:'點擊某個事件即可下載該事件的官方資料。',
		fr:'Cliquez sur un événement pour télécharger ses données officielles.',
	},
	api_events_refresh_link:{
		en:'Refresh event list',
		he:'רענן את רשימת האירועים',
		pt:'Atualizar lista de eventos',
		tr:'Etkinlik listesini yenile',
		zh_tw:'刷新事件列表',
		fr:'Actualiser la liste des événements',
	},
	season_label:{
		en:'Season:',
		he:'עוֹנָה:',
		pt:'Temporada:',
		tr:'Sezon:',
		zh_tw:'季節：',
		fr:'Saison :',
	},
	filter_label:{
		en:'Show:',
		he:'לְהַצִיג:',
		pt:'Mostrar:',
		tr:'Göster:',
		zh_tw:'展示：',
		fr:'Afficher :',
	},
	filter_all:{
		en:'All',
		he:'כֹּל',
		pt:'Todos',
		tr:'Tümü',
		zh_tw:'全部',
		fr:'Tous',
	},
	filter_upcoming:{
		en:'Upcoming',
		he:'בקרוב',
		pt:'Próximos',
		tr:'Yaklaşan',
		zh_tw:'即將推出',
		fr:'À venir',
	},
	cached_heading:{
		en:'Cached API Data Found',
		he:'נמצאו נתוני API שמורים',
		pt:'Dados da API em cache encontrados',
		tr:'Önbelleğe Alınan API Verileri Bulundu',
		zh_tw:'找到快取的 API 數據',
		fr:'Données API en cache trouvées',
	},
	cache_create_link:{
		en:'Create event from cached data',
		he:'צור אירוע מנתונים שמורים',
		pt:'Criar evento a partir de dados em cache',
		tr:'Önbelleğe alınan verilerden etkinlik oluştur',
		zh_tw:'根據快取資料建立事件',
		fr:'Créer un événement à partir des données en cache',
	},
	cached_refresh_link:{
		en:'Fetch latest from API first',
		he:'תחילה אחזר את העדכניים ביותר מ-API',
		pt:'Obter o mais recente da API primeiro',
		tr:'Önce API\'den son haberleri al',
		zh_tw:'首先從 API 取得最新內容',
		fr:'Récupérer les dernières données de l\'API en premier',
	},
})

var season=(location.hash.match(/^\#(?:(?:.*\&)?(?:(?:season)\=))?(20[0-9]{2}(?:-[0-9]{2})?)(?:\&.*)?$/)||["",""])[1]
var comp = /-/.test(season)?"ftc":"frc"
var eventFilters

$(document).ready(function(){
	if (!season) season = "" + new Date().getFullYear()
	var seasonSelect = $('#season')
	for (var y=new Date().getFullYear(); y>=2019; y--){
		if (y >= 2024 && (y<new Date().getFullYear() || new Date().getMonth()>=8)){
			var v = y+"-"+(y+1+"").slice(-2)
			seasonSelect.append($("<option>").attr('value',v).text(v + " FTC"))
		}
		seasonSelect.append($("<option>").attr('value',y).text(y + " FRC"))
	}
	seasonSelect.val(season)
	seasonSelect.change(function(){
		season=seasonSelect.val()
		comp = /-/.test(season)?"ftc":"frc"
		location.hash=season
		showSeason(season, comp)
	})
	showSeason(season, comp)
	$('#filter').change(function(){
		showEvents(eventFilters[$(this).val()])
	})
})

function showSeason(season, comp){
	$('#events').html("")
	eventFilters={
		all:[],
		upcoming:[]
	}
	$('a').each(function(){
		$(this).attr('href', $(this).attr('href').replace(/COMP|ftc|frc/g,comp).replace(/SEASON|YEAR|(20[0-9]{2}(-[0-9]{2})?)/g,season))
	})
	$.ajaxSetup({
		cache: false
	})
	$.getJSON(`/data/${season}.events.json`, function(json){
		var events = (json.Events||json.events).sort((a,b)=>a.dateStart.localeCompare(b.dateStart))
		events.forEach(function(event){
			eventFilters.all.push(event)
			if (new Date().toISOString()<event.dateEnd) eventFilters.upcoming.push(event)
		})
		var toShow = eventFilters.all
		if (eventFilters.upcoming.length){
			toShow=eventFilters.upcoming
			$('#filter').val('upcoming')
		} else {
			$('#filter').val('all')
		}
		showEvents(toShow)
	}).fail(function(){
		location.href=`/admin/${comp}-api-season.cgi?season=${season}`
	})
}

function clickOnEvent(){
	var href = $(this).attr('href'),
	eventId = href.replace(/^.*[\?\&]event=([^\&]+).*$/, "$1").toLowerCase()
	Promise.all([
		fetch(`/data/${eventId}.teams.json`),
		fetch(`/data/${eventId}.schedule.csv`)
	]).then(responses=>{
		var [teams, schedule] = responses
		if (!teams.ok) return location.href=href
		$('#fetchLink').attr('href', href)
		$('#importLink').attr('href',schedule.ok?`/event-downloaded.html#event=${eventId}`:`/import-api-event.html#event=${eventId}`)
		showLightBox($('#importOptions'))
	}).catch(()=>{
		location.href=href
	})
	return false
}

function showEvents(events){
	var div = $('#events').html("")
	events.forEach(function(event){
		$(div)
		.append($('<h2>').append($(`<a href="/admin/${comp}-api-event.cgi?event=${season}${event.code}">`).click(clickOnEvent).text(event.name)))
		.append($('<span>').text(toDisplayDate(event.dateStart))).append("<br>")
		.append($('<span>').text(event.venue)).append("<br>")
		.append($('<span>').text(event.address)).append("<br>")
		.append($('<span>').text(`${event.city}, ${event.stateprov}, ${event.country}`))
	})
}

function toDisplayDate(d){
	if (!d) return ""
	try {
		var b = d.split(/\D/)
		var date = new Date(b[0], b[1]-1, b[2])
		return new Intl.DateTimeFormat('en-US', {dateStyle: 'full'}).format(date)
	} catch (x){
		console.error("Could not parse",d,x)
		return ""
	}
}
