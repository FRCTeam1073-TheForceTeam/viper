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

if (location.hash){
	var keys = location.hash.replace(/^\#/,"").replace(/\#.*/,"").split(/,/)
	for (var i=0; i<keys.length; i++){
		var key = keys[i]
		if (/^20\d\d/.test(key)){
			var d = localStorage.getItem(key)
			localStorage.removeItem(key)
			if (d) localStorage.setItem(`uploaded_${key}`, d)
		}
	}
}
redirect()

function redirect(){
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
