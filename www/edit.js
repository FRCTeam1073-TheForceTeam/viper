"use strict"

addI18n({
	delete_confirm:{
		en:'Are you sure you want to delete _FILE_?',
		zh_tw:'您確定要刪除_FILE_嗎？',
		fr:'Êtes-vous sûr de vouloir supprimer _FILE_ ?',
		tr:'_FILE_ dosyasını silmek istediğinizden emin misiniz?',
		pt:'Você tem certeza de que deseja excluir _FILE_?',
		he:'האם אתה בטוח שברצונך למחוק את _FILE_?',
	},
})

var file=(location.hash.match(/^\#(?:(?:.*\&)?(?:file\=))?(20[0-9]{2}[a-zA-Z0-9\-]+\.[a-z]+\.csv)(?:\&.*)?$/)||["",""])[1],
editor

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
				console.error(err)
				blankTable()
			}
		})
	}
	loadFile()
	$('#saver').submit(function(e){
		try{
			$('#csv').val((to2DArray(editor.getData()).map(safeCSV).map(l=>l.join(",")).join('\n')+"\n").replace(/,(\r|\n|(\r\n))/gm,"\n").replace(/^,+\n/gm,""))
		} catch(x){
			console.error(x)
			return false
		}
	})
	$('#delete').click(function(e){
		if (!confirm(translate('delete_confirm',{file:file}))){
			e.preventDefault()
			return false
		}
	})
	document.title = document.title.replace(/FILE/,file)
})

function to2DArray(data){
	var h=Object.keys(data[0]).filter(k=>k!='id'),d=[]
	d.push(h)
	for(var i=0;i<data.length;i++){
		var r=[]
		for(var j=0;j<h.length;j++){
			r.push(data[i][h[j]])
		}
		d.push(r)
	}
	return d
}

function blankTable(){
	tableEditor([['','',''],['','',''],['','','']])
	$('#file').removeAttr('readonly')
	$('#delete').hide()
}

function tableEditor(data){
	var h=data[0],b=[],c=[]
	for(var j=0;j<h.length;j++){
		c.push({
			title:h[j],
			field:h[j],
		})
	}
	for (var i=1;i<data.length;i++){
		var d = data[i],r={id:i}
		for(var j=0;j<d.length;j++){
			r[h[j]]=d[j]
		}
		b.push(r)
	}

	editor = new Tabulator("#editor",{
		data:b,
		columns:c,
		history:true,
		height:"100%",
		paginationCounter:"rows",
		movableColumns:true,
		selectableRange:1,
		selectableRangeColumns:true,
		selectableRangeRows:true,
		selectableRangeClearCells:true,
		editTriggerEvent:"dblclick",
		clipboard:true,
		clipboardCopyStyled:false,
		clipboardCopyConfig:{
			rowHeaders:false,
			columnHeaders:false,
		},
		pagination:true,
		clipboardCopyRowRange:"range",
		clipboardPasteParser:"range",
		clipboardPasteAction:"range",
		headerSortClickElement:'icon',
		history:true,
		columnDefaults:{
			headerSort:true,
			headerHozAlign:"start",
			editor:"input",
			resizable:"header",
		},
		rowContextMenu:[
			{
				label:"Delete Row",
				action:function(_,row){
					row.delete()
				}
			},
			{
				label:"Add Row Above",
				action:function(_,row){
					editor.addRow([""],true,row.getIndex())
				}
			},
			{
				label:"Add Row Below",
				action:function(_,row){
					editor.addRow([""],false,row.getIndex())
				}
			},
		]
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
	if (s.map && typeof s.map === 'function'){
		return s.map(safeCSV)
	}
	return (""+s)
		.replace(/\t/g, " ")
		.replace(/\r|\n|\r\n/g, "⏎")
		.replace(/\"/g, "״")
		.replace(/,/g, "،")
}
