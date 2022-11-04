function addStat(map,field,value){
    map[field] = (map[field]||0)+(value||0)
}

function aggregateStats(scout, aggregate){
    scout['auto'] = (scout['taxi']||0)*2 + (scout['auto_low_hub']||0)*2 + (scout['auto_high_hub']||0)*4 + scout['fouls']||0*-4 + scout['techfouls']||0*-8
    scout['teleop'] = (scout['teleop_low_hub']||0) + (scout['teleop_high_hub']||0)*2
    scout[statInfo['rung']['breakout'][scout['rung']||0]] = 1
    scout['end_game'] = statInfo['rung']['points'][scout['rung']||0]
    scout['score'] = scout['auto'] + scout['teleop'] + scout['end_game']
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
    "auto": {
        name: "Auto Score",
        type: "avg"
    },
    "teleop": {
        name: "Remote Control Score",
        type: "avg"
    },
    "end_game": {
        name: "End Game Score",
        type: "avg"
    },
    "auto_low_hub": {
        name: "Auto Balls in Low Hub (2 points)",
        type: "avg"
    },
    "auto_high_hub": {
        name: "Auto Balls in High Hub (4 points)",
        type: "avg"
    },
    "auto_missed": {
        name: "Auto Missed shots",
        type: "avg",
        good: "low"
    },
    "auto_bounce_out": {
        name: "Auto Shots bounced out",
        type: "avg",
        good: "low"
    },
    "taxi": {
        name: "Auto Taxi (2 points)",
        type: "avg"
    },
    "human": {
        name: "Auto Human player goal (not included in score)",
        type: "%"
    },
    "teleop_low_hub": {
        name: "Remote Control Balls in Low Hub (1 point)",
        type: "avg"
    },
    "teleop_high_hub": {
        name: "Remote Control Balls in High Hub (2 points)",
        type: "avg"
    },
    "teleop_missed": {
        name: "Remote Control Missed shots",
        type: "avg",
        good: "low"
    },
    "teleop_bounce_out": {
        name: "Remote Control Shots bounced out",
        type: "avg",
        good: "low"
    },
    "shoot_from_hub": {
        name: "Took shots from next to hub",
        type: "%"
    },
    "shoot_from_field": {
        name: "Took shots from the field",
        type: "%"
    },
    "shoot_from_outer_LP": {
        name: "Took shots from outer landing pad",
        type: "%"
    },
    "shoot_from_wallLP": {
        name: "Took shots from landing pad by wall",
        type: "%"
    },
    "end_game": {
        name: "Hanging score",
        type: "avg"
    },
    "rung": {
        name: "Hung on rung",
        type: "enum",
        values: ['None','Low rung','Mid rung','High rung','Traversal rung'],
        breakout: ['no_rung','low_rung','mid_rung','high_rung','traversal_rung'],
        points: [0,4,6,10,15]
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
        "auto",
        "teleop",
        "end_game"
    ],
    "Fouls": [
        "fouls",
        "techfouls"
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