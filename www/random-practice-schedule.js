"use strict"

function randomPracticeSchedule(teams){
	if (!teams || !teams.length) return ""
	var match=0,
	matchTeams=0,
	csv="Match,"+BOT_POSITIONS.join(",")
	teams = shuffleArray([...new Set(teams)])
	teams.forEach(function(team){
		if (matchTeams >= BOT_POSITIONS.length) matchTeams = 0
		if (matchTeams == 0){
			match++
			csv+="\npm"+match
		}
		csv+=","+team
		matchTeams++
	})
	while (matchTeams < BOT_POSITIONS.length){
		teams = shuffleArray(teams)
		csv+=","+teams[0]
		matchTeams++
	}
	csv+="\n"
	return csv
}

// https://stackoverflow.com/a/46545530
function shuffleArray(array){
	return array.map(value => ({value, sort: Math.random()}))
	.sort((a, b) => a.sort - b.sort)
	.map(({value}) => value)
}
