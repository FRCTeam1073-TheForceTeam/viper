"use strict"

$(document).ready(function(){
	if (/^\#[0-9]+(,[0-9]+)*$/.test(location.hash)){
		var teams = location.hash.replace(/^\#/,"").split(/,/)
		for (var i=0; i<teams.length; i++){
			addTeam(teams[i]);
		}
	}
	$('#add').click(function(e){
		e.preventDefault()
		addTeam($('#team').val())
		return false
	})
	if (eventId){
		loadEventSchedule(function(){
			for(var i=0; i<eventTeams.length; i++){
			   addTeam(eventTeams[i])
			}
		})
	}
	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
	$('#fullPhoto').click(closeLightBox)
})

function showFullPhoto(){
	showLightBox($('#fullPhoto').attr('src',$(this).attr('src')))
}

function addTeam(team){
	if (!/^[0-9]+$/.test(team)) return
	var year = $('#yearInp').val()
	$('#teams').append(
		$('<tr>').append(
			$('<th>').append(`<h2>Team ${team}</h2>`)
		).append(
			$('<td>')
				.append($(`<img class=photoPreview src=/data/${year}/${team}.jpg>`).click(showFullPhoto))
				.append(`<input type=file name=${team} accept="image/*">`)
		).append(
			$('<td>')
				.append($(`<img class=photoPreview src=/data/${year}/${team}-top.jpg>`).click(showFullPhoto))
				.append(`<input type=file name=${team}-top accept="image/*">`)
		)
	)
	$('#team').val("")
}
