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
addI18n({
	eli5_label:{
		en:'Explain it like I’m 5',
		tr:'Bana 5 yasindaymisim gibi anlat',
		pt:'Explica como se eu tivesse 5 anos',
		zh_tw:'用最簡單的方式解釋',
		fr:'Explique-le comme si j’avais 5 ans',
		he:'תסביר לי כאילו אני בן 5',
		es:'Explicamelo como si tuviera 5 anos',
	},
})

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
		setupEli5()
	})
	lastLocale=locale
}

// A document can offer a plainer retelling of a section by wrapping it in
// <div class=eli5Simple>, alongside the usual text in <div class=eli5Detailed>.
// Where both exist, offer a switch between them; documents without a simple
// version are untouched and show no switch.
var eli5Key = 'md_eli5'

function eli5Enabled(){
	try { return localStorage.getItem(eli5Key) == '1' } catch(e) { return false }
}

function setEli5Enabled(on){
	try { localStorage.setItem(eli5Key, on ? '1' : '0') } catch(e) { /* private window */ }
}

function applyEli5(on){
	$('#md').toggleClass('eli5On', !!on)
}

function setupEli5(){
	var md = $('#md')
	if (!md.find('.eli5Simple').length || !md.find('.eli5Detailed').length) return
	var on = eli5Enabled(),
	row = $('<label class=eli5Toggle>')
		.append($('<span class=switch-label>').attr('data-i18n','eli5_label'))
		.append($('<span class=switch>')
			.append($('<input type=checkbox id=eli5Switch>').prop('checked', on))
			.append($('<span class=slider>')))
	// Sit the switch on the same line as the document's first heading rather than
	// on a row of its own, so it costs no extra height.
	var heading = md.children('h1,h2,h3,h4').first()
	if (heading.length){
		var head = $('<div class=eli5Head>')
		heading.before(head)
		head.append(heading).append(row)
	} else {
		md.prepend(row)
	}
	applyEli5(on)
	row.find('input').change(function(){
		setEli5Enabled(this.checked)
		applyEli5(this.checked)
	})
	// Pass the node so this does not re-enter the onApplyTranslation handlers.
	applyTranslations(md)
}
function load(locale){
	if (locale=='en')return load('')
	// Revalidate rather than trust the 20-hour cache: the document is the content
	// of this page, and an edit to it should show up on the next load, not tomorrow.
	return fetch(location.pathname.replace(/\.html$/,locale?`.${locale}.md`:'.md'),{cache:'no-cache'}).then(response=>{
		if(response.ok)return response.text()
		else if(!locale) return Promise.reject(new Error("404 Not Found"))
		else return load(locale.replace(/[_\-]?[^_\-]+$/,''))
	})
}
