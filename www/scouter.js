"use strict"

addI18n({
	scouter_page_title:{
		en:'_EVENT_ Scouters',
		pt:'_EVENT_ Scouters',
		he:'_EVENT_ צופים',
		tr:'_EVENT_ Scouters',
		zh_tw:'_EVENT_偵察員',
		fr:'_EVENT_ Animateurs',
	},
	scouter_heading:{
		en:'Scouter',
		pt:'Scouter',
		he:'צופית',
		tr:'Scouter',
		zh_tw:'偵查員',
		fr:'Animateur',
	},
	matches_heading:{
		en:'Matches',
		pt:'Partidas',
		he:'גפרורים',
		tr:'Maçlar',
		zh_tw:'火柴',
		fr:'Matchs',
	},
	error_heading:{
		en:'Average Error',
		pt:'Erro médio',
		he:'שגיאה ממוצעת',
		tr:'Ortalama Hata',
		zh_tw:'平均誤差',
		fr:'Erreur moyenne',
	},
})

addTranslationContext({event:eventName})

$(document).ready(function(){
	showScouters()
})

function showScouters(){
	promiseScoutScoreCompare().then(values=>{
		var [scouterStats, matchStats] = values
		var table = $('#scouterStats').html("")
		Object.keys(scouterStats).sort((a,b)=>scouterStats[b].matches-scouterStats[a].matches).forEach(key=>{
			var s = scouterStats[key]
			table.append(
				$('<tr>')
				.append($('<td>').text(s.name))
				.append($('<td>').text(s.matches))
				.append($('<td>').text(s.avgError))
			)
		})
	})
}
