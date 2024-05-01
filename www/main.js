"use strict"

function getDate(s){
	if (!s) return ""
	var m = /[0-9]{4}-[0-9]{2}-[0-9]{2}/.exec(s)
	if (m) return m[0]
	return ""
}

function dateCompare(a,b){
	return getDate(b).localeCompare(getDate(a))
}

$(document).ready(function(){
	if (!inIframe()){
		var hamburger = $('<div id=hamburger class=show-only-when-connected>☰</div>'),
		mainMenu = $('<div id=mainMenu class=lightBoxCenterContent>')
		$('body').append(hamburger).append(mainMenu)
		hamburger.click(function(){showLightBox(mainMenu)})

		populateMainMenu()

		function populateMainMenu(){
			$.get("/main-menu.html",function(data){
				var eName = window.eventName||localStorage.getItem('last_event_name')||"",
				eId = window.eventId||localStorage.getItem('last_event_id')||"",
				eYear = window.eventName||localStorage.getItem('last_event_year')||""
				if (localStorage.getItem('last_event_id')==eId)eName = localStorage.getItem('last_event_name')||window.eventName||""
				mainMenu.html(
					data
						.replace(/EVENT_NAME/g,eName)
						.replace(/EVENT_ID/g,eId)
						.replace(/YEAR/g,eYear)
				)
				mainMenu.find('.dependEvent').toggle(!!(eName))
				mainMenu.find('.my-team-input').val(getLocalTeam()).change(function(){
					localStorage.setItem('my-team', parseInt($(this).val()))
					location.reload()
				})
				showMainMenuUploads()
				$('#logout-link').click(function(){
					var req = new XMLHttpRequest()
					req.open("GET", "/logout", true, 'logout')
					req.onload = _ => {
						if (req.readyState === 4) console.log(req.status)
					}
					req.send()
					return false
				})
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
}

function showLightBox(content){
	closeLightBox()
	$('#lightBoxBG').show()
	content.show()
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
