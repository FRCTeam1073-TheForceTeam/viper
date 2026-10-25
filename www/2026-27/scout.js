"use strict"

addI18n({
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

// Every robot starts with 4 pre-loaded POLLEN (Section 10.3.4)
// Every robot starts with 4 pre-loaded POLLEN (Section 10.3.4)
const PRELOAD_POLLEN=4,
HELD_MAX=4,
COLLECT_GROUPS=['auto_collect_','tele_collect_'],
PLACE_GROUPS=['auto_cell_','auto_garden_','tele_cell_','tele_flower','tele_garden_'],
POLLEN_COLLECT=countersFor(COLLECT_GROUPS,'pollen'),
NECTAR_COLLECT=countersFor(COLLECT_GROUPS,'nectar'),
POLLEN_PLACE=countersFor(PLACE_GROUPS,'pollen'),
NECTAR_PLACE=countersFor(PLACE_GROUPS,'nectar'),
COLLECT_FIELDS=POLLEN_COLLECT+','+NECTAR_COLLECT,
PLACE_FIELDS=POLLEN_PLACE+','+NECTAR_PLACE,
TIP_FIELDS='#scouting [name=auto_hive_tip],#scouting [name=tele_hive_tip]'

function countersFor(groups, color){
	return groups.map(g=>`#scouting [name^=${g}][name$=_${color}]`).join(',')
}

function sumCounters(selector){
	var total=0
	$(selector).each(function(){ total+=parseInt($(this).val())||0 })
	return total
}

// Pieces controlled, per color. POLLEN starts at the 4 pre-loaded, and the combined total is
// capped at 4 (G407). Collection is blocked at the cap, and each color's placement is blocked at 0.
function updateHeldCount(){
	var pollen = PRELOAD_POLLEN + sumCounters(POLLEN_COLLECT) - sumCounters(POLLEN_PLACE),
	nectar = sumCounters(NECTAR_COLLECT) - sumCounters(NECTAR_PLACE),
	total = pollen+nectar
	$('.held-pollen').text(pollen)
	$('.held-nectar').text(nectar)
	$('.held-count').toggleClass('over', total>HELD_MAX || pollen<0 || nectar<0)
	$(COLLECT_FIELDS).closest('td').find('.disabledOverlay').toggle(total>=HELD_MAX)
	$(POLLEN_PLACE).closest('td').find('.disabledOverlay').toggle(pollen<=0)
	$(NECTAR_PLACE).closest('td').find('.disabledOverlay').toggle(nectar<=0)
}

// HIVE TIP only counts right after a POLLEN or NECTAR goes into a CELL, since only a launch
// into the upward-facing CELL can tip the HIVE (G417). Read the last action from the timeline.
function updateHiveTipGate(){
	var lastField = (($('#timeline').val()||"").trim().split(' ').pop()||"").split(':')[1]||"",
	enabled = /^(auto|tele)_cell_(pollen|nectar)$/.test(lastField)
	$(TIP_FIELDS).closest('td').find('.disabledOverlay').toggle(!enabled)
}

function updateCounters(){
	updateHeldCount()
	updateHiveTipGate()
}

$(document).ready(function(){
	const AUTO_MS=30000

	var matchStartTime = 0,
	wentToTeleAuto = false

	// Overlays block taps on a counter (same mechanism as earlier seasons). The click
	// is stopped here so it never reaches the cell's counter handler.
	$(COLLECT_FIELDS+','+PLACE_FIELDS+','+TIP_FIELDS).closest('td').prepend(
		$('<div class=disabledOverlay style=display:none>').click(function(e){
			e.stopPropagation()
			return false
		})
	)

	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		matchStartTime = 0
		wentToTeleAuto = false
		// Only one alliance is scouted at a time, so the NECTAR buttons use that alliance's color
		$('.nectar-img').attr('src',pos.startsWith('R')?'nectar-red.png':'nectar-blue.png')
		updateCounters()
		return true
	})

	window.onStore = window.onStore || []
	window.onStore.push(function(){
		if ($('#scouting [name=no_show]').is(':checked')) return true
		var missing = []
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
		if(input.closest('.auto,.teleop,#no-show-area').length){
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
		}
		updateCounters()
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
		if (!text) {
			matchStartTime = 0
			proceedToTeleBlink()
		}
		order.val(text)
		updateCounters()
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
