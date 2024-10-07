"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit){
}

var statInfo = {
	match:{
		name: "Match",
		type: "text"
	},
	team:{
		name: "Team",
		type: "text"
	},
	comments:{
		name: "Comments",
		type: "text"
	},
	created:{
		name: "Created",
		type: "datetime"
	},
	modified:{
		name: "Modified",
		type: "datetime"
	}
}

var teamGraphs = {
	"Match Score":{
		graph:"bar",
		data:["score"]
	},
}

var aggregateGraphs = {
	"Match Score":{
		graph:"boxplot",
		data:["max_score","score","min_score"]
	},
}


var matchPredictorSections = {
	Total:["score"],
}

var plannerSections = {
	Total:["score"],
}

var whiteboardStamps = []

var whiteboardOverlays = []
