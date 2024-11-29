"use strict"

$(document).ready(function(){
	function error(msg){
		$('body').append($('<p style=color:red>').text(msg))
		return false
	}

	function message(msg){
		$('body').append($('<p>').text(msg))
		return false
	}

	function getDataFromUrl(){
		var data=decodeURIComponent(location.search.substring(1)),
		fragment="1",header
		if (!data) return error("No data")
		var m = /^([0-9]+)\.\.\.(.*)/.exec(data)
		if (m) [{},fragment,data] = m
		m = /^((([0-9]{4}(?:-[0-9]{2})?)[A-Za-z0-9\-]+)((?:_subjective_[0-9]+)|(?:_[a-z0-9]+_[0-9]+)|(?:_[0-9]+))),(.*)/.exec(data)
		if (!m)return error("Data not in expected format")
		var [{},key,event,season,type,data] = m
		if (/subjective/.test(type)){
			header = localStorage.getItem(`${season}_subjectiveheaders`)
			if (!header) location.href = `/${season}/subjective-scout.html#event=${event}&go=back`
		} else if (/_.*_/.test(type)){
			header = localStorage.getItem(`${season}_headers`)
			if (!header) location.href = `/${season}/scout.html#event=${event}&go=back`
		} else {
			header = localStorage.getItem(`${season}_pitheaders`)
			if (!header) location.href = `/${season}/pit-scout.html#event=${event}&go=back`
		}
		var partialKey = `partial_${key}`
		if (fragment != 1){
			if (!(partialKey in localStorage)) return error("Could not append to last QR code: no previously uploaded data found")
			var partialData = localStorage.getItem(partialKey)
			m=/(.*)\.\.\.([0-9]+)/.exec(partialData)
			if (!m) return error("Previously stored QR code corrupted")
			var [{},partialData,expectedFragment] = m
			if (fragment != expectedFragment) return error(`Expected QR code ${expectedFragment} for this scouter but got ${fragment}`)
			data = partialData + data
		}
		var headers=header.split(/,/),
		dataPoints=data.split(/,/),
		tbc=/\.\.\.[0-9]+/.test(data)
		if (headers.length < dataPoints.length) {
			return error("Too much data scanned")
		}
		if (tbc || headers.length > dataPoints.length) {
			if (!tbc) data = data + "..." + (parseInt(fragment)+1)
			localStorage.setItem(partialKey,data)
			return message("Scan another QR code from this scouter")
		}
		localStorage.removeItem(partialKey)
		localStorage.setItem(key,data)
		message("Scanned data ready for upload")
		$('body').append($('<p><a href=/upload.html>Proceed to upload</a></p>'))
	}

	getDataFromUrl()
})
