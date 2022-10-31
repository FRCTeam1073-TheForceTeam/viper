var rungMap = {0:0, 1:4, 2:6, 3:10, 4:15}

function addStat(map,field,value){
    map[field] = (map[field]||0)+(value||0)
}

function aggregateStats(scout, aggregate){
    aggregate['count'] = (aggregate['count']||0)+1

    var sumFields = "auto_low_hub,auto_bounce_out,auto_missed,auto_high_hub,taxi,human,teleop_low_hub,teleop_bounce_out,teleop_missed,teleop_high_hub,fouls,techfouls".split(/,/);
    for (var i=0; i<sumFields.length; i++){
        var field = sumFields[i]        
        addStat(aggregate,field,scout[field])
    }

    var auto = (scout['taxi']||0)*2 + (scout['auto_low_hub']||0)*2 + (scout['auto_high_hub']||0)*4,
    teleop = (scout['tele_low_hub']||0) + (scout['tele_high_hub']||0)*2,
    endGame = rungMap[scout['rung']||0],
    score = auto+teleop+endGame

    addStat(aggregate,'auto',auto)
    addStat(aggregate,'teleop',teleop)
    addStat(aggregate,'end_game',endGame)
    addStat(aggregate,'score',score)
}

var statSections = {
    "Total": {
        "Score": "score"
    },
    "Game Stages": {
        "Auto": "auto",
        "Remote Control": "teleop",
        "End Game": "end_game"
    },
    "Auto": {
        "Taxi (2 points)": "taxi",
        "Balls in Low Hub (2 points)": "auto_low_hub",
        "Balls in High Hub (4 points)": "auto_high_hub",
        "Missed shots": "auto_missed",
        "Shots bounced out": "auto_bounce_out"
    },
    "Remote Control": {
        "Balls in Low Hub (1 point)": "teleop_low_hub",
        "Balls in High Hub (2 points)": "teleop_high_hub",
        "Missed shots": "teleop_missed",
        "Shots bounced out": "teleop_bounce_out"
    },
    "End Game": {
        "Hanging points": "end_game"
    }
}