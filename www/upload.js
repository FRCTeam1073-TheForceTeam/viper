"use strict"

addI18n({
	upload_page_title:{
		en:'Upload Data',
		tr:'Verileri Yükle',
		he:'העלה נתונים',
		zh_tw:'上傳數據',
		fr:'Importer des données',
		pt:'Carregar dados',
	},
	upload_all_button:{
		en:'Upload All Data',
		tr:'Tüm Verileri Yükle',
		he:'העלה את כל הנתונים',
		zh_tw:'上傳所有數據',
		fr:'Importer toutes les données',
		pt:'Carregar todos os dados',
	},
	no_uploads:{
		en:'There is no data to upload.',
		tr:'Yüklenecek veri yok.',
		he:'אין נתונים להעלות.',
		zh_tw:'沒有可上傳的數據。',
		fr:'Aucune donnée à importer.',
		pt:'Não há dados para carregar.',
	},
	uploading_button:{
		en:'Uploading, please wait…',
		tr:'Yükleniyor, lütfen bekleyin...',
		he:'מעלה, אנא המתן...',
		zh_tw:'正在上傳，請稍候…',
		fr:'Importation en cours, veuillez patienter…',
		pt:'Carrega, aguarde…',
	},
	delete_match_confirm:{
		en:'Are you sure you want to delete _MATCH_?',
		tr:'_MATCH_ öğesini silmek istediğinizden emin misiniz?',
		he:'האם אתה בטוח שברצונך למחוק את _MATCH_?',
		zh_tw:'您確定要刪除_MATCH_嗎？',
		fr:'Voulez-vous vraiment supprimer _MATCH_ ?',
		pt:'Tem certeza de que deseja excluir _MATCH_?',
	},
	remove_match_confirm:{
		en:'Are you sure you want to remove _MATCH_?',
		tr:'_MATCH_ öğesini kaldırmak istediğinizden emin misiniz?',
		he:'האם אתה בטוח שברצונך להסיר את _MATCH_?',
		zh_tw:'您確定要刪除_MATCH_嗎？',
		fr:'Voulez-vous vraiment supprimer _MATCH_ ?',
		pt:'Tem certeza de que deseja remover _MATCH_?',
	},
	show_data_button:{
		en:'Show Data',
		tr:'Verileri Göster',
		he:'הצג נתונים',
		zh_tw:'顯示數據',
		fr:'Afficher les données',
		pt:'Mostrar dados',
	},
	uploads_heading:{
		en:'Data to Upload (_UPLOADCOUNT_)',
		tr:'Yüklenecek Veriler (_UPLOADCOUNT_)',
		he:'נתונים להעלאה (_UPLOADCOUNT_)',
		zh_tw:'要上傳的資料 (_UPLOADCOUNT_)',
		fr:'Données à importer (_UPLOADCOUNT_)',
		pt:'Dados para carregar (_UPLOADCOUNT_)',
	},
	history_heading:{
		en:'History (_HISTORYCOUNT_)',
		tr:'Geçmiş (_HISTORYCOUNT_)',
		he:'היסטוריה (_HISTORYCOUNT_)',
		zh_tw:'歷史記錄 (_HISTORYCOUNT_)',
		fr:'Historique (_HISTORYCOUNT_)',
		pt:'Histórico (_HISTORYCOUNT_)',
	},
	qr_code_button:{
		en:'QR Code',
		tr:'QR Kodu',
		he:'קוד QR',
		zh_tw:'QR 圖碼',
		fr:'Code QR',
		pt:'Código QR',
	},
	undelete_button:{
		en:'Undelete',
		tr:'Silmeyi Geri Al',
		he:'בטל מחיקה',
		zh_tw:'取消刪除',
		fr:'Annuler la suppression',
		pt:'Desfazer exclusão',
	},
	remove_history_button:{
		en:'Remove from History',
		tr:'Geçmişten Kaldır',
		he:'הסר מההיסטוריה',
		zh_tw:'從歷史記錄中刪除',
		fr:'Supprimer de l\'historique',
		pt:'Remover do histórico',
	},
	reupload_button:{
		en:'Reupload',
		tr:'Yeniden Yükle',
		he:'העלה מחדש',
		zh_tw:'重新上傳',
		fr:'Importer à nouveau',
		pt:'Recarregar',
	},
	clear_history_button:{
		en:'Clear Entire History',
		tr:'Tüm Geçmişi Temizle',
		he:'נקה את כל ההיסטוריה',
		zh_tw:'清除全部歷史記錄',
		fr:'Effacer tout l\'historique',
		pt:'Limpar histórico inteiro',
	},
	clear_history_confirm:{
		en:'Are you sure you want to clear the history?',
		tr:'Geçmişi temizlemek istediğinizden emin misiniz?',
		he:'האם אתה בטוח שברצונך לנקות את ההיסטוריה?',
		zh_tw:'您確定要清除歷史記錄嗎？',
		fr:'Voulez-vous vraiment effacer l\'historique ?',
		pt:'Tem certeza de que deseja limpar o histórico?',
	},
	qr_heading:{
		en:'QR Code _QRNUM_ of _QRTOTAL_',
		tr:'QR Kodu _QRNUM_ / _QRTOTAL_',
		he:'קוד QR _QRNUM_ מתוך _QRTOTAL_',
		zh_tw:'QR 碼 _QRNUM_ / _QRTOTAL_',
		fr:'Code QR _QRNUM_ sur _QRTOTAL_',
		pt:'Código QR _QRNUM_ de _QRTOTAL_',
	},
})

$(document).ready(showUploads)

var scoutCsv,pitCsv,subjectiveCsv

function uploadComparator(i){
	var m = localStorage[i].match(/(20\d\d-[01]\d-[0-3]\dT[0-2]\d[^,\n]*)/g)||[i]
	return m[m.length-1]
}

function showUploads(){
	var up = $('#uploads').html(""),
	his = $('#history').html(""),
	count = 0,
	historyCount = 0
	scoutCsv = {}
	pitCsv = {}
	subjectiveCsv = {}
	his.append($('<button data-i18n=clear_history_button></button>').click(clearHistory))
	Object.keys(localStorage).toSorted((a,b)=>uploadComparator(b).localeCompare(uploadComparator(a))).forEach(i=>{
		if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_subjective_[0-9]+/.test(i)){
			var year = i.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1"),
			header = localStorage.getItem(`${year}_subjectiveheaders`)
			if (!subjectiveCsv[year]){
				subjectiveCsv[year] = header
			}
			subjectiveCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button data-i18n=delete_button></button>').attr("data-match",i).click(deleteMatch))
			up.append($('<button data-i18n=qr_code_button></button>').attr("data-match",i).click(showQrCode))
			count++
		} else if (/^20[0-9]{2}(-[0-9]{2})?.*_.*_/.test(i)){
			var year = i.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1"),
			header = localStorage.getItem(`${year}_headers`)
			if (!scoutCsv[year]){
				scoutCsv[year] = header
			}
			scoutCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button data-i18n=delete_button></button>').attr("data-match",i).click(deleteMatch))
			up.append($('<button data-i18n=qr_code_button></button>').attr("data-match",i).click(showQrCode))
			count++
		} else if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_[0-9]+/.test(i)){
			var year = i.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1"),
			header = localStorage.getItem(`${year}_pitheaders`)
			if (!pitCsv[year]){
				pitCsv[year] = header
			}
			pitCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button data-i18n=delete_button></button>').attr("data-match",i).click(deleteMatch))
			up.append($('<button data-i18n=qr_code_button></button>').attr("data-match",i).click(showQrCode))
			count++
		} else if (/^deleted_20/.test(i)){
			his.append($('<hr>'))
			his.append($('<h4 class=deleted>').text(i))
			his.append($('<pre>').text(localStorage.getItem(i)))
			his.append($('<button data-i18n=undelete_button></button>').attr("data-match",i).click(undeleteMatch))
			his.append($('<button data-i18n=remove_history_button></button>').attr("data-match",i).click(removeMatch))
			historyCount++
		} else if (/^uploaded_20/.test(i)){
			his.append($('<hr>'))
			his.append($('<h4 class=uploaded>').text(i))
			his.append($('<pre>').text(localStorage.getItem(i)))
			his.append($('<button data-i18n=reupload_button></button>').attr("data-match",i).click(undeleteMatch))
			his.append($('<button data-i18n=remove_history_button></button>').attr("data-match",i).click(removeMatch))
			historyCount++
		}
	})
	$('#upload-description').attr('data-i18n',!count?'no_uploads':'')
	addTranslationContext({
		uploadCount:count,
		historyCount:historyCount,
	})
	$('.uploads').toggle(!!count)
	$('.history').toggle(!!historyCount)
	var years = Object.keys(scoutCsv);
	var text = ""
	for (var i=0; i<years.length; i++){
		text += scoutCsv[years[i]]
	}
	years = Object.keys(pitCsv);
	for (var i=0; i<years.length; i++){
		text += pitCsv[years[i]]
	}
	years = Object.keys(subjectiveCsv);
	for (var i=0; i<years.length; i++){
		text += subjectiveCsv[years[i]]
	}
	$('#csv').val(text)

	$('#upload-all').click(function(){
		$(this).text(translate('uploading_button'))
		if ($('button').prop('disabled') != 'true'){
			$('button').prop('disabled', 'true')
			$('#upload').submit()
		}
		return false
	})

	$('#show-uploads').click(function(){
		$(this).hide()
		$('#uploads').show()
	})

	$('#show-history').click(function(){
		$(this).hide()
		$('#history').show()
	})
	applyTranslations()
}

function clearHistory(){
	if (!confirm(translate('clear_history_confirm'))) return
	for (var i in localStorage){
		if (/^(deleted|uploaded)_20/.test(i)) localStorage.removeItem(i)
	}
	showUploads()
}

function deleteMatch(){
	var match = $(this).attr("data-match")
	if (confirm(translate('delete_match_confirm',{match:match}))){
		var d = localStorage.getItem(match)
		localStorage.removeItem(match)
		localStorage.setItem(`deleted_${match}`, d)
		showUploads()
	}
}

function removeMatch(){
	var match = $(this).attr("data-match")
	if (confirm(translate('remove_match_confirm',{match:match}))){
		localStorage.removeItem(match)
		showUploads()
	}
}

function undeleteMatch(){
	var match = $(this).attr("data-match")
	var d = localStorage.getItem(match)
	localStorage.removeItem(match)
	localStorage.setItem(match.replace(/^(deleted|uploaded)_/,''), d)
	showUploads()
}

function getQrUrls(key,csv){
	var csvIndex=0,
	urls=[]
	csv=csv.replace(/,0(?=,)/g,",")
	for (var i=1;csvIndex<csv.length;i++){
		var parts=[location.origin,"/qr.html?"]
		if(i>1)parts.push(`${i}...`)
		parts.push(key,",")
		var len=parts.reduce((sum,v)=>sum+v.length,0)
		while(csvIndex<csv.length && len<1000){
			var next=encodeURIComponent(csv[csvIndex])
			len+=next.length
			parts.push(next)
			csvIndex++
		}
		if (csvIndex<csv.length) parts.push(`...${i+1}`)
		urls.push(parts.join(''))
	}
	return urls
}

var qrNum=0,
qrMatch,
qrUrls=[]
function nextQrCode(){
	showQrCode(qrNum+1)
}

function showQrCode(num){
	if (typeof num == 'object'){
		qrMatch = $(this).attr("data-match")
		qrUrls = getQrUrls(qrMatch,localStorage.getItem(qrMatch))
		num=1
	}
	qrNum=num
	if (num>qrUrls.length){
		closeLightBox()
		var d = localStorage.getItem(qrMatch)
		localStorage.removeItem(qrMatch)
		localStorage.setItem(`uploaded_${qrMatch}`, d)
		showUploads()
		$('#show-uploads').hide()
		$('#uploads').show()
		return false
	}
	var dialog=$('#qr-code-dialog')
	if (!dialog.length){
		dialog=$('<div id=qr-code-dialog class=lightBoxCenterContent>')
		.append($('<h2 id=qr-code-title>'))
		.append($('<div id=qr-code style="border:.5em solid white">'))
		.append($('<p>')
			.append($('<button data-i18n=cancel_button>').click(closeLightBox))
			.append(" ")
			.append($('<button id=qr-code-next style=float:right data-i18n=next_button>').click(nextQrCode))
		)
		$('body').append(dialog)
		applyTranslations()
	}
	$('#qr-code-title').text(translate('qr_heading',{qrNum:qrNum,qrTotal:qrUrls.length}))
	var size = Math.min($('body').innerWidth()-20,$('body').innerHeight()-20,700)
	new QRCode($("#qr-code").html("").click(copyTitleAttr)[0],{
		text:qrUrls[num-1],
		width:size,
		height:size,
		correctLevel:QRCode.CorrectLevel.L,
	})
	showLightBox(dialog)
	return false
}

function copyTitleAttr(){
	navigator.clipboard.writeText($(this).attr('title'))
}
