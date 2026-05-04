"use strict"

addI18n({
	auto_uploading:{
		en:'Auto-uploading...',
		tr:'Otomatik yükleniyor...',
		he:'העלאה אוטומטית...',
		zh_tw:'自動上傳中...',
		fr:'Chargement automatique...',
		pt:'Carregando automaticamente...',
		es:'Cargando automáticamente...',
	},
	auto_upload_success:{
		en:'Uploaded!',
		tr:'Yüklendi!',
		he:'הועלה!',
		zh_tw:'已上傳!',
		fr:'Téléchargé!',
		pt:'Carregado!',
		es:'¡Carga automática exitosa!',
	},
	auto_upload_failure:{
		en:'Upload failed',
		tr:'Yükleme başarısız',
		he:'ההעלאה נכשלה',
		zh_tw:'上傳失敗',
		es:'Error al cargar automáticamente',
		fr:'Échec du chargement',
		pt:'Falha no carregamento',
	},
	auto_upload_items:{
		en:'Items uploaded: _COUNT_',
		tr:'Yüklenen öğeler: _COUNT_',
		he:'פריטים שהועלו: _COUNT_',
		zh_tw:'上傳的項目: _COUNT_',
		es:'elementos',
		fr:'Éléments téléchargés: _COUNT_',
		pt:'Itens carregados: _COUNT_',
	},
	auto_uploading_photos:{
		en:'Photos: _COUNT_',
		tr:'Fotoğraflar: _COUNT_',
		he:'תמונות: _COUNT_',
		zh_tw:'照片: _COUNT_',
		fr:'Photos: _COUNT_',
		pt:'Fotos: _COUNT_',
		es:'Cargando fotos automáticamente...',
	},
	auto_uploading_scouting:{
		en:'Scouting: _COUNT_',
		tr:'İzcilik: _COUNT_',
		he:'סימון: _COUNT_',
		zh_tw:'偵測: _COUNT_',
		es:'Cargando datos de exploración automáticamente',
		fr:'Repérage: _COUNT_',
		pt:'Exploração: _COUNT_',
	},
	auto_uploading_pit:{
		en:'Pit: _COUNT_',
		tr:'Pit: _COUNT_',
		he:'Pit: _COUNT_',
		zh_tw:'Pit: _COUNT_',
		fr:'Pit: _COUNT_',
		pt:'Pit: _COUNT_',
		es:'Cargando datos de hoyo automáticamente...',
	},
	auto_uploading_subjective:{
		en:'Subjective: _COUNT_',
		tr:'Öznel: _COUNT_',
		he:'סובייקטיבי: _COUNT_',
		zh_tw:'主觀: _COUNT_',
		es:'Cargando datos subjetivos automáticamente',
		fr:'Subjectif: _COUNT_',
		pt:'Subjetivo: _COUNT_',
	},
})

var hasHeartbeat = true
var isUploading = false

// Create upload status UI
function createUploadStatusUI() {
	if (!$('#auto-upload-status').length) {
		$('body').append(
			$('<div id="auto-upload-status" style="'+
				'position:fixed;'+
				'top:1em;'+
				'left:1em;'+
				'background-color:var(--section-bg-color);'+
				'border:1px solid var(--main-border-color);'+
				'padding:1em;'+
				'border-radius:0.3em;'+
				'display:none;'+
				'z-index:10000;'+
				'max-width:20em;'+
				'box-shadow:0 4px 6px rgba(0,0,0,0.3)'+
			'">')
		)
	}
	return $('#auto-upload-status')
}

function showUploadStatus(message) {
	var ui = createUploadStatusUI()
	ui.html(message)
	applyTranslations(ui)
	ui.show()
}

function hideUploadStatus() {
	$('#auto-upload-status').fadeOut(5000)
}

function getUploadBatch() {
	var scoutCsv = {}
	var pitCsv = {}
	var subjectiveCsv = {}
	var photoCsv = {}
	var photoCount = 0
	var scoutingCount = 0
	var pitCount = 0
	var subjectiveCount = 0

	Object.keys(localStorage).forEach(key => {
		// Skip already uploaded, deleted, or header items
		if (/^(uploaded_|deleted_)/.test(key)) return
		if (/(headers|AggregateGraphs|TeamStats|WhiteboardStats|PredictorStats)$/.test(key)) return

		// Photos
		if (/^20[0-9]{2}(-[0-9]{2})?_photo_[0-9]+/.test(key) && photoCount < 4) {
			var year = key.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1")
			photoCsv[key] = localStorage[key]
			photoCount++
		}
		// Subjective scouting
		else if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_subjective_[0-9]+/.test(key) && subjectiveCount < 10) {
			var year = key.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1")
			if (!subjectiveCsv[year]) {
				subjectiveCsv[year] = localStorage.getItem(`${year}_subjectiveheaders`) || ""
			}
			subjectiveCsv[year] += localStorage[key]
			subjectiveCount++
		}
		// Regular scouting
		else if (/^20[0-9]{2}(-[0-9]{2})?.*_.*_/.test(key) && scoutingCount < 10 && !/(_photo_|_subjective_)/.test(key)) {
			var year = key.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1")
			if (!scoutCsv[year]) {
				scoutCsv[year] = localStorage.getItem(`${year}_headers`) || ""
			}
			scoutCsv[year] += localStorage[key]
			scoutingCount++
		}
		// Pit scouting
		else if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_[0-9]+$/.test(key) && pitCount < 10 && !/_photo_/.test(key) && !/_subjective_/.test(key)) {
			var year = key.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1")
			if (!pitCsv[year]) {
				pitCsv[year] = localStorage.getItem(`${year}_pitheaders`) || ""
			}
			pitCsv[year] += localStorage[key]
			pitCount++
		}
	})

	return {
		photos: photoCsv,
		scouting: scoutCsv,
		pit: pitCsv,
		subjective: subjectiveCsv,
		photoCount: photoCount,
		scoutingCount: scoutingCount,
		pitCount: pitCount,
		subjectiveCount: subjectiveCount,
		totalCount: photoCount + scoutingCount + pitCount + subjectiveCount
	}
}

function buildCSVData(batch) {
	var csv = ""

	Object.keys(batch.scouting).forEach(year => {
		var data = batch.scouting[year]
		// Only include if there's more than just the header (header has newline, data rows are appended after)
		if (data && data.split('\n').length > 2) {
			csv += data
		}
	})
	Object.keys(batch.pit).forEach(year => {
		var data = batch.pit[year]
		if (data && data.split('\n').length > 2) {
			csv += data
		}
	})
	Object.keys(batch.subjective).forEach(year => {
		var data = batch.subjective[year]
		if (data && data.split('\n').length > 2) {
			csv += data
		}
	})

	return csv
}

function processAutoUpload() {
	if (isUploading) return

	var batch = getUploadBatch()

	if (batch.totalCount === 0) {
		hideUploadStatus()
		return
	}

	isUploading = true
	var itemsToUpload = []
	var photoCount = 0
	var subjectiveCount = 0
	var scoutingCount = 0
	var pitCount = 0

	// Collect all item keys for cleanup after successful upload
	var keys = Object.keys(localStorage)
	for (var i = 0; i < keys.length; i++) {
		var key = keys[i]

		// Stop collecting once we've reached our batch limits
		if (itemsToUpload.length >= batch.totalCount) break

		if (/^(uploaded_|deleted_)/.test(key) || /(headers|AggregateGraphs|TeamStats|WhiteboardStats|PredictorStats)$/.test(key)) continue
		if (/^20[0-9]{2}(-[0-9]{2})?_photo_[0-9]+/.test(key) && photoCount < batch.photoCount) {
			itemsToUpload.push(key)
			photoCount++
		}
		else if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_subjective_[0-9]+/.test(key) && subjectiveCount < batch.subjectiveCount) {
			itemsToUpload.push(key)
			subjectiveCount++
		}
		else if (/^20[0-9]{2}(-[0-9]{2})?.*_.*_/.test(key) && scoutingCount < batch.scoutingCount && !/(_photo_|_subjective_)/.test(key)) {
			itemsToUpload.push(key)
			scoutingCount++
		}
		else if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_[0-9]+$/.test(key) && pitCount < batch.pitCount && !/_photo_/.test(key) && !/_subjective_/.test(key)) {
			itemsToUpload.push(key)
			pitCount++
		}
	}

	var csv = buildCSVData(batch)

	var statusHtml = '<strong data-i18n="auto_uploading"></strong>'
	if (batch.photoCount > 0) statusHtml += '<br><span data-i18n="auto_uploading_photos" data-translate-count="' + batch.photoCount + '"></span>'
	if (batch.scoutingCount > 0) statusHtml += '<br><span data-i18n="auto_uploading_scouting" data-translate-count="' + batch.scoutingCount + '"></span>'
	if (batch.pitCount > 0) statusHtml += '<br><span data-i18n="auto_uploading_pit" data-translate-count="' + batch.pitCount + '"></span>'
	if (batch.subjectiveCount > 0) statusHtml += '<br><span data-i18n="auto_uploading_subjective" data-translate-count="' + batch.subjectiveCount + '"></span>'

	showUploadStatus(statusHtml)

	var formData = new FormData()
	formData.append('csv', csv)
	formData.append('next', '/upload.html')

	// Collect photo data asynchronously
	var photoPromises = Object.keys(batch.photos).map(photoKey => {
		return new Promise(resolve => {
			var year = photoKey.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1")
			var name = photoKey.replace(/.*_photo_/,'')
			pdb.get(photoKey, photoData => {
				if (photoData) {
					formData.append(`${year}/${name}`, photoData)
				}
				resolve()
			})
		})
	})

	Promise.all(photoPromises).then(() => {
		fetch('/scout/upload.cgi', {
			method: 'POST',
			body: formData
		})
		.then(response => {
			if (response.ok) {
				// Mark uploaded items in localStorage (photo stays at original key in IndexedDB)
				itemsToUpload.forEach(key => {
					if (!key.startsWith('uploaded_')) {
						localStorage['uploaded_' + key] = localStorage[key]
						delete localStorage[key]
					}
				})

				// Update menu to reflect changes
				if (typeof showMainMenuUploads === 'function') {
					showMainMenuUploads()
				}

				var successHtml = '<strong style="color:var(--highlight-fg-color)" data-i18n="auto_upload_success"></strong><br><span data-i18n="auto_upload_items" data-translate-count="' + itemsToUpload.length + '"></span>'
				showUploadStatus(successHtml)
				hideUploadStatus()

				// Process next batch if one exists (with 2 second delay)
				isUploading = false
				setTimeout(processAutoUpload, 2000)
			} else {
				throw new Error('Upload failed with status ' + response.status)
			}
		})
		.catch(error => {
			console.error('Auto-upload error:', error)
			console.error('failed data', csv)
			var errorHtml = '<strong style="color:var(--button-disabled-decoration-color)" data-i18n="auto_upload_failure"></strong><br>' + error.message
			showUploadStatus(errorHtml)
			hideUploadStatus()
			isUploading = false
		})
	})
}

setInterval(function(){
	$.ajax({
		async: true,
		beforeSend: function(xhr){
			xhr.overrideMimeType("text/html;charset=UTF-8");
		},
		url: "/heartbeat.html",
		timeout: 5000,
		type: "GET",
		success: function(){
			hasHeartbeat = true
			$('.show-only-when-connected').show()
			// Trigger auto-upload on successful heartbeat
			processAutoUpload()
		},
		error: function(){
			hasHeartbeat = false
			$('.show-only-when-connected').hide()
		}
	})
}, 6*1000) // 6 seconds
