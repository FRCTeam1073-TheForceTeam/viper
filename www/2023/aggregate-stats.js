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



	scout['auto_mobility_score'] = scout['auto_mobility']?pointValues['auto_mobility']:0
	scout['auto_dock_score'] = pointValues['auto_'+scout['auto_dock']]||0
	scout['auto_dock_docked_attempts'] = scout['auto_dock']?1:0
	scout['auto_dock_docked'] = /docked|engaged/.test(scout['auto_dock']||"")?1:0
	scout['auto_dock_docked_failed'] = scout['auto_dock_docked_attempts']-scout['auto_dock_docked']
	scout['auto_dock_engaged_attempts'] = scout['auto_dock']?1:0
	scout['auto_dock_engaged'] = scout['auto_dock']=="engaged"?1:0
	scout['auto_dock_engaged_failed'] = scout['auto_dock_engaged_attempts']-scout['auto_dock_engaged']
	scout['auto_score'] = scout['auto_place_score']+scout['auto_dock_score']+scout['auto_mobility_score']

	scout['end_score'] = pointValues['end_'+scout['end']]||0
	scout['end_dock_score'] = scout['end']=='parked'?0:scout['end_score']

	scout['end_dock_docked'] = /docked|engaged/.test(scout['end']||"")?1:0
	scout['end_dock_docked_attempts'] = (scout['end_dock_docked']||scout['end_dock_fail']=='yes')?1:0
	scout['end_dock_docked_failed'] = scout['end_dock_docked_attempts']-scout['end_dock_docked']

	scout['end_dock_engaged'] = scout['end']=="engaged"?1:0
	scout['end_dock_engaged_attempts'] = (scout['end_dock_engaged']||scout['end_dock_fail']=='yes')?1:0
	scout['end_dock_engaged_failed'] = scout['end_dock_engaged_attempts']-scout['end_dock_engaged']
	
	scout['links_score'] = Math.round((scout['links']||0)*pointValues['links'])
	scout['tele_score'] = scout['tele_place_score']+scout['links_score']
	scout['dock_score'] = scout['auto_dock_score']+scout['end_dock_score']

	scout['score'] = scout['auto_score']+scout['tele_score']+scout['end_score']

	var cycleSeconds =  (scout['full_cycle_count']||0) * (scout["full_cycle_average_seconds"]||0) + (aggregate['full_cycle_count']||0) * (aggregate["full_cycle_average_seconds"]||0)
	var cycles = (scout['full_cycle_count']||0) + (aggregate['full_cycle_count']||0)

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])) aggregate[field] = (aggregate[field]||0)+(scout[field]||0)
		if(/^capability$/.test(statInfo[field]['type'])) aggregate[field] = aggregate[field]||scout[field]||0
		if(/^text$/.test(statInfo[field]['type'])) aggregate[field] = (!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
	})
	Object.keys(statInfo).forEach(function(field){
		if (/_reliability$/.test(field)){
			var base = field.replace(/_reliability$/,""),
			success = aggregate[base]||0,
			attempts = aggregate[`${base}_attempts`]||0
			if (attempts > 0) aggregate[field] = Math.round(100*success/attempts)
		}		
	})
	aggregate["count"] = (aggregate["count"]||0)+1
	aggregate["event"] = scout["event"]
	aggregate["full_cycle_fastest_seconds"] = (aggregate["full_cycle_fastest_seconds"]||999)>scout["full_cycle_fastest_seconds"]?scout["full_cycle_fastest_seconds"]:(aggregate["full_cycle_fastest_seconds"]||999)
	if (cycles > 0) aggregate["full_cycle_average_seconds"] = Math.round(cycleSeconds / cycles)
	aggregate["max_score"] = (aggregate["max_score"]||0)<scout["score"]?scout["score"]:(aggregate["max_score"]||0)
	aggregate["min_score"] = (aggregate["min_score"]||999)>scout["score"]?scout["score"]:(aggregate["min_score"]||999)
}

var statInfo = {
	"event": {
		name: "Event",
		type: "text"
	},
	"match": {
		name: "Match",
		type: "text"
	},
	"team": {
		name: "Team",
		type: "text"
	},
	"auto_dock": {
		name: "Auto Dock State",
		type: "text"
	},
	"auto_dock_docked": {
		name: "Docked During Auto",
		type: "count"
	},
	"auto_dock_docked_attempts": {
		name: "Dock During Auto Attempts",
		type: "count"
	},
	"auto_dock_docked_failed": {
		name: "Dock During Auto Failed",
		type: "count"
	},
	"auto_dock_docked_reliability": {
		name: "Dock During Auto Reliability",
		type: "fraction"
	},
	"auto_dock_engaged": {
		name: "Engaged During Auto",
		type: "count"
	},
	"auto_dock_engaged_attempts": {
		name: "Engaged During Auto Attempts",
		type: "count"
	},
	"auto_dock_engaged_failed": {
		name: "Engaged During Auto Failed",
		type: "count"
	},
	"auto_dock_engaged_reliability": {
		name: "Engage During Auto Reliability",
		type: "fraction"
	},
	"auto_dock_score": {
		name: "Auto Docking Score",
		type: "avg"
	},
	"auto_mobility": {
		name: "Exited Community During Auto",
		type: "%"
	},
	"auto_mobility_score": {
		name: "Exited Community During Auto Score",
		type: "avg"
	},
	"auto_score": {
		name: "Auto Score",
		type: "avg"
	},
	"community": {
		name: "Cargo Picked from Community",
		type: "avg"
	},
	"cone_sideways": {
		name: "Can Pickup Sideways Cone",
		type: "capability"
	},
	"count": {
		name: "Number of Matches",
		type: "count"
	},
	"dock_score": {
		name: "Docking Score",
		type: "avg"
	},
	"end": {
		name: "End Game State",
		type: "text"
	},
	"end_dock_docked": {
		name: "Docked During End Game",
		type: "avg"
	},
	"end_dock_docked_attempts": {
		name: "Docked During End Game Attempts",
		type: "avg"
	},
	"end_dock_docked_failed": {
		name: "Docked During End Game Failures",
		type: "avg"
	},
	"end_dock_docked_reliability": {
		name: "Docked During End Game Reliability",
		type: "fraction"
	},
	"end_dock_engaged": {
		name: "Engaged During End Game",
		type: "avg"
	},
	"end_dock_engaged_attempts": {
		name: "Engaged During End Game Attempts",
		type: "avg"
	},
	"end_dock_engaged_failed": {
		name: "Engaged During End Game Failed",
		type: "avg"
	},
	"end_dock_engaged_reliability": {
		name: "Engaged During End Game Reliability",
		type: "fraction"
	},
	"end_dock_fail": {
		name: "End Game Docking Failures",
		type: "text"
	},
	"end_dock_score": {
		name: "End Game Docking Score",
		type: "avg"
	},
	"end_score": {
		name: "End Game Score",
		type: "avg"
	},
	"field": {
		name: "Cargo Picked from Field",
		type: "avg"
	},
	"full_cycle_average_seconds": {
		name: "Full Cycle Time Average",
		type: "num"
	},
	"full_cycle_count": {
		name: "Full Cycle Count",
		type: "count"
	},
	"full_cycle_fastest_seconds": {
		name: "Full Cycle Time Fastest",
		type: "minmax"
	},
	"links": {
		name: "Alliance links",
		type: "avg"
	},
	"links_score": {
		name: "Links Score (1/3 Alliance Score)",
		type: "avg"
	},
	"loading_zone": {
		name: "Cargo Picked from Chute",
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
	"score": {
		name: "Score Contribution",
		type: "avg"
	},
	"shelf": {
		name: "Cargo Picked from Shelf",
		type: "avg"
	},
	"tele_score": {
		name: "Teleop Score",
		type: "avg"
	},
	"throw": {
		name: "Can Throw Cargo",
		type: "capability"
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
		data:['auto_dock_docked_reliability','auto_dock_engaged_reliability']
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
		data:["auto_score","tele_score","end_score"]
	},
	"Auto":{
		graph:"stacked",
		data:['auto_dock_docked_reliability','auto_dock_engaged_reliability']
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
	"Game Stages":["auto_score","tele_score","end_score"],
	"Auto":['auto_mobility_score','auto_place_score','auto_dock_score',],
	"Teleop":['tele_place_score','links_score'],
	"Teleop Cargo":['tele_cone_score','tele_cube_score','tele_top_score','tele_middle_score','tele_bottom_score','full_cycle_average_seconds'],
	"Auto Cargo":['auto_cone_score','auto_cube_score','auto_top_score','auto_middle_score','auto_bottom_score']
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
