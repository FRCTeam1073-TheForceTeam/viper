var file=(location.hash.match(/^\#(?:(?:.*\&)?(?:file\=))?(20[0-9]{2}[a-zA-Z0-9_\-]+\.[a-z]+\.csv)(?:\&.*)?$/)||["",""])[1]

$(document).ready(function(){
	var editor
	$('#file').val(file)
	function loadFile(){
		$.ajax({
			async: true,
			beforeSend: function(xhr){
				xhr.overrideMimeType("text/plain;charset=UTF-8");
			},
			url: `/data/${file}`,
			timeout: 5000,
			type: "GET",
			success: function(text){
				var data = text.split(/[\r\n]+/).map(l=>l.split(/,/))
				editor = new Handsontable($('#editor')[0],{
					data: data,
					rowHeaders: true,
					colHeaders: true,
					contextMenu: true
				})
			},
			error: function(xhr,status,err){
				console.log(err)
			}
		})
	}
	loadFile()
	$('#saver').submit(function(e){
		$('#csv').val((editor.getData().map(l=>l.join(",")).join('\n')+"\n").replace(/^,+[\r\n]+/gm,""))
	})
	$('#delete').click(function(e){
		if (!confirm(`Are you sure you want to delete ${file}?`)){
			e.preventDefault()
			return false
		}
	})
})
