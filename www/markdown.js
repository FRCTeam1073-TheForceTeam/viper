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
            var m
            if (m = /^([^\n\r]+)[\n\r]+\=\=\=+[\n\r]+([^]*)/.exec(text)){
                $('title').text(m[1])
                text = m[2]
            }
            $('#md').html(window.markdownit().render(text).replace(/\$URL\$/,url))
        }
	})
})
