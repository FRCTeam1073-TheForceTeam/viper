function addStat(map,field,value){
	if(/^(\%|avg)$/.test(statInfo[field]['type'])) map[field] = (map[field]||0)+(value||0)
}

function aggregateStats(scout, aggregate){
	scout["taxi_score"] = (scout["taxi"]||0)*2
	scout["auto_low_hub_score"] = (scout["auto_low_hub"]||0)*2
	scout["auto_high_hub_score"] = (scout["auto_high_hub"]||0)*4
	scout["human_score"] = (scout["human"]||0)*4
	scout["auto_score"] =  scout["taxi_score"] + scout["auto_low_hub_score"] + scout["auto_high_hub_score"] +  scout["human_score"]

	scout["teleop_low_hub_score"] = scout["teleop_low_hub"]||0
	scout["teleop_high_hub_score"] = (scout["teleop_high_hub"]||0)*2
	scout["teleop_score"] = scout["teleop_low_hub_score"] + scout["teleop_high_hub_score"]

	scout["end_game_score"] = statInfo["rung"]["points"][scout["rung"]||0]

	scout["fouls_score"] = (scout["fouls"]||0)*-4
	scout["techfouls_score"] = (scout["techfouls"]||0)*-8
	scout["penalty_score"] = scout["fouls_score"] + scout["techfouls_score"]

	scout["score"] = scout["auto_score"] + scout["teleop_score"] + scout["end_game_score"] + scout["penalty_score"]

	scout[statInfo["rung"]["breakout"][scout["rung"]||0]] = 1
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
		if (/^(\%|avg|count)$/.test(statInfo[field]["type"])){
			addStat(aggregate,field,scout[field])
		}
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
	"auto_score": {
		name: "Auto Score",
		type: "avg"
	},
	"teleop_score": {
		name: "Teleop Score",
		type: "avg"
	},
	"end_game_score": {
		name: "End Game Score",
		type: "avg"
	},
	"auto_low_hub": {
		name: "Auto Balls in Low Hub",
		type: "avg"
	},
	"auto_low_hub_score": {
		name: "Auto Low Hub Score",
		type: "avg"
	},
	"auto_high_hub": {
		name: "Auto Balls in High Hub",
		type: "avg"
	},
	"auto_high_hub_score": {
		name: "Auto High Hub Score",
		type: "avg"
	},
	"auto_missed": {
		name: "Auto Missed shots",
		type: "avg",
		good: "low"
	},
	"auto_bounce_out": {
		name: "Auto Shots bounced out",
		type: "avg",
		good: "low"
	},
	"taxi": {
		name: "Auto Taxi",
		type: "avg"
	},
	"taxi_score": {
		name: "Auto Taxi Score",
		type: "avg"
	},
	"human": {
		name: "Auto Human player goal",
		type: "%"
	},
	"human_score": {
		name: "Auto Human player goal score",
		type: "avg"
	},
	"teleop_low_hub": {
		name: "Teleop Balls in Low Hub",
		type: "avg"
	},
	"teleop_low_hub_score": {
		name: "Teleop Low Hub Score",
		type: "avg"
	},
	"teleop_high_hub": {
		name: "Teleop Balls in High Hub",
		type: "avg"
	},
	"teleop_high_hub_score": {
		name: "Teleop High Hub Score",
		type: "avg"
	},
	"teleop_missed": {
		name: "Teleop Missed shots",
		type: "avg",
		good: "low"
	},
	"teleop_bounce_out": {
		name: "Teleop Shots bounced out",
		type: "avg",
		good: "low"
	},
	"shoot_from_hub": {
		name: "Took shots from next to hub",
		type: "%"
	},
	"shoot_from_field": {
		name: "Took shots from the field",
		type: "%"
	},
	"shoot_from_outer_LP": {
		name: "Took shots from outer landing pad",
		type: "%"
	},
	"shoot_from_wallLP": {
		name: "Took shots from landing pad by wall",
		type: "%"
	},
	"end_game_score": {
		name: "Hanging score",
		type: "avg"
	},
	"rung": {
		name: "Hung on rung",
		type: "enum",
		values:["None","Low rung","Mid rung","High rung","Traversal rung"],
		breakout:["no_rung","low_rung","mid_rung","high_rung","traversal_rung"],
		points:[0,4,6,10,15]
	},
	"no_rung": {
		name: "Didn't hang",
		type: "%",
		good: "low"
	},
	"low_rung": {
		name: "Hung on low rung",
		type: "%"
	},
	"mid_rung": {
		name: "Hung on mid rung",
		type: "%"
	},
	"high_rung": {
		name: "Hung on high rung",
		type: "%"
	},
	"traversal_rung": {
		name: "Hung on traversal rung",
		type: "%"
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
		name: "Against Defense",
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
		name: "Fouls",
		type: "avg",
		good: "low"
	},
	"fouls_score":{
		name: "Fouls Score",
		type: "avg"
	},
	"techfouls":{
		name: "Tech Fouls",
		type: "avg",
		good: "low"
	},
	"techfouls_score":{
		name: "Tech Fouls score",
		type: "avg"
	},
	"penalty_score":{
		name: "Penalty score",
		type: "avg"
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
		data:["auto_score","teleop_score","end_game_score"]
	},
	"Penalties":{
		graph:"stacked",
		data:["fouls_score","techfouls_score"]
	},
	"Auto":{
		graph:"stacked",
		data:["taxi_score","auto_low_hub_score","auto_high_hub_score","human_score"]
	},
	"Teleop":{
		graph:"stacked",
		data:["teleop_low_hub_score","teleop_high_hub_score"]
	},
	"Misses":{
		graph:"stacked",
		data:["auto_missed","teleop_missed","auto_bounce_out","teleop_bounce_out"]
	},
	"Hanging":{
		graph:"stacked",
		data:["no_rung","low_rung","mid_rung","high_rung","traversal_rung"]
	},
	"Played Defense":{
		graph:"stacked",
		data:["defense_none","defense_bad","defense_ok","defense_great"]
	},
	"Good Against Defense":{
		graph:"stacked",
		data:["defended_none","defended_affected","defended_ok","defended_great"]
	},
	"Shot Locations":{
		graph:"bar",
		data:["shoot_from_hub","shoot_from_field","shoot_from_outer_LP","shoot_from_wallLP"]
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
		data:["auto_score","teleop_score","end_game_score"]
	},
	"Penalties":{
		graph:"stacked",
		data:["fouls_score","techfouls_score"]
	},
	"Auto":{
		graph:"stacked",
		data:["taxi_score","auto_low_hub_score","auto_high_hub_score","human_score"]
	},
	"Teleop":{
		graph:"stacked",
		data:["teleop_low_hub_score","teleop_high_hub_score"]
	},
	"Scouting Coverage":{
		graph:"stacked",
		data:["count"]
	},
	"Misses":{
		graph:"stacked",
		data:["auto_missed","teleop_missed","auto_bounce_out","teleop_bounce_out"]
	},
	"Hanging":{
		graph:"stacked",
		data:["no_rung","low_rung","mid_rung","high_rung","traversal_rung"]
	},
	"Played Defense":{
		graph:"stacked",
		data:["defense_none","defense_bad","defense_ok","defense_great"]
	},
	"Good Against Defense":{
		graph:"stacked",
		data:["defended_none","defended_affected","defended_ok","defended_great"]
	},
	"Shot Locations":{
		graph:"bar",
		data:["shoot_from_hub","shoot_from_field","shoot_from_outer_LP","shoot_from_wallLP"]
	},
	"Rank":{
		graph:"stacked",
		data:["rank_none","rank_struggled","rank_productive","rank_captain"]
	}
}

var matchPredictorSections = {
	"Total":["score"],
	"Game Stages":["auto_score","teleop_score","end_game_score"],
	"Penalties":["fouls_score","techfouls_score"],
	"Auto":["taxi_score","auto_low_hub_score","auto_high_hub_score"],
	"Teleop":["teleop_low_hub_score","teleop_high_hub_score"]
}
