"use strict"

$(document).ready(showUploads)

var scoutCsv,pitCsv,subjectiveCsv

function showUploads(){
	var up = $('#uploads').html(""),
	his = $('#history').html(""),
	count = 0,
	historyCount = 0
	scoutCsv = {}
	pitCsv = {}
	subjectiveCsv = {}
	his.append($('<button>Clear Entire History</button>').click(clearHistory))
	for (i in localStorage){
		if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_subjective_[0-9]+/.test(i)){
			var year = i.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1"),
			header = localStorage.getItem(`${year}_subjectiveheaders`)
			if (!subjectiveCsv[year]){
				subjectiveCsv[year] = header
			}
			subjectiveCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button>Delete</button>').attr("data-match",i).click(deleteMatch))
			up.append($('<button>QR Code</button>').attr("data-match",i).click(showQrCode))
			count++
		} else if (/^20[0-9]{2}(-[0-9]{2})?.*_.*_/.test(i)){
			var year = i.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1"),
			header = localStorage.getItem(`${year}_headers`)
			if (!scoutCsv[year]){
				scoutCsv[year] = header
			}
			scoutCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button>Delete</button>').attr("data-match",i).click(deleteMatch))
			up.append($('<button>QR Code</button>').attr("data-match",i).click(showQrCode))
			count++
		} else if (/^20[0-9]{2}(-[0-9]{2})?[A-Za-z0-9\-]+_[0-9]+/.test(i)){
			var year = i.replace(/^(20[0-9]{2}(-[0-9]{2})?).*/,"$1"),
			header = localStorage.getItem(`${year}_pitheaders`)
			if (!pitCsv[year]){
				pitCsv[year] = header
			}
			pitCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button>Delete</button>').attr("data-match",i).click(deleteMatch))
			up.append($('<button>QR Code</button>').attr("data-match",i).click(showQrCode))
			count++
		} else if (/^deleted_20/.test(i)){
			his.append($('<hr>'))
			his.append($('<h4 class=deleted>').text(i))
			his.append($('<pre>').text(localStorage.getItem(i)))
			his.append($('<button>Undelete</button>').attr("data-match",i).click(undeleteMatch))
			his.append($('<button>Remove from History</button>').attr("data-match",i).click(removeMatch))
			historyCount++
		} else if (/^uploaded_20/.test(i)){
			his.append($('<hr>'))
			his.append($('<h4 class=uploaded>').text(i))
			his.append($('<pre>').text(localStorage.getItem(i)))
			his.append($('<button>Reupload</button>').attr("data-match",i).click(undeleteMatch))
			his.append($('<button>Remove from History</button>').attr("data-match",i).click(removeMatch))
			historyCount++
		}
	}
	$('#upload-description').text(!count?'There is no data to upload.':'')
	$('#upload-count').text(count)
	$('.uploads').toggle(!!count)
	$('#history-count').text(historyCount)
	$('.history').toggle(!!historyCount)
	var years = Object.keys(scoutCsv);
	var text = ""
	for (var i=0; i<years.length; i++){
		text += scoutCsv[years[i]]
	}
	years = Object.keys(pitCsv);
	for (var i=0; i<years.length; i++){
		text += pitCsv[years[i]]
	}
	years = Object.keys(subjectiveCsv);
	for (var i=0; i<years.length; i++){
		text += subjectiveCsv[years[i]]
	}
	$('#csv').val(text)

	$('#upload-all').click(function(){
		$(this).text('Uploading, please wait ...')
		if ($('button').prop('disabled') != 'true'){
			$('button').prop('disabled', 'true')
			$('#upload').submit()
		}
		return false
	})

	$('#show-uploads').click(function(){
		$(this).hide()
		$('#uploads').show()
	})

	$('#show-history').click(function(){
		$(this).hide()
		$('#history').show()
	})

}

function clearHistory(){
	if (!confirm(`Are you sure you want to clear the history?`)) return
	for (var i in localStorage){
		if (/^(deleted|uploaded)_20/.test(i)) localStorage.removeItem(i)
	}
	showUploads()
}

function deleteMatch(){
	var match = $(this).attr("data-match")
	if (confirm(`Are you sure you want to delete ${match}?`)){
		var d = localStorage.getItem(match)
		localStorage.removeItem(match)
		localStorage.setItem(`deleted_${match}`, d)
		showUploads()
	}
}

function removeMatch(){
	var match = $(this).attr("data-match")
	if (confirm(`Are you sure you want to remove ${match}?`)){
		localStorage.removeItem(match)
		showUploads()
	}
}

function undeleteMatch(){
	var match = $(this).attr("data-match")
	var d = localStorage.getItem(match)
	localStorage.removeItem(match)
	localStorage.setItem(match.replace(/^(deleted|uploaded)_/,''), d)
	showUploads()
}

function getQrUrls(key,csv){
	var csvIndex=0,
	urls=[]
	csv=csv.replace(/,0(?=,)/g,",")
	for (var i=1;csvIndex<csv.length;i++){
		var parts=[location.origin,"/qr.html?"]
		if(i>1)parts.push(`${i}...`)
		parts.push(key,",")
		var len=parts.reduce((sum,v)=>sum+v.length,0)
		while(csvIndex<csv.length && len<1000){
			var next=encodeURIComponent(csv[csvIndex])
			len+=next.length
			parts.push(next)
			csvIndex++
		}
		if (csvIndex<csv.length) parts.push(`...${i+1}`)
		urls.push(parts.join(''))
	}
	return urls
}

var qrNum=0,
qrMatch,
qrUrls=[]
function nextQrCode(){
	showQrCode(qrNum+1)
}

function showQrCode(num){
	if (typeof num == 'object'){
		qrMatch = $(this).attr("data-match")
		qrUrls = getQrUrls(qrMatch,localStorage.getItem(qrMatch))
		num=1
	}
	qrNum=num
	if (num>qrUrls.length){
		closeLightBox()
		var d = localStorage.getItem(qrMatch)
		localStorage.removeItem(qrMatch)
		localStorage.setItem(`uploaded_${qrMatch}`, d)
		showUploads()
		$('#show-uploads').hide()
		$('#uploads').show()
		return false
	}
	var dialog=$('#qr-code-dialog')
	if (!dialog.length){
		dialog=$('<div id=qr-code-dialog class=lightBoxCenterContent>')
		.append($('<h2 id=qr-code-title>'))
		.append($('<div id=qr-code style="border:.5em solid white">'))
		.append($('<p>')
			.append($('<button>').text("Cancel").click(closeLightBox))
			.append(" ")
			.append($('<button id=qr-code-next style=float:right>').text('Next').click(nextQrCode))
		)
		$('body').append(dialog)
	}
	$('#qr-code-title').text(`QR Code ${qrNum} of ${qrUrls.length}`)
	var size = Math.min($('body').innerWidth()-20,$('body').innerHeight()-20,700)
	new QRCode($("#qr-code").html("").click(copyTitleAttr)[0],{
		text:qrUrls[num-1],
		width:size,
		height:size,
		correctLevel:QRCode.CorrectLevel.L,
	})
	showLightBox(dialog)
	return false
}

function copyTitleAttr(){
	navigator.clipboard.writeText($(this).attr('title'))
}
