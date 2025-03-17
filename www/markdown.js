"use strict"
onApplyTranslation.push(show)
var lastLocale='xx'
function show(){
	if(locale==lastLocale)return
	load(locale).then(function(text){
		var m,
		title = ""
		if(locale=='qd') text=text.replace(/[^ \n\r\t]/g,'.')
		if (m = /^([^\n\r]+)[\n\r]+\=\=\=+[\n\r]+([^]*)/.exec(text)){
			title = m[1]
			text = m[2]
		}
		if (title){
			if (document.title) document.title = `${title} — ${document.title}`
			else document.title = title
		}
		$('#md').html(window.markdownit({html:true}).render(text).replace(/\$URL\$/,location.origin+"/"))
	})
	lastLocale=locale
}
function load(locale){
	return fetch(location.pathname.replace(/\.html$/,locale?`.${locale}.md`:'.md')).then(response=>{
		if(response.ok)return response.text()
		else if(!locale) return Promise.reject(new Error("404 Not Found"))
		else return load(locale.replace(/[_\-]?[^_\-]+$/,''))
	})
}
