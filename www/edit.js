"use strict"

var file=(location.hash.match(/^\#(?:(?:.*\&)?(?:file\=))?(20[0-9]{2}[a-zA-Z0-9\-]+\.[a-z]+\.csv)(?:\&.*)?$/)||["",""])[1]

var editor
$(document).ready(function(){
	$('#file').val(file)
	function loadFile(){
		if (!file) return blankTable()
		$.ajax({
			async: true,
			beforeSend: function(xhr){
				xhr.overrideMimeType("text/plain;charset=UTF-8");
			},
			url: `/data/${file}`,
			timeout: 5000,
			type: "GET",
			success: function(text){
				tableEditor(text.split(/[\r\n]+/).map(l=>l.split(/,/).map(unescapeField)))
			},
			error: function(xhr,status,err){
				console.log(err)
				blankTable()
			}
		})
	}
	loadFile()
	$('#saver').submit(function(e){
		$('#csv').val((editor.getData().map(safeCSV).map(l=>l.join(",")).join('\n')+"\n").replace(/,(\r|\n|(\r\n))/gm,"\n").replace(/^,+\n/gm,""))
	})
	$('#delete').click(function(e){
		if (!confirm(`Are you sure you want to delete ${file}?`)){
			e.preventDefault()
			return false
		}
	})
})

function blankTable(){
	tableEditor([['','',''],['','',''],['','','']])
	$('#file').removeAttr('readonly')
	$('#delete').hide()
}

function tableEditor(data){
	editor = new Handsontable($('#editor')[0],{
		data: data,
		rowHeaders: true,
		colHeaders: true,
		contextMenu: true,
		manualColumnFreeze: true,
		minSpareRows: 1,
		minSpareCols: 1,
	})
}

function unescapeField(s){
	return s
		.replace(/⏎/g, "\n")
		.replace(/״/g, "\"")
		.replace(/،/g, ",")
}

function safeCSV(s){
	if (!s) return ""
	if (typeof s === 'object'){
		return s.map(safeCSV)
	}
	return s
		.replace(/\t/g, " ")
		.replace(/\r|\n|\r\n/g, "⏎")
		.replace(/\"/g, "״")
		.replace(/,/g, "،")
}
