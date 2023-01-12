"use strict"

function addStat(map,field,value){
	if(/^(\%|avg)$/.test(statInfo[field]['type'])) map[field] = (map[field]||0)+(value||0)
}

function aggregateStats(scout, aggregate){
}

function decodeIfNeeded(s){
	if (!s) s = ""
	if (/[a-zA-Z]\+([a-zA-Z]|$)/.test(s)) s = s.replace(/\+/g," ")
	if (/\%[0-9a-fA-F]{2}/.test(s)) s = decodeURIComponent(s)
	if (/\%[0-9a-fA-F]{2}/.test(s)) s = decodeURIComponent(s)
	if (/^(none|(n\/a)|unknown)$/i.test(s)) s = ""
	return s
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
	"Auto":{
		graph:"stacked",
		data:[]
	},
	"Teleop":{
		graph:"stacked",
		data:[]
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
	"Auto":{
		graph:"stacked",
		data:[]
	},
	"Teleop":{
		graph:"stacked",
		data:[]
	},
	"Scouting Coverage":{
		graph:"stacked",
		data:["count"]
	}
}

var matchPredictorSections = {
	"Total":["score"],
	"Game Stages":["auto_score","teleop_score","end_game_score"],
	"Auto":[],
	"Teleop":[]
}

function showPitScouting(el){
	loadPitScouting(function(dat){
		console.log(dat)
		el.append("<p>" + (dat.auto_have?"Has":"Does NOT have") + " auto</p>")
		if (dat.auto_preload){
			el.append("<p>Preloaded cargo scored in " + dat.auto_preload + "</p>")
		}
	})
}
