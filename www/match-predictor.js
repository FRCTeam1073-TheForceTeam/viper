
function lf(){
    return $('#matchTable .lastFocus')
}

$(document).ready(function(){
    loadEventStats(function(){
        var teamList = Object.keys(eventStatsByTeam)
        teamList.sort((a,b) => a-b)
        for (var i=0; i<teamList.length; i++){
            var team = teamList[i]
            $('#teamButtons').append($(`<button id=team-${team} class=team>${team}</button>`).click(teamButtonClicked))
        }
        loadFromLocationHash()
        $(window).on('hashchange', loadFromLocationHash)
    })
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
        var redScore = Math.round(getAllianceValue('score', red)),
        blueScore = Math.round(getAllianceValue('score', blue))
        setStats('redTeamBG',red,'Red', redScore, blueScore)
        setStats('blueTeamBG',blue,'Blue', blueScore, redScore)
    } else {
        $('#prediction').hide()
    }
    setLocationHash()
}

function setLocationHash(){
    var hash = `event=${eventId}`
    $('#matchTable input').each(function(){
        var val = $(this).val()
        if (/^[0-9]+$/.test(val)){
            var name = $(this).attr('id')
            hash += `&${name}=${val}`
        }
    })
    location.hash = hash
}

function loadFromLocationHash(){
    $('#matchTable input').each(function(){
        var name = $(this).attr('id')        
        var val = team = (location.hash.match(new RegExp(`^\\#(?:.*\\&)?(?:${name}\\=)([0-9]+)(?:\\&.*)?$`))||["",""])[1]
        $(this).val(val)
    })
    setPickedTeams()
    focusNext()
}

function setStats(colorClass, alliance, colorName, myScore, theirScore){
    $(`#prediction .${colorClass} .score`).text(myScore).toggleClass('winner',myScore>theirScore)
    var el = $(`#prediction .${colorClass} .statTables`).html('')
    var sections = Object.keys(matchPredictorSections)
    for (var i=0; i<sections.length; i++){
        var section = sections[i],
        team1=alliance[0],
        team2=alliance[1],
        team3=alliance[2]
        el.append($(`<tr><th colspan=5><h4>${section}</h4></th></tr>`))
        el.append($(`<tr><th></th><th>${team1}</th><th>${team2}</th><th>${team3}</th><th>${colorName}</th></tr>`))
        for (var j=0; j<matchPredictorSections[section].length; j++){
            var field = matchPredictorSections[section][j]
            statInfo[field] = statInfo[field]||{}
            var statName = statInfo[field]['name']||field,
            statType = statInfo[field]['type']||"",
            team1Val = Math.round(getTeamValue(field,alliance[0])),
            team2Val = Math.round(getTeamValue(field,alliance[1])),
            team3Val = Math.round(getTeamValue(field,alliance[2])),
            allianceVal = Math.round(getAllianceValue(field,alliance))
            if (statType=='avg') el.append($(`<tr><th>${statName}</th><td>${team1Val}</td><td>${team2Val}</td><td>${team3Val}</td><td>${allianceVal}</td></tr>`))
        }
    }
}

function getTeamValue(field, team){
    if (! team in eventStatsByTeam) return 0
    var stats = eventStatsByTeam[team]
    if (! stats || ! field in stats ||! 'count' in stats || !stats['count']) return 0
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