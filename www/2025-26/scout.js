"use strict"

addI18n({
	starting_position:{
		en:'Starting Position:',
		fr:'Position de départ :',
		he:'עמדת התחלה:',
		pt:'Posição Inicial:',
		tr:'Başlangıç ​​Pozisyonu:',
		zh_tw:'起始位置：',
	},
	at_goal:{
		en:'At Goal',
		fr:'Au but',
		he:'בשער',
		pt:'No Gol',
		tr:'Kalede',
		zh_tw:'在目標位置',
	},
	near_audience:{
		en:'Near Audience',
		fr:'Près du public',
		he:'ליד הקהל',
		pt:'Perto do Público',
		tr:'Seyirci Yakınında',
		zh_tw:'靠近觀眾',
	},
	use_preset:{
		en:'Use preset:',
		fr:'Utilisation du préréglage :',
		he:'השתמש בהגדרה מוגדרת מראש:',
		pt:'Usar predefinição:',
		tr:'Ön Ayarı Kullan:',
		zh_tw:'使用預設位置：',
	},
	in_goal:{
		en:'In goal:',
		fr:'Dans le but :',
		he:'בתוך השער:',
		pt:'No gol:',
		tr:'Kalede:',
		zh_tw:'在目標位置：',
	},
	in_depot:{
		en:'In depot:',
		fr:'Au dépôt :',
		he:'בתוך המחסן:',
		pt:'No depósito:',
		tr:'Depoda:',
		zh_tw:'在倉庫位置：',
	},
	opened_gate:{
		en:'Opened gate:',
		fr:'Porte ouverte :',
		he:'שער פתוח:',
		pt:'Portão aberto:',
		tr:'Kapı Açıldı:',
		zh_tw:'大門打開：',
	},
	returned_base:{
		en:'Returned to base:',
		fr:'Retour à la base :',
		he:'חזר לבסיס:',
		pt:'Retornou à base:',
		tr:'Üsse Döndü:',
		zh_tw:'返回基地：',
	},
	returned_base_partially:{
		en:'Partially',
		fr:'Partiellement',
		he:'חלקית',
		pt:'Parcialmente',
		tr:'Kısmen',
		zh_tw:'部分返回',
	},
	returned_base_alone:{
		en:'Fully (other robot not fully-in)',
		fr:'Complètement (autre robot non complètement à l\'intérieur)',
		he:'במלואו (רובוט אחר לא בפנים במלואו)',
		pt:'Totalmente (outro robô não está totalmente dentro)',
		tr:'Tamamen (diğer robot tamamen içeride değil)',
		zh_tw:'完全返回（其他機器人未完全進入）',
	},
	returned_base_under:{
		en:'Fully and underneath fully-in robot',
		fr:'Complètement et sous le robot complètement à l\'intérieur',
		he:'בפנים במלואו ומתחת לרובוט בפנים במלואו',
		pt:'Totalmente e abaixo do robô totalmente dentro',
		tr:'Tamamen ve tamamen içerideki robotun altında',
		zh_tw:'完全返回，且位於機器人下方',
	},
	returned_base_above:{
		en:'Fully and above fully-in robot',
		fr:'Complètement et au-dessus du robot complètement à l\'intérieur',
		he:'בפנים במלואו ומעליו',
		pt:'Totalmente e acima do robô totalmente dentro',
		tr:'Tamamen ve tamamen içerideki robotun üstünde',
		zh_tw:'完全返回，且位於機器人上方',
	},
	during_auto:{
		en:'During auto:',
		fr:'Pendant l\'auto :',
		he:'במהלך אוטומטי:',
		pt:'Durante o modo automático:',
		tr:'Otomatik sırasında:',
		zh_tw:'自動運行期間：',
	},
	during_auto_obelisk:{
		en:'Scanned obelisk, created patterns matching motif',
		fr:'Obélisque scanné, motifs correspondant au motif créés',
		he:'סרק אובליסק, יצר תבניות התואמות מוטיב',
		pt:'Escaneou o obelisco, criou padrões que correspondem ao motivo',
		tr:'Dikilitaş tarandı, motifle eşleşen desenler oluşturuldu',
		zh_tw:'掃描方尖碑，創造與圖案相符的圖案',
	},
	during_auto_purple:{
		en:'Used only purple classified artifacts',
		fr:'Utilisation exclusive d\'artefacts classés violets',
		he:'השתמש רק בחפצים מסווגים סגולים',
		pt:'Utilizou apenas artefatos classificados em roxo',
		tr:'Sadece mor sınıflandırılmış eserler kullanıldı',
		zh_tw:'僅使用紫色分類文物',
	},
	during_auto_took_turns:{
		en:'Avoided simultaneous goal shooting during classification',
		fr:'Évitement de tirs simultanés au but pendant la classification',
		he:'נמנע מקליעה בו זמנית לשער במהלך הסיווג',
		pt:'Evitou chutes a gol simultâneos durante a classificação',
		tr:'Sınıflandırma sırasında eş zamanlı kale atışlarından kaçınıldı',
		zh_tw:'分類過程中避免同時射擊目標',
	},
	during_tele:{
		en:'During teleop:',
		fr:'Pendant la téléopération :',
		he:'במהלך טלאופ:',
		pt:'Durante o teleoperador:',
		tr:'Teleop sırasında:',
		zh_tw:'遙控運轉期間：',
	},
	during_tele_patterns:{
		en:'Created patterns matching motif',
		fr:'Motifs correspondant au motif créés',
		he:'יצר תבניות התואמות מוטיב',
		pt:'Criou padrões que correspondem ao motivo',
		tr:'Motifle eşleşen desenler oluşturuldu',
		zh_tw:'創建與圖案相符的圖案',
	},
})

$(document).ready(function(){
	const AUTO_MS=30000

	var matchStartTime = 0

	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		matchStartTime = 0
		return true
	})
	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(function(input, change){
		var order = $('#timeline'),
		text = order.val(),
		name = input.attr('name'),
		re = name,
		tab = input.closest('.tab-content')
		if (!tab.is('.auto,.teleop')) return
		if (tab.is('.auto')) setTimeout(proceedToTeleBlink, AUTO_MS)
		if (matchStartTime==0) matchStartTime = new Date().getTime()
		if ('radio'==input.attr('type')){
			name += `:${input.val()}`
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}\:[a-z0-9_]*( |$)`),"$1").trim()
		}
		if (input.is('.num') || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.round((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
			if (change > 1) text += `:${change}`
		} else {
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`),"$1").trim()
		}
		order.val(text)
	})

	$('.undo').click(function(){
		var order = $('#timeline'),
		text = order.val(),
		m = text.match(/(.*(?: |^))[0-9]+\:([a-z0-9_]+)(?:\:([a-z0-9_]*))?$/)
		if (!m) return false
		text = m[1].trim()
		var field = m[2],
		change = m[3] ?? 1
		input = $(`input[name="${field}"]`)
		if (input.is(".num")){
			input.val(parseInt(input.val())-change)
			animateChangeFloater(-change, input)
		}
		if (input.is(":checked")) input.prop('checked',false)
		if (!text) {
			matchStartTime = 0
			proceedToTeleBlink()
		} else {
			var history = text.split(/ /)
			for (var i=history.length-1; i>=0; i--){
				var input = $(`input[name="${(history[i].match(/^[0-9]+\:([a-z0-9_]+)(?:\:[a-z0-9_]*)?$/)||["",""])[1]}"]`)
			}
		}
		order.val(text)
		return false
	})

	function proceedToTeleBlink(){
		var teleTime=(new Date().getTime()-matchStartTime)>=AUTO_MS
		$('#to-tele-button').toggleClass('pulse-bg', matchStartTime>0 && teleTime)
		if (teleTime)setTimeout(function(){showTab({},$('.tab[data-content="teleop"]'))},5000)
	}
})
