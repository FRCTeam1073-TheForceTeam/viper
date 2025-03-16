"use strict"

addI18n({
	coral_preload:{
		en:'Preloaded Coral',
		he:'קורל טעון מראש',
		tr:'Önceden Yüklenmiş Mercan',
		zh_tw:'預裝珊瑚',
		fr:'Corail préchargé',
		pt:'Coral pré-carregado',
	},
	opponent_processor_team:{
		en:'What is the team number of the OPPONENT\'s human player at the processor?',
		he:'מהו מספר הצוות של השחקן האנושי של OPPONENT במעבד?',
		tr:'Rakibin insan oyuncusunun işlemcideki takım numarası nedir?',
		zh_tw:'對手人類玩家在處理器處的隊號是多少？',
		fr:'Quel est le numéro d\'équipe du joueur humain adverse au processeur ?',
		pt:'Qual é o número da equipe do jogador humano do OPONENTE no processador?',
	},
	starting_position:{
		en:'Click team _TEAMNUM_\'s starting position.',
		he:'לחץ על עמדת ההתחלה של צוות _TEAMNUM_.',
		tr:'Takım _TEAMNUM_\'un başlangıç ​​pozisyonuna tıklayın.',
		zh_tw:'點選隊伍_TEAMNUM_的起始位置。',
		fr:'Cliquez sur la position de départ de l\'équipe _TEAMNUM_.',
		pt:'Clique na posição inicial da equipe _TEAMNUM_.',
	},
	pre_team_header:{
		en:'Team _TEAMNUM_',
		he:'צוות _TEAMNUM_',
		tr:'Takım _TEAMNUM_',
		zh_tw:'團隊 _TEAMNUM_',
		fr:'Équipe _TEAMNUM_',
		pt:'Equipe _TEAMNUM_',
	},
	barge_zone_question:{
		en:'Is _TEAMNUM_\'s robot in the _TEAMCOLOR_ barge zone?',
		he:'האם הרובוט של _TEAMNUM_ נמצא באזור ה-_TEAMCOLOR_?',
		tr:'_TEAMNUM_\'un robotu _TEAMRENGİ_ mavna bölgesinde mi?',
		zh_tw:'_TEAMNUM_ 的機器人是否在 _TEAMCOLOR_ 駁船區？',
		fr:'Le robot de _TEAMNUM_ se trouve-t-il dans la zone de la barge _TEAMCOLOR_ ?',
		pt:'O robô de _TEAMNUM_ está na zona de barcaça _TEAMCOLOR_?',
	},
	barge_zone_parked_button:{
		en:'Parked',
		he:'חונה',
		tr:'Park edilmiş',
		zh_tw:'停車',
		fr:'Stationné',
		pt:'Estacionado',
	},
	barge_zone_shallow_button:{
		en:'Hanging from a shallow cage',
		he:'תלוי מכלוב רדוד',
		tr:'Sığ bir kafesten sarkmış',
		zh_tw:'懸掛在淺籠子裡',
		fr:'Suspendu à une cage peu profonde',
		pt:'Pendurado em uma gaiola rasa',
	},
	barge_zone_deep_parked_button:{
		en:'Hanging from a deep cage',
		he:'תלוי מכלוב עמוק',
		tr:'Derin bir kafesten sarkmış',
		zh_tw:'吊在深籠子裡',
		fr:'Suspendu à une cage profonde',
		pt:'Pendurado em uma gaiola funda',
	},
	climb_failed_question:{
		en:'If not off the ground on a cage:',
		he:'אם לא מעל הקרקע על כלוב:',
		tr:'Kafes üzerinde yerden yüksekte değilse:',
		zh_tw:'如果籠子沒有離地面：',
		fr:'S\'il n\'est pas au sol sur une cage :',
		pt:'Se não estiver fora do chão em uma gaiola:',
	},
	climb_failed_button:{
		en:'Robot attempted to climb, but failed',
		he:'רובוט ניסה לטפס, אך נכשל',
		tr:'Robot tırmanmaya çalıştı ancak başaramadı',
		zh_tw:'機器人嘗試攀爬，但失敗了',
		fr:'Le robot a tenté de grimper, mais a échoué',
		pt:'O robô tentou escalar, mas falhou',
	},
	barge_heading:{
		en:'Barge',
		he:'דוֹבְרָה',
		tr:'Mavna',
		zh_tw:'駁船',
		fr:'Barge',
		pt:'Barcaça',
	},
	gameplay_heading:{
		en:'Gameplay',
		he:'משחקיות',
		tr:'Oyun',
		zh_tw:'遊戲玩法',
		fr:'Gameplay',
		pt:'Jogabilidade',
	},
	gameplay_question:{
		en:'During the match, the robot:',
		he:'במהלך המשחק, הרובוט:',
		tr:'Maç sırasında robot:',
		zh_tw:'比賽過程中，機器人：',
		fr:'Pendant le match, le robot :',
		pt:'Durante a partida, o robô:',
	},
	defense_button:{
		en:'Played defense',
		he:'שיחק הגנה',
		tr:'Defans oynadı',
		zh_tw:'防守',
		fr:'A joué en défense',
		pt:'Jogou na defesa',
	},
	bricked_button:{
		en:'Broke or was disabled',
		he:'נשבר או היה מושבת',
		tr:'Kırıldı veya devre dışı bırakıldı',
		zh_tw:'損壞或被停用',
		fr:'S\'est cassé ou a été désactivé',
		pt:'Quebrou ou foi desabilitado',
	},
	coral_stuck_button:{
		en:'Had a coral stuck on it',
		he:'היה תקוע עליו אלמוג',
		tr:'Üzerine bir mercan takıldı',
		zh_tw:'上面黏著一塊珊瑚',
		fr:'A eu un corail coincé dessus',
		pt:'Tinha um coral preso nele',
	},
})

$(document).ready(function(){
	const AUTO_MS=15000,
	AUTO_GAP_MS=3000,
	TELE_START_MS=AUTO_MS+AUTO_GAP_MS,
	TELE_MS=135000,
	MATCH_LENGTH_MS=TELE_START_MS+TELE_MS
	var matchStartTime = 0

	window.onBeforeShowScouting = window.onBeforeShowScouting || []
	window.onBeforeShowScouting.push(function(){
		var chooseOpp=$('#choose-opponent').html("")
		Object.entries(eventMatches.filter(x=>x.Match==match)[0]).map(([k,v],i)=>i!=0&&!k.startsWith(pos[0])?v:null).filter(x=>x!=null).forEach(opp=>{
			chooseOpp.append($(`<label><input type=radio name=opponent_human_player_team data-at-page-load=unchecked data-at-scout-start=unchecked value=${opp}><span>${opp}</span></label>`).click(labelClicked)).append(' ')
		})
		return true
	})
	window.onShowScouting = window.onShowScouting || []
	window.onShowScouting.push(function(){
		setTimeout(initialRobotStartPosition,500)
		initScouting2025()
		renderTimeline()
		return true
	})
	window.onShowPitScouting = window.onShowPitScouting || []
	window.onShowPitScouting.push(function(){
		setTimeout(drawAutos,0)
		return true
	})

	window.onInputChanged = window.onInputChanged || []
	window.onInputChanged.push(inputChanged)

	onApplyTranslation.push(renderTimeline)

	function initScouting2025(){
		matchStartTime = 0
		scoutTimers={}
		proceedToTeleBlink()
	}

	function inputChanged(input, change){
		toggleScoringElements()

		if(!input.closest('.auto,.teleop,#no-show-area').length) return

		var leave=$('[name="auto_leave"]')
		if (input.closest('.auto').length&&input.attr('name')!='auto_leave'&&!leave.is(':checked')){
			leave.prop('checked',true)
			inputChanged(leave,0)
		}
		var order = $('#timeline'),
		text = order.val(),
		name = input.attr('name'),
		re = name
		setTimeout(proceedToTeleBlink, AUTO_MS)
		if (matchStartTime==0) matchStartTime = new Date().getTime() - (input.closest('.teleop').length?TELE_START_MS:0)
		if ('radio'==input.attr('type')){
			name += `:${input.val()}`
			text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(?:\:[a-z0-9_]*)?( |$)`),"$1").trim()
		}
		if ((input.is('.num') && change>0) || input.is(':checked')){
			if (text) text += " "
			var seconds = Math.floor((new Date().getTime() - matchStartTime)/1000)
			text += `${seconds}:${name}`
		} else {
			if(input.val()=="0"){
				text = text.replace(new RegExp(`((?<= |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`,'g'),"").trim()
			} else {
				text = text.replace(new RegExp(`(.*(?: |^))[0-9]+\:${re}(\:[a-z0-9_]*)?( |$)`),"$1").trim()
			}
		}
		if (!text)initScouting2025()
		order.val(text)
		renderTimeline()
	}

	$('.undo').click(function(){
		var order = $('#timeline'),
		text = order.val(),
		m = text.match(/(.*(?: |^))[0-9]+\:([a-z0-9_]+)(?:\:[a-z0-9_]*)?$/)
		if (!m) return false
		scoutTimers={}
		text = m[1].trim()
		var field = m[2],
		input = $(`input[name="${field}"]`)
		if (input.is(".num")){
			input.val(Math.max(0,parseInt(input.val())-1))
			animateChangeFloater(-1, input)
		}
		if (input.is(":checked")) input.prop('checked',false)
		if (!text)initScouting2025()
		order.val(text)
		toggleScoringElements()
		renderTimeline()
		return false
	})

	function renderTimeline(){
		if(!$('#timeline').length)return
		var tl = $('.timeline').html("")
		$('#timeline').val().split(/ /).forEach(entry => {
			if (!entry) return
			var [time,action] = entry.split(/:/),
			min=Math.floor(time/60),
			sec=(""+time%60).padStart(2,'0')
			tl.append($('<tr>').append($('<td>').text(`${min}:${sec}`)).append($('<td>').text(translate(action))))
		})
	}

	function initialRobotStartPosition(){
		moveFloaterToPercentCoordinates(
			document.getElementById('start-area'),
			pos.startsWith('R'),
			$('#auto-start-input').val()||"6x16",
			document.getElementById('robot-starting-position')
		)
	}

	function moveFloaterToPercentCoordinates(mapImage, isRotated, coordinates, floatingImage){
		var c = getPixelCoordinates(mapImage, true, coordinates, floatingImage, true, true)
		if (!c) return
		floatingImage.style.left=c.x+"px"
		floatingImage.style.top=c.y+"px"
	}

	function getPercentCoordinates(event, mapImage, flipX, flipY, rotated){
		var d = mapImage.getBoundingClientRect(),
		x = event.clientX - d.left,
		y = event.clientY - d.top,
		px = Math.min(99,Math.max(1,Math.round(100 * x / d.width))),
		py =  Math.min(99,Math.max(1,Math.round(100 * y / d.height)))
		if (flipY) py = 100 - py
		if (flipX) px = 100 - px
		if (rotated) [py,px] = [px,py]
		return px+"x"+py
	}

	function setRobotStartPosition(e){
		var mi = document.getElementById('start-area'),
		fi = document.getElementById('robot-starting-position'),
		ir = "none"==(""+getComputedStyle($('#start-area')[0]).transform),
		co = getPercentCoordinates(e,mi,ir,ir,true)
		moveFloaterToPercentCoordinates(mi,ir,co,fi)
		$('#auto-start-input').val(co)
	}

	$('#start-area').mousemove(function(e){
		if (e.buttons) setRobotStartPosition(e)
	})

	$('#start-area').click(setRobotStartPosition)

	function scoringElementCount(el){
		el=$(el)
		var mul=parseInt(el.attr('data-provides')||("-"+el.attr('data-accepts'))),
		val=parseInt(el.val()||"0")
		if(el.is(':checkbox,:radio')&&!el.prop('checked'))val=0
		return(mul*val)
	}

	function hasCoral(){
		return hasScoringElement('coral')
	}
	function hasAlgae(){
		return hasScoringElement('algae')
	}
	function hasScoringElement(el){
		return sumValues($(`[data-element="${el}"]`))>0
	}
	function sumValues(el){
		return el.get().map(scoringElementCount).reduce((a,b)=>a+b,0)
	}
	function hasOpponentProcessorShots(){
		return -sumValues($('[name="auto_algae_processor"],[name="tele_algae_processor"]'))>-sumValues($('[name="auto_algae_opponent_net"],[name="tele_algae_opponent_net"]'))
	}

	function toggleScoringElements(){
		var has={
			coral:hasCoral(),
			algae:hasAlgae(),
			'opponent-algae':hasOpponentProcessorShots(),
		}
		$(`[data-element]`).each(function(){
			var el=$(this).attr('data-element'),
			show=(has[el]!=(!!$(this).attr('data-provides')))
			if($(this).attr('max')==$(this).val())show=false
			if($(this).is(':checkbox,:radio'))show=true
			$(this).closest('td').find('.disabledOverlay').toggle(!show)
			$(`[data-input="${$(this).attr('name')}"]`).toggle(show)
		})
	}

	$('.disabledOverlay').click(function(e){
		e.preventDefault()
		return false
	})

	$(`[data-element]`).each(function(){
		$(this).closest('td').prepend('<div class=disabledOverlay>')
	})
	toggleScoringElements()

	function getAutoPath(startNew){
		var chosen
		$('.auto-path').each(function(p){
			var p = $(this)
			if (!chosen) chosen = p
			if (p.val()) chosen = p
			if (startNew && chosen.val() && !p.val()) chosen = p
		})
		return chosen
	}

	var startNewAutoPath = false

	$('#auto-paths').click(function(e){
		var path = getAutoPath(startNewAutoPath),
		val = path.val()
		if (val) val += " "
		val += getPercentCoordinates(e, this, true, false)
		path.val(val)
		drawAutos()
		startNewAutoPath = false
	})

	$('#auto-path-next').click(function(){
		startNewAutoPath = true
		return false
	})

	$('#auto-path-undo').click(function(){
		var path = getAutoPath()
		path.val(path.val().replace(/ ?[^ ]+$/,""))
		drawAutos()
		return false
	})

	function drawAutos(){
		var canvas = $('#auto-paths')[0]
		sizeAndClearCanvas(canvas)
		$('.auto-path').each(function(){
			drawPath(canvas,$(this).attr('data-color'),$(this).val(),true,false)
		})
	}

	function proceedToTeleBlink(){
		var goTele=$('.auto.tab-content').is(':visible') && matchStartTime>0 && (new Date().getTime()-matchStartTime)>=AUTO_MS
		$('#tele-reminder').toggle(goTele)
		$('.to-tele').toggleClass('pulse-bg',goTele)
		if(goTele)setTimeout(proceedToTeleForce,10200)
	}

	function proceedToTeleForce(){
		if($('.auto.tab-content').is(':visible') && matchStartTime>0 && (new Date().getTime()-matchStartTime)>=AUTO_MS+10000) showTab(null, $('.tab[data-content="teleop"]'))
	}

	var scoutTimers={}

	setInterval(function(){
		if(matchStartTime==0||(new Date().getTime()-matchStartTime)>MATCH_LENGTH_MS) return
		Object.values(scoutTimers).forEach(function(timer){
			var oldVal = timer.input.val(),
			newVal = ""+Math.floor((new Date().getTime() - timer.start)/1000)
			if(oldVal != newVal){
				animateChangeFloater(newVal,timer.e)
				inputChanged(timer.input,1)
			}
			timer.input.val(newVal)
		})
	},100)

	$('.timer').click(function(e){
		var input = findInputInEl(findParentFromButton($(this))),
		name = input.attr('name')
		if(Object.hasOwn(scoutTimers,name)){
			delete scoutTimers[name]
		} else {
			var val=parseInt(input.val()||"0")
			inputChanged(input,1)
			scoutTimers[name]={
				e: e,
				input: input,
				start: new Date().getTime()-val*1000
			}
			animateChangeFloater("timing…", e)
		}
		return false
	})
})
