"use strict"

var scouterStats = {}
var matchStats = []

$(document).ready(function(){
	loadScoutScoreCompare(showScouters)
})

function showScouters(){
	$('h1').text($('h1').text().replace(/EVENT/,eventName))
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
}
