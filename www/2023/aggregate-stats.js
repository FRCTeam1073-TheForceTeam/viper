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

	function fromParent(stage,row,cargo,doSum){
		;["","score","failed"].forEach(stat=>{
			var key = placementKey(stage,row,cargo,stat)
			scout[key] = (scout[key]||0) + doSum(stat)
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
		"super_charge":3,
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
	scout['auto_dock_docked'] = scout['auto_dock']=="docked"?1:0
	scout['auto_dock_engaged'] = scout['auto_dock']=="engaged"?1:0
	scout['auto_dock_failed'] = scout['auto_dock']=="failed"?1:0
	scout['auto_dock_none'] = scout['auto_dock']?0:1
	scout['auto_dock_engaged_attempts'] = scout['auto_dock']?1:0
	scout['auto_dock_engaged_failed'] = scout['auto_dock_engaged_attempts']-scout['auto_dock_engaged']
	scout['auto_nondock_score'] = scout['auto_place_score']+scout['auto_mobility_score']
	scout['auto_score'] = scout['auto_nondock_score']+scout['auto_dock_score']
	scout['auto_start_cable'] = scout['auto_start']=='cable'?1:0
	scout['auto_start_barrier'] = scout['auto_start']=='barrier'?1:0
	scout['auto_start_charging'] = scout['auto_start']=='charging'?1:0
	scout['auto_start_cable_score'] = scout['auto_start']=='cable'?scout['auto_score']:0
	scout['auto_start_barrier_score'] = scout['auto_start']=='barrier'?scout['auto_score']:0
	scout['auto_start_charging_score'] = scout['auto_start']=='charging'?scout['auto_score']:0
	scout['auto_start_unknown'] = /^(cable|barrier|charging)$/.test(scout['auto_start']||"")?0:1

	scout['end_score'] = pointValues['end_'+scout['end']]||0
	scout['end_dock_score'] = scout['end']=='parked'?0:scout['end_score']
	scout['end_dock_docked'] = (scout['end']=='docked'&&scout['end_dock_fail']!='yes')?1:0
	scout['end_dock_engaged'] = scout['end']=="engaged"?1:0
	scout['end_dock_engaged_none'] = (!/^docked|engaged$/.test(scout['end'])&&!scout['end_dock_fail'])?1:0
	scout['end_dock_engaged_attempts'] = (/^docked|engaged$/.test(scout['end'])||scout['end_dock_fail']=='yes')?1:0
	scout['end_dock_engaged_failed'] = ((scout['end']=='docked'&&scout['end_dock_fail']!='nofault')||(scout['end']!='engaged'&&scout['end_dock_fail']=='yes'))?1:0
	scout['end_dock_engaged_failed_nofault'] = (scout['end']!='engaged'&&scout['end_dock_fail']=='nofault')?1:0

	scout['links_score'] = Math.round((scout['links']||0)*pointValues['links'])
	scout['super_charge_cube_score'] = (scout['links']||0)==9?((scout['super_charge_cube']||0)*pointValues['super_charge']):0
	scout['super_charge_cone_score'] = (scout['links']||0)==9?((scout['super_charge_cone']||0)*pointValues['super_charge']):0
	scout['super_charge_score'] = scout['super_charge_cube_score']+scout['super_charge_cone_score']
	scout['tele_score'] = scout['tele_place_score']+scout['links_score']+scout['super_charge_score']
	scout['dock_score'] = scout['auto_dock_score']+scout['end_dock_score']

	scout['score'] = scout['auto_score']+scout['tele_score']+scout['end_score']

	var cycleSeconds =  (scout['full_cycle_count']||0) * (scout["full_cycle_average_seconds"]||0) + (aggregate['full_cycle_count']||0) * (aggregate["full_cycle_average_seconds"]||0)
	var cycles = (scout['full_cycle_count']||0) + (aggregate['full_cycle_count']||0)

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			aggregate[field] = (aggregate[field]||0)+(scout[field]||0)
			var set = `${field}_set`
			aggregate[set] = aggregate[set]||[]
			aggregate[set].push(scout[field]||0)
		}
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
	aggregate["full_cycle_fastest_seconds"] = (scout["full_cycle_fastest_seconds"]&&(aggregate["full_cycle_fastest_seconds"]||999)>scout["full_cycle_fastest_seconds"])?scout["full_cycle_fastest_seconds"]:(aggregate["full_cycle_fastest_seconds"]||0)
	if (cycles > 0) aggregate["full_cycle_average_seconds"] = Math.round(cycleSeconds / cycles)
	aggregate["max_score"] = Math.max(aggregate["max_score"]||0,scout["score"])
	aggregate["min_score"] = Math.min(aggregate["min_score"]===undefined?999:aggregate["min_score"],scout["score"])
	aggregate["tele_max_place_score"] = Math.max(aggregate["tele_max_place_score"]||0,scout["tele_place_score"])
	aggregate["tele_min_place_score"] = Math.min(aggregate["tele_min_place_score"]===undefined?999:aggregate["tele_min_place_score"],scout["tele_place_score"])
	;['cable','barrier','charging'].forEach(loc=>{
		aggregate[`auto_start_${loc}_sum`] = (aggregate[`auto_start_${loc}_sum`]||0) + scout[`auto_start_${loc}_score`]
		aggregate[`auto_start_${loc}_score`] = aggregate[`auto_start_${loc}_sum`] / (aggregate[`auto_start_${loc}`]||1)
	})
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
	"auto_start": {
		name: "Location where the robot starts",
		type: "text"
	},
	"auto_start_barrier": {
		name: "Started by the barrier",
		type: "count"
	},
	"auto_start_charging": {
		name: "Started by the charge station",
		type: "count"
	},
	"auto_start_unknown": {
		name: "Unknown starting position",
		type: "count"
	},
	"auto_start_cable": {
		name: "Started by the cable protector",
		type: "count"
	},
	"auto_dock": {
		name: "Auto Dock State",
		type: "text"
	},
	"auto_dock_docked": {
		name: "Docked During Auto",
		type: "count"
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
		type: "count",
		good: "low"
	},
	"auto_dock_failed": {
		name: "Dock Failed During Auto",
		type: "count",
		good: "low"
	},
	"auto_dock_none": {
		name: "Dock Not Attempted During Auto",
		type: "count",
		good: "low"
	},
	"auto_dock_engaged_reliability": {
		name: "Engage During Auto Reliability",
		type: "fraction"
	},
	"auto_dock_score": {
		name: "Auto Docking Score",
		type: "avg"
	},
	"auto_nondock_score": {
		name: "Auto Mobility+Place Score",
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
	'auto_start_cable_score': {
		name: "Non-docking Auto Score Starting by Cable Protector",
		type: "fraction"
	},
	'auto_start_barrier_score': {
		name: "Non-docking Auto Score Starting by Barrier",
		type: "fraction"
	},
	'auto_start_charging_score': {
		name: "Non-docking Auto Score Starting by Charging Station",
		type: "fraction"
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
	"end_dock_engaged": {
		name: "Engaged During End Game",
		type: "count"
	},
	"end_dock_engaged_none": {
		name: "No Attempt to Engage During End Game",
		type: "count",
		good: "low"
	},
	"end_dock_engaged_attempts": {
		name: "Engaged During End Game Attempts",
		type: "count"
	},
	"end_dock_engaged_failed": {
		name: "Engaged During End Game Failed",
		type: "count",
		good: "low"
	},
	"end_dock_engaged_failed_nofault": {
		name: "Engaged During End Game Failed but Not at Fault",
		type: "count",
		good: "low"
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
		type: "num",
		good: "low"
	},
	"full_cycle_count": {
		name: "Full Cycle Count",
		type: "avg"
	},
	"full_cycle_fastest_seconds": {
		name: "Full Cycle Time Fastest",
		type: "minmax",
		good: "low"
	},
	"links": {
		name: "Alliance links",
		type: "avg"
	},
	"links_score": {
		name: "Links Score (⅓ Alliance Score)",
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
	"tele_min_place_score": {
		name: "Teleop Minimum Placing Score",
		type: "minmax"
	},
	"tele_max_place_score": {
		name: "Teleop Maximum Placing Score",
		type: "minmax"
	},
	"super_charge_cube": {
		name: "Super Charge Cubes Placed",
		type: "avg"
	},
	"super_charge_cone": {
		name: "Super Charge Cones Placed",
		type: "avg"
	},
	"super_charge_cube_score": {
		name: "Super Charge Cube Score",
		type: "avg"
	},
	"super_charge_cone_score": {
		name: "Super Charge Cone Score",
		type: "avg"
	},
	"super_charge_score": {
		name: "Super Charge Score",
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
		;[["","Placed","avg"],["score","Score","avg"],["failed","Failed","avg"],["attempts","Place Attempts","avg"],["reliability","Reliability","fraction"]].forEach(stat=>{
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
		data:["auto_nondock_score","auto_dock_score","tele_score","end_score"]
	},
	"Auto Dock":{
		graph:"stacked",
		data:['auto_dock_engaged', 'auto_dock_docked', 'auto_dock_failed', 'auto_dock_none']
	},
	"# Placed by Stage":{
		graph:"stacked",
		data:["auto_place","tele_place"]
	},
	"End Engage":{
		graph:"stacked",
		data:['end_dock_engaged', 'end_dock_engaged_failed_nofault', 'end_dock_engaged_failed', 'end_dock_engaged_none']
	},
	"Auto":{
		graph:"stacked",
		data:['auto_mobility_score','auto_place_score','auto_dock_score']
	},
	"Teleop":{
		graph:"stacked",
		data:['tele_place_score','links_score','super_charge_score']
	},
	"Cargo Picking":{
		graph:"stacked",
		data:['shelf','loading_zone','community','field']
	},
	"Capabilities":{
		graph:"bar",
		data:['cone_sideways','throw']
	},
	"Docking":{
		graph:"bar",
		data:['auto_dock_docked','auto_dock_engaged','end_dock_docked','end_dock_engaged']
	},
	"Engage Failures":{
		graph:"bar",
		data:['auto_dock_engaged_failed','end_dock_engaged_failed']
	},
	"Full Cycle Time":{
		graph:"bar",
		data:["full_cycle_average_seconds","full_cycle_fastest_seconds"]
	},
	"Full Cycle Count":{
		graph:"bar",
		data:["full_cycle_count"]
	},
	"# Placed by Type":{
		graph:"stacked",
		data:["cube","cone"]
	},
	"# Placed by Level":{
		graph:"stacked",
		data:["bottom","middle","top"]
	},
	"# Placed by Type and Level":{
		graph:"stacked",
		data:["bottom_cube","bottom_cone","middle_cube","middle_cone","top_cube","top_cone"]
	},
	"Place Reliability by Stage":{
		graph:"bar",
		data:["auto_place_reliability","tele_place_reliability"]
	},
	"Place Reliability by Type":{
		graph:"bar",
		data:["cone_reliability","cube_reliability"]
	}
}

var aggregateGraphs = {
	"Overall":{
		graph:"boxplot",
		data:["max_score","score","min_score"]
	},
	"Start Location Auto Score":{
		graph:"bar",
		data:['auto_start_cable_score','auto_start_barrier_score','auto_start_charging_score']
	},
	"Game Stages":{
		graph:"stacked",
		data:["auto_nondock_score","auto_dock_score","tele_score","end_score"]
	},
	"Auto Dock %":{
		graph:"stacked_percent",
		data:['auto_dock_engaged', 'auto_dock_docked', 'auto_dock_failed', 'auto_dock_none']
	},
	"# Placed by Stage":{
		graph:"stacked",
		data:["auto_place","tele_place"]
	},
	"End Engage %":{
		graph:"stacked_percent",
		data:['end_dock_engaged', 'end_dock_engaged_failed_nofault', 'end_dock_engaged_failed', 'end_dock_engaged_none']
	},
	"Auto":{
		graph:"stacked",
		data:['auto_mobility_score','auto_place_score','auto_dock_score']
	},
	"Teleop":{
		graph:"stacked",
		data:['tele_place_score','links_score','super_charge_score']
	},
	"Teleop Placing":{
		graph:"boxplot",
		data:["tele_max_place_score","tele_place_score","tele_min_place_score"]
	},
	"Cargo Picking":{
		graph:"stacked",
		data:['shelf','loading_zone','community','field']
	},
	"Capabilities":{
		graph:"bar",
		data:['cone_sideways','throw']
	},
	"Docking":{
		graph:"bar",
		data:['auto_dock_engaged_reliability','end_dock_engaged_reliability']
	},
	"Full Cycle Time":{
		graph:"bar",
		data:["full_cycle_average_seconds","full_cycle_fastest_seconds"]
	},
	"Full Cycle Count":{
		graph:"bar",
		data:["full_cycle_count"]
	},
	"Start Location %":{
		graph:"stacked_percent",
		data:['auto_start_barrier', 'auto_start_charging', 'auto_start_cable', 'auto_start_unknown']
	},
	"# Placed by Type":{
		graph:"stacked",
		data:["cube","cone"]
	},
	"# Placed by Level":{
		graph:"stacked",
		data:["bottom","middle","top"]
	},
	"# Placed by Type and Level":{
		graph:"stacked",
		data:["bottom_cube","bottom_cone","middle_cube","middle_cone","top_cube","top_cone"]
	},
	"Place Reliability by Stage":{
		graph:"bar",
		data:["auto_place_reliability","tele_place_reliability"]
	},
	"Place Reliability by Type":{
		graph:"bar",
		data:["cone_reliability","cube_reliability"]
	}
}

var matchPredictorSections = {
	"Total":["score"],
	"Game Stages":["auto_score","tele_score","end_score"],
	"Auto":['auto_mobility_score','auto_place_score','auto_dock_score'],
	"Auto Cargo":['auto_cone_score','auto_cube_score','auto_top_score','auto_middle_score','auto_bottom_score'],
	"Teleop":['tele_place_score','links_score'],
	"Teleop Cargo":['tele_cone_score','tele_cube_score','tele_top_score','tele_middle_score','tele_bottom_score','full_cycle_average_seconds']
}

var plannerSections = {
	"Total":["score"],
	"Game Stages":["auto_score","tele_score","end_score"],
	"Auto":['auto_place','auto_dock_engaged_attempts','auto_dock_engaged_reliability'],
	"Teleop":['tele_place','full_cycle_average_seconds'],
	"End":['end_dock_engaged_attempts','end_dock_engaged_reliability']
}

var fmsMapping = [
	[["autoChargeStationPoints"],["auto_dock_score"]],
	[["autoMobilityPoints"],["auto_mobility_score"]],
	[["autoGamePiecePoints"],["auto_place_score"]],
	[["teleopGamePiecePoints"],["tele_place_score"]],
	[["endGameChargeStationPoints","endGameParkPoints"],["end_score"]],
	[["linkPoints"],["links_score"]]
]

function showPitScouting(el,team){
	loadPitScouting(function(pitData){
		var dat = pitData[team]||{}
		if (dat['team_name']) el.append($("<p>").text("Team name: " + dat['team_name']))
		if (dat['team_location']) el.append($("<p>").text("Location: " + dat['team_location']))
		if (dat['bot_name']) el.append($("<p>").text("Bot name: " + dat['bot_name']))
		el.append($("<h4>").text("Autos Implemented"))
		el.append($("<ul>")
			.append(dat['auto_barrier']?$('<li>').text("Use grid and lane by barrier, no docking"):"")
			.append(dat['auto_charging']?$('<li>').text("Use center grid, drive over charging station, no docking"):"")
			.append(dat['auto_cable']?$('<li>').text("Use grid and lane with cable protector, no docking"):"")
			.append(dat['auto_barrier_dock']?$('<li>').text("Use grid and lane by barrier, then dock"):"")
			.append(dat['auto_charging_dock']?$('<li>').text("Use center grid, drive over charging station, then dock"):"")
			.append(dat['auto_cable_dock']?$('<li>').text("Use grid and lane with cable protector, then dock"):"")
			.append(dat['auto_static']?$('<li>').text("Stay put, place cargo"):"")
			.append(dat['auto_dock']?$('<li>').text("Don't exit community, then dock"):"")
			.append(
				(
					!dat['auto_barrier']&&
					!dat['auto_charging']&&
					!dat['auto_cable']&&
					!dat['auto_barrier_dock']&&
					!dat['auto_charging_dock']&&
					!dat['auto_cable_dock']&&
					!dat['auto_static']&&
					!dat['auto_dock']
				)?$('<li>').text("None"):"")
		)
		el.append($("<h4>").text("Can Place"))
		el.append($("<ul>")
			.append(dat['place_cones_top']?$('<li>').text("Cones on top row"):"")
			.append(dat['place_cubes_top']?$('<li>').text("Cubes on top row"):"")
			.append(dat['place_cones_middle']?$('<li>').text("Cones on middle row"):"")
			.append(dat['place_cubes_middle']?$('<li>').text("Cubes on middle row"):"")
			.append(
				(
					!dat['place_cones_top']&&
					!dat['place_cubes_top']&&
					!dat['place_cones_middle']&&
					!dat['place_cubes_middle']
				)?$('<li>').text("None"):"")
		)
		el.append($("<h4>").text("End Game"))
		el.append($("<ul>")
			.append(dat['end_charging']?$('<li>').text("Can end on charging station"):"")
			.append(dat['end_parking_brake']?$('<li>').text("Can stay on charging station while others get on"):"")
			.append(
				(
					!dat['end_charging']&&
					!dat['end_parking_brake']
				)?$('<li>').text("None"):"")
		)
		el.append($("<h4>").text("Dimensions (inches without bumpers)"))
		el.append($("<p>").text(format(dat['frame_length']+'x'+dat['frame_width']+'"')))
		el.append($("<h4>").text("Weight (pounds)"))
		el.append($("<p>").text(format(dat['weight'])))
		el.append($("<h4>").text("Drivetrain"))
		el.append($("<p>").text(format(dat['drivetrain'])))
		el.append($("<h4>").text("Swerve"))
		el.append($("<p>").text(format(dat['swerve'])))
		el.append($("<h4>").text("Drivetrain Motors"))
		el.append($("<p>").text((dat['motor_count']||"")+" "+format(dat['motors'])))
		el.append($("<h4>").text("Wheels"))
		el.append($("<p>").text((dat['wheel_count']||"")+" "+format(dat['wheels'])))
		el.append($("<h4>").text("Vision software used"))
		el.append($("<ul>")
			.append(dat['vision_auto']?$('<li>').text("Auto"):"")
			.append(dat['vision_tele']?$('<li>').text("Teleop"):"")
			.append(dat['vision_driving']?$('<li>').text("Driving"):"")
			.append(dat['vision_collecting']?$('<li>').text("Collecting"):"")
			.append(dat['vision_placing']?$('<li>').text("Placing"):"")
			.append(dat['vision_docking']?$('<li>').text("Docking"):"")
			.append(
				(
					!dat['vision_auto']&&
					!dat['vision_tele']&&
					!dat['vision_driving']&&
					!dat['vision_collecting']&&
					!dat['vision_placing']&&
					!dat['vision_docking']
				)?$('<li>').text("None"):"")
		)
		el.append($("<h4>").text("Robot tested"))
		el.append($("<ul>")
			.append(dat['field_built']?$('<li>').text("Built a practice field"):"")
			.append(dat['field_other_team']?$('<li>').text("Used another team's practice field"):"")
			.append(dat['field_wpi']?$('<li>').text("WPI Practice field"):"")
			.append(dat['field_events']?$('<li>').text("Previous Events"):"")
			.append(
				(
					!dat['field_built']&&
					!dat['field_other_team']&&
					!dat['field_wpi']&&
					!dat['field_events']
				)?$('<li>').text("None"):"")
		)
		el.append($("<h4>").text("Built field elements"))
		el.append($("<ul>")
			.append(dat['built_grid']?$('<li>').text("Grid"):"")
			.append(dat['built_charging_station']?$('<li>').text("Charging Station"):"")
			.append(dat['built_double_substation']?$('<li>').text("Double Substation"):"")
			.append(dat['built_single_substation']?$('<li>').text("Single Substation"):"")
			.append(
				(
					!dat['built_grid']&&
					!dat['built_charging_station']&&
					!dat['built_double_substation']&&
					!dat['built_single_substation']
				)?$('<li>').text("None"):"")
		)
		el.append($("<h4>").text("Meets days per week"))
		el.append($("<p>").text(format(dat['practice_days'])))
		if(dat['notes']){
			el.append($("<h4>").text("Notes"))
			el.append($("<p class=comments>").text(dat['notes']))
		}
		el.append($("<p class=scouter>").text(dat['scouter']))
	})

	function format(s){
		s = ""+s
		if (!s||s=="0"||/^undefined/.test(s)) s = "Unknown"
		s = s[0].toUpperCase() + s.slice(1)
		return s.replace(/_/g," ")
	}
}

var whiteboardStamps = [
	"/2023/cone-stamp.png",
	"/2023/cube-stamp.png"
]
