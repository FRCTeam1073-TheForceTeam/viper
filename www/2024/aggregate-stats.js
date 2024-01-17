"use strict"

function aggregateStats(scout, aggregate){

	var pointValues = {
		"auto_leave":2,
		"auto_amp":2,
		"auto_speaker":5,
		"tele_amp":1,
		"tele_speaker_unamped":2,
		"tele_speaker_amped":5,
		"tele_trap":5,
		"tele_park":1,
		"tele_onstage":3,
		"tele_spotlit":1,
		"tele_harmony":2,
	}

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			scout[field] = scout[field]||0
		}
	})

	scout["auto_leave_score"] = pointValues["auto_leave"] * scout["auto_leave"]
	scout["auto_collect_home"] =
		scout["auto_collect_blue_mid"]+
		scout["auto_collect_blue_mid_amp"]+
		scout["auto_collect_blue_amp"]+
		scout["auto_collect_red_mid"]+
		scout["auto_collect_red_mid_amp"]+
		scout["auto_collect_red_amp"]
	scout["auto_collect_center"] =
		scout["auto_collect_centerline_source"]+
		scout["auto_collect_centerline_mid_source"]+
		scout["auto_collect_centerline_mid"]+
		scout["auto_collect_centerline_mid_amp"]+
		scout["auto_collect_centerline_amp"]
	scout["auto_collect"] = scout["auto_collect_home"] + scout["auto_collect_center"]
	scout["auto_amp_score"] = pointValues["auto_amp"] * scout["auto_amp"]
	scout["auto_speaker_score"] = pointValues["auto_speaker"] * scout["auto_speaker"]
	scout["auto_amp_speaker_score"] = scout["auto_amp_score"] + scout["auto_speaker_score"]
	scout["auto_place"] = scout["auto_amp"] + scout["auto_speaker"]
	scout["auto_score"] = scout["auto_leave_score"] + scout["auto_amp_score"] + scout["auto_speaker_score"]
	scout["tele_collect"] = scout["tele_collect_home"]+
		scout["tele_collect_center"]+
		scout["tele_collect_source"]
	scout["tele_amp_score"] = pointValues["tele_amp"] * scout["tele_amp"]
	scout["tele_speaker_unamped_score"] = pointValues["tele_speaker_unamped"] * scout["tele_speaker_unamped"]
	scout["tele_speaker_amped_score"] = pointValues["tele_speaker_amped"] * scout["tele_speaker_amped"]
	scout["tele_speaker"] = scout["tele_speaker_unamped"] + scout["tele_speaker_amped"]
	scout["tele_speaker_score"] = scout["tele_speaker_unamped_score"] + scout["tele_speaker_amped_score"]
	scout["trap_score"] = pointValues["tele_trap"] * scout["trap"]
	scout["tele_place"] = scout["tele_amp"] + scout["tele_speaker"] + scout["tele_trap"]
	scout["tele_amp_speaker_score"] = scout["tele_amp_score"] + scout["tele_speaker_score"]
	scout["amp_score"] = scout["auto_amp_score"] + scout["tele_amp_score"]
	scout["speaker_score"] = scout["auto_speaker_score"] + scout["tele_speaker_score"]
	scout["amp_speaker_score"] = scout["auto_amp_speaker_score"] + scout["tele_amp_speaker_score"]

	// TODO

	var cycleSeconds =  scout['full_cycle_count'] * scout["full_cycle_average_seconds"] + aggregate['full_cycle_count'] * aggregate["full_cycle_average_seconds"]
	var cycles = scout['full_cycle_count'] + aggregate['full_cycle_count']

	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			aggregate[field] = (aggregate[field]||0)+scout[field]
			var set = `${field}_set`
			aggregate[set] = aggregate[set]||[]
			aggregate[set].push(scout[field])
		}
		if(/^capability$/.test(statInfo[field]['type'])) aggregate[field] = aggregate[field]||scout[field]||0
		if(/^text$/.test(statInfo[field]['type'])) aggregate[field] = (!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
	})
	aggregate["count"] = (aggregate["count"]||0)+1
	aggregate["event"] = scout["event"]
	aggregate["full_cycle_fastest_seconds"] = (scout["full_cycle_fastest_seconds"]&&(aggregate["full_cycle_fastest_seconds"]||999)>scout["full_cycle_fastest_seconds"])?scout["full_cycle_fastest_seconds"]:(aggregate["full_cycle_fastest_seconds"]||0)
	if (cycles > 0) aggregate["full_cycle_average_seconds"] = Math.round(cycleSeconds / cycles)
	aggregate["max_score"] = Math.max(aggregate["max_score"]||0,scout["score"])
	aggregate["min_score"] = Math.min(aggregate["min_score"]===undefined?999:aggregate["min_score"],scout["score"])
	aggregate["tele_max_place_score"] = Math.max(aggregate["tele_max_place_score"]||0,scout["tele_place_score"])
	aggregate["tele_min_place_score"] = Math.min(aggregate["tele_min_place_score"]===undefined?999:aggregate["tele_min_place_score"],scout["tele_place_score"])
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
		type: "heatmap",
		image: "/2024/auto-start-blue.png"
	},
	"auto_leave": {
		name: "Exited the Starting Area During Auto",
		type: "%"
	},
	"auto_leave_score": {
		name: "Score for Exiting the Starting Area During Auto",
		type: "avg"
	},
	"auto_collect_blue_mid": {
		name: "Collected Blue Wing Note Midfield During Auto",
		type: "%"
	},
	"auto_collect_blue_mid_amp": {
		name: "Collected Blue Wing Note Between Midfield and Amp During Auto",
		type: "%"
	},
	"auto_collect_blue_amp": {
		name: "Collected Blue Wing Note Nearest Amp During Auto",
		type: "%"
	},
	"auto_collect_centerline_source": {
		name: "Collected Centerline Note Nearest Source During Auto",
		type: "%"
	},
	"auto_collect_centerline_mid_source": {
		name: "Collected Centerline Note Between Midfield and Amp During Auto",
		type: "%"
	},
	"auto_collect_centerline_mid": {
		name: "Collected Centerline Note Midfield During Auto",
		type: "%"
	},
	"auto_collect_centerline_mid_amp": {
		name: "Collected Centerline Note Between Midfield and Source During Auto",
		type: "%"
	},
	"auto_collect_centerline_amp": {
		name: "Collected Centerline Nearest Amp During Auto",
		type: "%"
	},
	"auto_collect_red_mid": {
		name: "Collected Red Wing Note Midfield During Auto",
		type: "%"
	},
	"auto_collect_red_mid_amp": {
		name: "Collected Red Wing Note Between Midfield and Amp During Auto",
		type: "%"
	},
	"auto_collect_red_amp": {
		name: "Collected Red Wing Note Nearest Amp During Auto",
		type: "%"
	},
	"auto_collect_home": {
		name: "Notes Collected from the Home Wing During Auto",
		type: "avg"
	},
	"auto_collect_center": {
		name: "Notes Collected from Center Field During Auto",
		type: "avg"
	},
	"auto_collect": {
		name: "Notes Collected During Auto",
		type: "avg"
	},
	"auto_amp": {
		name: "Notes Placed in the Amp During Auto",
		type: "avg"
	},
	"auto_amp_score": {
		name: "Score in the Amp During Auto",
		type: "avg"
	},
	"auto_speaker": {
		name: "Notes Shot in the Speaker During Auto",
		type: "avg"
	},
	"auto_speaker_score": {
		name: "Score in the Speaker During Auto",
		type: "avg"
	},
	"auto_amp_speaker_score": {
		name: "Score in the Speaker and Amp During Auto",
		type: "avg"
	},
	"auto_place": {
		name: "Notes Placed During Auto",
		type: "avg"
	},
	"auto_score": {
		name: "Score During Auto",
		type: "avg"
	},
	"coopertition": {
		name: "Alliance activated coopertition light",
		type: "%"
	},
	"tele_collect_home": {
		name: "Notes Collected from Home Wing During Teleop",
		type: "avg"
	},
	"tele_collect_center": {
		name: "Notes Collected from Center Field During Teleop",
		type: "avg"
	},
	"tele_collect_source": {
		name: "Notes Collected from Source During Teleop",
		type: "avg"
	},
	"tele_collect": {
		name: "Notes Collected During Teleop",
		type: "avg"
	},
	"tele_amp": {
		name: "Notes Placed in the Amp During Teleop",
		type: "avg"
	},
	"tele_amp_score": {
		name: "Score in the Amp During Teleop",
		type: "avg"
	},
	"tele_speaker_unamped": {
		name: "Notes Shot in the Speaker when Not Amped During Teleop",
		type: "avg"
	},
	"tele_speaker_unamped_score": {
		name: "Score in the Speaker when Not Amped During Teleop",
		type: "avg"
	},
	"tele_speaker_amped": {
		name: "Notes Shot in the Speaker when Amped During Teleop",
		type: "avg"
	},
	"tele_speaker_amped_score": {
		name: "Score in the Speaker when Amped During Teleop",
		type: "avg"
	},
	"tele_speaker": {
		name: "Notes Shot in the Speaker During Teleop",
		type: "avg"
	},
	"tele_speaker_score": {
		name: "Score in the Speaker During Teleop",
		type: "avg"
	},
	"trap": {
		name: "Notes Placed in the Trap",
		type: "avg"
	},
	"trap_score": {
		name: "Score in the Trap",
		type: "avg"
	},
	"tele_amp_speaker_score": {
		name: "Score in the Speaker and Amp During Teleop",
		type: "avg"
	},
	"amp_score": {
		name: "Score in the Amp",
		type: "avg"
	},
	"speaker_score": {
		name: "Score in the Speaker",
		type: "avg"
	},
	"amp_speaker_score": {
		name: "Score in the Speaker and Amp",
		type: "avg"
	},
	"tele_place": {
		name: "Notes Placed During Teleop",
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
	//onstage,harmony,floor_pickup,source_pickup,passing,stashing,chain_end

	"scouter": {
		name: "Scouter",
		type: "text"
	},
	"comments": {
		name: "Comments",
		type: "text"
	},
	"created": {
		name: "Created",
		type: "datetime"
	},
	"modified": {
		name: "Modified",
		type: "datetime"
	}
}

var teamGraphs = {
}

var aggregateGraphs = {
}

function showPitScouting(el,team){
}

var whiteboardStamps = [
]
