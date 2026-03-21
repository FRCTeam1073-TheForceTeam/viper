"use strict"

addI18n({
	upload_done_title:{
		en:'Upload Complete',
		fr:'Téléchargement terminé',
		zh_tw:'上傳完成',
		pt:'Upload concluído',
		he:'ההעלאה הושלמה',
		tr:'Yükleme Tamamlandı',
	},
	upload_done_please_wait:{
		en:'Moving uploaded data to history…',
		fr:'Transfert des données téléchargées vers l\'historique…',
		zh_tw:'正在將上傳的資料移至歷史記錄...',
		pt:'Movendo dados enviados para o histórico…',
		he:'מעביר נתונים שהועלו להיסטוריה...',
		tr:'Yüklenen veriler geçmişe taşınıyor…',
	},
})

$(document).ready(function(){
	var keysToRename = []
	if (location.hash){
		keysToRename = location.hash.replace(/^\#/,"").replace(/\#.*/,"").split(/,/)
		for (var i=0; i<keysToRename.length; i++){
			var key = keysToRename[i]
			if (/^20\d\d/.test(key)){
				localStorage['uploaded_' + key] = localStorage[key]
				delete localStorage[key]
			}
		}
	}
	redirect(keysToRename)
})

function redirect(keysToRename){
	keysToRename = keysToRename || []
	// Check if there's more data to upload
	for (var i in localStorage){
		// Skip items that are being renamed, or have already been uploaded or deleted
		if (keysToRename.indexOf(i) !== -1 || i.match(/^(uploaded_|deleted_)/)) continue

		if (
			/^20[0-9]{2}(-[0-9]{2})?_photo_[0-9]+/.test(i) ||
			/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_subjective_[0-9]+/.test(i) ||
			/^20[0-9]{2}(-[0-9]{2})?.*_.*_/.test(i) ||
			/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_[0-9]+/.test(i)
		){
			return delayRedirect(`/upload.html`)
		}
	}

	var eId = localStorage.getItem('last_event_id'),
	eYear = localStorage.getItem('last_event_year'),
	ePos = localStorage.getItem('last_pos'),
	eOrient = localStorage.getItem('last_orient'),
	eType = localStorage.getItem("last_scout_type")
	if (!eId) return delayRedirect(`/`)
	if (!eYear || !eType) return delayRedirect(`/event.html#event=${eId}`)
	if (eType=='photos') return delayRedirect(`/bot-photos.html#event=${eId}`)
	if (eType=='scout' && ePos) return delayRedirect(`/${eYear}/scout.html#event=${eId}&pos=${ePos}`+(eOrient?`&orient=${eOrient}`:""))
	delayRedirect(`/${eYear}/${eType}.html#event=${eId}`)
}

function delayRedirect(url){
	setTimeout(function(){
		location.href = url
	},3000)
}
