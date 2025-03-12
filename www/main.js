"use strict"

const I18N={},
onApplyTranslation=[]

addI18n({
	home_link:{
		en:'Event List',
		pt:'Lista de eventos',
		fr:'Liste des événements',
		tr:'Etkinlik Listesi',
		zh_tw:'事件列表',
	},
	upload_data_link:{
		en:'Upload Data',
		pt:'Carregar dados',
		fr:'Télécharger des données',
		tr:'Veri Yükle',
		zh_tw:'上傳數據',
	},
	about_link:{
		en:'About this app',
		pt:'Sobre este aplicativo',
		fr:'À propos de cette application',
		tr:'Bu uygulama hakkında',
		zh_tw:'關於此應用程式',
	},
	my_team_num:{
		en:'My team #',
		pt:'Minha equipe #',
		fr:'Mon équipe #',
		tr:'Takımım #',
		zh_tw:'我的團隊',
	},
	instructions:{
		en:'Instructions',
		pt:'Instruções',
		fr:'Instructions',
		tr:'Talimatlar',
		zh_tw:'指示',
	},
})
var locale=computeLocale()
function addI18n(i){
	Object.assign(I18N,i)
}

function computeLocale(){
	var l=localStorage.locale||navigator.language||'en'
	l=l.replace(/\-/g,"_")
	while(l){
		if(l=='qd'||Object.hasOwn(I18N.home_link,l)) return l
		l=l.replace(/[_]?[^_]*$/,"")
	}
	return 'en'
}

function translate(key){
	var unknown=key
	if(!Object.hasOwn(I18N,key))return unknown
	var g=I18N[key],
	l=locale
	if(l=='qd')return Object.hasOwn(g,'en')?g.en.replace(/[^ ]/g,'.'):unknown
	while(l){
		if(Object.hasOwn(g,l))return g[l]
		l=l.replace(/[_]?[^_]*$/,"")
	}
	return unknown
}

function getDate(s){
	if (!s) return ""
	var m = /[0-9]{4}-[0-9]{2}-[0-9]{2}/.exec(s)
	if (m) return m[0]
	return ""
}

function dateCompare(a,b){
	return getDate(b).localeCompare(getDate(a))
}

function applyTranslations(node){
	if(!node)node=$('body')
	node.find('[data-i18n]').each(function(){
		$(this).text(translate($(this).attr('data-i18n')))
	})
	node.find('[data-i18n-value]').each(function(){
		$(this).attr('value',translate($(this).attr('data-i18n-value')))
	})
	node.find('[data-i18n-placeholder]').each(function(){
		$(this).attr('placeholder',translate($(this).attr('data-i18n-placeholder')))
	})
	onApplyTranslation.forEach(x=>x())
}

$(document).ready(function(){
	if (!inIframe()){
		var hamburger = $('<div id=hamburger class=show-only-when-connected>☰</div>'),
		mainMenu = $('<div id=mainMenu class=lightBoxCenterContent>')
		$('body').append(hamburger).append(mainMenu)
		hamburger.click(function(){showLightBox(mainMenu)})

		populateMainMenu()

		function populateMainMenu(){
			Promise.all([
				fetch('/main-menu.html').then(response=>response.text()),
				fetch('/user.cgi').then(response=>response.text())
			]).then(values =>{
				var [menuHtml, userName] = values,
				lastEventId=localStorage.getItem('last_event_id'),
				eId = window.eventId||lastEventId||"",
				eName = window.eventName||(eId==lastEventId?localStorage.getItem('last_event_name'):"")||"",
				eYear = window.eventYear||(eId==lastEventId?localStorage.getItem('last_event_year'):"")||""
				mainMenu.html(
					menuHtml
						.replace(/EVENT_NAME/g,eName)
						.replace(/EVENT_ID/g,eId)
						.replace(/YEAR/g,eYear)
				)
				applyTranslations(mainMenu)
				mainMenu.find('.dependEvent').toggle(!!(eName))
				mainMenu.find('.my-team-input').val(getLocalTeam()).change(function(){
					localStorage.setItem('my-team', parseInt($(this).val()))
					location.reload()
				})
				$('#locale-choose').val(locale).change(function(){
					localStorage.locale=locale=$(this).val()
					applyTranslations()

				})
				showMainMenuUploads()
				$('#logout-link').click(function(){
					var req = new XMLHttpRequest()
					req.open("GET", "/logout", true, 'logout')
					req.onload = _ => {
						if (req.readyState === 4) location.reload()
					}
					req.send()
					return false
				}).text(`Logout ${userName}`).closest('li').toggle(userName!='-')
			})
		}
		$('body').append($('<div id=fullscreen>⛶</div>').click(toggleFullScreen))
		function showMainMenuUploads(){
			hamburger.toggleClass("hasUploads", hasUploads())
			mainMenu.find('.dependUpload').toggle(hasUploadsOrHistory()).toggleClass("hasUploads", hasUploads())
		}
		$(window).on('hashchange',showMainMenuUploads)
		$('body').append($('<div id=lightBoxBG>').click(closeLightBox)).on('keyup',function(e){
			if (e.key=='Escape' && $('#lightBoxBG').is(":visible")){
				e.preventDefault()
				closeLightBox()
			}
		})
	}
	applyTranslations()
	var site = location.host.replace(/^(www|viper|webscout)\./,"")
	if (!site || /^[0-9\.\:]*$/.test(site)){
		site = ""
	} else {
		var m = site.match(/^viper([^\.]+)\.([^\.]+)/)
		if (m){
			site = m[1][0].toUpperCase() + m[1].slice(1) + " " + m[2][0].toUpperCase() + m[2].slice(1)
		} else {
			site = site.replace(/\..*/,'')
			site = site[0].toUpperCase() + site.slice(1)
		}
	}
	var t = document.title
	if (t) t += ' — '
	t += 'Viper'
	if (site) t += ` ${site}`
	document.title = t
})

function getLocalTeam(){
	return localStorage.getItem('my-team') || window.ourTeam || 0
}

function closeLightBox(){
	$('#lightBoxBG,.lightBoxCenterContent,.lightBoxFullContent').hide()
	return false
}

function showLightBox(content){
	closeLightBox()
	$('#lightBoxBG').show()
	content.show()
	return false
}

function toggleFullScreen() {
	if (!document.fullscreenElement) document.documentElement.requestFullscreen()
	else if (document.exitFullscreen) document.exitFullscreen()
	closeLightBox()
	return false
}

function hasUploads(){
	if (location.pathname == '/upload.html') return false
	for (var i in localStorage){
		if (/^20[0-9]{2}[A-Za-z0-9\-]+_(([0-9]+)|(.*_.*))$/.test(i)) return true
	}
	return false
}

function hasUploadsOrHistory(){
	for (var i in localStorage){
		if (/^((deleted|uploaded)_)?20[0-9]{2}[A-Za-z0-9\-]+_(([0-9]+)|(.*_.*))$/.test(i)) return true
	}
	return false
}

function inIframe(){
	try {
		return window.self !== window.top
	} catch (e) {
		return true
	}
}
