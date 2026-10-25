"use strict"

addI18n({
	preload_check:{
		en:'Robot started with 4 pre-loaded POLLEN',
		fr:'Le robot a commencé avec 4 POLLEN préchargés',
		pt:'O robô começou com 4 POLLEN pré-carregados',
		zh_tw:'機器人開始時已預載 4 個花粉',
		tr:'Robot 4 önceden yüklenmiş POLEN ile başladı',
		he:'הרובוט התחיל עם 4 אבקות שנטענו מראש',
		es:'El robot empezó con 4 POLEN precargados',
	},
	auto_leave:{
		en:'Left the perimeter wall during auto',
		fr:'A quitté le mur du périmètre pendant l\'auto',
		pt:'Saiu da parede do perímetro durante o modo automático',
		zh_tw:'自動運行期間離開周邊牆',
		tr:'Otonom sırasında çevre duvarından ayrıldı',
		he:'עזב את קיר ההיקף במהלך האוטומטי',
		es:'Salió de la pared perimetral durante el auto',
	},
	auto_park:{
		en:'Parked in LOADING ZONE during auto',
		fr:'Stationné dans la ZONE DE CHARGEMENT pendant l\'auto',
		pt:'Estacionou na ZONA DE CARREGAMENTO durante o modo automático',
		zh_tw:'自動運行期間停在裝載區',
		tr:'Otonom sırasında YÜKLEME BÖLGESİ\'ne park etti',
		he:'חנה באזור הטעינה במהלך האוטומטי',
		es:'Estacionó en la ZONA DE CARGA durante el auto',
	},
	end_park:{
		en:'Parked in LOADING ZONE at end of match',
		fr:'Stationné dans la ZONE DE CHARGEMENT à la fin du match',
		pt:'Estacionou na ZONA DE CARREGAMENTO no fim da partida',
		zh_tw:'比賽結束時停在裝載區',
		tr:'Maç sonunda YÜKLEME BÖLGESİ\'ne park etti',
		he:'חנה באזור הטעינה בסוף המשחק',
		es:'Estacionó en la ZONA DE CARGA al final del partido',
	},
	robot_disabled:{
		en:'Robot disabled or stuck',
		fr:'Robot désactivé ou bloqué',
		pt:'Robô desativado ou preso',
		zh_tw:'機器人失效或卡住',
		tr:'Robot devre dışı veya sıkışmış',
		he:'הרובוט מנוטרל או תקוע',
		es:'Robot desactivado o atascado',
	},
	collected:{
		en:'Collected',
		fr:'Collectés',
		pt:'Coletados',
		zh_tw:'已收集',
		tr:'Toplanan',
		he:'נאסף',
		es:'Recogidos',
	},
	pollen:{
		en:'POLLEN',
		fr:'POLLEN',
		pt:'PÓLEN',
		zh_tw:'花粉',
		tr:'POLEN',
		he:'אבקה',
		es:'POLEN',
	},
	nectar:{
		en:'NECTAR',
		fr:'NECTAR',
		pt:'NÉCTAR',
		zh_tw:'花蜜',
		tr:'NEKTAR',
		he:'צוף',
		es:'NÉCTAR',
	},
	cell:{
		en:'CELL',
		fr:'CELLULE',
		pt:'CÉLULA',
		zh_tw:'房室',
		tr:'HÜCRE',
		he:'תא',
		es:'CELDA',
	},
	garden:{
		en:'GARDEN',
		fr:'JARDIN',
		pt:'JARDIM',
		zh_tw:'花園',
		tr:'BAHÇE',
		he:'גן',
		es:'JARDÍN',
	},
	flower:{
		en:'FLOWER',
		fr:'FLEUR',
		pt:'FLOR',
		zh_tw:'花',
		tr:'ÇİÇEK',
		he:'פרח',
		es:'FLOR',
	},
	hive_tip:{
		en:'HIVE TIP',
		fr:'BASCULE DE LA RUCHE',
		pt:'INCLINAÇÃO DA COLMEIA',
		zh_tw:'蜂巢傾倒',
		tr:'KOVAN DEVRİLMESİ',
		he:'נְטִיַּת כוורת',
		es:'VUELCO DE COLMENA',
	},
	held:{
		en:'Held (max 4):',
		fr:'Tenus (max 4) :',
		pt:'Segurando (máx. 4):',
		zh_tw:'持有（最多 4 個）：',
		tr:'Tutulan (en fazla 4):',
		he:'מוחזק (מקסימום 4):',
		es:'En posesión (máx. 4):',
	},
	required_missing:{
		en:'Please fill in these required items before saving:',
		fr:'Veuillez remplir ces champs obligatoires avant d\'enregistrer :',
		pt:'Preencha estes itens obrigatórios antes de salvar:',
		zh_tw:'儲存前請填寫以下必填項目：',
		tr:'Kaydetmeden önce bu zorunlu alanları doldurun:',
		he:'נא למלא את הפריטים החובה הבאים לפני השמירה:',
		es:'Complete estos campos obligatorios antes de guardar:',
	},
})

// Robots start with 4 pre-loaded POLLEN (Section 10.3.4); the pre-match check enforces this
const PRELOAD_COUNT=4,
HELD_MAX=4

function sumCounters(selector){
	var total=0
	$(selector).each(function(){ total+=parseInt($(this).val())||0 })
	return total
}

// Pieces currently controlled = preload + collected - placed (G407 caps this at 4)
function updateHeldCount(){
	var held = PRELOAD_COUNT
		+ sumCounters('#scouting [name^=auto_collect_],#scouting [name^=tele_collect_]')
		- sumCounters('#scouting [name^=auto_cell_],#scouting [name^=auto_garden_],#scouting [name^=tele_cell_],#scouting [name^=tele_flower],#scouting [name^=tele_garden_]')
	$('.held-value').text(held)
	$('.held-count').toggleClass('over', held>HELD_MAX || held<0)
}

$(document).ready(function(){
	const AUTO_MS=30000

	var matchStartTime = 0,
	wentToTeleAuto = false

	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		matchStartTime = 0
		wentToTeleAuto = false
		updateHeldCount()
		return true
	})

	window.onStore = window.onStore || []
	window.onStore.push(function(){
		if ($('#scouting [name=no_show]').is(':checked')) return true
		var missing = []
		if (!$('#scouting [name=preload_check]').is(':checked')) missing.push(translate('preload_check'))
		if (!$('#scouting [name=scouter]').val().trim()) missing.push(translate('scouter_name_question'))
		if (missing.length){
			alert(translate('required_missing') + "\n" + missing.join("\n"))
			return false
		}
		return true
	})

	// Every tap is appended to the timeline as "seconds:field" (plus ":n" for multi-step taps)
	// so the global Undo button can reverse exactly the last action.
	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(function(input, change){
		updateHeldCount()
		if(!input.closest('.auto,.teleop,#no-show-area').length) return

		if (input.closest('.auto').length) setTimeout(proceedToTeleBlink, AUTO_MS)

		var order = $('#timeline'),
		text = order.val(),
		name = input.attr('name')
		if (matchStartTime==0) matchStartTime = new Date().getTime()
		if (input.is('.num') || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.round((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
			if (change > 1) text += `:${change}`
		} else {
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${name}(\:[0-9]+)?( |$)`),"$1").trim()
		}
		order.val(text)
	})

	$('.undo').click(function(){
		var order = $('#timeline'),
		text = order.val(),
		m = text.match(/(.*(?: |^))[0-9]+\:([a-z0-9_]+)(?:\:([0-9]+))?$/)
		if (!m) return false
		text = m[1].trim()
		var input = $(`input[name="${m[2]}"]`),
		change = parseInt(m[3]) || 1
		if (input.is('.num')){
			input.val(parseInt(input.val())-change)
			animateChangeFloater(-change, input)
		}
		if (input.is(':checked')) input.prop('checked',false)
		updateHeldCount()
		if (!text) {
			matchStartTime = 0
			proceedToTeleBlink()
		}
		order.val(text)
		return false
	})

	function proceedToTeleBlink(){
		var teleTime=(new Date().getTime()-matchStartTime)>=AUTO_MS
		$('#to-tele-button').toggleClass('pulse-bg', matchStartTime>0 && teleTime)
		if(!wentToTeleAuto){
			wentToTeleAuto=true
			if (teleTime) setTimeout(function(){showTab({},$('.tab[data-content="teleop"]'))},5000)
		}
	}
})
