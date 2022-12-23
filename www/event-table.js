"use strict"

function addRow(table){
	if (!table) table = "qm"
	var rowNum = $(`#${table} tr`).length+1;
	$(`#${table}`).append($('template#scheduleRow').html().replace(/\$\#/g, rowNum).replace(/\$TYPE/g, table))
	var rowInputs = $(`#${table} tr:last-child input`)
	rowInputs.change(teamEntered).focus(function(){
		focusInput($(this))
	})
}
function focusInput(input){
	if (input[0]==lf()[0]) return
	addTeamButton()
	$('#schedule input').removeClass('lastFocus')
	input.addClass('lastFocus')
	checkTeams(input.closest('tbody').attr('id'))
}
function hasRowData(tr){
	var rowHasData = false
	tr.find('input').each(function(){
		if ($(this).val()) rowHasData = true
	})
	return rowHasData
}
function teamEntered(){
	var table = lf().closest('tbody').attr('id')
	addTeamButton()
	checkTeams(table)
	focusFirst(table)
}
var teams = {}
function addTeamButton(team){
	if (!team) team = lf().val()
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
	focusFirst(lf().closest('tbody').attr('id'))
	return false
}
function checkTeams(table){
	var full=true
	var seenValue=false
	var rows = $(`#${table} tr`)
	$(rows.get().reverse()).each(function(i){
		var inputs = $(this).find('input')
		var empties = inputs.filter(withoutValues)
		var allEmpty = empties.length == inputs.length;
		if (allEmpty) full = false;
		if (!allEmpty) seenValue = true;
		if (seenValue){
			inputs.attr('required','1')
		} else {
			inputs.removeAttr('required')
		}
	})
	if (full) addRow(table)
}
function withoutValues(i,el){
	return $(el).val() == ''
}
function focusFirst(table){
	if(!table)table='pm'
	focusInput($(`#${table} input`).filter(withoutValues).first())
}
function lf(){
	return $('#schedule input.lastFocus')
}
function venueNameToId(){
	$('#idInp').val($('#startInp').val().substr(0,4)+$('#nameInp').val().replace(/20[0-9]{2}/g,"").trim().toLowerCase().replace(/\s+/g,"-").replace(/[^0-9a-z\-]/g,""))
}
$(document).ready(function(){
	addRow('qm')
	addRow('pm')
	$('#nameInp').change(venueNameToId).keyup(venueNameToId)
	var otherCSV = ""
	$('button.clearRow').click(function(){
		if (confirm("Clear entire row?")){
			lf().closest('tr').find('input').val("")
		}
		lf().focus()
		return false
	})
	$('#tableForm').submit(function(){
		var csv = "Match,R1,R2,R3,B1,B2,B3\n",
		tables = ['pm','qm']
		for (var k=0; k<tables.length; k++){
			var table = tables[k],
			hasVal=true
			for (var i=1; hasVal; i++){
				var line = `${table}${i}`
				for(var j=0; j<BOT_POSITIONS.length; j++){
					var val = $(`input[name="${table}${i}${BOT_POSITIONS[j]}"]`).val()
					if (val){
						line += ","+val
					} else {
						hasVal = false
					}
				}
				if (hasVal)csv += line + "\n"
			}
		}
		$('#csvInp').val(csv + otherCSV)
	})
	if (eventId){
		$('#idInp').val(eventId)
		loadEventSchedule(function(){
			for (var i=1; i<=eventMatches.length; i++){
				var match = eventMatches[i-1],
				matchId = match['Match'],
				table = matchId.replace(/[0-9]+/,""),
				matchNum = matchId.replace(/[^0-9]+/,"")
				if (/^(pm|qm)/.test(table)){
					for(var j=0; j<BOT_POSITIONS.length; j++){
						var team = match[BOT_POSITIONS[j]]
						addTeamButton(team)
						$(`input[name="${table}${matchNum}${BOT_POSITIONS[j]}"]`).val(team)
					}
					addRow(table)
				} else {
					otherCSV += matchId
					for(var j=0; j<BOT_POSITIONS.length; j++){
						otherCSV += "," + match[BOT_POSITIONS[j]]
					}
					otherCSV += "\n"
				}
			}
		})
		loadEventInfo(function(){
			$('#nameInp').val(eventInfo.name)
			$('#locationInp').val(eventInfo.location)
			$('#startInp').val(eventInfo.start)
			$('#endInp').val(eventInfo.end)
		})
	}
	setTimeout(focusFirst,100)
})
