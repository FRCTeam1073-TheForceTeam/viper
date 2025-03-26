"use strict"

addI18n({
	clear_row_confirm:{
		en:'Clear entire row?',
		tr:'Tüm satırı temizle?',
		pt:'Limpar linha inteira?',
		fr:'Effacer toute la ligne ?',
		he:'לנקות את כל השורה?',
		zh_tw:'清除整行？',
	},
	event_table_title:{
		en:'Enter Event Practice and Qualification Matches',
		pt:'Coloque eventos de pratica',
		fr:'Saisir les matchs d\'entraînement et de qualification',
		tr:'Etkinlik Uygulama ve Eleme Maçlarına Girin',
		zh_tw:'參加賽事練習和資格賽',
		he:'היכנס למשחקי תרגול והסמכה לאירועים',
	},
	event_table_comp_type:{
		en:'Competition type:',
		pt:'Tipo de competição:',
		fr:'Type de compétition :',
		tr:'Yarışma türü:',
		zh_tw:'比賽類型：',
		he:'סוג התחרות:',
	},
	event_name:{
		en:'Event name:',
		pt:'Nome do evento:',
		fr:'Nom de l\'événement :',
		tr:'Etkinlik adı:',
		zh_tw:'事件名稱：',
		he:'שם האירוע:',
	},
	event_name_placeholder:{
		en:'Name of event',
		pt:'Nome do evento',
		fr:'Nom de l\'événement',
		tr:'Etkinlik adı',
		zh_tw:'活動名稱',
		he:'שם האירוע',
	},
	event_start:{
		en:'Start date:',
		pt:'Data de inicio:',
		fr:'Date de début :',
		tr:'Başlangıç ​​tarihi:',
		zh_tw:'開始日期：',
		he:'תאריך התחלה:',
	},
	event_end:{
		en:'End date:',
		pt:'Data de término:',
		fr:'Date de fin :',
		tr:'Bitiş tarihi:',
		zh_tw:'結束日期：',
		he:'תאריך סיום:',
	},
	event_location:{
		en:'Location:',
		pt:'Localização:',
		fr:'Lieu :',
		tr:'Yer:',
		zh_tw:'地點：',
		he:'מִקוּם:',
	},
	event_location_placeholder:{
		en:'City, ST, USA',
		pt:'Cidade, ST, EUA',
		fr:'Ville, ST, États-Unis',
		tr:'Şehir, ST, ABD',
		zh_tw:'城市，ST，美國',
		he:'סיטי, ST, ארה"ב',
	},
	event_id:{
		en:'Event ID:',
		pt:'ID do evento:',
		fr:'ID de l\'événement :',
		tr:'Etkinlik kimliği:',
		zh_tw:'事件 ID：',
		he:'מזהה אירוע:',
	},
	event_id_placeholder:{
		en:'No spaces or punctuation',
		pt:'Sem espaços ou simbulos',
		fr:'Sans espaces ni ponctuation',
		tr:'Boşluk veya noktalama işareti yok',
		zh_tw:'沒有空格或標點',
		he:'ללא רווחים או סימני פיסוק',
	},
	event_table_practice:{
		en:'Practice Matches',
		pt:'Partidas de praticas',
		fr:'Matchs d\'entraînement',
		tr:'Uygulama Maçları',
		zh_tw:'練習賽',
		he:'תרגול התאמות',
	},
	event_table_qualification:{
		en:'Qualification Matches',
		pt:'Qualificatorias',
		fr:'Matchs de qualification',
		tr:'Eleme Maçları',
		zh_tw:'資格賽',
		he:'משחקי הסמכה',
	},
	swap_red_blue:{
		en:'Red ↔ Blue',
		pt:'Vermelho ↔ Azul',
		fr:'Rouge ↔ Bleu',
		tr:'Kırmızı ↔ Mavi',
		zh_tw:'紅色 ↔ 藍色',
		he:'אדום ↔ כחול',
	},
	clear_row:{
		en:'Clear Row',
		pt:'Limpar Coluna',
		fr:'Effacer la ligne',
		tr:'Satırı Temizle',
		zh_tw:'清除行',
		he:'נקה שורה',
	},
	save_event:{
		en:'Save Event',
		pt:'Salvar Evento',
		fr:'Enregistrer l\'événement',
		tr:'Etkinliği Kaydet',
		zh_tw:'保存事件',
		he:'שמור אירוע',
	},
})

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
						n.text(n.text().replace(/2$/,3))
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
						i.attr('name', i.attr('name').replace(/2$/,3)).val('')
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
		if (confirm(translate('clear_row_confirm'))){
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
