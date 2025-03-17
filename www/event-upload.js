"use strict"

addI18n({
	event_upload_title:{
		en:'Import an Event',
		he:'ייבוא ​​אירוע',
		pt:'Importar um evento',
		tr:'Bir Etkinliği İçe Aktar',
		fr:'Importer un événement',
		zh_tw:'導入事​​件',
	},
	event_upload_short_instructions:{
		en:'Paste data from another source into the text area below.',
		he:'הדבק נתונים ממקור אחר באזור הטקסט למטה.',
		pt:'Cole dados de outra fonte na área de texto abaixo.',
		tr:'Aşağıdaki metin alanına başka bir kaynaktan veri yapıştırın.',
		fr:'Collez les données d\'une autre source dans la zone de texte ci-dessous.',
		zh_tw:'將來自其他來源的數據貼到下面的文字區域。',
	},
	no_data:{
		en:'No data found!',
		he:'לא נמצאו נתונים!',
		pt:'Nenhum dado encontrado!',
		tr:'Veri bulunamadı!',
		fr:'Aucune donnée trouvée !',
		zh_tw:'沒有找到數據！',
	},
	event_name_label:{
		en:'Event name:',
		he:'שם האירוע:',
		pt:'Nome do evento:',
		tr:'Etkinlik adı:',
		fr:'Nom de l\'événement :',
		zh_tw:'事件名稱：',
	},
	event_name_placeholder:{
		en:'Name of event',
		he:'שם האירוע',
		pt:'Nome do evento',
		tr:'Etkinliğin adı',
		fr:'Nom de l\'événement',
		zh_tw:'活動名稱',
	},
	start_date_label:{
		en:'Start date:',
		he:'תאריך התחלה:',
		pt:'Data de início:',
		tr:'Başlangıç ​​tarihi:',
		fr:'Date de début :',
		zh_tw:'開始日期：',
	},
	end_date_label:{
		en:'End date:',
		he:'תאריך סיום:',
		pt:'Data de término:',
		tr:'Bitiş tarihi:',
		fr:'Date de fin :',
		zh_tw:'結束日期：',
	},
	event_location_label:{
		en:'Location:',
		he:'מִקוּם:',
		pt:'Localização:',
		tr:'Yer:',
		fr:'Lieu :',
		zh_tw:'地點：',
	},
	event_location_placeholder:{
		en:'Venue name and address',
		he:'שם המקום והכתובת',
		pt:'Nome e endereço do local',
		tr:'Mekan adı ve adresi',
		fr:'Nom et adresse du lieu',
		zh_tw:'場地名稱和地址',
	},
	event_id_label:{
		en:'Event ID:',
		he:'מזהה אירוע:',
		pt:'ID do evento:',
		tr:'Etkinlik kimliği:',
		fr:'ID de l\'événement :',
		zh_tw:'事件 ID：',
	},
	event_id_placeholder:{
		en:'No spaces or symbols',
		he:'ללא רווחים או סמלים',
		pt:'Sem espaços ou símbolos',
		tr:'Boşluk veya sembol yok',
		fr:'Sans espaces ni symboles',
		zh_tw:'沒有空格或符號',
	},
})

$(document).ready(function(){
	$('#importData').submit(processInput)
	$('input[type=submit]').click(processInput)

	function processInput(){
		var src=$('#sourceInp').val(),csv=(
			getBlueAllianceMatchSchedule(src)||
			getOrangeAllianceMatchSchedule(src)||
			getFirstInspiresMatchSchedule(src)||
			randomPracticeSchedule(getBlueAllianceTeamList(src))||
			randomPracticeSchedule(getGenericTeamList(src))
		)
		if (!csv){
			alert(translate('no_data'))
			return false
		}
		$('#csvInp').val(csv)
		var newEventId = (
			src.match(/event_key(?:=|\":\")([0-9]{4}[A-Za-z0-9\-]+)/)||
			src.match(/href\=\"\/(20[0-9]{2}\/[A-Z0-9]+)\"(?: [^\>]*)?\>Event Info/)||
			src.match(/\<link rel\=\"canonical\" href=\"https:\/\/theorangealliance\.org\/events\/([0-9A-Z\-]+)\"\>/)||
			["",$('#idInp').val()]
		)[1].replace(/\//g,"").toLowerCase()
		newEventId = newEventId.replace(/-/g,"")
		var m = newEventId.match(/^([0-9]{2})([0-9]{2})(.*)/)
		if (m && /FTC Event Web/.test(src)){
			newEventId = `20${m[2]}-${parseInt(m[2])+1}${m[3]}`
		} else if (m && !/^20/.test(newEventId)){
			newEventId = `20${m[1]}-${m[2]}${m[3]}`
		}
		if (newEventId != eventId){
			eventId=newEventId
			$('#idInp').val(eventId)
			promiseEventInfo().then(eventInfo => {
				if (srcToField(src, eventInfo)){
					$('#importData').submit()
				}
			})
			return false
		}
		srcToField(src)
	}

	function srcToField(src, eventInfo){
		eventInfo=eventInfo||{}
		$('#startInp').val((
			src.match(/itemprop\=\"startDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/)||
			["",eventInfo.start||
			$('#startInp').val()]
		)[1])
		$('#endInp').val((
			src.match(/itemprop\=\"endDate\" datetime\=\"(20[0-9]{2}-[0-9]{2}-[0-9]{2})/)||
			["",eventInfo.end||
			$('#endInp').val()]
		)[1])
		$('#nameInp').val((
			src.match(/id\=\"event-name\"\>([^\<]+)\</)||
			src.match(/\<span class\=\"hidden-xs hidden-sm align-middle\"\> - ([^\<]+)\</)||
			src.match(/\<title\>([^\>\<\|]+) \|/m)||
			src.match(/\<h1(?: [^\>]*)?\>([\s\S]*?)\<\/h1\>/m)||
			["",eventInfo.name||
			$('#nameInp').val()]
		)[1].replace(/\<[^\>]*\>/g,"").replace(/\s+/gm," ").trim().replace(/ Event$/,"").replace(/.*Matches /,""))
		$('#locationInp').val((
			src.match(/\<span itemprop\=\"location\"\>(.|[\r\n])*?\<\/span\>/m)||
			src.match(/(\<svg[^\>]+LocationOnIcon.*?\<\/p\>)/m)||
			["",eventInfo.location||
			$('#locationInp').val()]
		)[1].replace(/\<[^\>]*\>/g,""))
		var empty = false
		$('#autoFields input:empty').each(function(){
			if (!$(this).val()) empty = true
		})
		if(empty){
			$('#autoFields').show()
			$('#csvInp').show()
			$('#sourceInp').hide()
			return false
		}
		return true
	}

	function venueNameToId(){
		$('#idInp').val(new Date($('#startInp').val()).getFullYear()+$('#nameInp').val().replace(/20[0-9]{2}/g,"").trim().toLowerCase().replace(/\s+/g,"-").replace(/[^0-9a-z\-]/g,""))
	}

	$('#nameInp').change(venueNameToId).keyup(venueNameToId)

	function getBlueAllianceTeamList(src){
		return (src.match(/\/team\/([0-9]+)\//g)||[]).map(s=>s.replace(/[^0-9]/g,""))
	}

	function getGenericTeamList(src){
		return src.match(/\b([0-9]+)\b/g)
	}

	function getFirstInspiresMatchSchedule(src){
		var isPractice = /Official practice match schedule/.test(src),
		re= /\/20[0-9]{2}\/team\/([0-9]+)/g,
		ftc=/FTC Event Web/.test(src),
		m, matchNum=1, match=[], schedule = ftc?[["Match","R1","R2","B1","B2"]]:[["Match","R1","R2","R3","B1","B2","B3"]]
		while(m = re.exec(src)){
			if(!match.length){
				match.push((isPractice?"pm":"qm")+matchNum)
				matchNum++
			}
			match.push(m[1])
			if (match.length==(ftc?5:7)){
				schedule.push(match)
				match=[]
			}
		}
		if (schedule.length==1) return ""
		return schedule.map(a=>a.join(",")).join("\n")+"\n"
	}

	function getBlueAllianceMatchSchedule(src){
		var re= /(?:\/match\/(20[0-9]{2}[a-zA-Z0-9]+)_qm([0-9]+))|(?:\/team\/([0-9]+)\/20)/g,
		m, qual, schedule = [["Match","R1","R2","R3","B1","B2","B3"]]
		do {
			m = re.exec(src)
			if (m) {
				if (m[1]){
					qual = parseInt(m[2])
					if (!schedule[qual]) schedule[qual] = ["qm"+qual]
				} else if (qual && schedule[qual].length < 7){
					schedule[qual].push(m[3])
				}
			}
		} while (m)
		if (schedule.length == 1){
			return ""
		}
		var csv = ""
		for (var i=0; i<schedule.length; i++){
			var row = schedule[i]
			if (row.length != 7){
				alert("Could not find six teams for match: " + row[0])
				return ""
			}
			csv += row.join(",") + "\n"
		}
		return csv
	}
	function getOrangeAllianceMatchSchedule(src){
		var trRe = /<tr[\s\S]*?<\/tr>/gm,
		m, qual, schedule = [["Match","R1","R2","B1","B2"]]
		do {
			m = trRe.exec(src)
			if (m) {
				var teamM, row = m[0],
				qM = />Q-([0-9]+)</g.exec(row),
				teamRe= /\/teams\/([0-9]+)/g
				if (qM){
					var match = [`qm${qM[1]}`]
					do {
						teamM = teamRe.exec(row)
						if (teamM){
							match.push(teamM[1])
						}
					} while (teamM)
					if (match.length == 5) schedule.push(match)
				}
			}
		} while (m)
		if (schedule.length == 1){
			return ""
		}
		return schedule.map(function(d){return d.join(',')}).join('\n') + "\n"
	}

	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
})
