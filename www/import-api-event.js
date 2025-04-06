"use strict"

addI18n({
	import_api_event_title:{
		en:'Import API Event',
		fr:'Importation d\'un événement API',
		zh_tw:'導入API事件',
		tr:'API Etkinliğini İçe Aktar',
		he:'אירוע ייבוא ​​API',
		pt:'Importar evento da API',
	},
	import_api_event_heading:{
		en:'Importing API Event',
		fr:'Importation d\'un événement API',
		zh_tw:'導入API事件',
		tr:'API Etkinliğini İçe Aktarma',
		he:'ייבוא ​​אירוע API',
		pt:'Importando evento da API',
	},
	event_name_heading:{
		en:'Event name',
		fr:'Nom de l\'événement',
		zh_tw:'活動名稱',
		tr:'Etkinlik adı',
		he:'שם האירוע',
		pt:'Nome do evento',
	},
	dates_heading:{
		en:'Dates',
		fr:'Dates',
		zh_tw:'棗子',
		tr:'Tarihler',
		he:'תאריכים',
		pt:'Datas',
	},
	location_heading:{
		en:'Location',
		fr:'Lieu',
		zh_tw:'地點',
		tr:'Konum',
		he:'מִקוּם',
		pt:'Localização',
	},
	event_id_heading:{
		en:'Event ID',
		fr:'ID de l\'événement',
		zh_tw:'事件ID',
		tr:'Etkinlik kimliği',
		he:'מזהה אירוע',
		pt:'ID do evento',
	},
	schedule_heading:{
		en:'Schedule',
		fr:'Calendrier',
		zh_tw:'行程',
		tr:'Program',
		he:'לוּחַ זְמַנִים',
		pt:'Programação',
	},
	no_event_heading:{
		en:'No event specified',
		fr:'Aucun événement spécifié',
		zh_tw:'沒有指定事件',
		tr:'Belirtilen bir etkinlik yok',
		he:'לא צוין אירוע',
		pt:'Nenhum evento especificado',
	},
})

var backForward = false

window.addEventListener('pageshow', function (event){
	backForward = event.persisted || performance.getEntriesByType("navigation")[0].type === 'back_forward'
})

function fetchJson(url){
	return fetch(url,{cache:'reload'}).then(x=>x.ok?x.json():{})
}

$(document).ready(function(){
	if (!eventId){
		$('body').prepend("<h1 data-i18n=no_event_heading></h1>")
		return
	}
	Promise.all([
		fetchJson(`/data/${eventId}.info.json`),
		fetchJson(`/data/${eventId}.schedule.practice.json`),
		fetchJson(`/data/${eventId}.schedule.qualification.json`),
		fetchJson(`/data/${eventId}.schedule.playoff.json`),
		fetchJson(`/data/${eventId}.teams.json`)
	]).then(values => {
		var [info,practice,qual,playoffs,teamsJson] = values,
		csv = ""
		info.Events = info.Events||info.events||[]
		if (info.Events.length){
			var ev = info.Events[0]
			$('#nameInp').val(ev.name)
			$('#locationInp').val(`${ev.venue} in ${ev.city}, ${ev.stateprov}, ${ev.country}`)
			$('#startInp').val(ev.dateStart.slice(0,10))
			$('#endInp').val(ev.dateEnd.slice(0,10))
		}
		$('#importData').toggle(backForward)
		$('#idInp').val(eventId)

		practice = practice||{}
		practice.Schedule = practice.Schedule||practice.schedule||[]
		practice.Schedule.forEach(function(match){
			csv+="pm"+match.matchNumber
			match.teams.forEach(function(team){
				csv+=","+(team.teamNumber||0)
			})
			csv+="\n"
		})
		qual = qual||{}
		qual.Schedule = qual.Schedule||qual.schedule||[]
		qual.Schedule.forEach(function(match){
			csv+="qm"+match.matchNumber
			match.teams.forEach(function(team){
				csv+=","+(team.teamNumber||0)
			})
			csv+="\n"
		})
		playoffs = playoffs||{}
		playoffs.Schedule = playoffs.Schedule||playoffs.schedule||[]
		var lastRound=0,roundMatch=0
		playoffs.Schedule.forEach(function(match){
			var round=(match.description.match(/\(R([0-9])\)/)||["",""])[1]
			if(round)round=round+"p"
			if(!round && /^quarterfinal/i.test(match.description))round="qf"
			if(!round && /^semifinal/i.test(match.description))round="sf"
			if(!round && /^final/i.test(match.description))round="f"
			if(round){
				if(round!=lastRound)roundMatch=0
				roundMatch++
				csv+=round+roundMatch
				match.teams.forEach(function(team){
					csv+=","+(team.teamNumber||0)
				})
				csv+="\n"
				lastRound=round
			}
		})
		if (csv.length){
			csv = "Match," + BOT_POSITIONS.join(",") + "\n" + csv
			$('#csvInp').val(csv)
			if (!backForward) $('#importData').submit()
			return
		}
		var teams = []
		if (teamsJson.teams){
			teamsJson.teams.forEach(function(team){
				teams.push(team.teamNumber)
			})
			$('#csvInp').val(randomPracticeSchedule(teams))
			if (!backForward) $('#importData').submit()
		} else if (teamsJson.pageTotal){
			Promise.all(
				Array.from({length: teamsJson.pageTotal}, (_,i) => fetchJson(`/data/${eventId}.teams.${i+1}.json`))
			).then(function(results){
				results.forEach(teamsJson=>{
					teamsJson.teams.forEach(function(team){
						teams.push(team.teamNumber)
					})
				})
				$('#csvInp').val(randomPracticeSchedule(teams))
				if (!backForward) $('#importData').submit()
			})
		}
	})
})
