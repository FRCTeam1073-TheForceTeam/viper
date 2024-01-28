"use strict"

$(document).ready(showUploads)

var scoutCsv = {}
var pitCsv = {}
var subjectiveCsv = {}

function showUploads(){
	var up = $('#uploads').html("")
	var count = 0
	for (i in localStorage){
		if (/^20[0-9]{2}[A-Za-z0-9\-]+_subjective_[0-9]+/.test(i)){
			var year = i.replace(/^(20[0-9]{2}).*/,"$1"),
			header = localStorage.getItem(`${year}_subjectiveheaders`)
			if (!subjectiveCsv[year]){
				subjectiveCsv[year] = header
			}
			subjectiveCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button>Delete</button>').attr("data-match",i).click(deleteMatch))
			count++
		} else if (/^20[0-9]{2}.*_.*_/.test(i)){
			var year = i.replace(/^(20[0-9]{2}).*/,"$1"),
			header = localStorage.getItem(`${year}_headers`)
			if (!scoutCsv[year]){
				scoutCsv[year] = header
			}
			scoutCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button>Delete</button>').attr("data-match",i).click(deleteMatch))
			count++
		} else if (/^20[0-9]{2}[A-Za-z0-9\-]+_[0-9]+/.test(i)){
			var year = i.replace(/^(20[0-9]{2}).*/,"$1"),
			header = localStorage.getItem(`${year}_pitheaders`)
			if (!pitCsv[year]){
				pitCsv[year] = header
			}
			pitCsv[year] += localStorage.getItem(i)
			up.append($('<hr>'))
			up.append($('<h4>').text(i))
			up.append($('<pre>').text(header + localStorage.getItem(i)))
			up.append($('<button>Delete</button>').attr("data-match",i).click(deleteMatch))
			count++
		}
	}
	if (!count){
		up.text('There is no data to upload.')
		$('button').hide()
	}
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

	$('#uploadBtn').click(function(){
		$(this).text('Uploading, please wait ...')
		if ($('button').prop('disabled') != 'true'){
			$('button').prop('disabled', 'true')
			$('#upload').submit()
		}
		return false
	})
}

function deleteMatch(){
	var match = $(this).attr("data-match")
	if (confirm(`Are you sure you want to delete ${match}?`)){
		localStorage.removeItem(match)
		showUploads()
	}
}
