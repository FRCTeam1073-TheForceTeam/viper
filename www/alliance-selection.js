var teams = []
var allianceCount = 8;

$(document).ready(function(){
    for (var i=1; i<=allianceCount; i++){
        $('#alliances').append($('template#allianceRow').html().replace(/\$\#/g, i))
    }
    $('#alliances input').change(function(){
        $("#t" + $(this).val()).addClass('picked')
        if (!focusNext()) computeSchedule()
    }).focus(function(){
        focusInput($(this))
    })
    if (!focusNext()) computeSchedule()

    $('#save').click(function(){
        $('#eventInput').val(eventId)

        var table=$('#alliances').closest('table'),alliancesCsv=""
        table.find('tr').each(function(){
            var line=""
            $(this).find('th,input').each(function(){
                if (line) line += ","
                line += $(this).text() || $(this).val()
            })
            alliancesCsv += line + "\n"
        })
        $('#alliancesCsvInput').val(alliancesCsv)

        var table=$('#quarterFinals').closest('table')
        var quarterFinalsCsv=""
        table.find('tr').each(function(){
            var line=""
            $(this).find('th,td').each(function(){
                if (line) line += ","
                line += $(this).text()
            })
            quarterFinalsCsv += line + "\n"
        })
        $('#quarterFinalsCsvInput').val(quarterFinalsCsv)
        //console.log($('#addAlliances').serialize())
        $('#addAlliances').submit()
    })

    loadEventSchedule(function(data){
        var t = {}
        for (var i=1; i<data.length; i++){
            positions = Object.keys(data[i])
            for (var j=1; j<positions.length; j++){
                t[parseInt(data[i][positions[j]])] = 1
            }
        }
        teams = Object.keys(t);
        teams.sort((a,b) => {return a-b})
        for (var i=0; i<teams.length; i++){
            var team = teams[i]
            $('#teams').append($(`<button class=team id=t${team}>${team}</button>`).click(function(){
                $(this).addClass('picked')
                lf().val($(this).text())
                if (!focusNext()) computeSchedule()
            }))
        }
    })
})

function computeSchedule(){
    $('#quarterFinalSection').show()
    $('#quarterFinals').html('')
    schedule = [[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6],[1,8],[4,5],[2,7],[3,6]]
    for (var i=1; i<=schedule.length; i++){
        var a1=schedule[i-1][0], a2 = schedule[i-1][1],
        html = $('template#quarterFinalRow').html().replace(/\$\#/g, i)
            .replace(/\$team1/, $(`#A${a1}_captain`).val())
            .replace(/\$team2/, $(`#A${a1}_pick_1`).val())
            .replace(/\$team3/, $(`#A${a1}_pick_2`).val())
            .replace(/\$team4/, $(`#A${a2}_captain`).val())
            .replace(/\$team5/, $(`#A${a2}_pick_1`).val())
            .replace(/\$team6/, $(`#A${a2}_pick_2`).val())
        $('#quarterFinals').append(html)
    }
}

function focusInput(input){
    if (input[0]==lf()[0]) return
    $('#alliances input').removeClass('lastFocus')
    input.addClass('lastFocus')
}

function lf(){
    return $('#alliances input.lastFocus')
}

function withoutValues(i,el){
    return $(el).val() == ''
}

function focusNext(){
    var next = $('#alliances .captain, #alliances .pick_1').filter(withoutValues).first()
    if (!next.length) next = $('#alliances .pick_2').filter(withoutValues).last()
    if (next.length) focusInput(next)
    return next.length > 0
}