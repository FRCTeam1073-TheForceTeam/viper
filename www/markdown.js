"use strict"
$(document).ready(function(){
	var url = location.origin + "/"
	var mdFile = location.pathname.replace(/\.html$/,".md")
	$.ajax({
		async: true,
		beforeSend: function(xhr){
			xhr.overrideMimeType("text/plain;charset=UTF-8");
		},
		url: mdFile,
		timeout: 5000,
		type: "GET",
		success: function(text){
			var m,
			title = ""
			if (m = /^([^\n\r]+)[\n\r]+\=\=\=+[\n\r]+([^]*)/.exec(text)){
				title = m[1]
				text = m[2]
			}
			if (title){
				if (document.title) document.title = `${title} — ${document.title}`
				else document.title = title
			}
			$('#md').html(window.markdownit({html:true}).render(text).replace(/\$URL\$/,url))
		}
	})
})
