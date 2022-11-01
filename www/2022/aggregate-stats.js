var rungScoreMap = {0:0, 1:4, 2:6, 3:10, 4:15}
var rungNameMap = {0:'no_rung', 1:'low_rung', 2:'mid_rung', 3:'high_rung', 4:'traversal_rung'}

function addStat(map,field,value){
    map[field] = (map[field]||0)+(value||0)
}

function aggregateStats(scout, aggregate){
    scout['auto'] = (scout['taxi']||0)*2 + (scout['auto_low_hub']||0)*2 + (scout['auto_high_hub']||0)*4
    scout['teleop'] = (scout['teleop_low_hub']||0) + (scout['teleop_high_hub']||0)*2
    scout[rungNameMap[scout['rung']||0]] = 1
    scout['end_game'] = rungScoreMap[scout['rung']||0]
    scout['score'] = scout['auto'] + scout['teleop'] + scout['end_game']


    aggregate['count'] = (aggregate['count']||0)+1

    var sumFields = Object.keys(statInfo)
    for (var i=0; i<sumFields.length; i++){
        var field = sumFields[i]        
        addStat(aggregate,field,scout[field])
    }
}

var statInfo = {
    "score": {
        name: "Score",
        type: "avg"
    },
    "count": {
        name: "Number of Matches",
        type: "count"
    },
    "auto": {
        name: "Auto",
        type: "avg"
    },
    "teleop": {
        name: "Remote Control",
        type: "avg"
    },
    "end_game": {
        name: "End Game",
        type: "avg"
    },
    "taxi": {
        name: "Taxi (2 points)",
        type: "avg"
    },
    "auto_low_hub": {
        name: "Balls in Low Hub (2 points)",
        type: "avg"
    },
    "auto_high_hub": {
        name: "Balls in High Hub (4 points)",
        type: "avg"
    },
    "auto_missed": {
        name: "Missed shots",
        type: "avg",
        good: "low"
    },
    "auto_bounce_out": {
        name: "Shots bounced out",
        type: "avg",
        good: "low"
    },
    "teleop_low_hub": {
        name: "Balls in Low Hub (1 point)",
        type: "avg"
    },
    "teleop_high_hub": {
        name: "Balls in High Hub (2 points)",
        type: "avg"
    },
    "teleop_missed": {
        name: "Missed shots",
        type: "avg",
        good: "low"
    },
    "teleop_bounce_out": {
        name: "Shots bounced out",
        type: "avg",
        good: "low"
    },
    "end_game": {
        name: "Hanging points",
        type: "avg"
    },
    "human": {
        name: "Human player goal (not included in score)",
        type: "%"
    },
    'no_rung': {
        name: "Didn't hang",
        type: "%",
        good: "low"
    },
    'low_rung': {
        name: "Hung on low rung",
        type: "%"
    },
    'mid_rung': {
        name: "Hung on mid rung",
        type: "%"
    },
    'high_rung': {
        name: "Hung on high rung",
        type: "%"
    },
    'traversal_rung': {
        name: "Hung on traversal rung",
        type: "%"
    }
}

var statSections = {
    "Total": [
        "score",
        "count"
    ],
    "Game Stages": [
        "auto",
        "teleop",
        "end_game"
    ],
    "Auto": [
        "taxi",
        "auto_low_hub",
        "auto_high_hub",
        "auto_missed",
        "auto_bounce_out",
        "human"
    ],
    "Remote Control": [
        "teleop_low_hub",
        "teleop_high_hub",
        "teleop_missed",
        "teleop_bounce_out"
    ],
    "End Game": [
        "end_game",
        'no_rung',
        'low_rung',
        'mid_rung',
        'high_rung',
        'traversal_rung'
    ]
}