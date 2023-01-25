$(document).ready(function(){
	$('#blueAllianceSource').submit(function(){
		var re= /(?:\/match\/(20[0-9]{2}[a-zA-Z0-9]+)_qm([0-9]+))|(?:\/team\/([0-9]+)\/20)/g,
		m, event, qual, schedule = [["Match","R1","R2","R3","B1","B2","B3"]],
		src=$('textarea').val()
		do {
			m = re.exec(src);
			if (m) {
				if (m[1]){
					event = m[1]
					qual = parseInt(m[2])
					if (!schedule[qual]) schedule[qual] = ["qm"+qual]
				} else if (qual && schedule[qual].length < 7){
					schedule[qual].push(m[3])
				}
			}
		} while (m);
		if (schedule.length == 1){
			alert("No data found!")
		}
		var csv = ""
		for (var i=0; i<schedule.length; i++){
			row = schedule[i]
			if (row.length != 7){
				alert("Could not find six teams for match: " + row[0])
				return false
			}
			csv += row.join(",") + "\n"
		}
		if (m = /itemprop\=\"startDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/.exec(src)){
			$('#startInp').val(m[1])
		}
		if (m = /itemprop\=\"endDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/.exec(src)){
			$('#endInp').val(m[1])
		}
		if (m = /id\=\"event-name\"\>([^\<]+)\</.exec(src)){
			$('#nameInp').val(m[1])
		}
		if (m = /\<span itemprop\=\"location\"\>(.|[\r\n])*?\<\/span\>/m.exec(src)){
			$('#locationInp').val($(m[0]).text().trim())
		}
		$('#eventInp').val(event)
		$('#csvInp').val(csv)
		$('#csvForm').submit()
		return false
	})
})
