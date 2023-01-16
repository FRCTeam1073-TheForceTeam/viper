"use strict"


function aggregateStats(scout, aggregate){

	function sumXStats(stage,row,cargo,stat,values){
		var sum = 0,
		key=placementKey(stage,row,cargo,stat)
		values.forEach(function(val){
			sum+=scout[key.replace("X",val)]||0
		})
		return sum
	}

	function reliability(dat, stat){
		var success = dat[stat]||0,
		failure = dat[stat+"_failed"]||0,
		attempts = success+failure
		dat[stat+"_attempts"] = attempts
		if (attempts > 0) dat[stat+"_reliability"] = Math.round(100*success/attempts)
	}

	function addStat(map,field,value){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])) map[field] = (map[field]||0)+(value||0)
	}

	function fromParent(stage,row,cargo,doSum){	
		;["","score","failed"].forEach(stat=>{
			scout[placementKey(stage,row,cargo,stat)] = doSum(stat)
		})						
		reliability(scout,placementKey(stage,row,cargo))
	}

	var pointValues = {
		"auto_mobility":3,
		"auto_top":6,
		"auto_middle":4,
		"auto_bottom":3,
		"auto_docked":8,
		"auto_engaged":12,
		"tele_top":5,
		"tele_middle":3,
		"tele_bottom":2,
		"end_parked":2,
		"end_docked":6,
		"end_engaged":10,
		"links":5/3
	}

	forEachStageRowCargo(false,function(stage,row,cargo){
		if (stage&&row&&cargo){
			scout[placementKey(stage,row,cargo,"score")] = (scout[placementKey(stage,row,cargo)]||0)*pointValues[placementKey(stage,row)]
			reliability(scout,placementKey(stage,row,cargo))
		}
	})
	forEachStageRowCargo(false,function(stage,row,cargo){
		if (stage&&row&&!cargo){
			fromParent(stage,row,cargo,function(stat){
				return sumXStats(stage,row,"X",stat,["cone","cube"])
			})
		}
		if (stage&&!row&&cargo){
			fromParent(stage,row,cargo,function(stat){
				return sumXStats(stage,"X",cargo,stat,["top","middle","bottom"])
			})
		}
		if (!stage&&row&&cargo){
			fromParent(stage,row,cargo,function(stat){
				return sumXStats("X",row,cargo,stat,["auto","tele"])
			})
		}
	})
	forEachStageRowCargo(false,function(stage,row,cargo){
		if (stage&&!row&&!cargo){
			fromParent(stage,row,cargo,function(stat){
				return sumXStats(stage,row,"X",stat,["cone","cube"])
			})
		}
		if (!stage&&!row&&cargo){
			fromParent(stage,row,cargo,function(stat){
				return sumXStats(stage,"X",cargo,stat,["top","middle","bottom"])
			})
		}
		if (!stage&&row&&!cargo){
			fromParent(stage,row,cargo,function(stat){
				return sumXStats("X",row,cargo,stat,["auto","tele"])
			})
		}
	})

	fromParent("","","",function(stat){
		return sumXStats("X","","","",["auto","tele"])
	})
	console.log(scout)

	scout['auto_mobility_score'] = scout['auto_mobility']?pointValues['auto_mobility']:0
	scout['auto_dock_score'] = pointValues['auto_'+scout['auto_dock']]||0
	scout['auto_dock_docked_attempts'] = scout['auto_dock']?1:0
	scout['auto_dock_docked'] = /docked|engaged/.test(scout['auto_dock']||"")?1:0
	scout['auto_dock_docked_failed'] = scout['auto_dock_docked_attempts']-scout['auto_dock_docked']
	scout['auto_dock_engaged_attempts'] = scout['auto_dock']?1:0
	scout['auto_dock_engaged'] = scout['auto_dock']=="engaged"?1:0
	scout['auto_dock_engaged_failed'] = scout['auto_dock_engaged_attempts']-scout['auto_dock_engaged']
	scout['auto_score'] = scout['auto_place_score']+scout['auto_dock_score']+scout['auto_mobility_score']

	scout['end_score'] = pointValues['end'+scout['end']]||0
	scout['end_dock_score'] = scout['end']=='parked'?0:scout['end_score']

	scout['end_dock_docked'] = /docked|engaged/.test(scout['end']||"")?1:0
	scout['end_dock_docked_attempts'] = (scout['end_dock_docked']||scout['end_dock_fail']=='yes')?1:0
	scout['end_dock_docked_failed'] = scout['end_dock_docked_attempts']-scout['end_dock_docked']

	scout['end_dock_engaged'] = scout['end']=="engaged"?1:0
	scout['end_dock_engaged_attempts'] = (scout['end_dock_engaged']||scout['end_dock_fail']=='yes')?1:0
	scout['end_dock_engaged_failed'] = scout['end_dock_engaged_attempts']-scout['end_dock_engaged']
	
	scout['links_score'] = scout['links']||0*pointValues['links']
	scout['tele_score'] = scout['tele_place_score']+scout['links_score']
	scout['dock_score'] = scout['auto_dock_score']+scout['end_dock_score']

	scout['score'] = scout['auto_score']+scout['tele_score']+scout['end_score']

	Object.keys(statInfo).forEach(function(field){
		addStat(aggregate,field,scout[field])
	})
	Object.keys(statInfo).forEach(function(field){
		if (/_reliability$/.test(field)){
			var base = field.replace(/_reliability$/,""),
			success = aggregate[base]||0,
			attempts = aggregate[`${base}_attempts`]||0
			if (attempts > 0) aggregate[field] = Math.round(100*success/attempts)
			// if (attempts == 0){
			// 	console.log(`${base}: ${aggregate[base]}`)
			// 	console.log(`${base}_attempts: ${attempts}`)
			// 	console.log(`${field}: ${aggregate[field]}`)
			// }
		}		
	})
	aggregate["full_cycle_fastest_seconds"] = (aggregate["full_cycle_fastest_seconds"]||999)>scout["full_cycle_fastest_seconds"]?scout["full_cycle_fastest_seconds"]:(aggregate["full_cycle_fastest_seconds"]||999)
	aggregate["max_score"] = (aggregate["max_score"]||0)<scout["score"]?scout["score"]:(aggregate["max_score"]||0)
	aggregate["min_score"] = (aggregate["min_score"]||999)>scout["score"]?scout["score"]:(aggregate["min_score"]||999)
}

var statInfo = {
	"match": {
		name: "Match",
		type: "text"
	},
	"auto_mobility": {
		name: "",
		type: ""
	},
	"auto_dock": {
		name: "",
		type: ""
	},
	"shelf": {
		name: "",
		type: ""
	},
	"loading_zone": {
		name: "",
		type: ""
	},
	"community": {
		name: "",
		type: ""
	},
	"field": {
		name: "",
		type: ""
	},
	"full_cycle_fastest_seconds": {
		name: "",
		type: "minmax"
	},
	"full_cycle_average_seconds": {
		name: "",
		type: "avg"
	},
	"full_cycle_count": {
		name: "engaged",
		type: "count"
	},
	"tele_dock": {
		name: "",
		type: ""
	},
	"links": {
		name: "",
		type: ""
	},
	"cone_sideways": {
		name: "",
		type: ""
	},
	"throw": {
		name: "",
		type: ""
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

function placementKey(stage,row,cargo,stat){
	var key = row
	if (cargo) key += (key?"_":"")+cargo
	if (!key) key="place"
	if (stage) key = `${stage}_${key}`
	if (stat) key += `_${stat}`
	return key
}


function forEachStageRowCargo(full,callback){
	;[["",""],["auto","Auto"],["tele","Teleop"]].forEach(stage=>{
		;[["",""],["top","Top"],["middle","Middle"],["bottom","Bottom"]].forEach(row=>{
			;[["","Cargo"],["cone","Cones"],["cube","Cubes"]].forEach(cargo=>{
				if(full)callback(stage,row,cargo)
				else callback(stage[0],row[0],cargo[0])
			})
		})
	})
}

function forEachStageRowCargoStat(full,callback){
	forEachStageRowCargo(full,function(stage,row,cargo){
		;[["","Placed","count"],["score","Score","avg"],["failed","Failed","count"],["attempts","Place Attempts","count"],["reliability","Reliability","fraction"]].forEach(stat=>{
			if(full)callback(stage,row,cargo,stat)
			else callback(stage,row,cargo,stat[0])
		})
	})
}

forEachStageRowCargoStat(true,function(stage,row,cargo,stat){
	var key = placementKey(stage[0],row[0],cargo[0],stat[0])
	var name = `${cargo[1]} ${stat[1]}`
	if (row[1]) name += ` on ${row[1]}`
	if (stage[1]) name += ` During ${stage[1]}`
	statInfo[key] = {
		name: name,
		type: stat[2]
	}
})
console.log(statInfo)

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
