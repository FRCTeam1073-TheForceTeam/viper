"use strict"

$(document).ready(function(){
	var teams = (/^\#(?:.*\&)?(?:teams\=)([0-9]+(?:,[0-9]+)*)/g.exec(location.hash)||["",""])[1].split(/,/)
	$('#seasonInp').val(
		((/^\#(?:.*\&)?(?:season\=)(20[0-9]{2}(?:-[0-9]{2})?)/g.exec(location.hash)||["",""])[1])||
		((/^([0-9]{4}(?:-[0-9]{2})+)/.exec(eventId)||["",""])[1])||
		$('#seasonInp').val()
	)
	if(teams[0]){
		teams.forEach(function(team){
			addTeam(team);
		})
	} else if (eventId){
		promiseEventTeams().then(eventTeams=>{
			eventTeams.forEach(addTeam)
		})
	}
	$('#add').click(function(e){
		e.preventDefault()
		addTeam($('#team').val())
		return false
	})
	$('#team').keydown(function(e) {
		if (e.key == 'Enter') {
			e.preventDefault()
			addTeam($('#team').val())
			return false
		}
	})
	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
	$('#fullPhoto').click(closeLightBox)
	$('title').text($('title').text().replace(/EVENT/g, eventName))
})

function photoChange(url){
	$('img').each(function(){
		var src = $(this).attr('src')
		if (src && src.includes(url)){
			$(this).attr('src',src.replace(/\?.*/,"")+"?"+(new Date().getTime()))
		}
	})
}

function showFullPhoto(){
	showLightBox($('#fullPhoto').attr('src',$(this).attr('src')))
}

function addTeam(team){
	if (!/^[0-9]+$/.test(team)) return
	$('#teams').append(
		$('<tr>').append(
			$('<th>').append(`<h2>Team ${team}</h2>`)
		)
		.append(imageCell(team))
		.append(imageCell(`${team}-top`))
	)
	$('#team').val("")
}

function photoEditLightBox(){
	showLightBox($('#photoEdit').attr('src',$(this).attr('href')))
	return false
}

function imageCell(imgName){
	var season = $('#seasonInp').val(),
	td = $('<td>')
	td.append($(`<a class=show-only-when-connected href=/photo-edit.html#${season}/${imgName}.jpg>Edit</a>`).click(photoEditLightBox))
	.append($(`<img class=photoPreview src=/data/${season}/${imgName}.jpg>`).click(showFullPhoto).on('error',function(){
		$(this).parent().find('a,img').remove()
	}).each(function(){
		if(this.error) $(this).error()
	}))
	.append(`<input type=file name=${imgName} accept="image/*">`)
	return td
}
