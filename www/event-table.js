"use strict"

function addRow(table){
	if (!table) table = "qm"
	var rowNum = $(`#${table} tr`).length+1,
	row=$('<tr>').append($('<th>').text(rowNum))
	for(var j=0; j<BOT_POSITIONS.length; j++){
		row.append(
			$('<td>').attr('class',BOT_POSITIONS[j][0]=='R'?'redTeamBG':'blueTeamBG').append(
				$('<input inputmode=numeric type=text placeholder="team#" pattern="^[0-9]+$">').attr('name',table+rowNum+BOT_POSITIONS[j])
			)
		)
	}
	if(!redBlueSwapped)swapRedBlue(null,row)
	$(`#${table}`).append(row)
	setComp()
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
var teams = {},
comp = 'frc'
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
	var safeName = $('#nameInp').val().replace(/20[0-9]{2}/g,"").trim().toLowerCase().replace(/\s+/g,"-").replace(/[^0-9a-z\-]/g,"")
	var year = parseInt($('#startInp').val().slice(0,4))||new Date().getFullYear()
	if (comp == 'ftc'){
		var month = parseInt($('#startInp').val().slice(5,7),10)||(new Date().getMonth()+1)
		if (month >= 9) year = year + "-" + (""+(year+1)).slice(-2)
		else year = (year-1) + "-" + (""+year).slice(-2)
	}
	$('#idInp').val(year+safeName)
}
function setComp(){
	var newComp = $('#comp').val()
	if (comp!=newComp) swapRedBlue()
	comp = newComp
	location.hash=comp
	if (comp == 'ftc'){
		BOT_POSITIONS = FTC_BOT_POSITIONS
		$('#idInp').attr('pattern',"^20[0-9]{2}-[0-9]{2}[0-9a-zA-Z\\-]+$")
		$('table thead th').each(function(){
			if ($(this).text().endsWith(3)) $(this).remove()
		})
		$('table tbody td').each(function(){
			if ($(this).find('input').attr('name').endsWith(3)) $(this).remove()
		})
	}
	if (comp == 'frc'){
		BOT_POSITIONS = FRC_BOT_POSITIONS
		$('#idInp').attr('pattern',"^20[0-9]{2}[0-9a-zA-Z\\-]+$")
		$('table thead').each(function(){
			var has3 = false
			$(this).find('th').each(function(){
				if ($(this).text().endsWith(3)) has3 = true
			})
			if (!has3){
				$(this).find('th').each(function(){
					if ($(this).text().endsWith(2)){
						var n =$(this).clone()
						n.text(n.text().replace(/2/,3))
						n.insertAfter($(this))
					}
				})
			}
		})
		$('table tbody').each(function(){
			var has3 = false
			$(this).find('input').each(function(){
				if ($(this).attr('name').endsWith(3)) has3 = true
			})
			if (!has3){
				$(this).find('td').each(function(){
					if ($(this).find('input').attr('name').endsWith(2)){
						var n =$(this).clone(),
						i = n.find('input')
						i.attr('name', i.attr('name').replace(/2/,3)).val('')
						n.insertAfter($(this))
					}
				})
			}
		})
	}
}
var redBlueSwapped=false
function swapRedBlue(e, rows){
	if (e)e.preventDefault()
	if (!rows){
		rows=$('#schedule tr')
		redBlueSwapped=!redBlueSwapped
	}
	rows.each(function(){
		var perColor=BOT_POSITIONS.length/2
		for(var j=0; j<perColor; j++){
			$(this).children(':last-child').after($(this).children(":eq(1)"));
		}
	})
}
$(document).ready(function(){
	var hash = location.hash.replace(/^#/,"")
	$(`#comp option[value="${hash}"]`).attr('selected', 'selected')
	setComp()
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
	$('button.showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
	$('#tableForm').submit(function(){
		var csv = "Match,"+(BOT_POSITIONS.join(","))+"\n",
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
		promiseEventMatches().then(eventMatches => {
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
		promiseEventInfo().then(eventInfo => {
			$('#nameInp').val(eventInfo.name)
			$('#locationInp').val(eventInfo.location)
			$('#startInp').val(eventInfo.start)
			$('#endInp').val(eventInfo.end)
		})
	}
	$('#comp').change(setComp)
	setTimeout(focusFirst,100)
	$('#swap-red-blue').click(swapRedBlue)
})
