"use strict"

addI18n({
	bot_photo_title:{
		en:'Bot Photos for _EVENT_',
	},
	season_label:{
		en:'Season:',
	},
	team_header:{
		en:'Team',
	},
	side_view_header:{
		en:'Side View',
	},
	top_view_header:{
		en:'Top View',
	},
	add_team_button:{
		en:'Add Team',
	},
	upload_all_button:{
		en:'Upload All',
	},
	edit_link:{
		en:'Edit',
	},
	team_num_heading:{
		en:'Team _TEAMNUM_',
	},
	team_num_placeholder:{
		en:'Team #',
	},
})

$(document).ready(function(){
	var teams = (/^\#(?:.*\&)?(?:teams\=)([0-9]+(?:,[0-9]+)*)/g.exec(location.hash)||["",""])[1].split(/,/)
	$('#seasonInp').val(
		((/^\#(?:.*\&)?(?:season\=)(20[0-9]{2}(?:-[0-9]{2})?)/g.exec(location.hash)||["",""])[1])||
		((/^([0-9]{4}(?:-[0-9]{2})?)/.exec(eventId)||["",""])[1])||
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
	$('#add').click(clickAddTeam)
	$('#team').keydown(clickAddTeam)
	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
	$('#fullPhoto').click(closeLightBox)
	addTranslationContext({event:eventName,year:eventYear})
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

function clickAddTeam(e){
	if (e.type=='click'||e.key=='Enter'){
		e.preventDefault()
		addTeam($('#team').val())
		return false
	}
}

function addTeam(team){
	if (!/^[0-9]+$/.test(team))return
	var tr=$('<tr>').append(
		$('<th>').append($('<h2 data-i18n=team_num_heading>').attr('data-teamNum',team))
	).append(imageCell(team))
	.append(imageCell(`${team}-top`))
	applyTranslations(tr)
	$('#teams').append(tr)
	$('#team').val("")
}

function photoEditLightBox(){
	showLightBox($('#photoEdit').attr('src',$(this).attr('href')))
	return false
}

function imageCell(imgName){
	var season = $('#seasonInp').val(),
	td = $('<td>')
	td.append($(`<a class=show-only-when-connected href=/photo-edit.html#${season}/${imgName}.jpg data-i18n=edit_link></a>`).click(photoEditLightBox))
	.append($(`<img class=photoPreview src=/data/${season}/${imgName}.jpg>`).click(showFullPhoto).on('error',function(){
		$(this).parent().find('a,img').remove()
	}).each(function(){
		if(this.error) $(this).error()
	}))
	.append(`<input type=file name=${imgName} accept="image/*">`)
	return td
}
