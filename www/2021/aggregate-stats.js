"use strict"

function addStat(map,field,value){
	if(/^(\%|avg)$/.test(statInfo[field]['type'])) map[field] = (map[field]||0)+(value||0)
}

var endGamePoints=[0,3,6,12]
function aggregateStats(scout, aggregate){

	scout["auto_line_score"] = (scout["auto_line"]||0)*5
	scout["auto_bottom_score"] = (scout["auto_bottom"]||0)*2
	scout["auto_outer_score"] = (scout["auto_outer"]||0)*4
	scout["auto_inner_score"] = (scout["auto_inner"]||0)*6
	scout["auto_score"] = scout["auto_line_score"] + scout["auto_bottom_score"] + scout["auto_outer_score"] + scout["auto_inner_score"]

	scout["teleop_bottom_score"] = scout["teleop_bottom"]||0
	scout["teleop_outer_score"] = (scout["auto_line"]||0)*2
	scout["teleop_inner_score"] = (scout["teleop_inner"]||0)*3
	scout["teleop_score"] = scout["teleop_bottom_score"] + scout["teleop_outer_score"] + scout["teleop_inner_score"]

	scout["rotation_control_score"] = (scout["rotation_control"]||0)*10
	scout["position_control_score"] = (scout["position_control"]||0)*20
	scout["control_score"] = scout["rotation_control_score"] + scout["position_control_score"]

	scout["parked_score"] = (scout["parked"]||0)*5
	scout["climbed_score"] = (scout["climbed"]||0)*25
	scout["leveled_score"] = (scout["leveled"]||0)*15
	scout["endgame_score"] = scout["parked_score"] + scout["climbed_score"] + scout["leveled_score"]

	scout["score"] = scout["auto_score"] + scout["teleop_score"] + scout["control_score"] + scout["endgame_score"]

	scout[statInfo["defense"]["breakout"][scout["defense"]||0]] = 1
	scout[statInfo["defended"]["breakout"][scout["defended"]||0]] = 1
	scout[statInfo["rank"]["breakout"][scout["rank"]||0]] = 1

	if (scout["comments"] && /\%[0-9a-fA-F]{2}/.test(scout["comments"])) scout["comments"] = decodeURIComponent(scout["comments"])
	if (scout["comments"] && /^(none|(n\/a))$/i.test(scout["comments"])) scout["comments"] = ""
	if (scout["scouter"] && "unknown" == scout["scouter"]) scout["scouter"] = ""

	aggregate["count"] = (aggregate["count"]||0)+1

	var sumFields = Object.keys(statInfo)
	for (var i=0; i<sumFields.length; i++){
		var field = sumFields[i]
		addStat(aggregate,field,scout[field])
	}
	aggregate["max_score"] = (aggregate["max_score"]||0)<scout["score"]?scout["score"]:(aggregate["max_score"]||0)
	aggregate["min_score"] = (aggregate["min_score"]||999)>scout["score"]?scout["score"]:(aggregate["min_score"]||999)
}

var statInfo = {
	"match": {
		name: "Match",
		type: "text"
	},
	"score": {
		name: "Score Contribution",
		type: "avg"
	},
	"max_score": {
		name: "Maximum Score Contribution",
		type: "minmax"
	},
	"min_score": {
		name: "Minimum Score Contribution",
		type: "minmax"
	},
	"count": {
		name: "Number of Matches",
		type: "count"
	},
	"auto_line": {
		name: "Move from initial position during auto",
		type: "avg"
	},
	"auto_line_score": {
		name: "Points for move from initial position during auto",
		type: "avg"
	},
	"auto_bottom": {
		name: "Bottom port goals during auto",
		type: "avg"
	},
	"auto_bottom_score": {
		name: "Points for bottom port goals during auto",
		type: "avg"
	},
	"auto_outer": {
		name: "Outer port goals during auto",
		type: "avg"
	},
	"auto_outer_score": {
		name: "Points for outer port goals during auto",
		type: "avg"
	},
	"auto_inner": {
		name: "Inner port goals during auto",
		type: "avg"
	},
	"auto_inner_score": {
		name: "Points for inner port goals during auto",
		type: "avg"
	},
	"auto_score": {
		name: "Points during auto",
		type: "avg"
	},
	"teleop_bottom": {
		name: "Bottom port goals during remote control",
		type: "avg"
	},
	"teleop_bottom_score": {
		name: "Points for bottom port goals during remote control",
		type: "avg"
	},
	"teleop_outer": {
		name: "Outer port goals during remote control",
		type: "avg"
	},
	"teleop_outer_score": {
		name: "Points for outer port goals during remote control",
		type: "avg"
	},
	"teleop_inner": {
		name: "Inner port goals during remote control",
		type: "avg"
	},
	"teleop_inner_score": {
		name: "Points for inner port goals during remote control",
		type: "avg"
	},
	"teleop_score": {
		name: "Points during remote control",
		type: "avg"
	},
	"auto_missed": {
		name: "Shots missed during auto",
		type: "avg",
		good: "low"
	},
	"teleop_missed": {
		name: "Shots missed during remote control",
		type: "avg",
		good: "low"
	},
	"shotlocA2": {
		name: "Shot from location A2",
		type: "%"
	},
	"shotlocA3": {
		name: "Shot from location A3",
		type: "%"
	},
	"shotlocA4": {
		name: "Shot from location A4",
		type: "%"
	},
	"shotlocA5": {
		name: "Shot from location A5",
		type: "%"
	},
	"shotlocB1": {
		name: "Shot from location B1",
		type: "%"
	},
	"shotlocB2": {
		name: "Shot from location B2",
		type: "%"
	},
	"shotlocB3": {
		name: "Shot from location B3",
		type: "%"
	},
	"shotlocB4": {
		name: "Shot from location B4",
		type: "%"
	},
	"shotlocB5": {
		name: "Shot from location B5",
		type: "%"
	},
	"shotlocC1": {
		name: "Shot from location C1",
		type: "%"
	},
	"shotlocC2": {
		name: "Shot from location C2",
		type: "%"
	},
	"shotlocC3": {
		name: "Shot from location C3",
		type: "%"
	},
	"shotlocC4": {
		name: "Shot from location C4",
		type: "%"
	},
	"shotlocC5": {
		name: "Shot from location C5",
		type: "%"
	},
	"shotlocD1": {
		name: "Shot from location D1",
		type: "%"
	},
	"shotlocD2": {
		name: "Shot from location D2",
		type: "%"
	},
	"shotlocD3": {
		name: "Shot from location D3",
		type: "%"
	},
	"shotlocD4": {
		name: "Shot from location D4",
		type: "%"
	},
	"shotlocD5": {
		name: "Shot from location D5",
		type: "%"
	},
	"shotlocE1": {
		name: "Shot from location E1",
		type: "%"
	},
	"shotlocE2": {
		name: "Shot from location E2",
		type: "%"
	},
	"shotlocE3": {
		name: "Shot from location E3",
		type: "%"
	},
	"shotlocE4": {
		name: "Shot from location E4",
		type: "%"
	},
	"shotlocE5": {
		name: "Shot from location E5",
		type: "%"
	},
	"rotation_control": {
		name: "Rotation control",
		type: "%"
	},
	"rotation_control_score": {
		name: "Points for rotation control",
		type: "avg"
	},
	"position_control": {
		name: "Position control",
		type: "%"
	},
	"position_control_score": {
		name: "Points for position control",
		type: "avg"
	},
	"control_score": {
		name: "Points for control",
		type: "avg"
	},
	"parked": {
		name: "Parked",
		type: "%"
	},
	"parked_score": {
		name: "Points for parking",
		type: "avg"
	},
	"climbed": {
		name: "Climbed",
		type: "%"
	},
	"climbed_score": {
		name: "Points for climbing",
		type: "avg"
	},
	"bar_position": {
		name: "Climbed when the bar was",
		type: "enum",
		values: ["","Low","Level","High"]
	},
	"buddylift": {
		name: "Lifted others",
		type: "%"
	},
	"leveled": {
		name: "Controlled leveling",
		type: "%"
	},
	"leveled_score": {
		name: "Points for leveling bar",
		type: "avg"
	},
	"endgame_score": {
		name: "Points for end game",
		type: "avg"
	},
	"defense":{
		name: "Played defense",
		type: "enum",
		values:["","Bad","OK","Great"],
		breakout:["defense_none","defense_bad","defense_ok","defense_great"]
	},
	"defense_none": {
		name: "Didn't defend",
		type: "%"
	},
	"defense_bad": {
		name: "Below Average Defense",
		type: "%"
	},
	"defense_ok": {
		name: "Average Defense",
		type: "%"
	},
	"defense_great": {
		name: "Good Defense",
		type: "%"
	},
	"defended":{
		name: "Good against defense",
		type: "enum",
		values:["","Affected","OK","Great"],
		breakout:["defended_none","defended_affected","defended_ok","defended_great"]
	},
	"defended_none": {
		name: "Wasn't defended",
		type: "%"
	},
	"defended_affected": {
		name: "Affected by Defense",
		type: "%"
	},
	"defended_ok": {
		name: "Average Against Defense",
		type: "%"
	},
	"defended_great": {
		name: "Good Against Defense",
		type: "%"
	},
	"fouls":{
		name: "Fouls (-4 points)",
		type: "avg",
		good: "low"
	},
	"techfouls":{
		name: "Tech Fouls (-8 points)",
		type: "avg",
		good: "low"
	},
	"rank":{
		name: "Rank",
		type: "enum",
		values:["","Struggled","Productive","Captain"],
		breakout:["rank_none","rank_struggled","rank_productive","rank_captain"]
	},
	"rank_none": {
		name: "Not Ranked",
		type: "%"
	},
	"rank_struggled": {
		name: "Struggled to be Effective",
		type: "%"
	},
	"rank_productive": {
		name: "Decent Robot",
		type: "%"
	},
	"rank_captain": {
		name: "Very Good Robot",
		type: "%"
	},
	"scouter": {
		name: "Scouter",
		type: "text"
	},
	"comments": {
		name: "Comments",
		type: "text"
	}
}

var teamGraphs = {
	"Overall":{
		graph:"stacked",
		data:["score"]
	},
	"Game Stages":{
		graph:"stacked",
		data:["auto_score","teleop_score","control_score","endgame_score"]
	},
	"Penalties":{
		graph:"stacked",
		data:["fouls_score","techfouls_score"]
	},
	"Auto":{
		graph:"stacked",
		data:["auto_line_score","auto_bottom_score","auto_outer_score","auto_inner_score","auto_score"]
	},
	"Remote Control":{
		graph:"stacked",
		data:["teleop_bottom_score","teleop_outer_score","teleop_inner_score"]
	},
	"End Game":{
		graph:"stacked",
		data:["parked_score","climbed_score","leveled_score"]
	},
	"Misses":{
		graph:"stacked",
		data:["auto_missed","teleop_missed"]
	},
	"Played Defense":{
		graph:"stacked",
		data:["defense_none","defense_bad","defense_ok","defense_great"]
	},
	"Good Against Defense":{
		graph:"stacked",
		data:["defended_none","defended_affected","defended_ok","defended_great"]
	},
	"Rank":{
		graph:"stacked",
		data:["rank_none","rank_struggled","rank_productive","rank_captain"]
	}
}

var aggregateGraphs = {
	"Overall":{
		graph:"bar",
		data:["max_score","score","min_score"]
	},
	"Game Stages":{
		graph:"stacked",
		data:["auto_score","teleop_score","control_score","endgame_score"]
	},
	"Penalties":{
		graph:"stacked",
		data:["fouls_score","techfouls_score"]
	},
	"Auto":{
		graph:"stacked",
		data:["auto_line_score","auto_bottom_score","auto_outer_score","auto_inner_score","auto_score"]
	},
	"Remote Control":{
		graph:"stacked",
		data:["teleop_bottom_score","teleop_outer_score","teleop_inner_score"]
	},
	"End Game":{
		graph:"stacked",
		data:["parked_score","climbed_score","leveled_score"]
	},
	"Scouting Coverage":{
		graph:"stacked",
		data:["count"]
	},
	"Misses":{
		graph:"stacked",
		data:["auto_missed","teleop_missed"]
	},
	"Played Defense":{
		graph:"stacked",
		data:["defense_none","defense_bad","defense_ok","defense_great"]
	},
	"Good Against Defense":{
		graph:"stacked",
		data:["defended_none","defended_affected","defended_ok","defended_great"]
	},
	"Rank":{
		graph:"stacked",
		data:["rank_none","rank_struggled","rank_productive","rank_captain"]
	}
}


var matchPredictorSections = {
	"Total":["score","count"],
	"Game Stages":["auto_score","teleop_score","control_score","endgame_score"],
	"Penalties":["fouls","techfouls"],
	"Auto":["auto_line_score","auto_bottom_score","auto_outer_score","auto_inner_score","auto_score"],
	"Remote Control":["teleop_bottom_score","teleop_outer_score","teleop_inner_score"],
	"Control":["rotation_control_score","position_control_score"],
	"End Game":["parked_score","climbed_score","leveled_score"]
}
