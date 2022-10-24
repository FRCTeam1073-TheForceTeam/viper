rowNum=0
function addRow(){
    rowNum++;
    $('#qualifiers').append($('template#qualrow').html().replace(/\$\#/g, rowNum))
    var rowInputs = $('#qualifiers tr:last-child input')
    rowInputs.change(teamEntered).focus(function(){
        focusInput($(this))
    })
}
function focusInput(input){
    if (input[0]==lf()[0]) return
    addTeamButton()
    $('#qualifiers input').removeClass('lastFocus')
    input.addClass('lastFocus')
    checkTeams()
}
function hasRowData(tr){
    var rowHasData = false
    tr.find('input').each(function(){
        if ($(this).val()) rowHasData = true
    })
    return rowHasData
}
function teamEntered(){
    addTeamButton()
    checkTeams()
    focusFirst()
}
var teams = {}
function addTeamButton(){
    team = lf().val()
    if (teams[team]) return
    if (!/^[0-9]+$/.test(team)) return
    teams[team] = 1
    team = parseInt(team)
    var buttons = ($('#team-list button'));
    var button = $('<button class=team>').text(team).click(teamButtonClicked)
    buttons.each(function(){
        if (team && parseInt($(this).text()) > team){
            $(this).before(button)
            team = 0
        }
    })
    if (team){
        $('#team-list').append(button)
    }
}
function teamButtonClicked(){
    lf().val($(this).text())
    focusFirst()
    return false
}
function checkTeams(){
    var full=true
    var seenValue=false
    var rows = $('#qualifiers tr')
    $(rows.get().reverse()).each(function(i){
        var inputs = $(this).find('input')
        var empties = inputs.filter(withoutValues)
        var allEmpty = empties.length == inputs.length;
        if (allEmpty) full = false;
        if (!allEmpty) seenValue = true;
        if (seenValue || i == rows.length-1){
            inputs.attr('required','1')
        } else {
            inputs.removeAttr('required')
        }
    })
    if (full) addRow()
}
function withoutValues(i,el){
    return $(el).val() == ''
}
function focusFirst(){
    focusInput($('#qualifiers input').filter(withoutValues).first())
}
function lf(){
    return $('#qualifiers input.lastFocus')
}
$(document).ready(function(){
    addRow()
    focusFirst()
    $('button.num').click(function(){
        lf().val(lf().val()+$(this).text())
        lf().focus()
        return false
    })
    $('button.back').click(function(){
        lf().val(lf().val().slice(0,-1))
        lf().focus()
        return false
    })
    $('button.next').click(function(){
        focusFirst()
        return false
    })
    $('button.clearRow').click(function(){
        if (confirm("Clear entire row?")){
            lf().closest('tr').find('input').val("")
        }
        lf().focus()
        return false
    })
})