"use strict"

function onLocalJs(){
	;(localStorage.getItem("transferHosts")||"").split(",").forEach(addHost)
	if (window.transferHosts) window.transferHosts.forEach(addHost)
	addHost('localhost')
}

function addHost(host){
	if (host && !$(`#hostOptions option[value="${host}"]`).length){
		$('#hostOptions').append($('<option>').attr('value',host))
	}
}

$(document).ready(function(){
	var dataFull = {},
	dataCsv = {},
	types = ["alliances","event","pit","schedule","scouting"],
	teams = []
	types.forEach(function(csv){
		var file = `/data/${eventId}.${csv}.csv`
		eventAjax(file ,function(text){
			if (csv=='schedule'){
				var teamMap = {}
				text.match(/\b[0-9]{4,}\b/g).forEach(function(team){
					teamMap[team]=1
				})
				teams = Object.keys(teamMap)
				teams.forEach(function(team){
					["","-top"].forEach(function(suffix){
						var image = `/data/${eventYear}/${team}${suffix}.jpg`
						toDataURL(image, function(dataUrl) {
							dataFull[image] = dataUrl
						})
					})
				})
			}
			dataFull[file] = text||""
			dataCsv[file] = text||""
		})
	})
	$('.siteInput').change(function(){
		var url = $(this).val()
		if (/^((https?\/\/)?)([a-zA-Z0-9\-\.\:]+)(\/?)$/.test(url)){
			var hosts = (localStorage.getItem("transferHosts")||"").split(/,/),
			hostList = hosts.reduce((m,o)=>(m[o]=o,m),{})
			if (!hostList.hasOwnProperty(url)){
				hosts.push(url)
				hosts = hosts.slice(-5)
				localStorage.setItem("transferHosts",hosts.join(","))
			}
			addHost(url)
		}
		if (!url) url = "webscout.example.com"
		if (!/^https?\:\/\//.test(url)){
			var prefix = "http"
			if (/\./.test(url)) prefix="https" // fully qualified domain
			if (/^[0-9\.\:]+$/.test(url)) prefix="http" // IP address
			url = `${prefix}://${url}`
		}
		url = url.replace(/\/$/,"")
		url += "/admin/import.cgi"
		$(this).closest('form').attr('action',url)
	})
	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
	$('title,h1').each(function(){
		$(this).text($(this).text().replace(/EVENT/, eventName))
	})
	function fullDataLoaded(){
		if (Object.keys(dataFull).length != types.length + teams.length*2){
			setTimeout(fullDataLoaded,100)
			return
		}
		Object.keys(dataFull).forEach(function(key){
			if (!dataFull[key]) delete dataFull[key]
		})
		var json = JSON.stringify(dataFull)
		$('#downloadImages')
			.attr('href', window.URL.createObjectURL(new Blob([json], {type: 'text/json;charset=utf-8'})))
			.attr('download',`${eventId}.full.json`)
		$('#transferJsonImages').val(json)
	}
	fullDataLoaded()
	function csvDataLoaded(){
		if (Object.keys(dataCsv).length != types.length){
			setTimeout(csvDataLoaded,100)
			return
		}
		Object.keys(dataCsv).forEach(function(key){
			if (!dataCsv[key]) delete dataCsv[key]
		})
		var json = JSON.stringify(dataCsv)
		$('#downloadCsv')
			.attr('href', window.URL.createObjectURL(new Blob([json], {type: 'text/json;charset=utf-8'})))
			.attr('download',`${eventId}.csv.json`)
		$('#transferJsonCsv').val(json)
	}
	csvDataLoaded()
})

// https://stackoverflow.com/a/20285053
function toDataURL(url, callback){
	var xhr = new XMLHttpRequest()
	xhr.onload = function(){
		var reader = new FileReader()
		reader.onloadend = function(){
			var url = reader.result
			if (!url.startsWith("data:image/jpeg;base64")) url = ""
			callback(url)
		}
		reader.readAsDataURL(xhr.response)
	}
	xhr.open('GET', url)
	xhr.responseType = 'blob'
	xhr.send()
}
