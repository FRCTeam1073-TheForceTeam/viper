function randomPracticeSchedule(teams){
	if (!teams || !teams.length) return ""
	var match=0,
	matchTeams=0,
	csv="Match,R1,R2,R3,B1,B2,B3"
	teams = shuffleArray([...new Set(teams)])
	teams.forEach(function(team){
		if (matchTeams >= 6) matchTeams = 0
		if (matchTeams == 0){
			match++
			csv+="\npm"+match
		}
		csv+=","+team
		matchTeams++
	})
	while (matchTeams < 6){
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
