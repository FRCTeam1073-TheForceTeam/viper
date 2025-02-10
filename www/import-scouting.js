"use strict"

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
			$('#main').html("<h1>Import Scouting Data</h1><p>Sorry, no import options are available yet this season.</p>")
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
