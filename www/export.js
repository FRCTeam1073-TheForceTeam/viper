"use strict"

var hosts={}

function addHost(host){
	if (host && !hosts[host]){
		hosts[host]=1
		$('.hostOptions').append($('<li>').text(host).on('mousedown',setHost))
	}
}

function setHost(){
	var input=$(this).closest('form').find('.siteInput')
	input.val($(this).text())
	hostSet(input)
}

function hostSet(input){
	var url = input.val()
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
	if (!url) url = "example.viperscout.com"
	if (!/^https?\:\/\//.test(url)){
		var prefix = "http"
		if (/\./.test(url)) prefix="https" // fully qualified domain
		if (/^[0-9\.\:]+$/.test(url)) prefix="http" // IP address
		url = `${prefix}://${url}`
	}
	url = url.replace(/\/$/,"")
	url += "/admin/import.cgi"
	input.closest('form').attr('action',url)

}

$(document).ready(function(){
	var dataFull = {},
	dataText = {},
	fullFileCount = -1,
	textFileCount = -1
	if (!eventId) return $('#contents').text('No event ID')
	promiseEventFiles().then(fileList => {
		fullFileCount = fileList.length
		if (!fullFileCount) return $('#contents').text(`No ${eventId} files`)
		var textFiles = 0
		fileList.forEach(file=>{
			if (/\.jpg$/.test(file)){
				toDataURL(file, dataUrl => {
					dataFull[file] = dataUrl
				})
			} else {
				textFiles++
				promiseEventAjax(file).then(text => {
					dataFull[file] = text||""
					dataText[file] = text||""
				})
			}
		})
		textFileCount = textFiles
	})
	$('.siteInput').change(function(){
		hostSet($(this))
	})
	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
	$('title,h1').each(function(){
		$(this).text($(this).text().replace(/EVENT/, eventName))
	})
	function fullDataLoaded(){
		if (Object.keys(dataFull).length != fullFileCount){
			setTimeout(fullDataLoaded,100)
			return
		}
		var json = JSON.stringify(dataFull)
		$('#downloadImages')
			.attr('href', window.URL.createObjectURL(new Blob([json], {type: 'text/json;charset=utf-8'})))
			.attr('download',`${eventId}.full.json`)
		$('#transferJsonImages').val(json)
		$('#loadingImages').hide()
		$('#submitImages').removeAttr('disabled')
	}
	fullDataLoaded()
	function textDataLoaded(){
		if (Object.keys(dataText).length != textFileCount){
			setTimeout(textDataLoaded,100)
			return
		}
		var json = JSON.stringify(dataText)
		$('#downloadData')
			.attr('href', window.URL.createObjectURL(new Blob([json], {type: 'text/json;charset=utf-8'})))
			.attr('download',`${eventId}.dat.json`)
		$('#transferJsonData').val(json)
		$('#loadingData').hide()
		$('#submitData').removeAttr('disabled')
	}
	textDataLoaded()
	;(localStorage.getItem("transferHosts")||"").split(",").forEach(addHost)
	if (window.transferHosts) window.transferHosts.forEach(addHost)
	addHost('localhost')

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
