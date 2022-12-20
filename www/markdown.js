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
            $('#md').html(window.markdownit().render(text).replace(/\$URL\$/,url))
        }
	})
})
