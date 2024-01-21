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
			aggregate[field] = aggregate[field]||0
		}
		if(/^heatmap$/.test(statInfo[field]['type'])){
			scout[field] = scout[field]||""
			aggregate[field] = aggregate[field]||""
		}
		if(/^int-list$/.test(statInfo[field]['type'])){
			scout[field] = (scout[field]||"").split(" ").map(num => parseInt(num, 10)).filter(Number)
		}
	})

	scout["auto_leave_score"] = pointValues["auto_leave"] * scout["auto_leave"]
	scout["auto_collect_home"] =
		scout["auto_collect_wing_mid"]+
		scout["auto_collect_wing_mid_amp"]+
		scout["auto_collect_wing_amp"]
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
	scout["trap_percent"] = scout["trap"]>0?1:0
	scout["trap_score"] = pointValues["tele_trap"] * scout["trap"]
	scout["tele_place"] = scout["tele_amp"] + scout["tele_speaker"] + scout["trap"]
	scout["place"] = scout["auto_place"] + scout["tele_place"]
	scout["tele_amp_speaker_score"] = scout["tele_amp_score"] + scout["tele_speaker_score"]
	scout["amp_score"] = scout["auto_amp_score"] + scout["tele_amp_score"]
	scout["speaker_score"] = scout["auto_speaker_score"] + scout["tele_speaker_score"]
	scout["amp_speaker_score"] = scout["auto_amp_speaker_score"] + scout["tele_amp_speaker_score"]
	scout["parked_score"] = pointValues["tele_park"] * (scout["end_game_position"]=="parked"?1:0)
	scout["onstage_percent"] = scout["end_game_position"]=="onstage"?1:0
	scout["onstage_score"] = pointValues["tele_onstage"] * (scout["end_game_position"]=="onstage"?1:0)
	if (scout["end_game_position"]!="onstage"){
		scout["end_game_spotlit"]=""
		scout["end_game_harmony"]=0
	}
	scout["spotlit_score"] = pointValues["tele_spotlit"] * (scout["end_game_spotlit"]=="spotlit"?1:0)
	scout["harmony_score"] = Math.round(pointValues["tele_harmony"] * scout["end_game_harmony"] / (scout["end_game_harmony"]+1))
	scout["stage_score"] = scout["trap_score"] + scout["parked_score"] + scout["onstage_score"] + scout["spotlit_score"] + scout["harmony_score"]
	scout["score"] = scout["auto_score"] + scout["tele_amp_speaker_score"] + scout["stage_score"]
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
		if(/^heatmap$/.test(statInfo[field]['type'])) aggregate[field] += ((aggregate[field]&&scout[field])?" ":"")+scout[field]
		if(/^int-list$/.test(statInfo[field]['type'])) aggregate[field] = (aggregate[field]||[]).concat(scout[field])
	})
	aggregate["count"] = (aggregate["count"]||0)+1
	aggregate["event"] = scout["event"]
	aggregate["full_cycle_fastest_seconds"] = (scout["full_cycle_fastest_seconds"]&&(aggregate["full_cycle_fastest_seconds"]||999)>scout["full_cycle_fastest_seconds"])?scout["full_cycle_fastest_seconds"]:(aggregate["full_cycle_fastest_seconds"]||0)
	if (cycles > 0) aggregate["full_cycle_average_seconds"] = Math.round(cycleSeconds / cycles)
	aggregate["max_score"] = Math.max(aggregate["max_score"]||0,scout["score"])
	aggregate["min_score"] = Math.min(aggregate["min_score"]===undefined?999:aggregate["min_score"],scout["score"])
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
		image: "/2024/start-area-blue.png",
		aspect_ratio: 4
	},
	"auto_leave": {
		name: "Exited the Starting Area During Auto",
		type: "%"
	},
	"auto_leave_score": {
		name: "Score for Exiting the Starting Area During Auto",
		type: "avg"
	},
	"auto_collect_order": {
		name: "Order of Auto Collection",
		type: "text"
	},
	"auto_collect_wing_mid": {
		name: "Collected Wing Note Midfield During Auto",
		type: "%"
	},
	"auto_collect_wing_mid_amp": {
		name: "Collected Wing Note Between Midfield and Amp During Auto",
		type: "%"
	},
	"auto_collect_wing_amp": {
		name: "Collected Wing Note Nearest Amp During Auto",
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
		name: "Amp Score During Auto",
		type: "avg"
	},
	"auto_speaker": {
		name: "Notes Shot in the Speaker During Auto",
		type: "avg"
	},
	"auto_speaker_score": {
		name: "Speaker Score During Auto",
		type: "avg"
	},
	"auto_amp_speaker_score": {
		name: "Speaker and Amp Score During Auto",
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
		name: "Amp Score During Teleop",
		type: "avg"
	},
	"tele_speaker_unamped": {
		name: "Notes Shot in the Speaker when Not Amped During Teleop",
		type: "avg"
	},
	"tele_speaker_unamped_score": {
		name: "Speaker Score when Not Amped During Teleop",
		type: "avg"
	},
	"tele_speaker_amped": {
		name: "Notes Shot in the Speaker when Amped During Teleop",
		type: "avg"
	},
	"tele_speaker_amped_score": {
		name: "Speaker Score when Amped During Teleop",
		type: "avg"
	},
	"tele_speaker": {
		name: "Notes Shot in the Speaker During Teleop",
		type: "avg"
	},
	"tele_speaker_score": {
		name: "Speaker Score During Teleop",
		type: "avg"
	},
	"trap": {
		name: "Notes Placed in the Trap",
		type: "avg"
	},
	"trap_percent": {
		name: "Trap Percent",
		type: "%"
	},
	"trap_score": {
		name: "Trap Score",
		type: "avg"
	},
	"tele_amp_speaker_score": {
		name: "Speaker and Amp Score During Teleop",
		type: "avg"
	},
	"amp_score": {
		name: "Amp Score",
		type: "avg"
	},
	"speaker_score": {
		name: "Speaker Score",
		type: "avg"
	},
	"amp_speaker_score": {
		name: "Speaker and Amp Score",
		type: "avg"
	},
	"tele_place": {
		name: "Notes Placed During Teleop",
		type: "avg"
	},
	"place": {
		name: "Notes Placed",
		type: "avg"
	},
	"full_cycles": {
		name: "Full Cycle Seconds",
		type: "int-list"
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
	"floor_pickup": {
		name: "Floor Pickup",
		type: "%"
	},
	"source_pickup": {
		name: "Source Pickup",
		type: "%"
	},
	"passing": {
		name: "Passed Notes",
		type: "%"
	},
	"stashing": {
		name: "Stashed Notes",
		type: "%"
	},
	"end_game_hang_location": {
		name: "Hanging location at End Game",
		type: "text"
	},
	"parked_score": {
		name: "Parking Score",
		type: "avg"
	},
	"end_game_position": {
		name: "Position at End of Game",
		type: "text"
	},
	"end_game_harmony": {
		name: "Harmony at End of Game",
		type: "text"
	},
	"onstage_percent": {
		name: "Onstage Percent",
		type: "%"
	},
	"onstage_score": {
		name: "Onstage Score",
		type: "avg"
	},
	"end_game_spotlit": {
		name: "Spotlit at End of Game",
		type: "text"
	},
	"spotlit_score": {
		name: "Spotlit Score",
		type: "avg"
	},
	"harmony_score": {
		name: "Harmony Score",
		type: "avg"
	},
	"stage_score": {
		name: "Stage Score",
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
	"Match Score":{
		graph:"bar",
		data:["score"]
	},
	"Match Stages":{
		graph:"stacked",
		data:["auto_score","tele_amp_speaker_score","stage_score"]
	},
	"Full Cycle Times":{
		graph:"boxplot",
		data:['full_cycle_fastest_seconds','full_cycles']
	},
	"Start Location":{
		graph:"heatmap",
		data:['auto_start']
	},
	"Auto Collection":{
		graph:"stacked",
		data:['auto_collect_wing_amp', 'auto_collect_wing_mid_amp', 'auto_collect_wing_mid', 'auto_collect_centerline_amp', 'auto_collect_centerline_mid_amp', 'auto_collect_centerline_mid', 'auto_collect_centerline_mid_source', 'auto_collect_centerline_source']
	},
}

var aggregateGraphs = {
	"Match Score":{
		graph:"boxplot",
		data:["max_score","score","min_score"]
	},
	"Match Stages":{
		graph:"stacked",
		data:["auto_score","tele_amp_speaker_score","stage_score"]
	},
	"Full Cycle Times":{
		graph:"boxplot",
		data:['full_cycle_fastest_seconds','full_cycles']
	},
	"Start Location":{
		graph:"heatmap",
		data:['auto_start']
	},
}


var matchPredictorSections = {
	"Total":["score"],
	"Game Stages":["auto_score","tele_amp_speaker_score","stage_score"],
	"Auto":["auto_leave_score", "auto_amp_score", "auto_speaker_score"],
	"Teleop":["tele_amp_score","tele_speaker_score"],
	"Stage":["trap_score","parked_score","onstage_score","spotlit_score","harmony_score"]
}

var plannerSections = {
	"Total":["score"],
	"Game Stages":["auto_score","tele_amp_speaker_score","stage_score"],
	"Placement":["speaker_score","amp_score","trap_score","place"],
	"Percents":["trap_percent","onstage_percent","coopertition"],
}

var fmsMapping = [
]

function showPitScouting(el,team){

	loadPitScouting(function(pitData){
		var dat = pitData[team]||{}
		if (dat['team_name']) el.append($("<p>").text("Team name: " + dat['team_name']))
		if (dat['team_location']) el.append($("<p>").text("Location: " + dat['team_location']))
		if (dat['bot_name']) el.append($("<p>").text("Bot name: " + dat['bot_name']))
		el.append($("<h4>").text("Autos"))
		var autoList = $("<ul>")
		for (var i=0; i<9; i++){
			var desc = dat[`auto_${i}_description`]
			if (desc) autoList.append('<li style=white-space:pre-wrap>').text(desc)
		}
		el.append(autoList)
	})

	function format(s){
		s = ""+s
		if (!s||s=="0"||/^undefined/.test(s)) s = "Unknown"
		s = s[0].toUpperCase() + s.slice(1)
		return s.replace(/_/g," ")
	}
}

var whiteboardStamps = [
]
