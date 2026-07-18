"use strict"

function aggregateStats(scout, aggregate, apiScores, subjective, pit, eventStatsByMatchTeam, eventStatsByTeam, match){

	function bool_1_0(s){
		return (!s||/^0|no|false$/i.test(""+s))?0:1
	}

	var pointValues = {
		fuel: 1,
		tower_level_1_auto: 15,
		tower_level_1_tele: 10,
		tower_level_2: 20,
		tower_level_3: 30,
	}

	// Initialize numeric and heatmap fields from statInfo
	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			scout[field] = scout[field]||0
			aggregate[field] = aggregate[field]||0
		}
		if(/^heatmap$/.test(statInfo[field]['type'])){
			scout[field] = scout[field]||""
			aggregate[field] = aggregate[field]||""
		}
		if(/^int-list$/.test(statInfo[field]['type'])){
			scout[field] = ((scout[field]||"")+"").split(" ").map(num => parseInt(num, 10)).filter(Number)
		}
	})

	// Convert percentage fields to 0/1 values
	Object.keys(statInfo).forEach(function(field){
		if(/^%$/.test(statInfo[field].type)){
			scout[field] = bool_1_0(scout[field])
		}
	})

	// Compute enum counts
	Object.keys(statInfo).forEach(function(field){
		if(statInfo[field]['type']=='enum' && statInfo[field]['values']){
			var value = scout[field]||''
			if (value){
				var enumField = `${field}_${value}`
				scout[enumField] = (scout[enumField]||0)+1
			}
		}
	})

	scout.auto_fuel_output = scout.auto_fuel_score + scout.auto_fuel_neutral_alliance_pass
	scout.tele_fuel_output = scout.tele_fuel_score + scout.tele_fuel_alliance_dump + scout.tele_fuel_neutral_alliance_pass + scout.tele_fuel_opponent_alliance_pass + scout.tele_fuel_opponent_neutral_pass
	scout.fuel_output = scout.auto_fuel_output + scout.tele_fuel_output

	scout.fuel_score = scout.auto_fuel_score + scout.tele_fuel_score
	scout.bump_depot_alliance_to_neutral = scout.auto_bump_depot_alliance_to_neutral + scout.tele_bump_depot_alliance_to_neutral
	scout.bump_depot_neutral_to_alliance = scout.auto_bump_depot_neutral_to_alliance + scout.tele_bump_depot_neutral_to_alliance
	scout.bump_outpost_alliance_to_neutral = scout.auto_bump_outpost_alliance_to_neutral + scout.tele_bump_outpost_alliance_to_neutral
	scout.bump_outpost_neutral_to_alliance = scout.auto_bump_outpost_neutral_to_alliance + scout.tele_bump_outpost_neutral_to_alliance
	scout.climb_level = scout.auto_climb_level + scout.tele_climb_level
	scout.collect_depot = scout.auto_collect_depot + scout.tele_fuel_alliance_dump
	scout.collect_outpost = scout.auto_collect_outpost + scout.tele_fuel_outpost
	scout.fuel_neutral_alliance_pass = scout.auto_fuel_neutral_alliance_pass + scout.tele_fuel_neutral_alliance_pass
	scout.trench_depot_alliance_to_neutral = scout.auto_trench_depot_alliance_to_neutral + scout.tele_trench_depot_alliance_to_neutral
	scout.trench_depot_neutral_to_alliance = scout.auto_trench_depot_neutral_to_alliance + scout.tele_trench_depot_neutral_to_alliance
	scout.trench_outpost_alliance_to_neutral = scout.auto_trench_outpost_alliance_to_neutral + scout.tele_trench_outpost_alliance_to_neutral
	scout.trench_outpost_neutral_to_alliance = scout.auto_trench_outpost_neutral_to_alliance + scout.tele_trench_outpost_neutral_to_alliance

	scout.auto_tower_score = 0
	if (scout.auto_climb_level === 1) scout.auto_tower_score = pointValues.tower_level_1_auto * 2
	else if (scout.auto_climb_level === 2) scout.auto_tower_score = pointValues.tower_level_2
	else if (scout.auto_climb_level === 3) scout.auto_tower_score = pointValues.tower_level_3
	scout.tele_tower_score = 0
	if (scout.tele_climb_level === 1) scout.tele_tower_score = pointValues.tower_level_1_tele
	else if (scout.tele_climb_level === 2) scout.tele_tower_score = pointValues.tower_level_2
	else if (scout.tele_climb_level === 3) scout.tele_tower_score = pointValues.tower_level_3

	scout.tower_score = scout.auto_tower_score + scout.tele_tower_score
	scout.auto_score = scout.auto_tower_score + scout.auto_fuel_score
	scout.tele_score = scout.tele_tower_score + scout.tele_fuel_score
	scout.score = scout.auto_score + scout.tele_score

	scout.auto_bump_depot_alliance = scout.auto_bump_depot_alliance_to_neutral + scout.auto_bump_depot_neutral_to_alliance
	scout.auto_bump_outpost_alliance = scout.auto_bump_outpost_alliance_to_neutral + scout.auto_bump_outpost_neutral_to_alliance
	scout.auto_bump_alliance = scout.auto_bump_depot_alliance + scout.auto_bump_outpost_alliance
	scout.auto_bump = scout.auto_bump_alliance

	scout.tele_bump_depot_alliance = scout.tele_bump_depot_alliance_to_neutral + scout.tele_bump_depot_neutral_to_alliance
	scout.tele_bump_depot_opponent = scout.tele_bump_depot_neutral_to_opponent + scout.tele_bump_depot_opponent_to_neutral
	scout.tele_bump_outpost_alliance = scout.tele_bump_outpost_alliance_to_neutral + scout.tele_bump_outpost_neutral_to_alliance
	scout.tele_bump_outpost_opponent = scout.tele_bump_outpost_neutral_to_opponent + scout.tele_bump_outpost_opponent_to_neutral
	scout.tele_bump_alliance = scout.tele_bump_depot_alliance + scout.tele_bump_outpost_alliance
	scout.tele_bump_opponent = scout.tele_bump_depot_opponent + scout.tele_bump_outpost_opponent
	scout.tele_bump = scout.tele_bump_alliance + scout.tele_bump_opponent

	scout.bump_depot_alliance = scout.auto_bump_depot_alliance + scout.tele_bump_depot_alliance
	scout.bump_outpost_alliance = scout.auto_bump_outpost_alliance + scout.tele_bump_outpost_alliance
	scout.bump_alliance = scout.auto_bump_alliance + scout.tele_bump_alliance

	scout.auto_trench_depot_alliance = scout.auto_trench_depot_alliance_to_neutral + scout.auto_trench_depot_neutral_to_alliance
	scout.auto_trench_outpost_alliance = scout.auto_trench_outpost_alliance_to_neutral + scout.auto_trench_outpost_neutral_to_alliance
	scout.auto_trench_alliance = scout.auto_trench_depot_alliance + scout.auto_trench_outpost_alliance
	scout.auto_trench = scout.auto_trench_alliance

	scout.tele_trench_depot_alliance = scout.tele_trench_depot_alliance_to_neutral + scout.tele_trench_depot_neutral_to_alliance
	scout.tele_trench_depot_opponent = scout.tele_trench_depot_neutral_to_opponent + scout.tele_trench_depot_opponent_to_neutral
	scout.tele_trench_outpost_alliance = scout.tele_trench_outpost_alliance_to_neutral + scout.tele_trench_outpost_neutral_to_alliance
	scout.tele_trench_outpost_opponent = scout.tele_trench_outpost_neutral_to_opponent + scout.tele_trench_outpost_opponent_to_neutral
	scout.tele_trench_alliance = scout.tele_trench_depot_alliance + scout.tele_trench_outpost_alliance
	scout.tele_trench_opponent = scout.tele_trench_depot_opponent + scout.tele_trench_outpost_opponent
	scout.tele_trench = scout.tele_trench_alliance + scout.tele_trench_opponent

	scout.trench_depot_alliance = scout.auto_trench_depot_alliance + scout.tele_trench_depot_alliance
	scout.trench_depot_opponent = scout.tele_trench_depot_opponent
	scout.trench_outpost_alliance = scout.auto_trench_outpost_alliance + scout.tele_trench_outpost_alliance
	scout.trench_outpost_opponent = scout.tele_trench_outpost_opponent
	scout.trench_alliance = scout.auto_trench_alliance + scout.tele_trench_alliance

	scout.bump = scout.auto_bump + scout.tele_bump
	scout.trench = scout.auto_trench + scout.tele_trench
	scout.zone_change = scout.bump + scout.trench

	scout.auto_to_alliance = scout.auto_bump_depot_neutral_to_alliance + scout.auto_bump_outpost_neutral_to_alliance + scout.auto_trench_depot_neutral_to_alliance + scout.auto_trench_outpost_neutral_to_alliance
	scout.auto_to_neutral = scout.auto_bump_depot_alliance_to_neutral + scout.auto_bump_outpost_alliance_to_neutral + scout.auto_trench_depot_alliance_to_neutral + scout.auto_trench_outpost_alliance_to_neutral

	scout.tele_to_alliance = scout.tele_bump_depot_neutral_to_alliance + scout.tele_bump_outpost_neutral_to_alliance + scout.tele_trench_depot_neutral_to_alliance + scout.tele_trench_outpost_neutral_to_alliance
	scout.tele_to_neutral = scout.tele_bump_depot_alliance_to_neutral + scout.tele_bump_outpost_alliance_to_neutral + scout.tele_trench_depot_alliance_to_neutral + scout.tele_trench_outpost_alliance_to_neutral + scout.tele_bump_depot_opponent_to_neutral + scout.tele_bump_outpost_opponent_to_neutral + scout.tele_trench_depot_opponent_to_neutral + scout.tele_trench_outpost_opponent_to_neutral
	scout.tele_to_opponent = scout.tele_bump_depot_neutral_to_opponent + scout.tele_bump_outpost_neutral_to_opponent + scout.tele_trench_depot_neutral_to_opponent + scout.tele_trench_outpost_neutral_to_opponent + scout.tele_bump_depot_alliance_to_opponent + scout.tele_bump_outpost_alliance_to_opponent + scout.tele_trench_depot_alliance_to_opponent + scout.tele_trench_outpost_alliance_to_opponent

	scout.to_alliance = scout.auto_to_alliance + scout.tele_to_alliance
	scout.to_neutral = scout.auto_to_neutral + scout.tele_to_neutral
	scout.to_opponent = scout.tele_to_opponent

	scout.alliance_time = scout.auto_alliance_time + scout.tele_alliance_time
	scout.neutral_time = scout.auto_neutral_time + scout.tele_neutral_time
	scout.opponent_time = scout.tele_opponent_time

	function randomPositions(arr, pos, count, x, y, xRadius, yRadius){
		for(var i=0; i<count||0; i++){
			var dx=Math.floor(Math.random()*(2*xRadius+1))-xRadius,
			dy=Math.floor(Math.random()*(2*yRadius+1))-yRadius
			arr[pos] += `${x+dx}x${y+dy} `
		}
	}

	for (var stage of ["auto","tele"]){
		for (var out of [true,false]){
			for (var trench of [true,false]){
				for (var near of [true,false]){
					for (var outpost of [true,false]){
						var to=near?(out?'neutral':'alliance'):(out?'opponent':'neutral'),
						from=near?(out?'alliance':'neutral'):(out?'neutral':'opponent'),
						f=`${stage}_${trench?'trench':'bump'}_${outpost?'outpost':'depot'}_${from}_to_${to}`,
						x=trench?7:30,
						y=near?92:8,
						fp=`${stage}_zone_change_${out?'out':'in'}`
						if(near^outpost)x=100-x
						randomPositions(scout,fp,scout[f],x,y,3,5)
					}
				}
			}
		}
	}
	randomPositions(scout,'auto_collect_position',scout.auto_collect_depot,26,92,3,5)
	randomPositions(scout,'auto_collect_position',scout.auto_collect_outpost,92,94,3,5)

	// Accumulate scout data into aggregate
	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			aggregate[field] = (aggregate[field]||0)+scout[field]
			var set = `${field}_set`
			aggregate[set] = aggregate[set]||[]
			aggregate[set].push(scout[field])
		}
		if(/^(enum)$/.test(statInfo[field]['type'])){
			if(statInfo[field]['values']){
				Object.keys(statInfo[field]['values']).forEach(function(value){
					var enumField = `${field}_${value}`
					aggregate[enumField] = (aggregate[enumField]||0)+(scout[enumField]||0)
				})
			}
		}
		if(/^capability$/.test(statInfo[field]['type'])) aggregate[field] = aggregate[field]||scout[field]||0
		if(/^text$/.test(statInfo[field]['type'])) aggregate[field] = (!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
		if(/^heatmap$/.test(statInfo[field]['type'])) aggregate[field] += ((aggregate[field]&&scout[field])?" ":"")+scout[field]
		if(/^int-list$/.test(statInfo[field]['type'])) aggregate[field] = (aggregate[field]||[]).concat(scout[field])
	})

	aggregate.count = (aggregate.count||0)+1
	aggregate.max_score = Math.max(aggregate.max_score||0,scout.score||0)
	aggregate.max_auto_score = Math.max(aggregate.max_auto_score||0,scout.auto_score||0)
	aggregate.min_score = Math.min(aggregate.min_score===undefined?9999:aggregate.min_score,scout.score||0)
	aggregate.max_fuel_output = Math.max(aggregate.max_fuel_output||0,scout.fuel_output||0)
	aggregate.max_tele_climb_level = Math.max(aggregate.max_tele_climb_level||0, scout.tele_climb_level||0)
	aggregate.bump_percent = aggregate.bump / (aggregate.zone_change||1)
	aggregate.trench_percent = aggregate.trench / (aggregate.zone_change||1)

	// Aggregate the mode for each enum
	Object.keys(statInfo).forEach(function(field){
		if(statInfo[field]['type']=='enum' && statInfo[field]['values']){
			var maxCount = 0
			var mode = null
			Object.keys(statInfo[field]['values']).forEach(function(value){
				var enumField = `${field}_${value}`
				var count = aggregate[enumField]||0
				if(count!=0 && count >= maxCount){
					maxCount = count
					mode = value
				}
			})
			if(mode !== null){
				aggregate[`${field}_mode`] = mode
			}
		}
	})

	pit.auto_paths=[]
	for (var i=1; i<=9; i++){
		var path=pit[`auto_${i}_path`]
		if (path) pit.auto_paths.push(path)
	}
}

var statInfo={
	event:{
		name:'Event',
		type:'text',
		fr:'Événement',
		pt:'Evento',
		zh_tw:'事件',
		tr:'Etkinlik',
		he:'מִקרֶה',
		es:'Evento',

	},
	match:{
		name:"Match",
		type:"text",
		fr:'Match',
		pt:'Partida',
		zh_tw:'匹配',
		tr:'Maç',
		he:'לְהַתְאִים',
		es:'Partido',

	},
	team:{
		name:"Team",
		type:"text",
		fr:'Équipe',
		pt:'Equipe',
		zh_tw:'團隊',
		tr:'Takım',
		he:'קְבוּצָה',
		es:'Equipo',

	},
	count:{
		name:'Matches Scouted',
		type:'num',
		fr:'Matchs repérés',
		pt:'Partidas observadas',
		zh_tw:'已偵察的比賽',
		tr:'İzlenen Maçlar',
		he:'גפרורים בצופים',
		es:'Cantidad',

	},
	duplicate:{
		name:'Duplicate',
		type:'text',
		fr:'Dupliquer',
		pt:'Duplicar',
		zh_tw:'重複',
		tr:'Çoğaltmak',
		he:'כפול',
		es:'Duplicado',
	},
	bricked:{
		en:'Bricked',
		type:'enum',
		values: {
			'some':'bricked_some',
			'half':'bricked_half',
			'most':'bricked_most',
			'all':'bricked_all'
		},
		fr:'Gelé',
		pt:'Congelado',
		zh_tw:'凍結',
		tr:'Donmuş',
		he:'קפוא',
		es:'Congelado',
	},
	climb_method:{
		en:'Climb Method',
		type:'enum',
		values: {
			'rungs':'climb_method_rungs',
			'uprights':'climb_method_uprights',
			'flip':'climb_method_flip'
		},
		fr:'Méthode d\'escalade',
		pt:'Método de escalada',
		zh_tw:'爬升方法',
		tr:'Tırmanma Yöntemi',
		he:'שיטת טיפוס',
		es:'Método de escalada',
	},
	comments:{
		en:'Comments',
		type:'text',
		fr:'Commentaires',
		pt:'Comentários',
		zh_tw:'評論',
		tr:'Yorumlar',
		he:'הערות',
		es:'Comentarios',

	},
	created:{
		en:'Created',
		type:'datetime',
		fr:'Créé',
		pt:'Criado',
		zh_tw:'已創建',
		tr:'Oluşturuldu',
		he:'נוצר',
		es:'Creado',

	},
	defended:{
		en:'Defended',
		type:'enum',
		values: {
			'':'defended_undefended',
			'turned-tables':'defended_turned_tables',
			'unaffected':'defended_unaffected',
			'slowed':'defended_slowed',
			'slowed-greatly':'defended_slowed_greatly'
		},
		fr:'Défendu',
		pt:'Defendido',
		zh_tw:'防守',
		tr:'Savunulan',
		he:'הגן',
		es:'Defendido',
	},
	defense:{
		en:'Defense',
		type:'enum',
		values: {
			'':'defense_none',
			'bad':'defense_bad',
			'ineffective':'defense_ineffective',
			'good':'defense_good',
			'great':'defense_great'
		},
		fr:'Défense',
		pt:'Defesa',
		zh_tw:'防禦',
		tr:'Savunma',
		he:'הגנה',
		es:'Defensa',
	},
	defense_bad:{
		en:'Bad Defense',
		type:'%',
		fr:'Mauvaise Défense',
		pt:'Defesa Ruim',
		zh_tw:'不好的防禦',
		tr:'Kötü Savunma',
		he:'הגנה גרועה',
		es:'Defensa Mala',

	},
	defense_ineffective:{
		en:'Ineffective Defense',
		type:'%',
		fr:'Défense Inefficace',
		pt:'Defesa Ineficaz',
		zh_tw:'無效的防禦',
		tr:'Etkisiz Savunma',
		he:'הגנה לא יעילה',
		es:'Defensa Inefectiva',

	},
	defense_good:{
		en:'Good Defense',
		type:'%',
		fr:'Bonne Défense',
		pt:'Defesa Boa',
		zh_tw:'好的防禦',
		tr:'İyi Savunma',
		he:'הגנה טובה',
		es:'Defensa Buena',

	},
	defense_great:{
		en:'Great Defense',
		type:'%',
		fr:'Excellente Défense',
		pt:'Defesa Ótima',
		zh_tw:'很好的防禦',
		tr:'Harika Savunma',
		he:'הגנה מעולה',
		es:'Defensa Excelente',

	},
	defense_mode:{
		en:'Most Common Defense Rating',
		type:'text',
		fr:'Évaluation de la défense la plus courante',
		pt:'Avaliação de defesa mais comum',
		zh_tw:'最常見的防禦評級',
		tr:'En Yaygın Savunma Değerlendirmesi',
		he:'דירוג ההגנה הנפוץ ביותר',
		es:'Calificación de Defensa Más Común',

	},
	fuel_to_alliance:{
		en:'Fuel To Alliance',
		type:'enum',
		values: {
			'carried':'fuel_carried_label',
			'pushed':'fuel_pushed_label',
			'passed':'fuel_passed_label',
			'received':'fuel_received_label'
		},
		fr:'Carburant à l\'alliance',
		pt:'Combustível para a aliança',
		zh_tw:'燃料聯盟',
		tr:'Yakıt İttifakı',
		he:'דלק לברית',
		es:'Combustible a la alianza',
	},
	misses:{
		en:'Misses',
		type:'enum',
		values: {
			'0-1':'misses_0_1',
			'1-10':'misses_1_10',
			'10-30':'misses_10_30',
			'30-60':'misses_30_60',
			'60-100':'misses_60_100'
		},
		fr:'Manques',
		pt:'Erros',
		zh_tw:'錯過',
		tr:'Kaçırmalar',
		he:'חִסרוֹן',
		es:'Fallos',
	},
	modified:{
		en:'Modified',
		type:'datetime',
		fr:'Modifié',
		pt:'Modificado',
		zh_tw:'已修改',
		tr:'Değiştirilmiş',
		he:'שונה',
		es:'Modificado',

	},
	scouter:{
		en:'Scout',
		type:'text',
		fr:'Éclaireur',
		pt:'Escoteiro',
		zh_tw:'童子軍',
		tr:'İzcisi',
		he:'צופה',
		es:'Scout',

	},
	shoot_climbing:{
		en:'Shoot Climbing',
		type:'%',
		fr:'Tir Escalade',
		pt:'Disparo Escalada',
		zh_tw:'射擊攀爬',
		tr:'Atış Tırmanışı',
		he:'קליעה לטיפוס',
		es:'Disparo Escalada',

	},
	shoot_collecting:{
		en:'Shoot Collecting',
		type:'%',
		fr:'Tir Collecte',
		pt:'Disparo Coletando',
		zh_tw:'射擊收集',
		tr:'Atış Toplama',
		he:'קליעה לאיסוף',
		es:'Disparo Recolectando',

	},
	shoot_move:{
		en:'Shoot Move',
		type:'%',
		fr:'Tir Mouvement',
		pt:'Disparo Movimento',
		zh_tw:'射擊移動',
		tr:'Atış Hareketi',
		he:'קליעה תנועה',
		es:'Disparo Movimiento',

	},
	shoot_turret:{
		en:'Shoot Turret',
		type:'%',
		fr:'Tir Tourelle',
		pt:'Disparo Torreta',
		zh_tw:'射擊炮塔',
		tr:'Atış Kule',
		he:'קליעה צריח',
		es:'Disparo Torreta',

	},
	timeline:{
		en:'Timeline',
		type:'timeline',
		fr:'Chronologie',
		pt:'Linha do tempo',
		zh_tw:'時間軸',
		tr:'Zaman Çizelgesi',
		he:'ציר זמן',
		es:'Cronología',

	},
	drivetrain:{
		en:'Drivetrain',
		type:'enum',
		values: {
			'tank':'robot_drivetrain_tank',
			'swerve':'robot_drivetrain_swerve',
			'other':'robot_drivetrain_other'
		},
		fr:'Groupe motopropulseur',
		pt:'Trem de força',
		zh_tw:'傳動系統',
		tr:'Sürüş Sistemi',
		he:'מערכת הנעה',
		es:'Sistema de transmisión',
	},
	swerve:{
		en:'Swerve Module Type',
		type:'enum',
		values: {
			'swerve-drive-specialties':'robot_swerve_sds',
			'andymark':'robot_swerve_am',
			'rev-robotics':'robot_swerve_rev',
			'westcoast-products':'robot_swerve_wcp',
			'other':'robot_swerve_other'
		},
		fr:'Type de module Swerve',
		pt:'Tipo de módulo Swerve',
		zh_tw:'Swerve 模塊類型',
		tr:'Swerve Modül Türü',
		he:'סוג מודול סרב',
		es:'Tipo de módulo Swerve',
	},
	motors:{
		en:'Motor Type',
		type:'enum',
		values: {
			'neo':'motor_type_neo',
			'falcon_500':'motor_type_f500',
			'full_size_cim':'motor_type_cim',
			'kraken':'motor_type_kraken',
			'other':'motor_type_other'
		},
		fr:'Type de moteur',
		pt:'Tipo de motor',
		zh_tw:'電機類型',
		tr:'Motor Türü',
		he:'סוג מנוע',
		es:'Tipo de motor',
	},
	wheels:{
		en:'Wheel Type',
		type:'enum',
		values: {
			'traction':'wheel_type_traction',
			'high-traction':'wheel_type_high_traction',
			'pneumatic':'wheel_type_pneumatic',
			'mechanum':'wheel_type_mechanum',
			'omni':'wheel_type_omni',
			'untreaded':'wheel_type_untreaded',
			'mixed':'wheel_type_mixed',
			'other':'wheel_type_other'
		},
		fr:'Type de roue',
		pt:'Tipo de roda',
		zh_tw:'車輪類型',
		tr:'Tekerlek Türü',
		he:'סוג גלגל',
		es:'Tipo de rueda',
	},
	auto_bump_depot_alliance_to_neutral:{
		en:'Bump (Depot Side) Alliance To Neutral in Auto',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le dépôt de l\'alliance à neutre en auto',
		pt:'Empurrar o depósito da aliança para neutro no Auto',
		zh_tw:'自動將聯盟倉庫撞擊為中立',
		tr:'Otomatik Olarak İttifak Deposunu Nötr Yap',
		he:'לדחוף את מחסן הברית לנייטרלי באוטומט',
		es:'Empujar depósito de alianza a neutro en auto',
	},
	auto_bump_depot_neutral_to_alliance:{
		en:'Bump (Depot Side) Neutral To Alliance in Auto',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le dépôt neutre à l\'alliance en auto',
		pt:'Empurrar o depósito neutro para a aliança no Auto',
		zh_tw:'自動將中立倉庫撞擊到聯盟',
		tr:'Otomatik Olarak Nötr Depoyu İttifak Yap',
		he:'לדחוף מחסן נייטרלי לברית באוטומט',
		es:'Empujar depósito neutro a alianza en auto',
	},
	auto_bump_outpost_alliance_to_neutral:{
		en:'Bump (Outpost Side) Alliance To Neutral in Auto',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser l\'avant-poste de l\'alliance à neutre en auto',
		pt:'Empurrar o posto avançado da aliança para neutro no Auto',
		zh_tw:'自動將聯盟前哨撞擊為中立',
		tr:'Otomatik Olarak İttifak Karakolunu Nötr Yap',
		he:'לדחוף את מוצב הברית לנייטרלי באוטומט',
		es:'Empujar puesto de alianza a neutro en auto',
	},
	auto_bump_outpost_neutral_to_alliance:{
		en:'Bump (Outpost Side) Neutral To Alliance in Auto',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser l\'avant-poste neutre à l\'alliance en auto',
		pt:'Empurrar o posto avançado neutro para a aliança no Auto',
		zh_tw:'自動將中立前哨撞擊到聯盟',
		tr:'Otomatik Olarak Nötr Karakolu İttifak Yap',
		he:'לדחוף מוצב נייטרלי לברית באוטומט',
		es:'Empujar puesto neutro a alianza en auto',
	},
	auto_climb_level:{
		en:'Climb Level in Auto',
		type:'avg',
		timeline_stamp:"C",
		timeline_fill:"#F66",
		timeline_outline:"#C33",
		fr:'Niveau d\'escalade en auto',
		pt:'Nível de escalada no Auto',
		zh_tw:'自動攀爬等級',
		tr:'Otomatik Tırmanma Seviyesi',
		he:'רמת טיפוס באוטומט',
		es:'Nivel de Escalada en Auto',

	},
	auto_climb_position:{
		en:'Climb Position in Auto',
		type:'heatmap',
		image:"/2026/climb-area.png",
		aspect_ratio:1.271,
		whiteboard_start:12,
		whiteboard_end:0,
		whiteboard_left:35,
		whiteboard_right:72,
		whiteboard_char:"A",
		whiteboard_us:true,
		fr:'Position d\'escalade en auto',
		pt:'Posição de escalada no Auto',
		zh_tw:'自動攀爬位置',
		tr:'Otomatik Tırmanma Pozisyonu',
		he:'מיקום טיפוס באוטומט',
		es:'Posición de Escalada en Auto',

	},
	auto_collect_depot:{
		en:'Collected Depot in Auto',
		type:'avg',
		timeline_stamp:"D",
		timeline_fill:"#0F0",
		timeline_outline:"#efab00",
		fr:'Dépôt collecté en auto',
		pt:'Depósito coletado no Auto',
		zh_tw:'自動收集倉庫',
		tr:'Otomatik Olarak Depo Toplandı',
		he:'אוסף מחסן באוטומט',
		es:'Depósito Recolectado en Auto',

	},
	auto_collect_outpost:{
		en:'Collected Outpost in Auto',
		type:'avg',
		timeline_stamp:"O",
		timeline_fill:"#0F0",
		timeline_outline:"#efab00",
		fr:'Avant-poste collecté en auto',
		pt:'Posto avançado coletado no Auto',
		zh_tw:'自動收集前哨',
		tr:'Otomatik Olarak Karakol Toplandı',
		he:'אוסף מוצב באוטומט',
		es:'Puesto Recolectado en Auto',

	},
	auto_fuel_neutral_alliance_pass:{
		en:'Fuel Neutral Alliance Pass in Auto',
		type:'avg',
		timeline_stamp: {
			"1":"i",
			"5":"v",
			"10":"x",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:'Passage d\'alliance neutre de carburant en auto',
		pt:'Passe de aliança neutra de combustível no Auto',
		zh_tw:'自動燃料中立聯盟通行證',
		tr:'Otomatik Nötr Yakıt İttifak Pası',
		he:'דלק נייטרלי מעבר לברית באוטומט',
		es:'Pase de Alianza Neutral de Combustible en Auto',

	},
	auto_fuel_score:{
		en:'Fuel Score in Auto',
		type:'avg',
		timeline_stamp: {
			"1":"I",
			"5":"V",
			"10":"X",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:'Score de carburant en auto',
		pt:'Pontuação de combustível no Auto',
		zh_tw:'自動燃料得分',
		tr:'Otomatik Yakıt Skoru',
		he:'ציון דלק באוטומט',
		es:'Puntuación de Combustible en Auto',

	},
	auto_start:{
		name:"Location where the robot starts",
		type:"heatmap",
		image:"/2026/start-area.png",
		aspect_ratio:2.644,
		whiteboard_start:30.5,
		whiteboard_end:15.5,
		whiteboard_char:"□",
		whiteboard_us:true,
		fr:'Lieu de départ du robot',
		pt:'Local onde o robô começa',
		zh_tw:'機器人啟動的位置',
		tr:'Robotun başladığı yer',
		he:'המיקום שבו הרובוט מתחיל',
		es:'Inicio en Auto',

	},
	auto_trench_depot_alliance_to_neutral:{
		en:'Trench (Depot Side) Alliance To Neutral in Auto',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Dépôt Alliance à neutre en auto',
		pt:'Depósito de trincheira da aliança para neutro no Auto',
		zh_tw:'自動將聯盟壕溝倉庫轉為中立',
		tr:'Otomatik Olarak İttifak Hendeği Depoyu Nötr Yap',
		he:'לחפור מחסן ברית לנייטרלי באוטומט',
		es:'Trinchera (Lado Depósito) de Alianza a Neutral en Auto',

	},
	auto_trench_depot_neutral_to_alliance:{
		en:'Trench (Depot Side) Neutral To Alliance in Auto',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Dépôt Neutre à l\'alliance en auto',
		pt:'Depósito de trincheira neutro para a aliança no Auto',
		zh_tw:'自動將中立壕溝倉庫轉到聯盟',
		tr:'Otomatik Olarak Nötr Hendeği Depoyu İttifak Yap',
		he:'לחפור מחסן נייטרלי לברית באוטומט',
		es:'Trinchera (Lado Depósito) de Neutral a Alianza en Auto',

	},
	auto_trench_outpost_alliance_to_neutral:{
		en:'Trench (Outpost Side) Alliance To Neutral in Auto',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Avant-poste Alliance à neutre en auto',
		pt:'Posto avançado de trincheira da aliança para neutro no Auto',
		zh_tw:'自動將聯盟壕溝前哨轉為中立',
		tr:'Otomatik Olarak İttifak Hendeği Karakolunu Nötr Yap',
		he:'לחפור מוצב ברית לנייטרלי באוטומט',
		es:'Trinchera (Lado Puesto) de Alianza a Neutral en Auto',

	},
	auto_trench_outpost_neutral_to_alliance:{
		en:'Trench (Outpost Side) Neutral To Alliance in Auto',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Avant-poste Neutre à l\'alliance en auto',
		pt:'Posto avançado de trincheira neutro para a aliança no Auto',
		zh_tw:'自動將中立壕溝前哨轉到聯盟',
		tr:'Otomatik Olarak Nötr Hendeği Karakolu İttifak Yap',
		he:'לחפור מוצב נייטרלי לברית באוטומט',
		es:'Trinchera (Lado Puesto) de Neutral a Alianza en Auto',

	},
	defense_blocked:{
		en:'Defense Blocked',
		type:'%',
		fr:'Défense bloquée',
		pt:'Defesa bloqueada',
		zh_tw:'防禦封鎖',
		tr:'Savunma Engellendi',
		he:'הגנה חסומה',
		es:'Defensa Bloqueada',

	},
	defense_collected:{
		en:'Defense Collected',
		type:'%',
		fr:'Défense collectée',
		pt:'Defesa coletada',
		zh_tw:'防禦收集',
		tr:'Savunma Toplandı',
		he:'הגנה נאספה',
		es:'Defensa Recolectada',

	},
	defense_hit:{
		en:'Defense Hit',
		type:'%',
		fr:'Défense touchée',
		pt:'Defesa atingida',
		zh_tw:'防禦命中',
		tr:'Savunma Vuruldu',
		he:'הגנה נפגעה',
		es:'Defensa Golpeada',

	},
	defense_pinned:{
		en:'Defense Pinned',
		type:'%',
		fr:'Défense épinglée',
		pt:'Defesa fixada',
		zh_tw:'防禦釘住',
		tr:'Savunma Sabitlendi',
		he:'הגנה עצורה',
		es:'Defensa fijada',
	},
	no_show:{
		en:'No Show',
		type:'%',
		fr:'Absence',
		pt:'Não compareceu',
		zh_tw:'未出現',
		tr:'Gösteri Yok',
		he:'לא להופיע',
		es:'Sin Presentación',

	},
	review_requested:{
		en:'Review Requested',
		type:'%',
		fr:'Revue demandée',
		pt:'Revisão solicitada',
		zh_tw:'請求審查',
		tr:'İnceleme Talep Edildi',
		he:'בקשת סקירה',
		es:'Revisión Solicitada (Estimado)',

	},
	tele_bump_depot_alliance_to_neutral:{
		en:'Bump (Depot Side) Alliance To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le dépôt de l\'alliance à neutre en téléop',
		pt:'Empurrar o depósito da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟倉庫撞擊為中立',
		tr:'Teleopta İttifak Deposu Nötr Yap',
		he:'לדחוף את מחסן הברית לנייטרלי בטליאופ',
		es:'Golpe (Lado Depósito) de Alianza a Neutral en Teleop',

	},
	tele_bump_depot_neutral_to_alliance:{
		en:'Bump (Depot Side) Neutral To Alliance in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le dépôt neutre à l\'alliance en téléop',
		pt:'Empurrar o depósito neutro para a aliança no Teleop',
		zh_tw:'遙控將中立倉庫撞擊到聯盟',
		tr:'Teleopta Nötr Depoyu İttifak Yap',
		he:'לדחוף את מחסן נייטרלי לברית בטליאופ',
		es:'Golpe (Lado Depósito) de Neutral a Alianza en Teleop',

	},
	tele_bump_depot_neutral_to_opponent:{
		en:'Bump (Depot Side) Neutral To Opponent in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le dépôt neutre à l\'adversaire en téléop',
		pt:'Empurrar o depósito neutro para o oponente no Teleop',
		zh_tw:'遙控將中立倉庫撞擊到對手',
		tr:'Teleopta Nötr Depoyu Rakibe Yap',
		he:'לדחוף את מחסן נייטרלי ליריב בטליאופ',
		es:'Golpe (Lado Depósito) de Neutral a Oponente en Teleop',

	},
	tele_bump_depot_opponent_to_neutral:{
		en:'Bump (Depot Side) Opponent To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le dépôt de l\'adversaire à neutre en téléop',
		pt:'Empurrar o depósito do oponente para neutro no Teleop',
		zh_tw:'遙控將對手倉庫撞擊為中立',
		tr:'Teleopta Rakip Depoyu Nötr Yap',
		he:'לדחוף את מחסן היריב לנייטרלי בטליאופ',
		es:'Golpe (Lado Depósito) de Oponente a Neutral en Teleop',

	},
	tele_bump_outpost_alliance_to_neutral:{
		en:'Bump (Outpost Side) Alliance To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le avant-poste de l\'alliance à neutre en téléop',
		pt:'Empurrar o posto avançado da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟前哨撞擊為中立',
		tr:'Teleopta İttifak Karakolunu Nötr Yap',
		he:'לדחוף את מוצב הברית לנייטרלי בטליאופ',
		es:'Golpe (Lado Puesto) de Alianza a Neutral en Teleop',

	},
	tele_bump_outpost_neutral_to_alliance:{
		en:'Bump (Outpost Side) Neutral To Alliance in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le avant-poste neutre à l\'alliance en téléop',
		pt:'Empurrar o posto avançado neutro para a aliança no Teleop',
		zh_tw:'遙控將中立前哨撞擊到聯盟',
		tr:'Teleopta Nötr Karakolu İttifak Yap',
		he:'לדחוף את מוצב נייטרלי לברית בטליאופ',
		es:'Golpe (Lado Puesto) de Neutral a Alianza en Teleop',

	},
	tele_bump_outpost_neutral_to_opponent:{
		en:'Bump (Outpost Side) Neutral To Opponent in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le avant-poste neutre à l\'adversaire en téléop',
		pt:'Empurrar o posto avançado neutro para o oponente no Teleop',
		zh_tw:'遙控將中立前哨撞擊到對手',
		tr:'Teleopta Nötr Karakolu Rakibe Yap',
		he:'לדחוף את מוצב נייטרלי ליריב בטליאופ',
		es:'Golpe (Lado Puesto) de Neutral a Oponente en Teleop',

	},
	tele_bump_outpost_opponent_to_neutral:{
		en:'Bump (Outpost Side) Opponent To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0FF",
		timeline_outline:"#999",
		fr:'Pousser le avant-poste de l\'adversaire à neutre en téléop',
		pt:'Empurrar o posto avançado do oponente para neutro no Teleop',
		zh_tw:'遙控將對手前哨撞擊為中立',
		tr:'Teleopta Rakip Karakolu Nötr Yap',
		he:'לדחוף את מוצב היריב לנייטרלי בטליאופ',
		es:'Golpe (Lado Puesto) de Oponente a Neutral en Teleop',

	},
	tele_climb_level:{
		en:'Climb Level in Teleop',
		type:'avg',
		timeline_stamp:"C",
		timeline_fill:"#F66",
		timeline_outline:"#C33",
		fr:'Niveau d\'escalade en téléop',
		pt:'Nível de escalada no Teleop',
		zh_tw:'遙控攀爬等級',
		tr:'Teleopta Tırmanma Seviyesi',
		he:'רמת טיפוס בטליאופ',
		es:'Nivel de Escalada en Teleop',

	},
	tele_climb_position:{
		en:'Climb Position in Teleop',
		type:'heatmap',
		image:"/2026/climb-area.png",
		aspect_ratio:1.271,
		whiteboard_start:12,
		whiteboard_end:0,
		whiteboard_left:35,
		whiteboard_right:72,
		whiteboard_char:"T",
		whiteboard_us:true,
		fr:'Position d\'escalade en téléop',
		pt:'Posição de escalada no Teleop',
		zh_tw:'遙控攀爬位置',
		tr:'Teleopta Tırmanma Pozisyonu',
		he:'מיקום טיפוס בטליאופ',
		es:'Posición de Escalada en Teleop',

	},
	tele_fuel_alliance_dump:{
		en:'Fuel Alliance Dump in Teleop',
		type:'avg',
		timeline_stamp: {
			"1":"i",
			"5":"v",
			"10":"x",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:'Dépôt d\'alliance de carburant en téléop',
		pt:'Descarte de aliança de combustível no Teleop',
		zh_tw:'遙控燃料聯盟傾倒',
		tr:'Teleopta Yakıt İttifak Dökümü',
		he:'דלק ברית שפיכה בטליאופ',
		es:'Vertedero de Alianza de Combustible en Teleop',

	},
	tele_fuel_neutral_alliance_pass:{
		en:'Fuel Neutral Alliance Pass in Teleop',
		type:'avg',
		timeline_stamp: {
			"1":"i",
			"5":"v",
			"10":"x",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:'Passage d\'alliance neutre de carburant en téléop',
		pt:'Passe de aliança neutra de combustível no Teleop',
		zh_tw:'遙控燃料中立聯盟通行證',
		tr:'Teleopta Nötr Yakıt İttifak Pası',
		he:'דלק נייטרלי מעבר לברית בטליאופ',
		es:'Pase de Alianza Neutral de Combustible en Teleop',

	},
	tele_fuel_opponent_alliance_pass:{
		en:'Fuel Opponent Alliance Pass in Teleop',
		type:'avg',
		timeline_stamp: {
			"1":"i",
			"5":"v",
			"10":"x",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:'Passage d\'alliance adverse de carburant en téléop',
		pt:'Passe de aliança do oponente de combustível no Teleop',
		zh_tw:'遙控燃料對手聯盟通行證',
		tr:'Teleopta Rakip Yakıt İttifak Pası',
		he:'דלק יריב מעבר לברית בטליאופ',
		es:'Pase de Alianza de Oponente de Combustible en Teleop',

	},
	tele_fuel_opponent_neutral_pass:{
		en:'Fuel Opponent Neutral Pass in Teleop',
		type:'avg',
		timeline_stamp: {
			"1":"i",
			"5":"v",
			"10":"x",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:	'Passage neutre adverse de carburant en téléop',
		pt:'Passe neutra do oponente de combustível no Teleop',
		zh_tw:'遙控燃料對手中立通行證',
		tr:'Teleopta Rakip Nötr Yakıt Pası',
		he:'דלק יריב מעבר לנייטרלי בטליאופ',
		es:'Pase Neutral de Oponente de Combustible en Teleop',

	},
	tele_fuel_outpost:{
		en:'Fuel Outpost in Teleop',
		type:'avg',
		fr:'Dépôt d\'avant-poste de carburant en téléop',
		pt:'Posto avançado de combustível no Teleop',
		zh_tw:'遙控燃料前哨',
		tr:'Teleopta Yakıt Karakolu',
		he:'דלק מוצב בטליאופ',
		es:'Puesto de Combustible en Teleop',

	},
	tele_fuel_score:{
		en:'Fuel Score in Teleop',
		type:'avg',
		timeline_stamp: {
			"1":"I",
			"5":"V",
			"10":"X",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:'Score de carburant en téléop',
		pt:'Pontuação de combustível no Teleop',
		zh_tw:'遙控燃料得分',
		tr:'Teleopta Yakıt Skoru',
		he:'ציון דלק בטליאופ',
		es:'Puntuación de Combustible en Teleop',

	},
	tele_trench_depot_alliance_to_neutral:{
		en:'Trench (Depot Side) Alliance To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Dépôt Alliance à neutre en téléop',
		pt:'Depósito de trincheira da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟壕溝倉庫轉為中立',
		tr:'Teleopta İttifak Hendeği Deposu Nötr Yap',
		he:'לחפור מחסן ברית לנייטרלי בטליאופ',
		es:'Trinchera (Lado Depósito) de Alianza a Neutral en Teleop',

	},
	tele_trench_depot_neutral_to_alliance:{
		en:'Trench (Depot Side) Neutral To Alliance in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Dépôt Neutre à l\'alliance en téléop',
		pt:'Depósito de trincheira neutro para a aliança no Teleop',
		zh_tw:'遙控將中立壕溝倉庫轉到聯盟',
		tr:'Teleopta Nötr Hendeği Depoyu İttifak Yap',
		he:'לחפור מחסן נייטרלי לברית בטליאופ',
		es:'Trinchera (Lado Depósito) de Neutral a Alianza en Teleop',

	},
	tele_trench_depot_neutral_to_opponent:{
		en:'Trench (Depot Side) Neutral To Opponent in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Dépôt Neutre à l\'adversaire en téléop',
		pt:'Depósito de trincheira neutro para o oponente no Teleop',
		zh_tw:'遙控將中立壕溝倉庫轉到對手',
		tr:'Teleopta Nötr Hendeği Rakibe Yap',
		he:'לחפור מחסן נייטרלי ליריב בטליאופ',
		es:'Trinchera (Lado Depósito) de Neutral a Oponente en Teleop',

	},
	tele_trench_depot_opponent_to_neutral:{
		en:'Trench (Depot Side) Opponent To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Dépôt de l\'adversaire à neutre en téléop',
		pt:'Depósito de trincheira do oponente para neutro no Teleop',
		zh_tw:'遙控將對手壕溝倉庫轉為中立',
		tr:'Teleopta Rakip Hendeği Nötr Yap',
		he:'לחפור מחסן יריב לנייטרלי בטליאופ',
		es:'Trinchera (Lado Depósito) de Oponente a Neutral en Teleop',

	},
	tele_trench_outpost_alliance_to_neutral:{
		en:'Trench (Outpost Side) Alliance To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Avant-poste Alliance à neutre en téléop',
		pt:'Posto avançado de trincheira da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟壕溝前哨轉為中立',
		tr:'Teleopta İttifak Hendeği Karakolunu Nötr Yap',
		he:'לחפור מוצב ברית לנייטרלי בטליאופ',
		es:'Trinchera (Lado Puesto) de Alianza a Neutral en Teleop',

	},
	tele_trench_outpost_neutral_to_alliance:{
		en:'Trench (Outpost Side) Neutral To Alliance in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Avant-poste Neutre à l\'alliance en téléop',
		pt:'Posto avançado de trincheira neutro para a aliança no Teleop',
		zh_tw:'遙控將中立壕溝前哨轉到聯盟',
		tr:'Teleopta Nötr Hendeği Karakolu İttifak Yap',
		he:'לחפור מוצב נייטרלי לברית בטליאופ',
		es:'Trinchera (Lado Puesto) de Neutral a Alianza en Teleop',

	},
	tele_trench_outpost_neutral_to_opponent:{
		en:'Trench (Outpost Side) Neutral To Opponent in Teleop',
		type:'avg',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Avant-poste Neutre à l\'adversaire en téléop',
		pt:'Posto avançado de trincheira neutro para o oponente no Teleop',
		zh_tw:'遙控將中立壕溝前哨轉到對手',
		tr:'Teleopta Nötr Hendeği Rakibe Yap',
		he:'לחפור מוצב נייטרלי ליריב בטליאופ',
		es:'Trinchera (Lado Puesto) de Neutral a Oponente en Teleop',

	},
	tele_trench_outpost_opponent_to_neutral:{
		en:'Trench (Outpost Side) Opponent To Neutral in Teleop',
		type:'avg',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée Avant-poste de l\'adversaire à neutre en téléop',
		pt:'Posto avançado de trincheira do oponente para neutro no Teleop',
		zh_tw:'遙控將對手壕溝前哨轉為中立',
		tr:'Teleopta Rakip Hendeği Nötr Yap',
		he:'לחפור מוצב יריב לנייטרלי בטליאופ',
		es:'Trinchera (Lado Puesto) de Oponente a Neutral en Teleop',

	},
	auto_bump:{
		en:'Bump in Auto',
		type:'%',
		fr:'Pousser en auto',
		pt:'Empurrar no Auto',
		zh_tw:'自動撞擊',
		tr:'Otomatik Vuruş',
		he:'דחיפה באוטומט',
		es:'Golpe en Auto',

	},
	auto_bump_alliance:{
		en:'Bump Alliance in Auto',
		type:'%',
		fr:'Pousser l\'alliance en auto',
		pt:'Empurrar a Aliança no Auto',
		zh_tw:'自動撞擊聯盟',
		tr:'Otomatik İttifak Vuruşu',
		he:'דחיפת ברית באוטומט',
		es:'Golpe de Alianza en Auto',

	},
	auto_bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance in Auto',
		type:'%',
		fr:'Pousser l\'alliance (dépôt) en auto',
		pt:'Empurrar Aliança (Lado Depósito) no Auto',
		zh_tw:'自動撞擊聯盟(倉庫側)',
		tr:'Otomatik İttifak Vuruşu (Depo Tarafı)',
		he:'דחיפת ברית דיפו באוטומט',
		es:'Golpe (Lado Depósito) de Alianza en Auto',

	},
	auto_bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance in Auto',
		type:'%',
		fr:'Pousser l\'alliance (avant-poste) en auto',
		pt:'Empurrar Aliança (Lado Posto Avançado) no Auto',
		zh_tw:'自動撞擊聯盟(前哨側)',
		tr:'Otomatik İttifak Vuruşu (Karakol Tarafı)',
		he:'דחיפת ברית חוסן באוטומט',
		es:'Golpe (Lado Puesto) de Alianza en Auto',

	},
	auto_score:{
		en:'Score in Auto',
		type:'avg',
		fr:'Pointage en auto',
		pt:'Pontuação no Auto',
		zh_tw:'自動得分',
		tr:'Otomatik Skor',
		he:'ציון באוטומט',
		es:'Puntuación en Auto (Estimado)',

	},
	max_auto_score:{
		en:'Max Auto Score',
		type:'minmax',
		fr:'Score max en auto',
		pt:'Pontuação máxima no Auto',
		zh_tw:'自動最高得分',
		tr:'Maksimum Otomatik Skor',
		he:'ציון מקסימלי באוטומט',
		es:'Puntuación Máxima en Auto',

	},
	auto_to_alliance:{
		en:'To Alliance in Auto',
		type:'%',
		fr:'Vers l\'alliance en auto',
		pt:'Para a Aliança no Auto',
		zh_tw:'自動進入聯盟',
		tr:'Otomatik İttifak Hedefi',
		he:'לברית באוטומט',
		es:'A la Alianza en Auto',

	},
	auto_to_neutral:{
		en:'To Neutral in Auto',
		type:'%',
		fr:'Vers le neutre en auto',
		pt:'Para Neutro no Auto',
		zh_tw:'自動進入中立',
		tr:'Otomatik Nötr Hedefi',
		he:'לנייטרלי באוטומט',
		es:'A Neutral en Auto',

	},
	auto_tower_score:{
		en:'Tower Score in Auto',
		type:'avg',
		fr:'Pointage de tour en auto',
		pt:'Pontuação da Torre no Auto',
		zh_tw:'自動塔樓得分',
		tr:'Otomatik Kule Skoru',
		he:'ציון מגדל באוטומט',
		es:'Puntuación de Torre en Auto',

	},
	auto_trench:{
		en:'Trench in Auto',
		type:'%',
		fr:'Tranchée en auto',
		pt:'Trincheira no Auto',
		zh_tw:'自動壕溝',
		tr:'Otomatik Hendeği',
		he:'תעלה באוטומט',
		es:'Trinchera en Auto',

	},
	auto_trench_alliance:{
		en:'Trench Alliance in Auto',
		type:'%',
		fr:'Tranchée alliance en auto',
		pt:'Trincheira Aliança no Auto',
		zh_tw:'自動壕溝聯盟',
		tr:'Otomatik İttifak Hendeği',
		he:'תעלת ברית באוטומט',
		es:'Trinchera de Alianza en Auto',

	},
	auto_trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance in Auto',
		type:'%',
		fr:'Tranchée alliance (dépôt) en auto',
		pt:'Trincheira Aliança (Lado Depósito) no Auto',
		zh_tw:'自動壕溝聯盟(倉庫側)',
		tr:'Otomatik İttifak Hendeği (Depo Tarafı)',
		he:'תעלת ברית דיפו באוטומט',
		es:'Trinchera (Lado Depósito) de Alianza en Auto',

	},
	auto_trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance in Auto',
		type:'%',
		fr:'Tranchée alliance (avant-poste) en auto',
		pt:'Trincheira Aliança (Lado Posto Avançado) no Auto',
		zh_tw:'自動壕溝聯盟(前哨側)',
		tr:'Otomatik İttifak Hendeği (Karakol Tarafı)',
		he:'תעלת ברית חוסן באוטומט',
		es:'Trinchera (Lado Puesto) de Alianza en Auto',

	},
	bump:{
		en:'Bump',
		type:'%',
		fr:'Pousser',
		pt:'Empurrar',
		zh_tw:'撞擊',
		tr:'Vuruş',
		he:'דחיפה',
		es:'Golpe',

	},
	bump_alliance:{
		en:'Bump Alliance',
		type:'%',
		fr:'Pousser l\'alliance',
		pt:'Empurrar a Aliança',
		zh_tw:'撞擊聯盟',
		tr:'İttifak Vuruşu',
		he:'דחיפת ברית',
		es:'Golpe de Alianza',

	},
	bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance',
		type:'%',
		fr:'Pousser l\'alliance (dépôt)',
		pt:'Empurrar Aliança (Lado Depósito)',
		zh_tw:'撞擊聯盟(倉庫側)',
		tr:'İttifak Vuruşu (Depo Tarafı)',
		he:'דחיפת ברית דיפו',
		es:'Golpe (Lado Depósito) de Alianza',

	},
	bump_depot_alliance_to_neutral:{
		en:'Bump (Depot Side) Alliance To Neutral',
		type:'%',
		fr:'Pousser alliance vers neutre (dépôt)',
		pt:'Empurrar Aliança para Neutro (Lado Depósito)',
		zh_tw:'撞擊聯盟至中立(倉庫側)',
		tr:'İttifak Vuruşunu Nötr Yap (Depo Tarafı)',
		he:'דחיפת ברית לנייטרלי דיפו',
		es:'Golpe (Lado Depósito) de Alianza a Neutral',

	},
	bump_depot_neutral_to_alliance:{
		en:'Bump (Depot Side) Neutral To Alliance',
		type:'%',
		fr:'Pousser neutre vers alliance (dépôt)',
		pt:'Empurrar Neutro para Aliança (Lado Depósito)',
		zh_tw:'撞擊中立至聯盟(倉庫側)',
		tr:'Nötr Vuruşunu İttifak Yap (Depo Tarafı)',
		he:'דחיפת נייטרלי לברית דיפו',
		es:'Golpe (Lado Depósito) de Neutral a Alianza',

	},
	bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance',
		type:'%',
		fr:'Pousser l\'alliance (avant-poste)',
		pt:'Empurrar Aliança (Lado Posto Avançado)',
		zh_tw:'撞擊聯盟(前哨側)',
		tr:'İttifak Vuruşu (Karakol Tarafı)',
		he:'דחיפת ברית חוסן',
		es:'Golpe (Lado Puesto) de Alianza',

	},
	bump_outpost_alliance_to_neutral:{
		en:'Bump (Outpost Side) Alliance To Neutral',
		type:'%',
		fr:'Pousser alliance vers neutre (avant-poste)',
		pt:'Empurrar Aliança para Neutro (Lado Posto Avançado)',
		zh_tw:'撞擊聯盟至中立(前哨側)',
		tr:'İttifak Vuruşunu Nötr Yap (Karakol Tarafı)',
		he:'דחיפת ברית לנייטרלי חוסן',
		es:'Golpe (Lado Puesto) de Alianza a Neutral',

	},
	bump_outpost_neutral_to_alliance:{
		en:'Bump (Outpost Side) Neutral To Alliance',
		type:'%',
		fr:'Pousser neutre vers alliance (avant-poste)',
		pt:'Empurrar Neutro para Aliança (Lado Posto Avançado)',
		zh_tw:'撞擊中立至聯盟(前哨側)',
		tr:'Nötr Vuruşunu İttifak Yap (Karakol Tarafı)',
		he:'דחיפת נייטרלי לברית חוסן',
		es:'Golpe (Lado Puesto) de Neutral a Alianza',

	},
	climb_level:{
		en:'Climb Level',
		type:'%',
		fr:'Niveau d\'escalade',
		pt:'Nível de Escalada',
		zh_tw:'攀爬等級',
		tr:'Tırmanma Seviyesi',
		he:'רמת טיפוס',
		es:'Nivel de Escalada',

	},
	collect_depot:{
		en:'Collected Depot',
		type:'avg',
		fr:'Dépôt collecté',
		pt:'Depósito Coletado',
		zh_tw:'收集倉庫',
		tr:'Depo Toplandı',
		he:'אוסף מחסן',
		es:'Depósito Recolectado',

	},
	collect_outpost:{
		en:'Collected Outpost',
		type:'avg',
		fr:'Avant-poste collecté',
		pt:'Posto Avançado Coletado',
		zh_tw:'收集前哨',
		tr:'Karakol Toplandı',
		he:'אוסף מוצב',
		es:'Puesto Recolectado',

	},
	fuel_neutral_alliance_pass:{
		en:'Fuel Neutral Alliance Pass',
		type:'%',
		timeline_stamp: {
			"1":"i",
			"5":"v",
			"10":"x",
		},
		timeline_fill:"#f1ce03",
		timeline_outline:"#f1ce03",
		fr:'Passage alliance neutre de carburant',
		pt:'Passe de Aliança Neutra de Combustível',
		zh_tw:'燃料中立聯盟通行證',
		tr:'Nötr Yakıt İttifak Pası',
		he:'דלק נייטרלי מעבר לברית',
		es:'Pase de Alianza Neutral de Combustible',

	},
	fuel_score:{
		en:'Fuel Score',
		type:'avg',
		fr:'Pointage de carburant',
		pt:'Pontuação de Combustível',
		zh_tw:'燃料得分',
		tr:'Yakıt Skoru',
		he:'ציון דלק',
		es:'Puntuación de Combustible',

	},
	auto_fuel_output:{
		en:'Fuel Output to Target in Auto',
		type:'avg',
		fr:'Sortie de carburant en auto',
		pt:'Saída de Combustível no Auto',
		zh_tw:'自動燃料輸出',
		tr:'Otomatik Yakıt Çıkışı',
		he:'פלט דלק באוטומט',
		es:'Salida de Combustible en Auto',

	},
	tele_fuel_output:{
		en:'Fuel Output to Target in Teleop',
		type:'avg',
		fr:'Sortie de carburant en téléop',
		pt:'Saída de Combustível no Teleop',
		zh_tw:'遙控燃料輸出',
		tr:'Teleopta Yakıt Çıkışı',
		he:'פלט דלק בטליאופ',
		es:'Salida de Combustible en Teleop',

	},
	fuel_output:{
		en:'Fuel Output to Target',
		type:'avg',
		fr:'Sortie de carburant',
		pt:'Saída de Combustível',
		zh_tw:'燃料輸出',
		tr:'Yakıt Çıkışı',
		he:'פלט דלק',
		es:'Salida de Combustible',

	},
	max_score:{
		en:'Max Score',
		type:'minmax',
		fr:'Pointage Maximum',
		pt:'Pontuação Máxima',
		zh_tw:'最大得分',
		tr:'Maksimum Skor',
		he:'ציון מקסימום',
		es:'Puntuación Máxima',

	},
	min_score:{
		en:'Min Score',
		type:'minmax',
		fr:'Pointage Minimum',
		pt:'Pontuação Mínima',
		zh_tw:'最小得分',
		tr:'Minimum Skor',
		he:'ציון מינימום',
		es:'Puntuación Mínima',

	},
	score:{
		en:'Score',
		type:'avg',
		fr:'Pointage',
		pt:'Pontuação',
		zh_tw:'得分',
		tr:'Skor',
		he:'ציון',
		es:'Contribución de Puntuación (Estimado)',

	},
	tele_bump:{
		en:'Bump in Teleop',
		type:'%',
		fr:'Pousser en téléop',
		pt:'Empurrar no Teleop',
		zh_tw:'遙控撞擊',
		tr:'Teleopta Vuruş',
		he:'דחיפה בטליאופ',
		es:'Golpe en Teleop',

	},
	tele_bump_alliance:{
		en:'Bump Alliance in Teleop',
		type:'%',
		fr:'Pousser l\'alliance en téléop',
		pt:'Empurrar a Aliança no Teleop',
		zh_tw:'遙控撞擊聯盟',
		tr:'Teleopta İttifak Vuruşu',
		he:'דחיפת ברית בטליאופ',
		es:'Golpe de Alianza en Teleop',

	},
	tele_bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance in Teleop',
		type:'%',
		fr:'Pousser l\'alliance (dépôt) en téléop',
		pt:'Empurrar Aliança (Lado Depósito) no Teleop',
		zh_tw:'遙控撞擊聯盟(倉庫側)',
		tr:'Teleopta İttifak Vuruşu (Depo Tarafı)',
		he:'דחיפת ברית דיפו בטליאופ',
		es:'Golpe (Lado Depósito) de Alianza en Teleop',

	},
	tele_bump_depot_opponent:{
		en:'Bump (Depot Side) Opponent in Teleop',
		type:'%',
		fr:'Pousser l\'adversaire (dépôt) en téléop',
		pt:'Empurrar Oponente (Lado Depósito) no Teleop',
		zh_tw:'遙控撞擊對手(倉庫側)',
		tr:'Teleopta Rakip Vuruşu (Depo Tarafı)',
		he:'דחיפת יריב דיפו בטליאופ',
		es:'Golpe (Lado Depósito) de Oponente en Teleop',

	},
	tele_bump_opponent:{
		en:'Bump Opponent in Teleop',
		type:'%',
		fr:'Pousser l\'adversaire en téléop',
		pt:'Empurrar Oponente no Teleop',
		zh_tw:'遙控撞擊對手',
		tr:'Teleopta Rakip Vuruşu',
		he:'דחיפת יריב בטליאופ',
		es:'Golpe de Oponente en Teleop',

	},
	tele_bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance in Teleop',
		type:'%',
		fr:'Pousser l\'alliance (avant-poste) en téléop',
		pt:'Empurrar Aliança (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控撞擊聯盟(前哨側)',
		tr:'Teleopta İttifak Vuruşu (Karakol Tarafı)',
		he:'דחיפת ברית חוסן בטליאופ',
		es:'Golpe (Lado Puesto) de Alianza en Teleop',

	},
	tele_bump_outpost_opponent:{
		en:'Bump (Outpost Side) Opponent in Teleop',
		type:'%',
		fr:'Pousser l\'adversaire (avant-poste) en téléop',
		pt:'Empurrar Oponente (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控撞擊對手(前哨側)',
		tr:'Teleopta Rakip Vuruşu (Karakol Tarafı)',
		he:'דחיפת יריב חוסן בטליאופ',
		es:'Golpe (Lado Puesto) de Oponente en Teleop',

	},
	tele_score:{
		en:'Score in Teleop',
		type:'avg',
		fr:'Pointage en téléop',
		pt:'Pontuação no Teleop',
		zh_tw:'遙控得分',
		tr:'Teleopta Skor',
		he:'ציון בטליאופ',
		es:'Puntuación en Teleop (Estimado)',

	},
	tele_to_alliance:{
		en:'To Alliance in Teleop',
		type:'%',
		fr:'Vers l\'alliance en téléop',
		pt:'Para a Aliança no Teleop',
		zh_tw:'遙控進入聯盟',
		tr:'Teleopta İttifak Hedefi',
		he:'לברית בטליאופ',
		es:'A la Alianza en Teleop',

	},
	tele_to_neutral:{
		en:'To Neutral in Teleop',
		type:'%',
		fr:'Vers le neutre en téléop',
		pt:'Para Neutro no Teleop',
		zh_tw:'遙控進入中立',
		tr:'Teleopta Nötr Hedefi',
		he:'לנייטרלי בטליאופ',
		es:'A Neutral en Teleop',

	},
	tele_to_opponent:{
		en:'To Opponent in Teleop',
		type:'%',
		fr:'Vers l\'adversaire en téléop',
		pt:'Para o Oponente no Teleop',
		zh_tw:'遙控進入對手',
		tr:'Teleopta Rakip Hedefi',
		he:'ליריב בטליאופ',
		es:'Al Oponente en Teleop',

	},
	tele_tower_score:{
		en:'Tower Score in Teleop',
		type:'avg',
		fr:'Pointage de tour en téléop',
		pt:'Pontuação da Torre no Teleop',
		zh_tw:'遙控塔樓得分',
		tr:'Teleopta Kule Skoru',
		he:'ציון מגדל בטליאופ',
		es:'Puntuación de Torre en Teleop',

	},
	tele_trench:{
		en:'Trench in Teleop',
		type:'%',
		fr:'Tranchée en téléop',
		pt:'Trincheira no Teleop',
		zh_tw:'遙控壕溝',
		tr:'Teleopta Hendeği',
		he:'תעלה בטליאופ',
		es:'Trinchera en Teleop',

	},
	tele_trench_alliance:{
		en:'Trench Alliance in Teleop',
		type:'%',
		fr:'Tranchée alliance en téléop',
		pt:'Trincheira Aliança no Teleop',
		zh_tw:'遙控壕溝聯盟',
		tr:'Teleopta İttifak Hendeği',
		he:'תעלת ברית בטליאופ',
		es:'Trinchera de Alianza en Teleop',

	},
	tele_trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance in Teleop',
		type:'%',
		fr:'Tranchée alliance (dépôt) en téléop',
		pt:'Trincheira Aliança (Lado Depósito) no Teleop',
		zh_tw:'遙控壕溝聯盟(倉庫側)',
		tr:'Teleopta İttifak Hendeği (Depo Tarafı)',
		he:'תעלת ברית דיפו בטליאופ',
		es:'Trinchera (Lado Depósito) de Alianza en Teleop',

	},
	tele_trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent in Teleop',
		type:'%',
		fr:'Tranchée adversaire (dépôt) en téléop',
		pt:'Trincheira Oponente (Lado Depósito) no Teleop',
		zh_tw:'遙控壕溝對手(倉庫側)',
		tr:'Teleopta Rakip Hendeği (Depo Tarafı)',
		he:'תעלת יריב דיפו בטליאופ',
		es:'Trinchera (Lado Depósito) de Oponente en Teleop',

	},
	tele_trench_opponent:{
		en:'Trench Opponent in Teleop',
		type:'%',
		fr:'Tranchée adversaire en téléop',
		pt:'Trincheira Oponente no Teleop',
		zh_tw:'遙控壕溝對手',
		tr:'Teleopta Rakip Hendeği',
		he:'תעלת יריב בטליאופ',
		es:'Trinchera de Oponente en Teleop',

	},
	tele_trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance in Teleop',
		type:'%',
		fr:'Tranchée alliance (avant-poste) en téléop',
		pt:'Trincheira Aliança (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控壕溝聯盟(前哨側)',
		tr:'Teleopta İttifak Hendeği (Karakol Tarafı)',
		he:'תעלת ברית חוסן בטליאופ',
		es:'Trinchera (Lado Puesto) de Alianza en Teleop',

	},
	tele_trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent in Teleop',
		type:'%',
		fr:'Tranchée adversaire (avant-poste) en téléop',
		pt:'Trincheira Oponente (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控壕溝對手(前哨側)',
		tr:'Teleopta Rakip Hendeği (Karakol Tarafı)',
		he:'תעלת יריב חוסן בטליאופ',
		es:'Trinchera (Lado Puesto) de Oponente en Teleop',

	},
	to_alliance:{
		en:'To Alliance',
		type:'%',
		fr:'Vers l\'alliance',
		pt:'Para a Aliança',
		zh_tw:'進入聯盟',
		tr:'İttifak Hedefi',
		he:'לברית',
		es:'A la Alianza',

	},
	to_neutral:{
		en:'To Neutral',
		type:'%',
		fr:'Vers le neutre',
		pt:'Para Neutro',
		zh_tw:'進入中立',
		tr:'Nötr Hedefi',
		he:'לנייטרלי',
		es:'A Neutral',

	},
	to_opponent:{
		en:'To Opponent',
		type:'%',
		fr:'Vers l\'adversaire',
		pt:'Para o Oponente',
		zh_tw:'進入對手',
		tr:'Rakip Hedefi',
		he:'ליריב',
		es:'Al Oponente',

	},
	tower_score:{
		en:'Tower Score',
		type:'avg',
		fr:'Pointage de tour',
		pt:'Pontuação da Torre',
		zh_tw:'塔樓得分',
		tr:'Kule Skoru',
		he:'ציון מגדל',
		es:'Puntuación de Torre',

	},
	trench:{
		en:'Trench',
		type:'%',
		fr:'Tranchée',
		pt:'Trincheira',
		zh_tw:'壕溝',
		tr:'Hendeği',
		he:'תעלה',
		es:'Trinchera',

	},
	trench_alliance:{
		en:'Trench Alliance',
		type:'%',
		fr:'Tranchée alliance',
		pt:'Trincheira Aliança',
		zh_tw:'壕溝聯盟',
		tr:'İttifak Hendeği',
		he:'תעלת ברית',
		es:'Trinchera de Alianza',

	},
	trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance',
		type:'%',
		fr:'Tranchée alliance (dépôt)',
		pt:'Trincheira Aliança (Lado Depósito)',
		zh_tw:'壕溝聯盟(倉庫側)',
		tr:'İttifak Hendeği (Depo Tarafı)',
		he:'תעלת ברית דיפו',
		es:'Trinchera (Lado Depósito) de Alianza',

	},
	trench_depot_alliance_to_neutral:{
		en:'Trench (Depot Side) Alliance To Neutral',
		type:'%',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée alliance vers neutre (dépôt)',
		pt:'Trincheira Aliança para Neutro (Lado Depósito)',
		zh_tw:'壕溝聯盟至中立(倉庫側)',
		tr:'İttifak Hendeğini Nötr Yap (Depo Tarafı)',
		he:'תעלת ברית לנייטרלי דיפו',
		es:'Trinchera (Lado Depósito) de Alianza a Neutral',

	},
	trench_depot_neutral_to_alliance:{
		en:'Trench (Depot Side) Neutral To Alliance',
		type:'%',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée neutre vers alliance (dépôt)',
		pt:'Trincheira Neutro para Aliança (Lado Depósito)',
		zh_tw:'壕溝中立至聯盟(倉庫側)',
		tr:'Nötr Hendeğini İttifak Yap (Depo Tarafı)',
		he:'תעלת נייטרלי לברית דיפו',
		es:'Trinchera (Lado Depósito) de Neutral a Alianza',

	},
	trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent',
		type:'%',
		fr:'Tranchée adversaire (dépôt)',
		pt:'Trincheira Oponente (Lado Depósito)',
		zh_tw:'壕溝對手(倉庫側)',
		tr:'Rakip Hendeği (Depo Tarafı)',
		he:'תעלת יריב דיפו',
		es:'Trinchera (Lado Depósito) de Oponente',

	},
	trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance',
		type:'%',
		fr:'Tranchée alliance (avant-poste)',
		pt:'Trincheira Aliança (Lado Posto Avançado)',
		zh_tw:'壕溝聯盟(前哨側)',
		tr:'İttifak Hendeği (Karakol Tarafı)',
		he:'תעלת ברית חוסן',
		es:'Trinchera (Lado Puesto) de Alianza',

	},
	trench_outpost_alliance_to_neutral:{
		en:'Trench (Outpost Side) Alliance To Neutral',
		type:'%',
		timeline_stamp:"🢁",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée alliance vers neutre (avant-poste)',
		pt:'Trincheira Aliança para Neutro (Lado Posto Avançado)',
		zh_tw:'壕溝聯盟至中立(前哨側)',
		tr:'İttifak Hendeğini Nötr Yap (Karakol Tarafı)',
		he:'תעלת ברית לנייטרלי חוסן',
		es:'Trinchera (Lado Puesto) de Alianza a Neutral',

	},
	trench_outpost_neutral_to_alliance:{
		en:'Trench (Outpost Side) Neutral To Alliance',
		type:'%',
		timeline_stamp:"🢃",
		timeline_fill:"#0F0",
		timeline_outline:"#999",
		fr:'Tranchée neutre vers alliance (avant-poste)',
		pt:'Trincheira Neutro para Aliança (Lado Posto Avançado)',
		zh_tw:'壕溝中立至聯盟(前哨側)',
		tr:'Nötr Hendeğini İttifak Yap (Karakol Tarafı)',
		he:'תעלת נייטרלי לברית חוסן',
		es:'Trinchera (Lado Puesto) de Neutral a Alianza',

	},
	trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent',
		type:'%',
		fr:'Tranchée adversaire (avant-poste)',
		pt:'Trincheira Oponente (Lado Posto Avançado)',
		zh_tw:'壕溝對手(前哨側)',
		tr:'Rakip Hendeği (Karakol Tarafı)',
		he:'תעלת יריב חוסן',
		es:'Trinchera (Lado Puesto) de Oponente',

	},
	zone_change:{
		en:'Zone Change',
		type:'%',
		fr:'Changement de zone',
		pt:'Mudança de Zona',
		zh_tw:'區域變化',
		tr:'Bölge Değişimi',
		he:'שינוי אזור',
		es:'Cambio de Zona',

	},
	auto_alliance_time:{
		en:'Alliance Time in Auto',
		type:'avg',
		fr:'Temps alliance en auto',
		pt:'Tempo de Aliança no Auto',
		zh_tw:'自動聯盟時間',
		tr:'Otomatik İttifak Zamanı',
		he:'זמן ברית באוטומט',
		es:'Tiempo de Alianza en Auto',

	},
	auto_neutral_time:{
		en:'Neutral Time in Auto',
		type:'avg',
		fr:'Temps neutre en auto',
		pt:'Tempo Neutro no Auto',
		zh_tw:'自動中立時間',
		tr:'Otomatik Nötr Zamanı',
		he:'זמן נייטרלי באוטומט',
		es:'Tiempo Neutral en Auto',

	},
	tele_alliance_time:{
		en:'Alliance Time in Teleop',
		type:'avg',
		fr:'Temps alliance en téléop',
		pt:'Tempo de Aliança no Teleop',
		zh_tw:'遙控聯盟時間',
		tr:'Teleopta İttifak Zamanı',
		he:'זמן ברית בטליאופ',
		es:'Tiempo de Alianza en Teleop',

	},
	tele_neutral_time:{
		en:'Neutral Time in Teleop',
		type:'avg',
		fr:'Temps neutre en téléop',
		pt:'Tempo Neutro no Teleop',
		zh_tw:'遙控中立時間',
		tr:'Teleopta Nötr Zamanı',
		he:'זמן נייטרלי בטליאופ',
		es:'Tiempo Neutral en Teleop',

	},
	tele_opponent_time:{
		en:'Opponent Time in Teleop',
		type:'avg',
		fr:'Temps adversaire en téléop',
		pt:'Tempo do Oponente no Teleop',
		zh_tw:'遙控對手時間',
		tr:'Teleopta Rakip Zamanı',
		he:'זמן יריב בטליאופ',
		es:'Tiempo de Oponente en Teleop',

	},
	alliance_time:{
		en:'Alliance Time',
		type:'avg',
		fr:'Temps d\'alliance',
		pt:'Tempo de aliança',
		zh_tw:'聯盟時間',
		tr:'İttifak Zamanı',
		he:'זמן ברית',
		es:'Tiempo de Alianza',

	},
	neutral_time:{
		en:'Neutral Time',
		type:'avg',
		fr:'Temps neutre',
		pt:'Tempo neutro',
		zh_tw:'中立時間',
		tr:'Nötr Zaman',
		he:'זמן ניטרלי',
		es:'Tiempo Neutral',

	},
	opponent_time:{
		en:'Opponent Time',
		type:'avg',
		fr:'Temps adversaire',
		pt:'Tempo do oponente',
		zh_tw:'對手時間',
		tr:'Rakip Zamanı',
		he:'זמן יריב',
		es:'Tiempo de Oponente',

	},
	auto_paths:{
		name:"Auto Paths",
		type:"pathlist",
		aspect_ratio:.916,
		whiteboard_start:0,
		whiteboard_end:55,
		whiteboard_us:true,
		source:"pit",
		fr:'Trajectoires automatiques',
		pt:'Caminhos Automáticos',
		zh_tw:'自動路徑',
		tr:'Otomatik Yollar',
		he:'נתיבים אוטומטיים',
		es:'Rutas de Auto',
	},
	shooting_locations:{
		en:'Defendable Shooting Locations',
		type:"heatmap",
		image:'2026/alliance-area.png',
		aspect_ratio:1.55,
		whiteboard_start:0,
		whiteboard_end:30,
		whiteboard_us:false,
		whiteboard_char:'D',
		fr:'Emplacements de tir défendables',
		pt:'Locais de Tiro Defensáveis',
		zh_tw:'可防守射擊位置',
		tr:'Savunulabilir Atış Konumları',
		he:'מיקומי ירי שניתן להגן עליהם',
		es:'Ubicaciones de Disparo',

	},
	bump_percent:{
		en:'Bump Zone Crossings',
		type:'ratio',
		fr:'Traversées de zone de bosses',
		pt:'Travessias da Zona de Pancadas',
		zh_tw:'衝擊區域穿越',
		tr:'Çarpma Bölgesi Geçişleri',
		he:'חציות אזור התנגשות',
		es:'Porcentaje de Golpe',

	},
	trench_percent:{
		en:'Trench Zone Crossings',
		type:'ratio',
		fr:'Traversées de zone de tranchée',
		pt:'Travessias da Zona de Trincheira',
		zh_tw:'壕溝區域穿越',
		tr:'Hendek Bölgesi Geçişleri',
		he:'חציות אזור התעלה',
		es:'Porcentaje de Trinchera',

	},
	max_tele_climb_level:{
		en:'Max Teleop Climb Level',
		type:'minmax',
		fr:'Niveau d\'escalade maximum en téléop',
		pt:'Nível Máximo de Escalada no Teleop',
		zh_tw:'遙控最大攀爬等級',
		tr:'Maksimum Teleop Tırmanma Seviyesi',
		he:'רמת טיפוס מקסימלית בטליאופ',
		es:'Nivel Máximo de Escalada en Teleop',

	},
	max_fuel_output:{
		en:'Max Fuel Output to Target',
		type:'minmax',
		fr:'Sortie de carburant maximale vers la cible',
		pt:'Máxima Saída de Combustível para o Alvo',
		zh_tw:'最大燃料輸出',
		tr:'Maksimum Yakıt Çıkışı',
		he:'מקסימום פלט דלק',
		es:'Salida Máxima de Combustible',

	},
	'auto_zone_change_out':{
		en:'Zone Change Away in Auto',
		type:'heatmap',
		image:'2026/zone-change.png',
		aspect_ratio:.942,
		whiteboard_start:76,
		whiteboard_end:24,
		whiteboard_char:"O",
		whiteboard_us:true,
		fr:'Changement de zone loin en Auto',
		pt:'Mudança de zona longe em Auto',
		zh_tw:'自動區域變化外',
		tr:'Oto Modu Dış Bölge Değişimi',
		he:'שינוי אזור הרחק באוטומט',
	},
	'auto_zone_change_in':{
		en:'Zone Change Back in Auto',
		type:'heatmap',
		image:'2026/zone-change.png',
		aspect_ratio:.942,
		whiteboard_start:76,
		whiteboard_end:24,
		whiteboard_char:"B",
		whiteboard_us:true,
		fr:'Changement de zone retour en Auto',
		pt:'Mudança de zona de volta em Auto',
		zh_tw:'自動區域變化回',
		tr:'Oto Modu İç Bölge Değişimi',
		he:'שינוי אזור חזרה באוטומט',
	},
	'tele_zone_change_in':{
		en:'Zone Change Back in Teleop',
		type:'heatmap',
		image:'2026/zone-change.png',
		aspect_ratio:.942,
		whiteboard_start:76,
		whiteboard_end:24,
		whiteboard_char:"b",
		whiteboard_us:false,
		fr:'Changement de zone retour en Téléop',
		pt:'Mudança de zona de volta em Teleop',
		zh_tw:'遙控區域變化回',
		tr:'Teleop İç Bölge Değişimi',
		he:'שינוי אזור חזרה בטליאופ',
	},
	'tele_zone_change_out':{
		en:'Zone Change Away in Teleop',
		type:'heatmap',
		image:'2026/zone-change.png',
		aspect_ratio:.942,
		whiteboard_start:76,
		whiteboard_end:24,
		whiteboard_char:"o",
		whiteboard_us:false,
		fr:'Changement de zone loin en Téléop',
		pt:'Mudança de zona longe em Teleop',
		zh_tw:'遙控區域變化外',
		tr:'Teleop Dış Bölge Değişimi',
		he:'שינוי אזור הרחק בטליאופ',
	},
	'auto_collect_position':{
		en:'Collect in Auto',
		type:'heatmap',
		image:'2026/alliance-area.png',
		aspect_ratio:1.55,
		whiteboard_start:25,
		whiteboard_end:1,
		whiteboard_char:"C",
		whiteboard_us:true,
	},
}

var teamGraphs={
	"Game Stage":{
		graph:"stacked",
		tr:'Oyun Aşaması',
		pt:'Estágio do jogo',
		fr:'Phase de jeu',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		es:'Etapa del Juego',
		data:["auto_score","tele_score"],
	},
	"Fuel to Target":{
		graph:"stacked",
		tr:'Hedefe Yakıt',
		pt:'Combustível para o Alvo',
		fr:'Carburant vers la cible',
		he:'דלק למטרה',
		zh_tw:'燃料到目標',
		es:'Combustible al Objetivo',
		data:["auto_fuel_output","tele_fuel_output"],
	},
	"Match Timeline":{
		graph:"timeline",
		tr:'Maç Zaman Çizelgesi',
		pt:'Linha do tempo da partida',
		fr:'Chronologie du match',
		he:'התאם ציר זמן',
		zh_tw:'比賽時間表',
		es:'Cronología del Partido',
		data:['timeline'],
	},
	"Fuel vs Climb":{
		graph:"stacked",
		data:["fuel_score","tower_score"],
		tr:'Yakıt vs Tırmanış',
		pt:'Combustível vs Escalada',
		fr:'Carburant vs Escalade',
		he:'דלק לעומת טיפוס',
		zh_tw:'燃料與攀登',
		es:'Combustible vs Escalada',
	},
	"Start Location":{
		graph:"heatmap",
		fr:'Lieu de départ',
		pt:'Local de Partida',
		zh_tw:'起始位置',
		tr:'Başlangıç Konumu',
		he:'מיקום התחלה',
		es:'Ubicación de inicio',
		data:['auto_start']
	},
	"Collect in Auto":{
		graph:"heatmap",
		fr:'Collecter en auto',
		pt:'Coletar em Auto',
		zh_tw:'自動收集',
		tr:'Otomatik Toplama',
		he:'אסוף בתא אוטוטי',
		es:'Colectar en auto',
		data:['auto_collect_position']
	},
	"Zone Change Away in Auto":{
		graph:"heatmap",
		fr:'Changement de zone loin en auto',
		pt:'Mudança de zona longe em auto',
		zh_tw:'自動區域變化外',
		tr:'Otomatik Alan Değişimi Dış',
		he:'שינוי אזור הרחק באוטומט',
		es:'Cambio de zona lejos en auto',
		data:['auto_zone_change_out']
	},
	"Zone Change Back in Auto":{
		graph:"heatmap",
		fr:'Changement de zone retour en auto',
		pt:'Mudança de zona de volta em auto',
		zh_tw:'自動區域變化回',
		tr:'Otomatik Alan Değişimi İç',
		he:'שינוי אזור חזרה באוטומט',
		es:'Cambio de zona regreso en auto',
		data:['auto_zone_change_in']
	},
	"Climb Position in Auto":{
		graph:"heatmap",
		fr:'Position d\'escalade en auto',
		pt:'Posição de escalada em auto',
		zh_tw:'自動攀爬位置',
		tr:'Otomatik Tırmanma Pozisyonu',
		he:'מיקום טיפוס באוטומט',
		es:'Posición de escalada en auto',
		data:['auto_climb_position']
	},
	"Zone Change Away in Teleop":{
		graph:"heatmap",
		fr:'Changement de zone loin en Téléop',
		pt:'Mudança de zona longe em Teleop',
		zh_tw:'遙控區域變化外',
		tr:'Teleop Alan Değişimi Dış',
		he:'שינוי אזור הרחק בטליאופ',
		es:'Cambio de zona lejos en Teleop',
		data:['tele_zone_change_out']
	},
	"Zone Change Back in Teleop":{
		graph:"heatmap",
		fr:'Changement de zone retour en Téléop',
		pt:'Mudança de zona de volta em Teleop',
		zh_tw:'遙控區域變化回',
		tr:'Teleop Alan Değişimi İç',
		he:'שינוי אזור חזרה בטליאופ',
		es:'Cambio de zona regreso en Teleop',
		data:['tele_zone_change_in']
	},
	"Defendable Shooting Locations":{
		graph:"heatmap",
		fr:'Emplacements de tir défendables',
		pt:'Locais de tiro defensáveis',
		zh_tw:'可防守射擊位置',
		tr:'Savunulabilir atış konumları',
		he:'מיקומי ירי שניתן להגן עליהם',
		es:'Ubicaciones de disparo defensables',
		data:['shooting_locations']
	},
	"Climb Position in Teleop":{
		graph:"heatmap",
		fr:'Position d\'escalade en téléop',
		pt:'Posição de escalada em Teleop',
		zh_tw:'遙控攀爬位置',
		tr:'Teleop Tırmanma Pozisyonu',
		he:'מיקום טיפוס בטליאופ',
		es:'Posición de escalada en Teleop',
		data:['tele_climb_position']
	},
}

var aggregateGraphs={
	"Match Score":{
		graph:"boxplot",
		tr:'Maç Puanı',
		pt:'Pontuação da partida',
		fr:'Score du match',
		he:'ציון התאמה',
		zh_tw:'比賽比分',
		es:'Puntuación del Partido',
		data:["max_score","score","min_score"],
	},
	"Fuel to Target":{
		graph:"boxplot",
		tr:'Hedefe Yakıt',
		pt:'Combustível para o Alvo',
		fr:'Carburant vers la cible',
		he:'דלק למטרה',
		zh_tw:'燃料到目標',
		es:'Combustible al Objetivo',
		data:["fuel_output"],
	},
	"Game Stage":{
		graph:"stacked",
		tr:'Oyun Aşaması',
		pt:'Estágio do jogo',
		fr:'Phase de jeu',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		es:'Etapa del juego',
		data:["auto_score","tele_score"],
	},
	"Fuel vs Climb":{
		graph:"stacked",
		data:["fuel_score","tower_score"],
		tr:'Yakıt vs Tırmanış',
		pt:'Combustível vs Escalada',
		fr:'Carburant vs Escalade',
		he:'דלק לעומת טיפוס',
		zh_tw:'燃料與攀登',
		es:'Combustible vs Escalada',
	},
}

var matchPredictorSections={
	Total:{
		tr:'Total',
		he:'סַך הַכֹּל',
		zh_tw:'全部的',
		pt:'Total',
		fr:'Total',
		data:["score"],
		es:'Total',

	},
	"Game Stage":{
		tr:'Fase do Jogo',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		pt:'Fase do Jogo',
		fr:'Phase de jeu',
		es:'Etapa del juego',
		data:["auto_score","tele_score"],
	},
	"Fuel vs Climb":{
		graph:"stacked",
		data:["fuel_score","tower_score"],
		tr:'Yakıt vs Tırmanış',
		pt:'Combustível vs Escalada',
		fr:'Carburant vs Escalade',
		he:'דלק לעומת טיפוס',
		zh_tw:'燃料與攀登',
		es:'Combustible vs Escalada',
	},
}

var whiteboardStamps = [
	"/2026/fuel-stamp.png"
]

var fieldRotationalSymmetry=true

window.whiteboard_aspect_ratio=2.18

var whiteboardStats=[
	"score",
	"auto_score",
	"tele_score",
	"fuel_output",
	"trench_percent",
	"max_tele_climb_level",
	"tele_alliance_time",
	"tele_neutral_time",
	"tele_opponent_time",
	"defense_mode",
	"auto_start",
	"auto_paths",
	"auto_climb_position",
	"tele_climb_position",
	"auto_collect_position",
	'auto_zone_change_out',
	'auto_zone_change_in',
	'tele_zone_change_out',
	'tele_zone_change_in',
	"shooting_locations",
]

// https://www.postman.com/firstrobotics/workspace/frc-fms-public-published-workspace/example/13920602-f345156c-f083-4572-8d4a-bee22a3fdea1
var fmsMapping=[
	[["hubScore.autoPoints"],["auto_fuel_score"]],
	[["autoTowerPoints"],["auto_tower_score"]],
	[["hubScore.transitionPoints","hubScore.shift1Points","hubScore.shift2Points","hubScore.shift3Points","hubScore.endgamePoints"],["tele_fuel_score"]],
	[["teleTowerPoints"],["tele_tower_score"]],
]

function showPitScouting(el,team){
	promisePitScouting().then(pitData => {
		var dat=pitData[team]||{},
		section=$('<fieldset>').append($('<legend>').attr('data-i18n','team_info_legend')),
		ti=(window.eventTeamsInfo||{})[team]||{}
		dlText(section,'team_name_label',dat.team_name||ti.nameShort)
		dlText(section,'team_location_label',dat.team_location||ti.city?`${ti.city}, ${ti.stateProv}, ${ti.country}`:'')
		dlText(section,'bot_name_label',dat.bot_name||ti.robotName)
		el.append(section)

		section=$('<fieldset>').append($('<legend>').attr('data-i18n','robot_legend'))
		dlText(section,'robot_size_question',`${dat.frame_length}x${dat.frame_width}`,'robot_size_unit')
		dlText(section,'robot_fuel_capacity_question',dat.fuel_capacity)
		dlCheckboxes(section,'trenchbot_question',['trenchbot_option'],[dat.trenchbot])
		dlText(section,'intake_count_question',dat.intake_count)
		dlText(section,'robot_weight_question',dat.weight,'robot_weight_unit')
		dlTranslation(section,'robot_drivetrain_question',dat.drivetrain,'robot_drivetrain_')
		dlTranslation(section,'robot_swerve_question',dat.swerve,'robot_swerve_')
		dlText(section,'drivetrain_motor_count_question',dat.motor_count)
		dlTranslation(section,'drivetrain_motor_type_question',dat.motors,'motor_type_')
		dlText(section,'wheel_count_question',dat.wheel_count)
		dlTranslation(section,'wheel_type_question',dat.wheels,'wheel_type_')
		el.append(section)

		section=$('<fieldset>').append($('<legend>').attr('data-i18n','intake_style_question'))
		divCheckbox(section,'robot_intake_style_otb',dat.intake_otb)
		divCheckbox(section,'robot_intake_style_gap',dat.intake_gap)
		divCheckbox(section,'robot_intake_style_reversible',dat.intake_reversible)
		el.append(section)

		section=$('<fieldset>').append($('<legend>').attr('data-i18n','shooter_style_question'))
		dlText(section,'shooter_count_question',dat.shooter_count)
		dlCheckboxes(section,'shooter_style_question',['robot_shooter_style_fixed','robot_shooter_style_turret'],[dat.shooter_fixed,dat.shooter_turret])
		el.append(section)

		section=$('<fieldset>').append($('<legend>').attr('data-i18n','software_section'))
		dlText(section,'programming_language_question',dat.programming_language)
		dlText(section,'auto_software_question',dat.auto_software)
		dlCheckboxes(section,'vision_question',['vision_auto','vision_collecting','vision_placing','vision_localization'],[dat.vision_auto,dat.vision_collecting,dat.vision_placing,dat.vision_localization])
		el.append(section)

		if(dat.scouter||dat.notes){
			section=$('<fieldset>').append($('<legend>').attr('data-i18n','scouter_header'))
			dlText(section,'scouter_name_question',dat.scouter)
			if(dat.notes)section.append($("<dl>").append($('<dt>').attr('data-i18n','pit_scout_notes_placeholder')).append($('<dd>').append($('<div style=white-space:pre-wrap>').text(dat.notes))))
			el.append(section)
		}

		applyTranslations()
	})

	function divCheckbox(parent,key,value){
		parent.append($('<div>').attr('data-i18n',key).toggleClass('unused',!is(value)))
	}

	function dlText(parent,question,s,unit){
		parent.append($("<dl>").append($('<dt>').attr('data-i18n',question)).append(text($('<dd>'),s,unit)))
	}

	function dlCheckboxes(parent,question,checkboxKeys,values){
		var dl=$("<dl>").append($('<dt>').attr('data-i18n',question))
		checkboxKeys.forEach(function(key,i){
			dl.append($('<dt>').attr('data-i18n',key).toggleClass('unused',!is(values?values[i]:null)))
		})
		parent.append(dl)
	}

	function text(node,s,unit){
		if (is(s)){
			node.text(s)
			if (unit)node.append(' ').append($('<span>').attr('data-i18n',unit))
		}else node.attr('data-i18n','pit_scout_not_answered')
		return node
	}

	function dlTranslation(parent,question,s,prefix){
		parent.append($("<dl>").append($('<dt>').attr('data-i18n',question)).append(translation($('<dd>'),s,prefix)))
	}

	function translation(node,s,prefix){
		var swerveMap={'swerve-drive-specialties':'sds','andymark':'am','rev-robotics':'rev','westcoast-products':'wcp','other':'other'}
		var key=s
		if(prefix==='robot_swerve_'&&swerveMap[s])key=swerveMap[s]
		return node.attr('data-i18n',is(s)?`${prefix}${key}`.replace(/-/g,'_'):'pit_scout_not_answered')
	}

	function is(s){
		return s&&s!="0"&&!/^undefined/.test(s)
	}
}

var importFunctions={
	"195":{
		example:"/2026/195.csv",
		convert:importScouting195,
	},
	"lovat":{
		example:"/2026/lovat.csv",
		convert:importScouting_lovat,
	},
}

function importScouting195(text){
	var rows=csvToArrayOfMaps(text)
	rows=rows.filter(row=>row.preNoShow !== '')
	rows.forEach(row=>{
		row.match="qm" + row.matchNum
		row.no_show=row.preNoShow

		// Map starting position (preStartPosID) to auto_start percentage coordinates
		// Positions: 1=left, 2=left-center, 3=center, 4=right-center, 5=right
		row.auto_start=''
		switch(((""+row.preStartPosID)||"0")[0]){
			case "1":row.auto_start='10x50';break
			case "2":row.auto_start='30x50';break
			case "3":row.auto_start='50x50';break
			case "4":row.auto_start='70x50';break
			case "5":row.auto_start='90x50';break
		}

		// Auto fuel scoring
		row.auto_fuel_score=row.autoFuelTotal||0

		// Auto climb level (0=Fail, 1=Success, 5 or null=No attempt)
		// Map: 1=success (L1+), else=0 (fail or no attempt)
		row.auto_climb_level = (row.autoClimbTypeID=='1')?1:0

		// Auto climb position (1=Outer Left, 2=Left, 3=Center, 4=Right, 5=Outer Right)
		row.auto_climb_position=''
		switch(((""+row.autoClimbLocID)||"0")[0]){
			case "1":row.auto_climb_position='20x40';break
			case "2":row.auto_climb_position='35x40';break
			case "3":row.auto_climb_position='50x40';break
			case "4":row.auto_climb_position='65x40';break
			case "5":row.auto_climb_position='80x40';break
		}

		// Teleop fuel scoring
		row.tele_fuel_score=row.teleFuelTotal||0

		// Teleop climb level (1=L1, 2=L2, 3=L3, 4=Failed, 5 or null=No Attempt)
		// Map to Viper levels: 1=L1, 2=L2, 3=L3, else=0
		row.tele_climb_level = parseInt(row.climbTypeID)||0
		if(row.tele_climb_level>=4)row.tele_climb_level=0

		// Teleop climb position (same mapping as auto climb)
		row.tele_climb_position=''
		switch(((""+row.climbLocID)||"0")[0]){
			case "1":row.tele_climb_position='20x40';break
			case "2":row.tele_climb_position='35x40';break
			case "3":row.tele_climb_position='50x40';break
			case "4":row.tele_climb_position='65x40';break
			case "5":row.tele_climb_position='80x40';break
		}

		// Defense: postDef=0 (no), 1 (yes) → maps to '' or 'good'
		row.defense = row.postDef=='1'?'good':''

		// Defended: postWasDef=0 (no), 1 (yes) → maps to '' or 'slowed'
		row.defended = row.postWasDef=='1'?'slowed':''
		row.scouter="195"
	})
	return rows
}

function importScouting_lovat(text){
	var rows=csvToArrayOfMaps(text)
	rows.forEach(row=>{
		row.team=row.teamNumber

		// Map match number format (Q2 → qm2)
		row.match = row.match.replace(/^Q/, 'qm')

		// Map autoClimb value to auto_climb_level
		// NOT_ATTEMPTED = 0, otherwise parse as integer
		if(row.autoClimb === 'NOT_ATTEMPTED' || !row.autoClimb){
			row.auto_climb_level = 0
		} else {
			row.auto_climb_level = parseInt(row.autoClimb)||0
		}

		// Map endgameClimb value to tele_climb_level
		// NOT_ATTEMPTED = 0, otherwise parse as integer
		if(row.endgameClimb === 'NOT_ATTEMPTED' || !row.endgameClimb){
			row.tele_climb_level = 0
		} else {
			row.tele_climb_level = parseInt(row.endgameClimb)||0
		}

		// Map fuel/scoring points
		row.auto_fuel_score = parseInt(row.autoPoints)||0
		row.tele_fuel_score = parseInt(row.teleopPoints)||0

		// Map defense effectiveness to defense rating
		var defRating = parseInt(row.defenseEffectiveness)||0
		if(defRating >= 4){
			row.defense = 'great'
		} else if(defRating === 3){
			row.defense = 'good'
		} else if(defRating === 2){
			row.defense = 'ineffective'
		} else if(defRating === 1){
			row.defense = 'bad'
		} else {
			row.defense = ''
		}

		// Map comments/notes
		row.comments = row.notes||''

		// Set scouter
		row.scouter = row.scouter || 'lovat'
	})
	return rows
}
