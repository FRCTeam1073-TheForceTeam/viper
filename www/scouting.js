"use strict"

addI18n({
	scouter_page_title:{
		en:'_EVENT_ Scouting Stats',
		fr:'_EVENT_ Statistiques de Repérage',
		zh_tw:'_EVENT_ 偵察統計',
		tr:'_EVENT_ İzcilik İstatistikleri',
		he:'_EVENT_ סטטיסטיקות צופים',
		pt:'_EVENT_ Estatísticas de Scouting',
	},
	difference_heading:{
		en:'Match/Alliance Difference',
		fr:'Différence Match/Alliance',
		zh_tw:'比賽/聯盟差異',
		tr:'Maç/İttifak Farkı',
		he:'התאמה/הפרש ברית',
		pt:'Diferença de Partida/Aliança',
	},
	details_heading:{
		en:'Details',
		fr:'Détails',
		zh_tw:'細節',
		tr:'Ayrıntılar',
		he:'פרטים',
		pt:'Detalhes',
	},
	difference_short_heading:{
		en:'Diff',
		fr:'Différence',
		zh_tw:'差異',
		tr:'Fark',
		he:'הבדל',
		pt:'Diferença',
	},
	api_heading:{
		en:'API',
		fr:'API',
		zh_tw:'應用程式介面',
		tr:'API',
		he:'ממשק API',
		pt:'API',
	},
	scouting_heading:{
		en:'Scouting',
		fr:'Repérage',
		zh_tw:'偵察',
		tr:'İzcilik',
		he:'צוֹפִיוּת',
		pt:'Scouting',
	},
	name_heading:{
		en:'Name',
		fr:'Nom',
		zh_tw:'姓名',
		tr:'Ad',
		he:'שֵׁם',
		pt:'Nome',
	},
	value_heading:{
		en:'Value',
		fr:'Valeur',
		zh_tw:'價值',
		tr:'Değer',
		he:'עֵרֶך',
		pt:'Valor',
	},
	match_alliance:{
		en:'_MATCHTYPE__MATCHNUM_ - _ALLIANCE_',
		fr:'_MATCHTYPE__MATCHNUM_ - _ALLIANCE_',
		zh_tw:'_MATCHTYPE__MATCHNUM_ - _ALLIANCE_',
		tr:'_MATCHTYPE__MATCHNUM_ - _ALLIANCE_',
		he:'_MATCHTYPE__MATCHNUM_ - _ALLIANCE_',
		pt:'_MATCHTYPE__MATCHNUM_ - _ALLIANCE_',
	},
})

addTranslationContext({event:eventName})

$(document).ready(function(){
	promiseScoutScoreCompare().then(values=>{
		var [_, matchStats] = values,
		allianceStats = []
		matchStats.forEach(match=>{
			if (match.Red) allianceStats.push(match.Red)
			if (match.Blue) allianceStats.push(match.Blue)
		})
		allianceStats = allianceStats.sort((a,b)=>b.diff-a.diff)
		allianceStats.forEach(alliance=>{
			var details = $('<table>'),
			dh1 = $('<tr>'),
			dh2 = $('<tr>')
			dh1.append($('<td rowspan=2 data-i18n=difference_short_heading>'))
			dh1.append($('<td colspan=2 data-i18n=api_heading>'))
			dh1.append($('<td colspan=5 data-i18n=scouting_heading>'))
			dh2.append($('<td data-i18n=name_heading>'))
			dh2.append($('<td data-i18n=value_heading>'))
			dh2.append($('<td data-i18n=name_heading>'))
			dh2.append($('<td data-i18n=value_heading>'))
			alliance.teams.forEach((team,i)=>{
				dh2.append($('<td>').append($(`<a target=_blank href="/${eventYear}/scout.html#event=${eventId}&pos=${alliance.alliance.charAt(0)}${i+1}&team=${team}&match=${alliance.match}">`).text(`${team} - ${alliance.scouters[i]}`))
				)
			})
			details.append(dh1).append(dh2)
			alliance.dat.forEach(stat=>{
				var fmsFields = Object.keys(stat.fms),
				scoutFields = Object.keys(stat.scout),
				rowCount = Math.max(fmsFields.length,scoutFields.length)
				var row = $('<tr>')
				row.append($(`<td rowspan=${rowCount}>`).text(stat.diff))
				for(var i=0; i<rowCount; i++){
					if(i>0){
						details.append(row)
						row = $('<tr>')
					}
					if (i>=fmsFields.length){
						row.append("<td>").append("<td>")
					} else {
						row.append($("<td>").text(fmsFields[i]))
						.append($('<td>').text(stat.fms[fmsFields[i]]))
					}
					if (i>=scoutFields.length){
						row.append("<td>").append("<td>").append("<td>").append("<td>").append("<td>")
					} else {
						row.append($("<td>").text(scoutFields[i]))
						.append($('<td>').text(stat.scout[scoutFields[i]].total))
						stat.scout[scoutFields[i]].teams.forEach(team=>{
							row.append($('<td>').text(team.points).addClass(team.review_requested ? 'reviewRequested' : ''))
						})
					}
				}
				details.append(row)
			})
			$('#allianceStats').append(
				$('<tr>')
					.append(
						$('<td>')
						.append($('<span>').attr('data-translate-match-type',getShortMatchNameKey(alliance.match)).attr('data-match-num',getMatchNumber(alliance.match)).attr('data-translate-alliance',alliance.alliance.toLowerCase()+"_heading").attr('data-i18n','match_alliance'))
						.append('<br>')
						.append(`<span class=mainDiff>${alliance.diff}</span>`)
					)
					.append(details)

			)
		})
		applyTranslations()
	})
})
