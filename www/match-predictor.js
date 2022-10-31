var eventStatsByTeam = {}

loadEventStats(function(){
    var teamList = Object.keys(eventStatsByTeam)
    teamList.sort((a,b) => a-b)
    for (var i=0; i<teamList.length; i++){
        var team = teamList[i]
        $('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
    }
})

function lf(){
    return $('#matchTable .lastFocus')
}

$(document).ready(function(){
    focusNext()
    $('#matchTable input').focus(focusInput).change(setPickedTeams)
})

function focusInput(input){
    if ('target' in input) input = $(input.target)
    if (input[0]==lf()[0]) return
    $('#matchTable input').removeClass('lastFocus')
    input.addClass('lastFocus')
}

function lf(){
    return $('#matchTable input.lastFocus')
}

function withoutValues(i,el){
    return $(el).val() == ''
}

function focusNext(){
    var next = $('#matchTable .redTeamBG input').filter(withoutValues).first()
    if (!next.length) next = $('#matchTable .blueTeamBG input').filter(withoutValues).first()
    if (next.length) focusInput(next)
    return next.length > 0
}

function setPickedTeams(){
    $('#teamButtons button').removeClass("picked")
    var teamCount = 0
    $('#matchTable input').each(function(){
        val = $(this).val()
        if (val){
            $(`#team-${val}`).addClass("picked")
            teamCount++
        }
    })
    if (teamCount == 6){
        $('#prediction').show()
        var red = [parseInt($('#R1').val()),parseInt($('#R2').val()),parseInt($('#R3').val())],
        blue = [parseInt($('#B1').val()),parseInt($('#B2').val()),parseInt($('#B3').val())]
        var redScore = getAllianceValue('score', red),
        blueScore = getAllianceValue('score', blue)
        setStats('redTeamBG',red,'Red', redScore, blueScore)
        setStats('blueTeamBG',blue,'Blue', blueScore, redScore)
    }
}

function setStats(colorClass, alliance, colorName, myScore, theirScore){
    $(`#prediction .${colorClass} .score`).text(myScore).toggleClass('winner',myScore>theirScore)
    var el = $(`#prediction .${colorClass} .statTables`).html('')
    var sections = Object.keys(statSections)
    for (var i=0; i<sections.length; i++){
        var section = sections[i],
        team1=alliance[0],
        team2=alliance[1],
        team3=alliance[2]
        el.append($(`<tr><th colspan=5><h4>${section}</h4></th></tr>`))
        el.append($(`<tr><th></th><th>${team1}</th><th>${team2}</th><th>${team3}</th><th>${colorName}</th></tr>`))
        var stats = Object.keys(statSections[section])
        for (var j=0; j<stats.length; j++){
            var statName = stats[j]
            var field = statSections[section][statName]
            var team1Val = getTeamValue(field,alliance[0]),
            team2Val = getTeamValue(field,alliance[1]),
            team3Val = getTeamValue(field,alliance[2]),
            allianceVal = getAllianceValue(field,alliance)
            el.append($(`<tr><th>${statName}</th><td>${team1Val}</td><td>${team2Val}</td><td>${team3Val}</td><td>${allianceVal}</td></tr>`))
        }
    }

}

function getTeamValue(field, team){
    if (! team in eventStatsByTeam) return 0
    var stats = eventStatsByTeam[team]
    if (! field in stats ||! 'count' in stats || !stats['count']) return 0
    return (stats[field]||0) / stats['count']
}

function getAllianceValue(field, teams){
    var value = 0
    for (var i = 0; i<teams.length; i++){
        value += getTeamValue(field, teams[i])
    }
    return value
}

function teamButtonClicked(){
    lf().val($(this).text())
    focusNext()
    setPickedTeams()
}