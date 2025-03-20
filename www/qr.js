"use strict"

addI18n({
	qr_title{
		en:'Processing QR Code',
		fr:'Traitement du code QR',
		tr:'QR Kodu İşleniyor',
		zh_tw:'正在處理二維碼',
		he:'מעבד קוד QR',
		pt:'Processando código QR',
	},
	qr_format_error:{
		en:'Data not in expected format',
		zh_tw:'數據不符合預期格式',
		he:'הנתונים אינם בפורמט הצפוי',
		pt:'Dados fora do formato esperado',
		tr:'Veriler beklenen biçimde değil',
		fr:'Données non au format attendu',
	},
	qr_no_data_error:{
		en:'No data',
		zh_tw:'沒有數據',
		he:'אין נתונים',
		pt:'Nenhum dado',
		tr:'Veri yok',
		fr:'Aucune donnée',
	},
	qr_partial_error:{
		en:'Could not append to last QR code: no previously uploaded data found',
		zh_tw:'無法附加到最後一個二維碼：未找到先前上傳的數據',
		he:'לא ניתן לצרף לקוד QR האחרון: לא נמצאו נתונים שהועלו בעבר',
		pt:'Não foi possível anexar ao último código QR: nenhum dado carregado anteriormente foi encontrado',
		tr:'Son QR koduna eklenemedi: daha önce yüklenmiş veri bulunamadı',
		fr:'Impossible d\'ajouter le code QR précédent : aucune donnée téléchargée n\'a été trouvée.',
	},
	qr_corrupted_error:{
		en:'Previously stored QR code corrupted',
		zh_tw:'先前儲存的二維碼已損壞',
		he:'קוד QR שנשמר בעבר פגום',
		pt:'Código QR armazenado anteriormente corrompido',
		tr:'Önceden depolanan QR kodu bozuldu',
		fr:'Code QR précédemment enregistré corrompu.',
	},
	qr_sequence_error:{
		en:'Expected QR code _EXPECTEDNUM_ for this scouter but got _ACTUALNUM_',
		zh_tw:'該偵察兵預期的二維碼為 _EXPECTEDNUM_，但實際得到的是 _ACTUALNUM_',
		he:'צפי לקוד QR _EXPECTEDNUM_ עבור הסקאוטר הזה אבל קיבל _ACTUALNUM_',
		pt:'Código QR esperado _EXPECTEDNUM_ para este scouter, mas obteve _ACTUALNUM_',
		tr:'Bu scouter için _EXPECTEDNUM_ QR kodu bekleniyordu ancak _ACTUALNUM_ alındı',
		fr:'Le code QR attendu était _EXPECTEDNUM_ pour ce scouter, mais il a été obtenu _ACTUALNUM_.',
	},
	qr_extra_error:{
		en:'Too much data scanned',
		zh_tw:'掃描的資料過多',
		he:'יותר מדי נתונים נסרקו',
		pt:'Muitos dados escaneados',
		tr:'Çok fazla veri tarandı',
		fr:'Trop de données scannées.',
	},
	qr_another_needed:{
		en:'Scan another QR code from this scouter',
		zh_tw:'從此偵察器掃描另一個二維碼',
		he:'סרוק קוד QR נוסף מהסקאוטר הזה',
		pt:'Escanear outro código QR deste scouter',
		tr:'Bu scouter\'dan başka bir QR kodu tarayın',
		fr:'Scannez un autre code QR de ce scouter.',
	},
	qr_upload_complete:{
		en:'Scanned data ready for upload',
		zh_tw:'掃描資料已準備好上傳',
		he:'נתונים סרוקים מוכנים להעלאה',
		pt:'Dados escaneados prontos para upload',
		tr:'Taranan veriler yüklenmeye hazır',
		fr:'Données scannées prêtes à être téléchargées.',
	},
	qr_upload_link:{
		en:'Proceed to upload',
		zh_tw:'繼續上傳',
		he:'המשך להעלות',
		pt:'Prosseguir para upload',
		tr:'Yüklemeye devam edin',
		fr:'Procéder au téléchargement.',
	},
	qr_delete_partial_confirm:{
		en:'Are you sure you want to delete this partial scan?',
		zh_tw:'您確實要刪除此部分掃描嗎？',
		he:'האם אתה בטוח שברצונך למחוק את הסריקה החלקית הזו?',
		pt:'Tem certeza de que deseja excluir esta varredura parcial?',
		tr:'Bu kısmi taramayı silmek istediğinizden emin misiniz?',
		fr:'Voulez-vous vraiment supprimer ce scan partiel ?',
	},
	qr_optional_scan_another:{
		en:'or scan another QR code for _SCOUTINGNAME_',
		zh_tw:'或掃描 _SCOUTINGNAME_ 的另一個二維碼',
		he:'או סרוק קוד QR אחר עבור _SCOUTINGNAME_',
		pt:'ou escanear outro código QR para _SCOUTINGNAME_',
		tr:'veya _SCOUTINGNAME_ için başka bir QR kodu tarayın',
		fr:'ou scannez un autre code QR pour _SCOUTINGNAME_.',
	},
})

$(document).ready(function(){
	function error(msg,args){
		return message(msg,args,'color:red')
	}

	function message(msg,args,style){
		var messages=$('#messages'),
		p=$('<p>').attr('style',style).text(msg).attr('data-i18n',msg)
		Object.entries(args||{}).forEach(([k,v])=>p.attr(`data-${k}`,v))
		messages.append(p)
		applyTranslations(messages)
		return false
	}

	function getDataFromUrl(){
		var data=decodeURIComponent(location.search.substring(1)),
		fragment="1",header
		if (!data) return error('qr_no_data_error')
		var m = /^([0-9]+)\.\.\.(.*)/.exec(data)
		if (m) [{},fragment,data] = m
		m = /^((([0-9]{4}(?:-[0-9]{2})?)[A-Za-z0-9\-]+)((?:_subjective_[0-9]+)|(?:_[a-z0-9]+_[0-9]+)|(?:_[0-9]+))),(.*)/.exec(data)
		if (!m)return error('qr_format_error')
		var [{},key,event,season,type,data] = m
		if (/subjective/.test(type)){
			header = localStorage.getItem(`${season}_subjectiveheaders`)
			if (!header) location.href = `/${season}/subjective-scout.html#event=${event}&go=back`
		} else if (/_.*_/.test(type)){
			header = localStorage.getItem(`${season}_headers`)
			if (!header) location.href = `/${season}/scout.html#event=${event}&go=back`
		} else {
			header = localStorage.getItem(`${season}_pitheaders`)
			if (!header) location.href = `/${season}/pit-scout.html#event=${event}&go=back`
		}
		var partialKey = `partial_${key}`
		if (fragment != 1){
			if (!(partialKey in localStorage)) return error('qr_partial_error')
			var partialData = localStorage.getItem(partialKey)
			m=/(.*)\.\.\.([0-9]+)/.exec(partialData)
			if (!m) return error('qr_corrupted_error')
			var [{},partialData,expectedFragment] = m
			if (fragment != expectedFragment) return error('qr_sequence_error',{expectedNum:expectedFragment,actualNum:fragment})
			data = partialData + data
		}
		var headers=header.split(/,/),
		dataPoints=data.split(/,/),
		tbc=/\.\.\.[0-9]+/.test(data)
		if (headers.length < dataPoints.length) {
			return error('qr_extra_error')
		}
		if (tbc || headers.length > dataPoints.length) {
			if (!tbc) data = data + "..." + (parseInt(fragment)+1)
			localStorage.setItem(partialKey,data)
			return message('qr_another_needed')
		}
		localStorage.removeItem(partialKey)
		localStorage.setItem(key,data)
		message('qr_upload_complete')
		$('body').append($('<p><a href=/upload.html data-i18n=qr_upload_link></a></p>'))
		applyTranslations()
	}

	getDataFromUrl()

	function deletePartial(){
		var partial = $(this).attr('data-partial')
		if (confirm(translate('qr_delete_partial_confirm'))){
			localStorage.removeItem(partial)
			$(this).closest('p').remove()
		}
	}

	for(var i in localStorage){
		if (/^partial_.*/.test(i)){
			var name = i.replace(/^partial_/,"")
			$('#partials').append(
				$('<p>').append($('<button data-i18n=delete_button>').attr('data-partial',i).click(deletePartial))
				.append(" ").append($('<span data-i18n=qr_optional_scan_another>').attr('data-scoutingName',name))
			)
		}
	}
	applyTranslations()
})
