function addStat(map,field,value){
    map[field] = (map[field]||0)+(value||0)
}

var endGamePoints=[0,3,6,12]
function aggregateStats(scout, aggregate){

    scout['start_score'] = (scout['startlevel']||0)*3
    scout['hatch_score'] = (scout['total_hatches']||0)*2
    scout['cargo_score'] = (scout['total_cargo']||0)*3
    scout['end_score'] = endGamePoints[scout['end_level']||0]
    scout['score'] = scout['start_score'] + scout['hatch_score'] + scout['cargo_score'] + scout['end_score']
 
    scout['end_level_1'] = scout['end_level']==1?1:0
    scout['end_level_2'] = scout['end_level']==2?1:0
    scout['end_level_3'] = scout['end_level']==3?1:0

    if (scout['comments'] && /\%[0-9a-fA-F]{2}/.test(scout['comments'])) scout['comments'] = decodeURIComponent(scout['comments'])
    if (scout['comments'] && "none" == scout['comments']) scout['comments'] = ""
    if (scout['scouter'] && "unknown" == scout['scouter']) scout['scouter'] = ""

    aggregate['count'] = (aggregate['count']||0)+1

    var sumFields = Object.keys(statInfo)
    for (var i=0; i<sumFields.length; i++){
        var field = sumFields[i]        
        addStat(aggregate,field,scout[field])
    }
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
    "count": {
        name: "Number of Matches",
        type: "count"
    },
    "start_score": {
        name: "Starting Position Score Contribution",
        type: "avg"
    },
    "hatch_score": {
        name: "Hatches Score Contribution",
        type: "avg"
    },
    "cargo_score": {
        name: "Cargo Score Contribution",
        type: "avg"
    },
    "end_score": {
        name: "End Position Score Contribution",
        type: "avg"
    },    "startlevel": {
        name: "Starting level",
        type: "avg"
    },
    "total_hatches": {
        name: "Total hatches",
        type: "avg"
    },
    "total_cargo": {
        name: "Total cargo",
        type: "avg"
    },
    "end_level": {
        name: "Ending level",
        type: "avg"
    },
    "end_level_1": {
        name: "Times on lowest ending level",
        type: "%"
    },
    "end_level_2": {
        name: "Times on middle ending level",
        type: "%"
    },
    "end_level_3": {
        name: "Times on highest ending level",
        type: "%"
    },
    "auto_hatch_cs": {
        name: "Hatches onto cargo ship during auto",
        type: "avg"
    },
    "auto_cargo_cs": {
        name: "Cargo into cargo ship during auto",
        type: "avg"
    },
    "auto_hatch_topr": {
        name: "Hatches onto top of rocket during auto",
        type: "avg"
    },
    "auto_hatch_midr": {
        name: "Hatches onto middle of rocket during auto",
        type: "avg"
    },
    "auto_hatch_botr": {
        name: "Hatches onto bottom of rocket during auto",
        type: "avg"
    },
    "auto_cargo_topr": {
        name: "Cargo into top of rocket during auto",
        type: "avg"
    },
    "auto_cargo_midr": {
        name: "Cargo into middle of rocket during auto",
        type: "avg"
    },
    "auto_cargo_botrr": {
        name: "Cargo into bottom of rocket during auto",
        type: "avg"
    },
    "hatch_cs": {
        name: "Hatches onto cargo ship during remote control",
        type: "avg"
    },
    "cargo_cs": {
        name: "Cargo into cargo ship during remote control",
        type: "avg"
    },
    "hatch_topr": {
        name: "Hatches onto top of rocket during remote control",
        type: "avg"
    },
    "hatch_midr": {
        name: "Hatches onto middle of rocket during remote control",
        type: "avg"
    },
    "hatch_botrr": {
        name: "Hatches onto bottom of rocket during remote control",
        type: "avg"
    },
    "cargo_topr": {
        name: "Cargo into top of rocket during remote control",
        type: "avg"
    },
    "cargo_midr": {
        name: "Cargo into middle of rocket during remote control",
        type: "avg"
    },
    "cargo_botrr": {
        name: "Cargo into bottom of rocket during remote control",
        type: "avg"
    },
    'defense':{
        name: "Played defense",
        type: "enum",
        values: ["","Bad","OK","Great"]
    },
    'defended':{
        name: "Good against defense",
        type: "enum",
        values: ["","Affected","OK","Great"]
    },
    'fouls':{
        name: "Fouls (-4 points)",
        type: "avg",
        good: "low"
    },
    'techfouls':{
        name: "Tech Fouls (-8 points)",
        type: "avg",
        good: "low"
    },
    'rank':{
        name: "Rank",
        type: "enum",
        values: ["","Struggled","Productive","Captain"]
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

var statSections = {
    "Total": [
        "score",
        "count"
    ],
    "Game Stages": [
        "start_score",
        "hatch_score",
        "cargo_score",
        "end_score"
    ],
    "Fouls": [
        "fouls",
        "techfouls"
    ],
    "Auto": [
        'auto_hatch_cs',
        'auto_cargo_cs',
        'auto_hatch_topr',
        'auto_hatch_midr',
        'auto_hatch_botr',
        'auto_cargo_topr',
        'auto_cargo_midr',
        'auto_cargo_botr'
        
    ],
    "Remote Control":  [
        'hatch_cs',
        'cargo_cs',
        'hatch_topr',
        'hatch_midr',
        'hatch_botr',
        'cargo_topr',
        'cargo_midr',
        'cargo_botr'        
    ],
    "End Game": [
        "end_level",
        "end_level_1",
        "end_level_2",
        "end_level_3"
    ]
}