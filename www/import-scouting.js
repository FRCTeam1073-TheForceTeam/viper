"use strict"

$(document).ready(function(){
	function safeCSV(s){
		s = s.toString()
		return s
			.replace(/\t/g, " ")
			.replace(/\r|\n|\r\n/g, "⏎")
			.replace(/\"/g, "״")
			.replace(/,/g, "،")
	}
	function processData(){
		var rows = importScoutingFires($('#import-data').val())
		if (!rows || !rows.length) return
		var csv = Object.keys(rows[0]).join(",")+"\n"
		rows.forEach(row=>{
			csv += Object.values(row).map(safeCSV).join(",")+"\n"
		})

		$('#csv').val(csv)
	}
	promiseScript(`/${eventYear}/aggregate-stats.js`)
	$('#import-data').change(processData)
	$('#file').val(eventId + ".scouting.csv")
})
