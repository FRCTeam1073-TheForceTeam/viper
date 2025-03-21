"use strict"

addI18n({
	revisions_page_title:{
		en:'_FILENAME_ Revisions',
		fr:'_FILENAME_ Révisions',
		zh_tw:'_FILENAME_ 修訂版本',
		he:'_FILENAME_ גרסאות',
		pt:'_FILENAME_ Revisões',
		tr:'_FILENAME_ Revizyonları',
	},
	error_no_file:{
		en:'No file specified',
		fr:'Aucun fichier spécifié',
		zh_tw:'未指定文件',
		he:'לא צוין קובץ',
		pt:'Nenhum arquivo especificado',
		tr:'Belirtilen dosya yok',
	},
	revision_label:{
		en:'Revision:',
		fr:'Révision :',
		zh_tw:'修訂：',
		he:'עדכון:',
		pt:'Revisão:',
		tr:'Revizyon:',
	},
	timestamp_label:{
		en:'Timestamp:',
		fr:'Horodatage :',
		zh_tw:'時間戳：',
		he:'חותמת זמן:',
		pt:'Carimbo de data/hora:',
		tr:'Zaman damgası:',
	},
	message_label:{
		en:'Message:',
		fr:'Message :',
		zh_tw:'訊息:',
		he:'הוֹדָעָה:',
		pt:'Mensagem:',
		tr:'Mesaj:',
	},
	view_link:{
		en:'View',
		fr:'Afficher',
		zh_tw:'看法',
		he:'נוֹף',
		pt:'Visualizar',
		tr:'Görüntüle',
	},
	download_link:{
		en:'Download',
		fr:'Télécharger',
		zh_tw:'下載',
		he:'הורד',
		pt:'Baixar',
		tr:'İndir',
	},
	revert_link:{
		en:'Revert',
		fr:'Annuler',
		zh_tw:'恢復',
		he:'לַחֲזוֹר',
		pt:'Reverter',
		tr:'Geri al',
	},
})

var file=(location.hash.match(/^\#(?:(?:.*\&)?(?:file\=))?(20[0-9]{2}[a-zA-Z0-9\-]+\.[a-z]+\.csv)(?:\&.*)?$/)||["",""])[1]

$(document).ready(function(){
	if (!file){
		$('h1,title').attr('data-i18n','error_no_file')
		applyTranslations()
		return
	}
	addTranslationContext({'fileName':file})
	applyTranslations()
	$.getJSON(`/revisions.cgi?file=${file}`, function(json){
		var revList = $('#revisions').html(''),
		first=true
		json.forEach(revision=>{
			var revItem = $('<li>'),
			fieldList=$('<ul>')
			revItem.append($('<h2>').append($('<span>').attr('data-i18n','revision_label')).append(` ${revision.revision}`))
			fieldList.append($('<li>').append($('<span>').attr('data-i18n','timestamp_label')).append(` ${revision.date}`))
			fieldList.append($('<li>').append($('<span>').attr('data-i18n','message_label')).append(` ${revision.message}`))
			var links = $('<li>')
			links
				.append(`<a href=/revisions.cgi?file=${file}&revision=${revision.revision} data-i18n=view_link></a>`)
				.append(' | ')
				.append(`<a href=/revisions.cgi?file=${file}&revision=${revision.revision}&download=1 data-i18n=download_link></a>`)
			if (!first){
				links
					.append(' | ')
					.append(`<a href=/admin/revert.cgi?file=${file}&revision=${revision.revision} data-i18n=revert_link></a>`)
			}
			fieldList.append(links)
			revItem.append(fieldList)
			var diffLines = (revision.diffs||"").replace(/^.*\n.*\n.*\n/,"").split(/\n/),
			pre = $('<pre>')
			diffLines.forEach(line=>{
				var span=$('<span>')
				if (/^\+/.test(line)) span.addClass('add')
				if (/^\-/.test(line)) span.addClass('rem')
				span.text(line+"\n")
				pre.append(span)
			})
			revItem.append(pre)
			revList.append(revItem)
			first=false
		})
		applyTranslations()
	})
})
