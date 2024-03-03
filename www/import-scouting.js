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
		var f =  window[$('#format').val()]
		if (typeof f != 'function') return
		var rows = f($('#import-data').val())
		if (!rows || !rows.length || !rows[0].match || !rows[0].team) return
		var headers = Object.keys(rows[0]).filter(k=>!!statInfo[k])
		var csv = headers.join(",")+"\n"
		rows.forEach(row=>{
			if (row.match && row.team) csv += headers.map(k=>safeCSV(row[k])).join(",")+"\n"
		})
		$('#csv').val(csv)
	}
	promiseScript(`/${eventYear}/aggregate-stats.js`).then(function(){
		$('#format option').each(function(){
			if (typeof window[$(this).attr('value')]!='function') $(this).remove()
		})
		processData()
	})
	$('#import-data,#format').change(processData)
	$('#file').val(eventId + ".scouting.csv")
})
