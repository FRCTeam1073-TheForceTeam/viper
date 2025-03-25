"use strict"

addI18n({
	import_page_title:{
		en:'Import Scouting Data',
		pt:'Importar dados de escotismo',
		he:'ייבוא ​​נתוני צופי',
		tr:'İzcilik Verilerini İçe Aktar',
		fr:'Importer les données de dépistage',
		zh_tw:'導入偵察數據',
	},
	format_label:{
		en:'Format:',
		pt:'Formato:',
		he:'פוּרמָט:',
		tr:'Biçim:',
		fr:'Format :',
		zh_tw:'格式：',
	},
	example_button:{
		en:'Show Example',
		pt:'Mostrar exemplo',
		he:'הצג דוגמה',
		tr:'Örnek Göster',
		fr:'Afficher un exemple',
		zh_tw:'顯示範例',
	},
	input_placeholder:{
		en:'Paste data here',
		pt:'Colar dados aqui',
		he:'הדבק נתונים כאן',
		tr:'Verileri buraya yapıştır',
		fr:'Coller les données ici',
		zh_tw:'將數據貼到此處',
	},
	convert_button:{
		en:'Convert ↓',
		pt:'Converter ↓',
		he:'המרה ↓',
		tr:'Dönüştür ↓',
		fr:'Convertir ↓',
		zh_tw:'轉換↓',
	},
	output_placeholder:{
		en:'Reformatted data will appear here',
		pt:'Os dados reformatados aparecerão aqui',
		he:'נתונים מעוצבים מחדש יופיעו כאן',
		tr:'Yeniden biçimlendirilmiş veriler burada görünecek',
		fr:'Les données reformatées apparaîtront ici.',
		zh_tw:'重新格式化的資料將出現在此處',
	},
	error_not_implemented:{
		en:'Sorry, no import options are available yet this season.',
		pt:'Desculpe, ainda não há opções de importação disponíveis nesta temporada.',
		he:'מצטערים, אין עדיין אפשרויות ייבוא ​​זמינות העונה.',
		tr:'Üzgünüz, bu sezon henüz hiçbir içe aktarma seçeneği mevcut değil.',
		fr:'Désolé, aucune option d\'importation n\'est encore disponible cette saison.',
		zh_tw:'抱歉，本季尚無可用的導入選項。',
	},
})

$(document).ready(function(){
	function safeCSV(s){
		if (s===undefined)s=""
		s = s.toString()
		return s
			.replace(/\t/g, " ")
			.replace(/\r|\n|\r\n/g, "⏎")
			.replace(/\"/g, "״")
			.replace(/,/g, "،")
	}
	function processData(){
		var csv=""
		try {
			var rows = window.importFunctions[$('#format').val()].convert($('#import-data').val())
			if (!rows || !rows.length || !rows[0].match || !rows[0].team) return
			var headers = Object.keys(rows[0]).filter(k=>!!statInfo[k])
			csv = headers.join(",")+"\n"
			rows.forEach(row=>{
				if (row.match && row.team) csv += headers.map(k=>safeCSV(row[k])).join(",")+"\n"
			})
		} catch (error){
			console.error(error)
		}
		$('#csv').val(csv)
		$('#save-container').toggle(!!csv)
		return false
	}
	function setExample(){
		fetch( window.importFunctions[$('#format').val()].example).then(response=>{return response.text()}).then(text=>{
			$('#import-data').attr('placeholder',text)
			$('#example-content').text(text)
		})
	}
	promiseScript(`/${eventYear}/aggregate-stats.js`).then(function(){
		if (!window.importFunctions||!Object.keys(window.importFunctions).length){
			$('#main').html("<h1 data-i18n=import_page_title></h1><p data-i18n=error_not_implemented></p>")
			applyTranslations()
			return
		}
		Object.keys(window.importFunctions).forEach(convertName => {
			$('#format').append($('<option>').text(convertName).attr('value',convertName))
		})
		processData()
		setExample()
	})
	$('#import-data,#change').change(processData)
	$('#format').on('change',processData)
	$('#format').on('change',setExample)
	$('#file').val(eventId + ".scouting.csv")
	$('#example-button').click(function(){showLightBox($('#example-lightbox'))})
})
