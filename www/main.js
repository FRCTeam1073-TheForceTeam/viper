"use strict"

window.addEventListener("load", () => {
	if ("serviceWorker" in navigator){
		navigator.serviceWorker.register("/offline-service-worker.cgi").then(function(reg) {
			//console.log('Registration succeeded. Scope is ' + reg.scope)
		})
	}
})

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
	$.getScript("/local.js", window.onLocalJs)
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
				mainMenu.html(
					data
						.replace(/EVENT_NAME/g,eName)
						.replace(/EVENT_ID/g,eId)
						.replace(/YEAR/g,eYear)
				)
				mainMenu.find('.dependEvent').toggle(!!(eName))
				showMainMenuUploads()
			})
		}
		$('body').append($('<div id=fullscreen>⛶</div>').click(toggleFullScreen))
		function showMainMenuUploads(){
			hamburger.toggleClass("hasUploads", hasUploads())
			mainMenu.find('.dependUpload').toggle(hasUploads())
		}
		$(window).on('hashchange',showMainMenuUploads)
		$('body').append($('<div id=lightBoxBG>').click(closeLightBox)).on('keyup',function(e){
			if (e.key=='Escape' && $('#lightBoxBG').is(":visible")){
				e.preventDefault()
				closeLightBox()
			}
		})
	}
})
function closeLightBox(){
	$('#lightBoxBG,.lightBoxCenterContent,.lightBoxFullContent').hide()
}
function showLightBox(content){
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
	for (var i in localStorage){
		if (/^20[0-9]{2}[A-Za-z0-9\-]+_(([0-9]+)|(.*_.*))$/.test(i)) return true
	}
	return false
}

function inIframe(){
	try {
		return window.self !== window.top;
	} catch (e) {
		return true;
	}
}
