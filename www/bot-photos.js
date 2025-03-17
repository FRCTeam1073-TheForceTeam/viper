"use strict"

addI18n({
	bot_photo_title:{
		en:'Bot Photos for _EVENT_',
		pt:'Fotos de bot para _EVENTO_',
		he:'תמונות בוט עבור _EVENT_',
		tr:'_EVENT_ için Bot Fotoğrafları',
		zh_tw:'_EVENT_ 的機器人照片',
		fr:'Photos du robot pour _EVENT_',
	},
	season_label:{
		en:'Season:',
		pt:'Temporada:',
		he:'עוֹנָה:',
		tr:'Sezon:',
		zh_tw:'季節：',
		fr:'Saison :',
	},
	team_header:{
		en:'Team',
		pt:'Equipe',
		he:'קְבוּצָה',
		tr:'Takım',
		zh_tw:'團隊',
		fr:'Équipe',
	},
	side_view_header:{
		en:'Side View',
		pt:'Vista lateral',
		he:'מבט מהצד',
		tr:'Yan Görünüm',
		zh_tw:'側面圖',
		fr:'Vue latérale',
	},
	top_view_header:{
		en:'Top View',
		pt:'Vista superior',
		he:'תצוגה למעלה',
		tr:'Üst Görünüm',
		zh_tw:'頂視圖',
		fr:'Vue de dessus',
	},
	add_team_button:{
		en:'Add Team',
		pt:'Adicionar equipe',
		he:'הוסף צוות',
		tr:'Takım Ekle',
		zh_tw:'新增團隊',
		fr:'Ajouter une équipe',
	},
	upload_all_button:{
		en:'Upload All',
		pt:'Carregar tudo',
		he:'העלה הכל',
		tr:'Tümünü Yükle',
		zh_tw:'全部上傳',
		fr:'Télécharger tout',
	},
	edit_link:{
		en:'Edit',
		pt:'Editar',
		he:'לַעֲרוֹך',
		tr:'Düzenle',
		zh_tw:'編輯',
		fr:'Modifier',
	},
	team_num_heading:{
		en:'Team _TEAMNUM_',
		pt:'Equipe _TEAMNUM_',
		he:'צוות _TEAMNUM_',
		tr:'Takım _TEAMNUM_',
		zh_tw:'團隊 _TEAMNUM_',
		fr:'Équipe _TEAMNUM_',
	},
	team_num_placeholder:{
		en:'Team #',
		pt:'Equipe nº',
		he:'צוות מס\'',
		tr:'Takım #',
		zh_tw:'團隊 ＃',
		fr:'Équipe n°',
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
