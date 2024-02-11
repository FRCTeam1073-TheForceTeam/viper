"use strict"

var file=(location.hash.match(/^\#(?:(?:.*\&)?(?:file\=))?(20[0-9]{2}[a-zA-Z0-9\-]+\.[a-z]+\.csv)(?:\&.*)?$/)||["",""])[1]

$(document).ready(function(){
	if (!file){
		$('h1').text("No file specified")
		return
	}
	$.getJSON(`/revisions.cgi?file=${file}`, function(json){
		$('h1').text(`${file} Revisions`)
		document.title = document.title.replace(/FILE/,file)
		var revList = $('#revisions').html(''),
		first=true
		json.forEach(revision=>{
			var revItem = $('<li>'),
			fieldList=$('<ul>')
			revItem.append($('<h2>').text(`Revision: ${revision.revision}`))
			fieldList.append($('<li>').text(`Timestamp: ${revision.date}`))
			fieldList.append($('<li>').text(`Message: ${revision.message}`))
			var links = $('<li>')
			links
				.append(`<a href=/revisions.cgi?file=${file}&revision=${revision.revision}>View</a>`)
				.append(' | ')
				.append(`<a href=/revisions.cgi?file=${file}&revision=${revision.revision}&download=1>Download</a>`)
			if (!first){
				links
					.append(' | ')
					.append(`<a href=/admin/revert.cgi?file=${file}&revision=${revision.revision}>Revert</a>`)
			}
			fieldList.append(links)
			revItem.append(fieldList)
			var diffLines = (revision.diffs||"").replace(/^.*\n.*\n.*\n/,"").split(/\n/),
			pre = $('<pre>')
			diffLines.forEach(line=>{
				var span=$('<span>')
				if (/^\+/.test(line)) span.addClass('add')
				if (/^\-/.test(line)) span.addClass('rem')
				span.text(line+"\n")
				pre.append(span)
			})
			revItem.append(pre)
			revList.append(revItem)
			first=false
		})
	})
})
