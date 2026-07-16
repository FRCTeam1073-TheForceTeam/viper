"use strict"
// When shown inside a lightbox iframe, mark the doc so the page background can drop out,
// leaving only the #md content card visible (no surrounding panel). Clicking anywhere outside
// the card (the transparent area of the iframe) closes the lightbox in the parent.
if (window.self !== window.top){
	document.documentElement.classList.add('in-frame')
	document.addEventListener('click', function(e){
		if (!e.target.closest('#md')){
			try { window.parent.closeLightBox() } catch(x) {}
		}
	})
}
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
	if (locale=='en')return load('')
	return fetch(location.pathname.replace(/\.html$/,locale?`.${locale}.md`:'.md')).then(response=>{
		if(response.ok)return response.text()
		else if(!locale) return Promise.reject(new Error("404 Not Found"))
		else return load(locale.replace(/[_\-]?[^_\-]+$/,''))
	})
}
