"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit){

	function bool_1_0(s){
		return (!s||/^0|no|false$/i.test(""+s))?0:1
	}

	var pointValues = {
		auto_leave:3,
		auto_l1:3,
		auto_l2:4,
		auto_l3:6,
		auto_l4:7,
		processor:2,
		net:4,
		tele_l1:2,
		tele_l2:3,
		tele_l3:4,
		tele_l4:5,
		park:2,
		shallow:6,
		deep:12,
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
			scout[field] = ((scout[field]||"")+"").split(" ").map(num => parseInt(num, 10)).filter(Number)
		}
	})

	scout.bricked = bool_1_0(scout.bricked)
	scout.defense = bool_1_0(scout.defense)
	scout.end_game_climb_fail = bool_1_0(scout.end_game_climb_fail)
	scout.score = 0

	pit.auto_paths = []
	for (var i=1; i<=9; i++){
		var path = pit[`auto_${i}_path`]
		if (path) pit.auto_paths.push(path)
	}

	var cycleSeconds =  scout.full_cycle_count * scout.full_cycle_average_seconds + aggregate.full_cycle_count * aggregate.full_cycle_average_seconds
	var cycles = scout.full_cycle_count + aggregate.full_cycle_count

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
	aggregate.count = (aggregate.count||0)+1
	aggregate.full_cycle_fastest_seconds = (scout.full_cycle_fastest_seconds&&(aggregate.full_cycle_fastest_seconds||999)>scout.full_cycle_fastest_seconds)?scout.full_cycle_fastest_seconds:(aggregate.full_cycle_fastest_seconds||0)
	if (cycles > 0) aggregate.full_cycle_average_seconds = Math.round(cycleSeconds / cycles)
	aggregate.max_score = Math.max(aggregate.max_score||0,scout.score)
	aggregate.min_score = Math.min(aggregate.min_score===undefined?999:aggregate.min_score,scout.score)
	aggregate.auto_place_percent = Math.round(100 * aggregate.auto_place / aggregate.auto_notes_handled)

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
	auto_start:{
		name: "Location where the robot starts",
		type: "heatmap",
		image: "/2025/start-area-blue.png",
		aspect_ratio: 4,
		whiteboard_start: 0,
		whiteboard_end: 13,
		whiteboard_char: "□",
		whiteboard_us: true
	},
	auto_leave:{
		name: "Left the Start Line During Auto",
		type: "%",
		timeline_stamp: "L",
		timeline_fill: "#BB0",
		timeline_outline: "#888"
	},
	auto_leave_score:{
		name: "Score for Leaving the Start Line During Auto",
		type: "avg"
	},
	no_show:{
		name: "No Show",
		type: "%",
		timeline_stamp: "N",
		timeline_fill: "#F0F",
		timeline_outline: "#F0F"
	},
	defense:{
		name: "Played Defense",
		type: "%"
	},
	bricked:{
		name: "Robot Disabled",
		type: "%"
	},
	end_game_climb_fail:{
		name: "Climb Failed",
		type: "%"
	},
	auto_paths:{
		name: "Auto Paths",
		type: "pathlist",
		aspect_ratio: .75,
		whiteboard_start: 0,
		whiteboard_end: 64,
		whiteboard_us: true,
		source: "pit"
	},
	auto_collect_order:{
		name: "Order of Auto Collection",
		type: "text"
	},
	auto_place:{
		name: "Scoring Elements Placed During Auto",
		type: "avg"
	},
	auto_score:{
		name: "Score During Auto",
		type: "avg"
	},
	auto_place_percent:{
		name: "Percent of Scoring Elements Placed During Auto",
		type: "ratio"
	},
	tele_drop:{
		name: "Scoring Elements Dropped in Teleop",
		type: "avg",
		timeline_stamp: "D",
		timeline_fill: "#000",
		timeline_outline: "#808"
	},
	tele_place:{
		name: "Scoring Elements Placed During Teleop",
		type: "avg"
	},
	place:{
		name: "Scoring Elements Placed",
		type: "avg"
	},
	parked_score:{
		name: "Parking Score",
		type: "avg"
	},
	end_game_position:{
		name: "Position at End of Game",
		type: "text"
	},
	timeline:{
		name: "Timeline",
		type: "timeline"
	},
	max_score:{
		name: "Maximum Score Contribution",
		type: "minmax"
	},
	min_score:{
		name: "Minimum Score Contribution",
		type: "minmax"
	},
	score:{
		name: "Score Contribution",
		type: "avg"
	},
	scouter:{
		name: "Scouter",
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
	"Game Stages":["auto_score","tele_amp_speaker_score","stage_score"],
	Auto:["auto_leave_score", "auto_amp_score", "auto_speaker_score"],
	Teleop:["tele_amp_score","tele_speaker_score"],
	Stage:["trap_score","parked_score","onstage_score","spotlit_score","harmony_score"]
}

var whiteboardStamps = []

var whiteboardStats = [
	"score",
	"auto_score",
]

// https://www.postman.com/firstrobotics/workspace/frc-fms-public-published-workspace/example/13920602-f345156c-f083-4572-8d4a-bee22a3fdea1
var fmsMapping = [
]

function showPitScouting(el,team){
	promisePitScouting().then(pitData => {
		var dat = pitData[team]||{}
		if (dat.team_name) el.append($("<p>").text("Team name: " + dat.team_name))
		if (dat.team_location) el.append($("<p>").text("Location: " + dat.team_location))
		if (dat.bot_name) el.append($("<p>").text("Bot name: " + dat.bot_name))
		el.append($("<h4>").text("Autos"))
		var list = $("<ul>")
		for (var i=1; i<=9; i++){
			var desc = dat[`auto_${i}_description`]||""
			var tested = dat[`auto_${i}_testing`]||'no'
			if (tested == 'no') tested = ($('<span style=color:red>').text("Not tested"))
			if (tested == 'practice') tested = ($('<span style=color:yellow>').text("Tested in practice only"))
			if (tested == 'match') tested = ($('<span style=color:green>').text("Test in a match"))
			if (desc.length) list.append($('<li style=white-space:pre-wrap>').append(tested).append(": ").append(desc))
		}
		el.append(list)

		el.append('<h4>Capabilities</h4>')
		list = $("<ul>")
		list.append((dat.notes_amp?$('<li>'):$('<li style=text-decoration:line-through>')).text("Amp"))
		list.append((dat.notes_speaker?$('<li>'):$('<li style=text-decoration:line-through>')).text("Speaker"))
		list.append((dat.notes_trap?$('<li>'):$('<li style=text-decoration:line-through>')).text("Trap"))
		list.append((dat.onstage?$('<li>'):$('<li style=text-decoration:line-through>')).text("Onstage"))
		el.append(list)

		el.append($("<h4>").text("Robot"))
		list = $("<ul>")
		list.append($("<li>").text("Dimensions (inches without bumpers): " + format(dat.frame_length+'x'+dat.frame_width+'"')))
		list.append($("<li>").text("Weight (pounds): "+ format(dat.weight)))
		list.append($("<li>").text("Drivetrain: " + format(dat.drivetrain)))
		list.append($("<li>").text("Swerve: " + format(dat.swerve)))
		list.append($("<li>").text("Drivetrain motors: " +  (dat.motor_count||"")+" "+format(dat.motors)))
		list.append($("<li>").text("Wheels: " + (dat.wheel_count||"")+" "+format(dat.wheels)))
		el.append(list)

		el.append($("<h4>").text("Computer Vision"))
		list = $("<ul>")
		list.append((dat.vision_auto?$('<li>'):$('<li style=text-decoration:line-through>')).text("Auto"))
		list.append((dat.vision_collecting?$('<li>'):$('<li style=text-decoration:line-through>')).text("Collecting"))
		list.append((dat.vision_placing?$('<li>'):$('<li style=text-decoration:line-through>')).text("Placing, shooting or aiming"))
		list.append((dat.vision_localization?$('<li>'):$('<li style=text-decoration:line-through>')).text("Localization"))
		el.append(list)
	})

	function format(s){
		s = ""+s
		if (!s||s=="0"||/^undefined/.test(s)) s = "Unknown"
		s = s[0].toUpperCase() + s.slice(1)
		return s.replace(/_/g," ")
	}
}

function showSubjectiveScouting(el,team){
	promiseSubjectiveScouting().then(subjectiveData => {
		var dat = subjectiveData[team]||{},
		graph=$('<div class=graph>'),
		f
		el.append(graph)
		f = dat.penalties||""
		if (f){
			el.append('<h4>Penalties</h4>')
			el.append($('<div style=white-space:pre-wrap>').text(f))
		}
		f = dat.defense_tips||""
		if (f){
			el.append('<h4>Defense Tips</h4>')
			el.append($('<div style=white-space:pre-wrap>').text(f))
		}
		f = dat.notes||""
		if (f){
			el.append('<h4>Other</h4>')
			el.append($('<div style=white-space:pre-wrap>').text(f))
		}
	})
}
