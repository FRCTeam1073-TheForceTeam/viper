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
		if(/^%$/.test(statInfo[field]['type'])){
			scout[field] = bool_1_0(scout[field])
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
	scout.auto_bump_depot_opponent = scout.auto_bump_depot_neutral_to_opponent + scout.auto_bump_depot_opponent_to_neutral
	scout.auto_bump_outpost_alliance = scout.auto_bump_outpost_alliance_to_neutral + scout.auto_bump_outpost_neutral_to_alliance
	scout.auto_bump_outpost_opponent = scout.auto_bump_outpost_neutral_to_opponent + scout.auto_bump_outpost_opponent_to_neutral
	scout.auto_bump_alliance = scout.auto_bump_depot_alliance + scout.auto_bump_outpost_alliance
	scout.auto_bump_opponent = scout.auto_bump_depot_opponent + scout.auto_bump_outpost_opponent
	scout.auto_bump = scout.auto_bump_alliance + scout.auto_bump_opponent

	scout.tele_bump_depot_alliance = scout.tele_bump_depot_alliance_to_neutral + scout.tele_bump_depot_neutral_to_alliance
	scout.tele_bump_depot_opponent = scout.tele_bump_depot_neutral_to_opponent + scout.tele_bump_depot_opponent_to_neutral
	scout.tele_bump_outpost_alliance = scout.tele_bump_outpost_alliance_to_neutral + scout.tele_bump_outpost_neutral_to_alliance
	scout.tele_bump_outpost_opponent = scout.tele_bump_outpost_neutral_to_opponent + scout.tele_bump_outpost_opponent_to_neutral
	scout.tele_bump_alliance = scout.tele_bump_depot_alliance + scout.tele_bump_outpost_alliance
	scout.tele_bump_opponent = scout.tele_bump_depot_opponent + scout.tele_bump_outpost_opponent
	scout.tele_bump = scout.tele_bump_alliance + scout.tele_bump_opponent

	scout.bump_depot_alliance = scout.auto_bump_depot_alliance + scout.tele_bump_depot_alliance
	scout.bump_depot_opponent = scout.auto_bump_depot_opponent + scout.tele_bump_depot_opponent
	scout.bump_outpost_alliance = scout.auto_bump_outpost_alliance + scout.tele_bump_outpost_alliance
	scout.bump_outpost_opponent = scout.auto_bump_outpost_opponent + scout.tele_bump_outpost_opponent
	scout.bump_alliance = scout.auto_bump_alliance + scout.tele_bump_alliance
	scout.bump_opponent = scout.auto_bump_opponent + scout.tele_bump_opponent

	scout.auto_trench_depot_alliance = scout.auto_trench_depot_alliance_to_neutral + scout.auto_trench_depot_neutral_to_alliance
	scout.auto_trench_depot_opponent = scout.auto_trench_depot_neutral_to_opponent + scout.auto_trench_depot_opponent_to_neutral
	scout.auto_trench_outpost_alliance = scout.auto_trench_outpost_alliance_to_neutral + scout.auto_trench_outpost_neutral_to_alliance
	scout.auto_trench_outpost_opponent = scout.auto_trench_outpost_neutral_to_opponent + scout.auto_trench_outpost_opponent_to_neutral
	scout.auto_trench_alliance = scout.auto_trench_depot_alliance + scout.auto_trench_outpost_alliance
	scout.auto_trench_opponent = scout.auto_trench_depot_opponent + scout.auto_trench_outpost_opponent
	scout.auto_trench = scout.auto_trench_alliance + scout.auto_trench_opponent

	scout.tele_trench_depot_alliance = scout.tele_trench_depot_alliance_to_neutral + scout.tele_trench_depot_neutral_to_alliance
	scout.tele_trench_depot_opponent = scout.tele_trench_depot_neutral_to_opponent + scout.tele_trench_depot_opponent_to_neutral
	scout.tele_trench_outpost_alliance = scout.tele_trench_outpost_alliance_to_neutral + scout.tele_trench_outpost_neutral_to_alliance
	scout.tele_trench_outpost_opponent = scout.tele_trench_outpost_neutral_to_opponent + scout.tele_trench_outpost_opponent_to_neutral
	scout.tele_trench_alliance = scout.tele_trench_depot_alliance + scout.tele_trench_outpost_alliance
	scout.tele_trench_opponent = scout.tele_trench_depot_opponent + scout.tele_trench_outpost_opponent
	scout.tele_trench = scout.tele_trench_alliance + scout.tele_trench_opponent

	scout.trench_depot_alliance = scout.auto_trench_depot_alliance + scout.tele_trench_depot_alliance
	scout.trench_depot_opponent = scout.auto_trench_depot_opponent + scout.tele_trench_depot_opponent
	scout.trench_outpost_alliance = scout.auto_trench_outpost_alliance + scout.tele_trench_outpost_alliance
	scout.trench_outpost_opponent = scout.auto_trench_outpost_opponent + scout.tele_trench_outpost_opponent
	scout.trench_alliance = scout.auto_trench_alliance + scout.tele_trench_alliance
	scout.trench_opponent = scout.auto_trench_opponent + scout.tele_trench_opponent

	scout.bump = scout.auto_bump + scout.tele_bump
	scout.trench = scout.auto_trench + scout.tele_trench
	scout.zone_change = scout.bump + scout.trench

	scout.auto_to_alliance = scout.auto_bump_depot_neutral_to_alliance + scout.auto_bump_outpost_neutral_to_alliance + scout.auto_trench_depot_neutral_to_alliance + scout.auto_trench_outpost_neutral_to_alliance
	scout.auto_to_neutral = scout.auto_bump_depot_alliance_to_neutral + scout.auto_bump_outpost_alliance_to_neutral + scout.auto_trench_depot_alliance_to_neutral + scout.auto_trench_outpost_alliance_to_neutral + scout.auto_bump_depot_opponent_to_neutral + scout.auto_bump_outpost_opponent_to_neutral + scout.auto_trench_depot_opponent_to_neutral + scout.auto_trench_outpost_opponent_to_neutral
	scout.auto_to_opponent = scout.auto_bump_depot_neutral_to_opponent + scout.auto_bump_outpost_neutral_to_opponent + scout.auto_trench_depot_neutral_to_opponent + scout.auto_trench_outpost_neutral_to_opponent + scout.auto_bump_depot_alliance_to_opponent + scout.auto_bump_outpost_alliance_to_opponent + scout.auto_trench_depot_alliance_to_opponent + scout.auto_trench_outpost_alliance_to_opponent

	scout.tele_to_alliance = scout.tele_bump_depot_neutral_to_alliance + scout.tele_bump_outpost_neutral_to_alliance + scout.tele_trench_depot_neutral_to_alliance + scout.tele_trench_outpost_neutral_to_alliance
	scout.tele_to_neutral = scout.tele_bump_depot_alliance_to_neutral + scout.tele_bump_outpost_alliance_to_neutral + scout.tele_trench_depot_alliance_to_neutral + scout.tele_trench_outpost_alliance_to_neutral + scout.tele_bump_depot_opponent_to_neutral + scout.tele_bump_outpost_opponent_to_neutral + scout.tele_trench_depot_opponent_to_neutral + scout.tele_trench_outpost_opponent_to_neutral
	scout.tele_to_opponent = scout.tele_bump_depot_neutral_to_opponent + scout.tele_bump_outpost_neutral_to_opponent + scout.tele_trench_depot_neutral_to_opponent + scout.tele_trench_outpost_neutral_to_opponent + scout.tele_bump_depot_alliance_to_opponent + scout.tele_bump_outpost_alliance_to_opponent + scout.tele_trench_depot_alliance_to_opponent + scout.tele_trench_outpost_alliance_to_opponent

	scout.to_alliance = scout.auto_to_alliance + scout.tele_to_alliance
	scout.to_neutral = scout.auto_to_neutral + scout.tele_to_neutral
	scout.to_opponent = scout.auto_to_opponent + scout.tele_to_opponent

	scout.alliance_time = scout.auto_alliance_time + scout.tele_alliance_time
	scout.neutral_time = scout.auto_neutral_time + scout.tele_neutral_time
	scout.opponent_time = scout.tele_opponent_time

	// Accumulate scout data into aggregate
	Object.keys(statInfo).forEach(function(field){
		if(/^(\%|avg|count)$/.test(statInfo[field]['type'])){
			aggregate[field] = (aggregate[field]||0)+scout[field]
			var set = `${field}_set`
			aggregate[set] = aggregate[set]||[]
			aggregate[set].push(scout[field])
		}
		if(/^capability$/.test(statInfo[field]['type'])) aggregate[field] = aggregate[field]||scout[field]||0
		if(/^text$/.test(statInfo[field]['type'])) aggregate[field] = (!aggregate[field]||aggregate[field]==scout[field])?scout[field]:"various"
		if(/^heatmap$/.test(statInfo[field]['type'])) aggregate[field] += ((aggregate[field]&&scout[field])?" ":"")+scout[field]
		if(/^int-list$/.test(statInfo[field]['type'])) aggregate[field] = (aggregate[field]||[]).concat(scout[field])
	})

	aggregate.count = (aggregate.count||0)+1
	aggregate.max_score = Math.max(aggregate.max_score||0,scout.score||0)
	aggregate.min_score = Math.min(aggregate.min_score===undefined?999:aggregate.min_score,scout.score||0)

	pit.auto_paths=[]
	for (var i=1; i<=9; i++){
		var path=pit[`auto_${i}_path`]
		if (path) pit.auto_paths.push(path)
	}
}

var statInfo={
	event:{
		name: 'Event',
		type: 'text',
		fr:'Événement',
		pt:'Evento',
		zh_tw:'事件',
		tr:'Etkinlik',
		he:'מִקרֶה',
	},
	match:{
		name: "Match",
		type: "text",
		fr:'Match',
		pt:'Partida',
		zh_tw:'匹配',
		tr:'Maç',
		he:'לְהַתְאִים',
	},
	team:{
		name: "Team",
		type: "text",
		fr:'Équipe',
		pt:'Equipe',
		zh_tw:'團隊',
		tr:'Takım',
		he:'קְבוּצָה',
	},
	count:{
		name: 'Matches Scouted',
		type: 'num',
		fr:'Matchs repérés',
		pt:'Partidas observadas',
		zh_tw:'已偵察的比賽',
		tr:'İzlenen Maçlar',
		he:'גפרורים בצופים',
	},
	bricked:{
		en: 'Bricked',
		type: 'enum',
		values: {
			'some': 'bricked_some',
			'half': 'bricked_half',
			'most': 'bricked_most',
			'all': 'bricked_all'
		}
	},
	climb_method:{
		en: 'Climb Method',
		type: 'enum',
		values: {
			'rungs': 'climb_method_rungs',
			'uprights': 'climb_method_uprights',
			'flip': 'climb_method_flip'
		}
	},
	comments:{
		en: 'Comments',
		type: 'text',
		fr:'Commentaires',
		pt:'Comentários',
		zh_tw:'評論',
		tr:'Yorumlar',
		he:'הערות',
	},
	created:{
		en: 'Created',
		type: 'datetime',
		fr:'Créé',
		pt:'Criado',
		zh_tw:'已創建',
		tr:'Oluşturuldu',
		he:'נוצר',
	},
	defended:{
		en: 'Defended',
		type: 'enum',
		values: {
			'': 'defended_undefended',
			'turned-tables': 'defended_turned_tables',
			'unaffected': 'defended_unaffected',
			'slowed': 'defended_slowed',
			'slowed-greatly': 'defended_slowed_greatly'
		},
		fr:'Défendu',
		pt:'Defendido',
		zh_tw:'防守',
		tr:'Savunulan',
		he:'הגן',
	},
	defense:{
		en: 'Defense',
		type: 'enum',
		values: {
			'': 'defense_none',
			'bad': 'defense_bad',
			'ineffective': 'defense_ineffective',
			'good': 'defense_good',
			'great': 'defense_great'
		},
		fr:'Défense',
		pt:'Defesa',
		zh_tw:'防禦',
		tr:'Savunma',
		he:'הגנה',
	},
	fuel_to_alliance:{
		en: 'Fuel To Alliance',
		type: 'enum',
		values: {
			'carried': 'fuel_carried_label',
			'pushed': 'fuel_pushed_label',
			'passed': 'fuel_passed_label',
			'received': 'fuel_received_label'
		},
		fr:'Carburant à l\'alliance',
		pt:'Combustível para a aliança',
		zh_tw:'燃料聯盟',
		tr:'Yakıt İttifakı',
		he:'דלק לברית',
	},
	misses:{
		en: 'Misses',
		type: 'enum',
		values: {
			'0-1': 'misses_0_1',
			'1-10': 'misses_1_10',
			'10-30': 'misses_10_30',
			'30-60': 'misses_30_60',
			'60-100': 'misses_60_100'
		},
		fr:'Manques',
		pt:'Erros',
		zh_tw:'錯過',
		tr:'Kaçırmalar',
		he:'חִסרוֹן',
	},
	modified:{
		en: 'Modified',
		type: 'datetime',
		fr:'Modifié',
		pt:'Modificado',
		zh_tw:'已修改',
		tr:'Değiştirilmiş',
		he:'שונה',
	},
	scouter:{
		en: 'Scout',
		type: 'text',
		fr:'Éclaireur',
		pt:'Escoteiro',
		zh_tw:'童子軍',
		tr:'İzcisi',
		he:'צופה',
	},
	shoot_climbing:{
		en: 'Shoot Climbing',
		type: '%',
		fr:'Tir Escalade',
		pt:'Disparo Escalada',
		zh_tw:'射擊攀爬',
		tr:'Atış Tırmanışı',
		he:'קליעה לטיפוס',
	},
	shoot_collecting:{
		en: 'Shoot Collecting',
		type: '%',
		fr:'Tir Collecte',
		pt:'Disparo Coletando',
		zh_tw:'射擊收集',
		tr:'Atış Toplama',
		he:'קליעה לאיסוף',
	},
	shoot_move:{
		en: 'Shoot Move',
		type: '%',
		fr:'Tir Mouvement',
		pt:'Disparo Movimento',
		zh_tw:'射擊移動',
		tr:'Atış Hareketi',
		he:'קליעה תנועה',
	},
	shoot_turret:{
		en: 'Shoot Turret',
		type: '%',
		fr:'Tir Tourelle',
		pt:'Disparo Torreta',
		zh_tw:'射擊炮塔',
		tr:'Atış Kule',
		he:'קליעה צריח',
	},
	timeline:{
		en: 'Timeline',
		type: 'timeline',
		fr:'Chronologie',
		pt:'Linha do tempo',
		zh_tw:'時間軸',
		tr:'Zaman Çizelgesi',
		he:'ציר זמן',
	},
	drivetrain:{
		en: 'Drivetrain',
		type: 'enum',
		values: {
			'tank': 'robot_drivetrain_tank',
			'swerve': 'robot_drivetrain_swerve',
			'other': 'robot_drivetrain_other'
		},
		fr:'Groupe motopropulseur',
		pt:'Trem de força',
		zh_tw:'傳動系統',
		tr:'Sürüş Sistemi',
		he:'מערכת הנעה',
	},
	swerve:{
		en: 'Swerve Module Type',
		type: 'enum',
		values: {
			'swerve-drive-specialties': 'robot_swerve_sds',
			'andymark': 'robot_swerve_am',
			'rev-robotics': 'robot_swerve_rev',
			'westcoast-products': 'robot_swerve_wcp',
			'other': 'robot_swerve_other'
		},
		fr:'Type de module Swerve',
		pt:'Tipo de módulo Swerve',
		zh_tw:'Swerve 模塊類型',
		tr:'Swerve Modül Türü',
		he:'סוג מודול סרב',
	},
	motors:{
		en: 'Motor Type',
		type: 'enum',
		values: {
			'neo': 'motor_type_neo',
			'falcon_500': 'motor_type_f500',
			'full_size_cim': 'motor_type_cim',
			'kraken': 'motor_type_kraken',
			'other': 'motor_type_other'
		},
		fr:'Type de moteur',
		pt:'Tipo de motor',
		zh_tw:'電機類型',
		tr:'Motor Türü',
		he:'סוג מנוע',
	},
	wheels:{
		en: 'Wheel Type',
		type: 'enum',
		values: {
			'traction': 'wheel_type_traction',
			'high-traction': 'wheel_type_high_traction',
			'pneumatic': 'wheel_type_pneumatic',
			'mechanum': 'wheel_type_mechanum',
			'omni': 'wheel_type_omni',
			'untreaded': 'wheel_type_untreaded',
			'mixed': 'wheel_type_mixed',
			'other': 'wheel_type_other'
		},
		fr:'Type de roue',
		pt:'Tipo de roda',
		zh_tw:'車輪類型',
		tr:'Tekerlek Türü',
		he:'סוג גלגל',
	},
	auto_bump_depot_alliance_to_neutral:{
		en: 'Bump (Depot Side) Alliance To Neutral in Auto',
		type: 'avg',
		fr:'Pousser le dépôt de l\'alliance à neutre en auto',
		pt:'Empurrar o depósito da aliança para neutro no Auto',
		zh_tw:'自動將聯盟倉庫撞擊為中立',
		tr:'Otomatik Olarak İttifak Deposunu Nötr Yap',
		he:'לדחוף את מחסן הברית לנייטרלי באוטומט',
	},
	auto_bump_depot_neutral_to_alliance:{
		en: 'Bump (Depot Side) Neutral To Alliance in Auto',
		type: 'avg',
		fr:'Pousser le dépôt neutre à l\'alliance en auto',
		pt:'Empurrar o depósito neutro para a aliança no Auto',
		zh_tw:'自動將中立倉庫撞擊到聯盟',
		tr:'Otomatik Olarak Nötr Depoyu İttifak Yap',
		he:'לדחוף מחסן נייטרלי לברית באוטומט',
	},
	auto_bump_outpost_alliance_to_neutral:{
		en: 'Bump (Outpost Side) Alliance To Neutral in Auto',
		type: 'avg',
		fr:'Pousser l\'avant-poste de l\'alliance à neutre en auto',
		pt:'Empurrar o posto avançado da aliança para neutro no Auto',
		zh_tw:'自動將聯盟前哨撞擊為中立',
		tr:'Otomatik Olarak İttifak Karakolunu Nötr Yap',
		he:'לדחוף את מוצב הברית לנייטרלי באוטומט',
	},
	auto_bump_outpost_neutral_to_alliance:{
		en: 'Bump (Outpost Side) Neutral To Alliance in Auto',
		type: 'avg',
		fr:'Pousser l\'avant-poste neutre à l\'alliance en auto',
		pt:'Empurrar o posto avançado neutro para a aliança no Auto',
		zh_tw:'自動將中立前哨撞擊到聯盟',
		tr:'Otomatik Olarak Nötr Karakolu İttifak Yap',
		he:'לדחוף מוצב נייטרלי לברית באוטומט',
	},
	auto_climb_level:{
		en: 'Climb Level in Auto',
		type: 'avg',
		fr:'Niveau d\'escalade en auto',
		pt:'Nível de escalada no Auto',
		zh_tw:'自動攀爬等級',
		tr:'Otomatik Tırmanma Seviyesi',
		he:'רמת טיפוס באוטומט',
	},
	auto_climb_position:{
		en: 'Climb Position in Auto',
		type: 'heatmap',
		image: "/2026/climb-area-blue.png",
		aspect_ratio: 1,
		whiteboard_start: 0,
		whiteboard_end: 12,
		whiteboard_left: 35,
		whiteboard_right: 72,
		whiteboard_char: "A",
		whiteboard_us: true,
		fr:'Position d\'escalade en auto',
		pt:'Posição de escalada no Auto',
		zh_tw:'自動攀爬位置',
		tr:'Otomatik Tırmanma Pozisyonu',
		he:'מיקום טיפוס באוטומט',
	},
	auto_collect_depot:{
		en: 'Collected Depot in Auto',
		type: 'avg',
		fr:'Dépôt collecté en auto',
		pt:'Depósito coletado no Auto',
		zh_tw:'自動收集倉庫',
		tr:'Otomatik Olarak Depo Toplandı',
		he:'אוסף מחסן באוטומט',
	},
	auto_collect_outpost:{
		en: 'Collected Outpost in Auto',
		type: 'avg',
		fr:'Avant-poste collecté en auto',
		pt:'Posto avançado coletado no Auto',
		zh_tw:'自動收集前哨',
		tr:'Otomatik Olarak Karakol Toplandı',
		he:'אוסף מוצב באוטומט',
	},
	auto_fuel_neutral_alliance_pass:{
		en: 'Fuel Neutral Alliance Pass in Auto',
		type: 'avg',
		fr:'Passage d\'alliance neutre de carburant en auto',
		pt:'Passe de aliança neutra de combustível no Auto',
		zh_tw:'自動燃料中立聯盟通行證',
		tr:'Otomatik Nötr Yakıt İttifak Pası',
		he:'דלק נייטרלי מעבר לברית באוטומט',
	},
	auto_fuel_score:{
		en: 'Fuel Score in Auto',
		type: 'avg',
		fr:'Score de carburant en auto',
		pt:'Pontuação de combustível no Auto',
		zh_tw:'自動燃料得分',
		tr:'Otomatik Yakıt Skoru',
		he:'ציון דלק באוטומט',
	},
	auto_start:{
		name: "Location where the robot starts",
		type: "heatmap",
		image: "/2025/start-area-blue.png",
		aspect_ratio: 3.375,
		whiteboard_start: 15.5,
		whiteboard_end: 30.5,
		whiteboard_char: "□",
		whiteboard_us: true,
		fr:'Lieu de départ du robot',
		pt:'Local onde o robô começa',
		zh_tw:'機器人啟動的位置',
		tr:'Robotun başladığı yer',
		he:'המיקום שבו הרובוט מתחיל',
	},
	auto_trench_depot_alliance_to_neutral:{
		en: 'Trench (Depot Side) Alliance To Neutral in Auto',
		type: 'avg',
		fr:'Tranchée Dépôt Alliance à neutre en auto',
		pt:'Depósito de trincheira da aliança para neutro no Auto',
		zh_tw:'自動將聯盟壕溝倉庫轉為中立',
		tr:'Otomatik Olarak İttifak Hendeği Depoyu Nötr Yap',
		he:'לחפור מחסן ברית לנייטרלי באוטומט',
	},
	auto_trench_depot_neutral_to_alliance:{
		en: 'Trench (Depot Side) Neutral To Alliance in Auto',
		type: 'avg',
		fr:'Tranchée Dépôt Neutre à l\'alliance en auto',
		pt:'Depósito de trincheira neutro para a aliança no Auto',
		zh_tw:'自動將中立壕溝倉庫轉到聯盟',
		tr:'Otomatik Olarak Nötr Hendeği Depoyu İttifak Yap',
		he:'לחפור מחסן נייטרלי לברית באוטומט',
	},
	auto_trench_outpost_alliance_to_neutral:{
		en: 'Trench (Outpost Side) Alliance To Neutral in Auto',
		type: 'avg',
		fr:'Tranchée Avant-poste Alliance à neutre en auto',
		pt:'Posto avançado de trincheira da aliança para neutro no Auto',
		zh_tw:'自動將聯盟壕溝前哨轉為中立',
		tr:'Otomatik Olarak İttifak Hendeği Karakolunu Nötr Yap',
		he:'לחפור מוצב ברית לנייטרלי באוטומט',
	},
	auto_trench_outpost_neutral_to_alliance:{
		en: 'Trench (Outpost Side) Neutral To Alliance in Auto',
		type: 'avg',
		fr:'Tranchée Avant-poste Neutre à l\'alliance en auto',
		pt:'Posto avançado de trincheira neutro para a aliança no Auto',
		zh_tw:'自動將中立壕溝前哨轉到聯盟',
		tr:'Otomatik Olarak Nötr Hendeği Karakolu İttifak Yap',
		he:'לחפור מוצב נייטרלי לברית באוטומט',
	},
	defense_blocked:{
		en: 'Defense Blocked',
		type: '%',
		fr:'Défense bloquée',
		pt:'Defesa bloqueada',
		zh_tw:'防禦封鎖',
		tr:'Savunma Engellendi',
		he:'הגנה חסומה',
	},
	defense_collected:{
		en: 'Defense Collected',
		type: '%',
		fr:'Défense collectée',
		pt:'Defesa coletada',
		zh_tw:'防禦收集',
		tr:'Savunma Toplandı',
		he:'הגנה נאספה',
	},
	defense_hit:{
		en: 'Defense Hit',
		type: '%',
		fr:'Défense touchée',
		pt:'Defesa atingida',
		zh_tw:'防禦命中',
		tr:'Savunma Vuruldu',
		he:'הגנה נפגעה',
	},
	defense_pinned:{
		en: 'Defense Pinned',
		type: '%',
		fr:'Défense épinglée',
		pt:'Defesa fixada',
		zh_tw:'防禦釘住',
		tr:'Savunma Sabitlendi',
	},
	no_show:{
		en: 'No Show',
		type: '%',
		fr:'Absence',
		pt:'Não compareceu',
		zh_tw:'未出現',
		tr:'Gösteri Yok',
		he:'לא להופיע',
	},
	review_requested:{
		en: 'Review Requested',
		type: '%',
		fr:'Revue demandée',
		pt:'Revisão solicitada',
		zh_tw:'請求審查',
		tr:'İnceleme Talep Edildi',
		he:'בקשת סקירה',
	},
	tele_bump_depot_alliance_to_neutral:{
		en: 'Bump (Depot Side) Alliance To Neutral in Teleop',
		type: 'avg',
		fr:'Pousser le dépôt de l\'alliance à neutre en téléop',
		pt:'Empurrar o depósito da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟倉庫撞擊為中立',
		tr:'Teleopta İttifak Deposu Nötr Yap',
		he:'לדחוף את מחסן הברית לנייטרלי בטליאופ',
	},
	tele_bump_depot_neutral_to_alliance:{
		en: 'Bump (Depot Side) Neutral To Alliance in Teleop',
		type: 'avg',
		fr:'Pousser le dépôt neutre à l\'alliance en téléop',
		pt:'Empurrar o depósito neutro para a aliança no Teleop',
		zh_tw:'遙控將中立倉庫撞擊到聯盟',
		tr:'Teleopta Nötr Depoyu İttifak Yap',
		he:'לדחוף את מחסן נייטרלי לברית בטליאופ',
	},
	tele_bump_depot_neutral_to_opponent:{
		en: 'Bump (Depot Side) Neutral To Opponent in Teleop',
		type: 'avg',
		fr:'Pousser le dépôt neutre à l\'adversaire en téléop',
		pt:'Empurrar o depósito neutro para o oponente no Teleop',
		zh_tw:'遙控將中立倉庫撞擊到對手',
		tr:'Teleopta Nötr Depoyu Rakibe Yap',
		he:'לדחוף את מחסן נייטרלי ליריב בטליאופ',
	},
	tele_bump_depot_opponent_to_neutral:{
		en: 'Bump (Depot Side) Opponent To Neutral in Teleop',
		type: 'avg',
		fr:'Pousser le dépôt de l\'adversaire à neutre en téléop',
		pt:'Empurrar o depósito do oponente para neutro no Teleop',
		zh_tw:'遙控將對手倉庫撞擊為中立',
		tr:'Teleopta Rakip Depoyu Nötr Yap',
		he:'לדחוף את מחסן היריב לנייטרלי בטליאופ',
	},
	tele_bump_outpost_alliance_to_neutral:{
		en: 'Bump (Outpost Side) Alliance To Neutral in Teleop',
		type: 'avg',
		fr:'Pousser le avant-poste de l\'alliance à neutre en téléop',
		pt:'Empurrar o posto avançado da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟前哨撞擊為中立',
		tr:'Teleopta İttifak Karakolunu Nötr Yap',
		he:'לדחוף את מוצב הברית לנייטרלי בטליאופ',
	},
	tele_bump_outpost_neutral_to_alliance:{
		en: 'Bump (Outpost Side) Neutral To Alliance in Teleop',
		type: 'avg',
		fr:'Pousser le avant-poste neutre à l\'alliance en téléop',
		pt:'Empurrar o posto avançado neutro para a aliança no Teleop',
		zh_tw:'遙控將中立前哨撞擊到聯盟',
		tr:'Teleopta Nötr Karakolu İttifak Yap',
		he:'לדחוף את מוצב נייטרלי לברית בטליאופ',
	},
	tele_bump_outpost_neutral_to_opponent:{
		en: 'Bump (Outpost Side) Neutral To Opponent in Teleop',
		type: 'avg',
		fr:'Pousser le avant-poste neutre à l\'adversaire en téléop',
		pt:'Empurrar o posto avançado neutro para o oponente no Teleop',
		zh_tw:'遙控將中立前哨撞擊到對手',
		tr:'Teleopta Nötr Karakolu Rakibe Yap',
		he:'לדחוף את מוצב נייטרלי ליריב בטליאופ',
	},
	tele_bump_outpost_opponent_to_neutral:{
		en: 'Bump (Outpost Side) Opponent To Neutral in Teleop',
		type: 'avg',
		fr:'Pousser le avant-poste de l\'adversaire à neutre en téléop',
		pt:'Empurrar o posto avançado do oponente para neutro no Teleop',
		zh_tw:'遙控將對手前哨撞擊為中立',
		tr:'Teleopta Rakip Karakolu Nötr Yap',
		he:'לדחוף את מוצב היריב לנייטרלי בטליאופ',
	},
	tele_climb_level:{
		en: 'Climb Level in Teleop',
		type: 'avg',
		fr:'Niveau d\'escalade en téléop',
		pt:'Nível de escalada no Teleop',
		zh_tw:'遙控攀爬等級',
		tr:'Teleopta Tırmanma Seviyesi',
		he:'רמת טיפוס בטליאופ',
	},
	tele_climb_position:{
		en: 'Climb Position in Teleop',
		type: 'heatmap',
		image: "/2026/climb-area-blue.png",
		aspect_ratio: 1,
		whiteboard_start: 0,
		whiteboard_end: 12,
		whiteboard_left: 35,
		whiteboard_right: 72,
		whiteboard_char: "T",
		whiteboard_us: true,
		fr:'Position d\'escalade en téléop',
		pt:'Posição de escalada no Teleop',
		zh_tw:'遙控攀爬位置',
		tr:'Teleopta Tırmanma Pozisyonu',
		he:'מיקום טיפוס בטליאופ',
	},
	tele_fuel_alliance_dump:{
		en: 'Fuel Alliance Dump in Teleop',
		type: 'avg',
		fr:'Dépôt d\'alliance de carburant en téléop',
		pt:'Descarte de aliança de combustível no Teleop',
		zh_tw:'遙控燃料聯盟傾倒',
		tr:'Teleopta Yakıt İttifak Dökümü',
		he:'דלק ברית שפיכה בטליאופ',
	},
	tele_fuel_neutral_alliance_pass:{
		en: 'Fuel Neutral Alliance Pass in Teleop',
		type: 'avg',
		fr:'Passage d\'alliance neutre de carburant en téléop',
		pt:'Passe de aliança neutra de combustível no Teleop',
		zh_tw:'遙控燃料中立聯盟通行證',
		tr:'Teleopta Nötr Yakıt İttifak Pası',
		he:'דלק נייטרלי מעבר לברית בטליאופ',
	},
	tele_fuel_opponent_alliance_pass:{
		en: 'Fuel Opponent Alliance Pass in Teleop',
		type: 'avg',
		fr:'Passage d\'alliance adverse de carburant en téléop',
		pt:'Passe de aliança do oponente de combustível no Teleop',
		zh_tw:'遙控燃料對手聯盟通行證',
		tr:'Teleopta Rakip Yakıt İttifak Pası',
		he:'דלק יריב מעבר לברית בטליאופ',
	},
	tele_fuel_opponent_neutral_pass:{
		en: 'Fuel Opponent Neutral Pass in Teleop',
		type: 'avg',
		fr:	'Passage neutre adverse de carburant en téléop',
		pt:'Passe neutra do oponente de combustível no Teleop',
		zh_tw:'遙控燃料對手中立通行證',
		tr:'Teleopta Rakip Nötr Yakıt Pası',
		he:'דלק יריב מעבר לנייטרלי בטליאופ',
	},
	tele_fuel_outpost:{
		en: 'Fuel Outpost in Teleop',
		type: 'avg',
		fr:'Dépôt d\'avant-poste de carburant en téléop',
		pt:'Posto avançado de combustível no Teleop',
		zh_tw:'遙控燃料前哨',
		tr:'Teleopta Yakıt Karakolu',
		he:'דלק מוצב בטליאופ',
	},
	tele_fuel_score:{
		en: 'Fuel Score in Teleop',
		type: 'avg',
		fr:'Score de carburant en téléop',
		pt:'Pontuação de combustível no Teleop',
		zh_tw:'遙控燃料得分',
		tr:'Teleopta Yakıt Skoru',
		he:'ציון דלק בטליאופ',
	},
	tele_trench_depot_alliance_to_neutral:{
		en: 'Trench (Depot Side) Alliance To Neutral in Teleop',
		type: 'avg',
		fr:'Tranchée Dépôt Alliance à neutre en téléop',
		pt:'Depósito de trincheira da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟壕溝倉庫轉為中立',
		tr:'Teleopta İttifak Hendeği Deposu Nötr Yap',
		he:'לחפור מחסן ברית לנייטרלי בטליאופ',
	},
	tele_trench_depot_neutral_to_alliance:{
		en: 'Trench (Depot Side) Neutral To Alliance in Teleop',
		type: 'avg',
		fr:'Tranchée Dépôt Neutre à l\'alliance en téléop',
		pt:'Depósito de trincheira neutro para a aliança no Teleop',
		zh_tw:'遙控將中立壕溝倉庫轉到聯盟',
		tr:'Teleopta Nötr Hendeği Depoyu İttifak Yap',
		he:'לחפור מחסן נייטרלי לברית בטליאופ',
	},
	tele_trench_depot_neutral_to_opponent:{
		en: 'Trench (Depot Side) Neutral To Opponent in Teleop',
		type: 'avg',
		fr:'Tranchée Dépôt Neutre à l\'adversaire en téléop',
		pt:'Depósito de trincheira neutro para o oponente no Teleop',
		zh_tw:'遙控將中立壕溝倉庫轉到對手',
		tr:'Teleopta Nötr Hendeği Rakibe Yap',
		he:'לחפור מחסן נייטרלי ליריב בטליאופ',
	},
	tele_trench_depot_opponent_to_neutral:{
		en: 'Trench (Depot Side) Opponent To Neutral in Teleop',
		type: 'avg',
		fr:'Tranchée Dépôt de l\'adversaire à neutre en téléop',
		pt:'Depósito de trincheira do oponente para neutro no Teleop',
		zh_tw:'遙控將對手壕溝倉庫轉為中立',
		tr:'Teleopta Rakip Hendeği Nötr Yap',
		he:'לחפור מחסן יריב לנייטרלי בטליאופ',
	},
	tele_trench_outpost_alliance_to_neutral:{
		en: 'Trench (Outpost Side) Alliance To Neutral in Teleop',
		type: 'avg',
		fr:'Tranchée Avant-poste Alliance à neutre en téléop',
		pt:'Posto avançado de trincheira da aliança para neutro no Teleop',
		zh_tw:'遙控將聯盟壕溝前哨轉為中立',
		tr:'Teleopta İttifak Hendeği Karakolunu Nötr Yap',
		he:'לחפור מוצב ברית לנייטרלי בטליאופ',
	},
	tele_trench_outpost_neutral_to_alliance:{
		en: 'Trench (Outpost Side) Neutral To Alliance in Teleop',
		type: 'avg',
		fr:'Tranchée Avant-poste Neutre à l\'alliance en téléop',
		pt:'Posto avançado de trincheira neutro para a aliança no Teleop',
		zh_tw:'遙控將中立壕溝前哨轉到聯盟',
		tr:'Teleopta Nötr Hendeği Karakolu İttifak Yap',
		he:'לחפור מוצב נייטרלי לברית בטליאופ',
	},
	tele_trench_outpost_neutral_to_opponent:{
		en: 'Trench (Outpost Side) Neutral To Opponent in Teleop',
		type: 'avg',
		fr:'Tranchée Avant-poste Neutre à l\'adversaire en téléop',
		pt:'Posto avançado de trincheira neutro para o oponente no Teleop',
		zh_tw:'遙控將中立壕溝前哨轉到對手',
		tr:'Teleopta Nötr Hendeği Rakibe Yap',
		he:'לחפור מוצב נייטרלי ליריב בטליאופ',
	},
	tele_trench_outpost_opponent_to_neutral:{
		en: 'Trench (Outpost Side) Opponent To Neutral in Teleop',
		type: 'avg',
		fr:'Tranchée Avant-poste de l\'adversaire à neutre en téléop',
		pt:'Posto avançado de trincheira do oponente para neutro no Teleop',
		zh_tw:'遙控將對手壕溝前哨轉為中立',
		tr:'Teleopta Rakip Hendeği Nötr Yap',
		he:'לחפור מוצב יריב לנייטרלי בטליאופ',
	},
	auto_bump:{
		en:'Bump in Auto',
		type:'%',
		fr:'Pousser en auto',
		pt:'Empurrar no Auto',
		zh_tw:'自動撞擊',
		tr:'Otomatik Vuruş',
		he:'דחיפה באוטומט',
	},
	auto_bump_alliance:{
		en:'Bump Alliance in Auto',
		type:'%',
		fr:'Pousser l\'alliance en auto',
		pt:'Empurrar a Aliança no Auto',
		zh_tw:'自動撞擊聯盟',
		tr:'Otomatik İttifak Vuruşu',
		he:'דחיפת ברית באוטומט',
	},
	auto_bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance in Auto',
		type:'%',
		fr:'Pousser l\'alliance (dépôt) en auto',
		pt:'Empurrar Aliança (Lado Depósito) no Auto',
		zh_tw:'自動撞擊聯盟(倉庫側)',
		tr:'Otomatik İttifak Vuruşu (Depo Tarafı)',
		he:'דחיפת ברית דיפו באוטומט',
	},
	auto_bump_depot_opponent:{
		en:'Bump (Depot Side) Opponent in Auto',
		type:'%',
		fr:'Pousser l\'adversaire (dépôt) en auto',
		pt:'Empurrar Oponente (Lado Depósito) no Auto',
		zh_tw:'自動撞擊對手(倉庫側)',
		tr:'Otomatik Rakip Vuruşu (Depo Tarafı)',
		he:'דחיפת יריב דיפו באוטומט',
	},
	auto_bump_opponent:{
		en:'Bump Opponent in Auto',
		type:'%',
		fr:'Pousser l\'adversaire en auto',
		pt:'Empurrar Oponente no Auto',
		zh_tw:'自動撞擊對手',
		tr:'Otomatik Rakip Vuruşu',
		he:'דחיפת יריב באוטומט',
	},
	auto_bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance in Auto',
		type:'%',
		fr:'Pousser l\'alliance (avant-poste) en auto',
		pt:'Empurrar Aliança (Lado Posto Avançado) no Auto',
		zh_tw:'自動撞擊聯盟(前哨側)',
		tr:'Otomatik İttifak Vuruşu (Karakol Tarafı)',
		he:'דחיפת ברית חוסן באוטומט',
	},
	auto_bump_outpost_opponent:{
		en:'Bump (Outpost Side) Opponent in Auto',
		type:'%',
		fr:'Pousser l\'adversaire (avant-poste) en auto',
		pt:'Empurrar Oponente (Lado Posto Avançado) no Auto',
		zh_tw:'自動撞擊對手(前哨側)',
		tr:'Otomatik Rakip Vuruşu (Karakol Tarafı)',
		he:'דחיפת יריב חוסן באוטומט',
	},
	auto_score:{
		en:'Score in Auto',
		type:'avg',
		fr:'Pointage en auto',
		pt:'Pontuação no Auto',
		zh_tw:'自動得分',
		tr:'Otomatik Skor',
		he:'ציון באוטומט',
	},
	auto_to_alliance:{
		en:'To Alliance in Auto',
		type:'%',
		fr:'Vers l\'alliance en auto',
		pt:'Para a Aliança no Auto',
		zh_tw:'自動進入聯盟',
		tr:'Otomatik İttifak Hedefi',
		he:'לברית באוטומט',
	},
	auto_to_neutral:{
		en:'To Neutral in Auto',
		type:'%',
		fr:'Vers le neutre en auto',
		pt:'Para Neutro no Auto',
		zh_tw:'自動進入中立',
		tr:'Otomatik Nötr Hedefi',
		he:'לנייטרלי באוטומט',
	},
	auto_to_opponent:{
		en:'To Opponent in Auto',
		type:'%',
		fr:'Vers l\'adversaire en auto',
		pt:'Para o Oponente no Auto',
		zh_tw:'自動進入對手',
		tr:'Otomatik Rakip Hedefi',
		he:'ליריב באוטומט',
	},
	auto_tower_score:{
		en:'Tower Score in Auto',
		type:'avg',
		fr:'Pointage de tour en auto',
		pt:'Pontuação da Torre no Auto',
		zh_tw:'自動塔樓得分',
		tr:'Otomatik Kule Skoru',
		he:'ציון מגדל באוטומט',
	},
	auto_trench:{
		en:'Trench in Auto',
		type:'%',
		fr:'Tranchée en auto',
		pt:'Trincheira no Auto',
		zh_tw:'自動壕溝',
		tr:'Otomatik Hendeği',
		he:'תעלה באוטומט',
	},
	auto_trench_alliance:{
		en:'Trench Alliance in Auto',
		type:'%',
		fr:'Tranchée alliance en auto',
		pt:'Trincheira Aliança no Auto',
		zh_tw:'自動壕溝聯盟',
		tr:'Otomatik İttifak Hendeği',
		he:'תעלת ברית באוטומט',
	},
	auto_trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance in Auto',
		type:'%',
		fr:'Tranchée alliance (dépôt) en auto',
		pt:'Trincheira Aliança (Lado Depósito) no Auto',
		zh_tw:'自動壕溝聯盟(倉庫側)',
		tr:'Otomatik İttifak Hendeği (Depo Tarafı)',
		he:'תעלת ברית דיפו באוטומט',
	},
	auto_trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent in Auto',
		type:'%',
		fr:'Tranchée adversaire (dépôt) en auto',
		pt:'Trincheira Oponente (Lado Depósito) no Auto',
		zh_tw:'自動壕溝對手(倉庫側)',
		tr:'Otomatik Rakip Hendeği (Depo Tarafı)',
		he:'תעלת יריב דיפו באוטומט',
	},
	auto_trench_opponent:{
		en:'Trench Opponent in Auto',
		type:'%',
		fr:'Tranchée adversaire en auto',
		pt:'Trincheira Oponente no Auto',
		zh_tw:'自動壕溝對手',
		tr:'Otomatik Rakip Hendeği',
		he:'תעלת יריב באוטומט',
	},
	auto_trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance in Auto',
		type:'%',
		fr:'Tranchée alliance (avant-poste) en auto',
		pt:'Trincheira Aliança (Lado Posto Avançado) no Auto',
		zh_tw:'自動壕溝聯盟(前哨側)',
		tr:'Otomatik İttifak Hendeği (Karakol Tarafı)',
		he:'תעלת ברית חוסן באוטומט',
	},
	auto_trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent in Auto',
		type:'%',
		fr:'Tranchée adversaire (avant-poste) en auto',
		pt:'Trincheira Oponente (Lado Posto Avançado) no Auto',
		zh_tw:'自動壕溝對手(前哨側)',
		tr:'Otomatik Rakip Hendeği (Karakol Tarafı)',
		he:'תעלת יריב חוסן באוטומט',
	},
	bump:{
		en:'Bump',
		type:'%',
		fr:'Pousser',
		pt:'Empurrar',
		zh_tw:'撞擊',
		tr:'Vuruş',
		he:'דחיפה',
	},
	bump_alliance:{
		en:'Bump Alliance',
		type:'%',
		fr:'Pousser l\'alliance',
		pt:'Empurrar a Aliança',
		zh_tw:'撞擊聯盟',
		tr:'İttifak Vuruşu',
		he:'דחיפת ברית',
	},
	bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance',
		type:'%',
		fr:'Pousser l\'alliance (dépôt)',
		pt:'Empurrar Aliança (Lado Depósito)',
		zh_tw:'撞擊聯盟(倉庫側)',
		tr:'İttifak Vuruşu (Depo Tarafı)',
		he:'דחיפת ברית דיפו',
	},
	bump_depot_alliance_to_neutral:{
		en:'Bump (Depot Side) Alliance To Neutral',
		type:'%',
		fr:'Pousser alliance vers neutre (dépôt)',
		pt:'Empurrar Aliança para Neutro (Lado Depósito)',
		zh_tw:'撞擊聯盟至中立(倉庫側)',
		tr:'İttifak Vuruşunu Nötr Yap (Depo Tarafı)',
		he:'דחיפת ברית לנייטרלי דיפו',
	},
	bump_depot_neutral_to_alliance:{
		en:'Bump (Depot Side) Neutral To Alliance',
		type:'%',
		fr:'Pousser neutre vers alliance (dépôt)',
		pt:'Empurrar Neutro para Aliança (Lado Depósito)',
		zh_tw:'撞擊中立至聯盟(倉庫側)',
		tr:'Nötr Vuruşunu İttifak Yap (Depo Tarafı)',
		he:'דחיפת נייטרלי לברית דיפו',
	},
	bump_depot_opponent:{
		en:'Bump (Depot Side) Opponent',
		type:'%',
		fr:'Pousser l\'adversaire (dépôt)',
		pt:'Empurrar Oponente (Lado Depósito)',
		zh_tw:'撞擊對手(倉庫側)',
		tr:'Rakip Vuruşu (Depo Tarafı)',
		he:'דחיפת יריב דיפו',
	},
	bump_opponent:{
		en:'Bump Opponent',
		type:'%',
		fr:'Pousser l\'adversaire',
		pt:'Empurrar Oponente',
		zh_tw:'撞擊對手',
		tr:'Rakip Vuruşu',
		he:'דחיפת יריב',
	},
	bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance',
		type:'%',
		fr:'Pousser l\'alliance (avant-poste)',
		pt:'Empurrar Aliança (Lado Posto Avançado)',
		zh_tw:'撞擊聯盟(前哨側)',
		tr:'İttifak Vuruşu (Karakol Tarafı)',
		he:'דחיפת ברית חוסן',
	},
	bump_outpost_alliance_to_neutral:{
		en:'Bump (Outpost Side) Alliance To Neutral',
		type:'%',
		fr:'Pousser alliance vers neutre (avant-poste)',
		pt:'Empurrar Aliança para Neutro (Lado Posto Avançado)',
		zh_tw:'撞擊聯盟至中立(前哨側)',
		tr:'İttifak Vuruşunu Nötr Yap (Karakol Tarafı)',
		he:'דחיפת ברית לנייטרלי חוסן',
	},
	bump_outpost_neutral_to_alliance:{
		en:'Bump (Outpost Side) Neutral To Alliance',
		type:'%',
		fr:'Pousser neutre vers alliance (avant-poste)',
		pt:'Empurrar Neutro para Aliança (Lado Posto Avançado)',
		zh_tw:'撞擊中立至聯盟(前哨側)',
		tr:'Nötr Vuruşunu İttifak Yap (Karakol Tarafı)',
		he:'דחיפת נייטרלי לברית חוסן',
	},
	bump_outpost_opponent:{
		en:'Bump (Outpost Side) Opponent',
		type:'%',
		fr:'Pousser l\'adversaire (avant-poste)',
		pt:'Empurrar Oponente (Lado Posto Avançado)',
		zh_tw:'撞擊對手(前哨側)',
		tr:'Rakip Vuruşu (Karakol Tarafı)',
		he:'דחיפת יריב חוסן',
	},
	climb_level:{
		en:'Climb Level',
		type:'%',
		fr:'Niveau d\'escalade',
		pt:'Nível de Escalada',
		zh_tw:'攀爬等級',
		tr:'Tırmanma Seviyesi',
		he:'רמת טיפוס',
	},
	collect_depot:{
		en:'Collected Depot',
		type:'avg',
		fr:'Dépôt collecté',
		pt:'Depósito Coletado',
		zh_tw:'收集倉庫',
		tr:'Depo Toplandı',
		he:'אוסף מחסן',
	},
	collect_outpost:{
		en:'Collected Outpost',
		type:'avg',
		fr:'Avant-poste collecté',
		pt:'Posto Avançado Coletado',
		zh_tw:'收集前哨',
		tr:'Karakol Toplandı',
		he:'אוסף מוצב',
	},
	fuel_neutral_alliance_pass:{
		en:'Fuel Neutral Alliance Pass',
		type:'%',
		fr:'Passage alliance neutre de carburant',
		pt:'Passe de Aliança Neutra de Combustível',
		zh_tw:'燃料中立聯盟通行證',
		tr:'Nötr Yakıt İttifak Pası',
		he:'דלק נייטרלי מעבר לברית',
	},
	fuel_score:{
		en:'Fuel Score',
		type:'avg',
		fr:'Pointage de carburant',
		pt:'Pontuação de Combustível',
		zh_tw:'燃料得分',
		tr:'Yakıt Skoru',
		he:'ציון דלק',
	},
	auto_fuel_output:{
		en:'Fuel Output to Target in Auto',
		type:'avg',
		fr:'Sortie de carburant en auto',
		pt:'Saída de Combustível no Auto',
		zh_tw:'自動燃料輸出',
		tr:'Otomatik Yakıt Çıkışı',
		he:'פלט דלק באוטומט',
	},
	tele_fuel_output:{
		en:'Fuel Output to Target in Teleop',
		type:'avg',
		fr:'Sortie de carburant en téléop',
		pt:'Saída de Combustível no Teleop',
		zh_tw:'遙控燃料輸出',
		tr:'Teleopta Yakıt Çıkışı',
		he:'פלט דלק בטליאופ',
	},
	fuel_output:{
		en:'Fuel Output to Target',
		type:'avg',
		fr:'Sortie de carburant',
		pt:'Saída de Combustível',
		zh_tw:'燃料輸出',
		tr:'Yakıt Çıkışı',
		he:'פלט דלק',
	},
	max_score:{
		en:'Max Score',
		type:'minmax',
		fr:'Pointage Maximum',
		pt:'Pontuação Máxima',
		zh_tw:'最大得分',
		tr:'Maksimum Skor',
		he:'ציון מקסימום',
	},
	min_score:{
		en:'Min Score',
		type:'minmax',
		fr:'Pointage Minimum',
		pt:'Pontuação Mínima',
		zh_tw:'最小得分',
		tr:'Minimum Skor',
		he:'ציון מינימום',
	},
	score:{
		en:'Score',
		type:'avg',
		fr:'Pointage',
		pt:'Pontuação',
		zh_tw:'得分',
		tr:'Skor',
		he:'ציון',
	},
	tele_bump:{
		en:'Bump in Teleop',
		type:'%',
		fr:'Pousser en téléop',
		pt:'Empurrar no Teleop',
		zh_tw:'遙控撞擊',
		tr:'Teleopta Vuruş',
		he:'דחיפה בטליאופ',
	},
	tele_bump_alliance:{
		en:'Bump Alliance in Teleop',
		type:'%',
		fr:'Pousser l\'alliance en téléop',
		pt:'Empurrar a Aliança no Teleop',
		zh_tw:'遙控撞擊聯盟',
		tr:'Teleopta İttifak Vuruşu',
		he:'דחיפת ברית בטליאופ',
	},
	tele_bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance in Teleop',
		type:'%',
		fr:'Pousser l\'alliance (dépôt) en téléop',
		pt:'Empurrar Aliança (Lado Depósito) no Teleop',
		zh_tw:'遙控撞擊聯盟(倉庫側)',
		tr:'Teleopta İttifak Vuruşu (Depo Tarafı)',
		he:'דחיפת ברית דיפו בטליאופ',
	},
	tele_bump_depot_opponent:{
		en:'Bump (Depot Side) Opponent in Teleop',
		type:'%',
		fr:'Pousser l\'adversaire (dépôt) en téléop',
		pt:'Empurrar Oponente (Lado Depósito) no Teleop',
		zh_tw:'遙控撞擊對手(倉庫側)',
		tr:'Teleopta Rakip Vuruşu (Depo Tarafı)',
		he:'דחיפת יריב דיפו בטליאופ',
	},
	tele_bump_opponent:{
		en:'Bump Opponent in Teleop',
		type:'%',
		fr:'Pousser l\'adversaire en téléop',
		pt:'Empurrar Oponente no Teleop',
		zh_tw:'遙控撞擊對手',
		tr:'Teleopta Rakip Vuruşu',
		he:'דחיפת יריב בטליאופ',
	},
	tele_bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance in Teleop',
		type:'%',
		fr:'Pousser l\'alliance (avant-poste) en téléop',
		pt:'Empurrar Aliança (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控撞擊聯盟(前哨側)',
		tr:'Teleopta İttifak Vuruşu (Karakol Tarafı)',
		he:'דחיפת ברית חוסן בטליאופ',
	},
	tele_bump_outpost_opponent:{
		en:'Bump (Outpost Side) Opponent in Teleop',
		type:'%',
		fr:'Pousser l\'adversaire (avant-poste) en téléop',
		pt:'Empurrar Oponente (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控撞擊對手(前哨側)',
		tr:'Teleopta Rakip Vuruşu (Karakol Tarafı)',
		he:'דחיפת יריב חוסן בטליאופ',
	},
	tele_score:{
		en:'Score in Teleop',
		type:'avg',
		fr:'Pointage en téléop',
		pt:'Pontuação no Teleop',
		zh_tw:'遙控得分',
		tr:'Teleopta Skor',
		he:'ציון בטליאופ',
	},
	tele_to_alliance:{
		en:'To Alliance in Teleop',
		type:'%',
		fr:'Vers l\'alliance en téléop',
		pt:'Para a Aliança no Teleop',
		zh_tw:'遙控進入聯盟',
		tr:'Teleopta İttifak Hedefi',
		he:'לברית בטליאופ',
	},
	tele_to_neutral:{
		en:'To Neutral in Teleop',
		type:'%',
		fr:'Vers le neutre en téléop',
		pt:'Para Neutro no Teleop',
		zh_tw:'遙控進入中立',
		tr:'Teleopta Nötr Hedefi',
		he:'לנייטרלי בטליאופ',
	},
	tele_to_opponent:{
		en:'To Opponent in Teleop',
		type:'%',
		fr:'Vers l\'adversaire en téléop',
		pt:'Para o Oponente no Teleop',
		zh_tw:'遙控進入對手',
		tr:'Teleopta Rakip Hedefi',
		he:'ליריב בטליאופ',
	},
	tele_tower_score:{
		en:'Tower Score in Teleop',
		type:'avg',
		fr:'Pointage de tour en téléop',
		pt:'Pontuação da Torre no Teleop',
		zh_tw:'遙控塔樓得分',
		tr:'Teleopta Kule Skoru',
		he:'ציון מגדל בטליאופ',
	},
	tele_trench:{
		en:'Trench in Teleop',
		type:'%',
		fr:'Tranchée en téléop',
		pt:'Trincheira no Teleop',
		zh_tw:'遙控壕溝',
		tr:'Teleopta Hendeği',
		he:'תעלה בטליאופ',
	},
	tele_trench_alliance:{
		en:'Trench Alliance in Teleop',
		type:'%',
		fr:'Tranchée alliance en téléop',
		pt:'Trincheira Aliança no Teleop',
		zh_tw:'遙控壕溝聯盟',
		tr:'Teleopta İttifak Hendeği',
		he:'תעלת ברית בטליאופ',
	},
	tele_trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance in Teleop',
		type:'%',
		fr:'Tranchée alliance (dépôt) en téléop',
		pt:'Trincheira Aliança (Lado Depósito) no Teleop',
		zh_tw:'遙控壕溝聯盟(倉庫側)',
		tr:'Teleopta İttifak Hendeği (Depo Tarafı)',
		he:'תעלת ברית דיפו בטליאופ',
	},
	tele_trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent in Teleop',
		type:'%',
		fr:'Tranchée adversaire (dépôt) en téléop',
		pt:'Trincheira Oponente (Lado Depósito) no Teleop',
		zh_tw:'遙控壕溝對手(倉庫側)',
		tr:'Teleopta Rakip Hendeği (Depo Tarafı)',
		he:'תעלת יריב דיפו בטליאופ',
	},
	tele_trench_opponent:{
		en:'Trench Opponent in Teleop',
		type:'%',
		fr:'Tranchée adversaire en téléop',
		pt:'Trincheira Oponente no Teleop',
		zh_tw:'遙控壕溝對手',
		tr:'Teleopta Rakip Hendeği',
		he:'תעלת יריב בטליאופ',
	},
	tele_trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance in Teleop',
		type:'%',
		fr:'Tranchée alliance (avant-poste) en téléop',
		pt:'Trincheira Aliança (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控壕溝聯盟(前哨側)',
		tr:'Teleopta İttifak Hendeği (Karakol Tarafı)',
		he:'תעלת ברית חוסן בטליאופ',
	},
	tele_trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent in Teleop',
		type:'%',
		fr:'Tranchée adversaire (avant-poste) en téléop',
		pt:'Trincheira Oponente (Lado Posto Avançado) no Teleop',
		zh_tw:'遙控壕溝對手(前哨側)',
		tr:'Teleopta Rakip Hendeği (Karakol Tarafı)',
		he:'תעלת יריב חוסן בטליאופ',
	},
	to_alliance:{
		en:'To Alliance',
		type:'%',
		fr:'Vers l\'alliance',
		pt:'Para a Aliança',
		zh_tw:'進入聯盟',
		tr:'İttifak Hedefi',
		he:'לברית',
	},
	to_neutral:{
		en:'To Neutral',
		type:'%',
		fr:'Vers le neutre',
		pt:'Para Neutro',
		zh_tw:'進入中立',
		tr:'Nötr Hedefi',
		he:'לנייטרלי',
	},
	to_opponent:{
		en:'To Opponent',
		type:'%',
		fr:'Vers l\'adversaire',
		pt:'Para o Oponente',
		zh_tw:'進入對手',
		tr:'Rakip Hedefi',
		he:'ליריב',
	},
	tower_score:{
		en:'Tower Score',
		type:'avg',
		fr:'Pointage de tour',
		pt:'Pontuação da Torre',
		zh_tw:'塔樓得分',
		tr:'Kule Skoru',
		he:'ציון מגדל',
	},
	trench:{
		en:'Trench',
		type:'%',
		fr:'Tranchée',
		pt:'Trincheira',
		zh_tw:'壕溝',
		tr:'Hendeği',
		he:'תעלה',
	},
	trench_alliance:{
		en:'Trench Alliance',
		type:'%',
		fr:'Tranchée alliance',
		pt:'Trincheira Aliança',
		zh_tw:'壕溝聯盟',
		tr:'İttifak Hendeği',
		he:'תעלת ברית',
	},
	trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance',
		type:'%',
		fr:'Tranchée alliance (dépôt)',
		pt:'Trincheira Aliança (Lado Depósito)',
		zh_tw:'壕溝聯盟(倉庫側)',
		tr:'İttifak Hendeği (Depo Tarafı)',
		he:'תעלת ברית דיפו',
	},
	trench_depot_alliance_to_neutral:{
		en:'Trench (Depot Side) Alliance To Neutral',
		type:'%',
		fr:'Tranchée alliance vers neutre (dépôt)',
		pt:'Trincheira Aliança para Neutro (Lado Depósito)',
		zh_tw:'壕溝聯盟至中立(倉庫側)',
		tr:'İttifak Hendeğini Nötr Yap (Depo Tarafı)',
		he:'תעלת ברית לנייטרלי דיפו',
	},
	trench_depot_neutral_to_alliance:{
		en:'Trench (Depot Side) Neutral To Alliance',
		type:'%',
		fr:'Tranchée neutre vers alliance (dépôt)',
		pt:'Trincheira Neutro para Aliança (Lado Depósito)',
		zh_tw:'壕溝中立至聯盟(倉庫側)',
		tr:'Nötr Hendeğini İttifak Yap (Depo Tarafı)',
		he:'תעלת נייטרלי לברית דיפו',
	},
	trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent',
		type:'%',
		fr:'Tranchée adversaire (dépôt)',
		pt:'Trincheira Oponente (Lado Depósito)',
		zh_tw:'壕溝對手(倉庫側)',
		tr:'Rakip Hendeği (Depo Tarafı)',
		he:'תעלת יריב דיפו',
	},
	trench_opponent:{
		en:'Trench Opponent',
		type:'%',
		fr:'Tranchée adversaire',
		pt:'Trincheira Oponente',
		zh_tw:'壕溝對手',
		tr:'Rakip Hendeği',
		he:'תעלת יריב',
	},
	trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance',
		type:'%',
		fr:'Tranchée alliance (avant-poste)',
		pt:'Trincheira Aliança (Lado Posto Avançado)',
		zh_tw:'壕溝聯盟(前哨側)',
		tr:'İttifak Hendeği (Karakol Tarafı)',
		he:'תעלת ברית חוסן',
	},
	trench_outpost_alliance_to_neutral:{
		en:'Trench (Outpost Side) Alliance To Neutral',
		type:'%',
		fr:'Tranchée alliance vers neutre (avant-poste)',
		pt:'Trincheira Aliança para Neutro (Lado Posto Avançado)',
		zh_tw:'壕溝聯盟至中立(前哨側)',
		tr:'İttifak Hendeğini Nötr Yap (Karakol Tarafı)',
		he:'תעלת ברית לנייטרלי חוסן',
	},
	trench_outpost_neutral_to_alliance:{
		en:'Trench (Outpost Side) Neutral To Alliance',
		type:'%',
		fr:'Tranchée neutre vers alliance (avant-poste)',
		pt:'Trincheira Neutro para Aliança (Lado Posto Avançado)',
		zh_tw:'壕溝中立至聯盟(前哨側)',
		tr:'Nötr Hendeğini İttifak Yap (Karakol Tarafı)',
		he:'תעלת נייטרלי לברית חוסן',
	},
	trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent',
		type:'%',
		fr:'Tranchée adversaire (avant-poste)',
		pt:'Trincheira Oponente (Lado Posto Avançado)',
		zh_tw:'壕溝對手(前哨側)',
		tr:'Rakip Hendeği (Karakol Tarafı)',
		he:'תעלת יריב חוסן',
	},
	zone_change:{
		en:'Zone Change',
		type:'%',
		fr:'Changement de zone',
		pt:'Mudança de Zona',
		zh_tw:'區域變化',
		tr:'Bölge Değişimi',
		he:'שינוי אזור',
	},
	auto_alliance_time:{
		en:'Alliance Time in Auto',
		type:'avg',
		fr:'Temps alliance en auto',
		pt:'Tempo de Aliança no Auto',
		zh_tw:'自動聯盟時間',
		tr:'Otomatik İttifak Zamanı',
		he:'זמן ברית באוטומט',
	},
	auto_neutral_time:{
		en:'Neutral Time in Auto',
		type:'avg',
		fr:'Temps neutre en auto',
		pt:'Tempo Neutro no Auto',
		zh_tw:'自動中立時間',
		tr:'Otomatik Nötr Zamanı',
		he:'זמן נייטרלי באוטומט',
	},
	tele_alliance_time:{
		en:'Alliance Time in Teleop',
		type:'avg',
		fr:'Temps alliance en téléop',
		pt:'Tempo de Aliança no Teleop',
		zh_tw:'遙控聯盟時間',
		tr:'Teleopta İttifak Zamanı',
		he:'זמן ברית בטליאופ',
	},
	tele_neutral_time:{
		en:'Neutral Time in Teleop',
		type:'avg',
		fr:'Temps neutre en téléop',
		pt:'Tempo Neutro no Teleop',
		zh_tw:'遙控中立時間',
		tr:'Teleopta Nötr Zamanı',
		he:'זמן נייטרלי בטליאופ',
	},
	tele_opponent_time:{
		en:'Opponent Time in Teleop',
		type:'avg',
		fr:'Temps adversaire en téléop',
		pt:'Tempo do Oponente no Teleop',
		zh_tw:'遙控對手時間',
		tr:'Teleopta Rakip Zamanı',
		he:'זמן יריב בטליאופ',
	},
	alliance_time:{
		en:'Alliance Time',
		type:'avg',
		fr:'Temps d\'alliance',
		pt:'Tempo de aliança',
		zh_tw:'聯盟時間',
		tr:'İttifak Zamanı',
		he:'זמן ברית',
	},
	neutral_time:{
		en:'Neutral Time',
		type:'avg',
		fr:'Temps neutre',
		pt:'Tempo neutro',
		zh_tw:'中立時間',
		tr:'Nötr Zaman',
		he:'זמן ניטרלי',
	},
	opponent_time:{
		en:'Opponent Time',
		type:'avg',
		fr:'Temps adversaire',
		pt:'Tempo do oponente',
		zh_tw:'對手時間',
		tr:'Rakip Zamanı',
		he:'זמן יריב',
	},
	auto_paths:{
		name: "Auto Paths",
		type: "pathlist",
		aspect_ratio: .916,
		whiteboard_start: 0,
		whiteboard_end: 55,
		whiteboard_us: true,
		source: "pit",
		fr:'Trajectoires automatiques',
		pt:'Caminhos Automáticos',
		zh_tw:'自動路徑',
		tr:'Otomatik Yollar',
		he:'נתיבים אוטומטיים',
	},
	shooting_locations:{
		en:'Defendable Shooting Locations',
		type: "heatmap",
		aspect_ratio: .916,
		whiteboard_start: 0,
		whiteboard_end: 30,
		whiteboard_us: false,
		whiteboard_char: 'D',
		fr:'Emplacements de tir défendables',
		pt:'Locais de Tiro Defensáveis',
		zh_tw:'可防守射擊位置',
		tr:'Savunulabilir Atış Konumları',
		he:'מיקומי ירי שניתן להגן עליהם',
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
		data:["auto_score","tele_score"],
	},
	"Fuel to Target":{
		graph:"stacked",
		tr:'Hedefe Yakıt',
		pt:'Combustível para o Alvo',
		fr:'Carburant vers la cible',
		he:'דלק למטרה',
		zh_tw:'燃料到目標',
		data:["auto_fuel_output","tele_fuel_output"],
	},
	"Fuel vs Climb":{
		graph:"stacked",
		data:["fuel_score","tower_score"],
		tr:'Yakıt vs Tırmanış',
		pt:'Combustível vs Escalada',
		fr:'Carburant vs Escalade',
		he:'דלק לעומת טיפוס',
		zh_tw:'燃料與攀登',
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
		data:["max_score","score","min_score"],
	},
	"Fuel to Target":{
		graph:"boxplot",
		tr:'Hedefe Yakıt',
		pt:'Combustível para o Alvo',
		fr:'Carburant vers la cible',
		he:'דלק למטרה',
		zh_tw:'燃料到目標',
		data:["fuel_output"],
	},
	"Game Stage":{
		graph:"stacked",
		tr:'Oyun Aşaması',
		pt:'Estágio do jogo',
		fr:'Phase de jeu',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
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
	},
	"Game Stage":{
		tr:'Fase do Jogo',
		he:'שלב המשחק',
		zh_tw:'遊戲舞台',
		pt:'Fase do Jogo',
		fr:'Phase de jeu',
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
	},
}

var whiteboardStamps=[]

var fieldRotationalSymmetry=true

window.whiteboard_aspect_ratio=2.18

var whiteboardStats=[
	"score",
	"auto_score",
	"tele_score",
	"fuel_output",
	"tele_alliance_time",
	"tele_neutral_time",
	"tele_opponent_time",
	"shooting_locations",
	"auto_climb_position",
	"tele_climb_position",
	"auto_start",
	"auto_paths",
]

// https://www.postman.com/firstrobotics/workspace/frc-fms-public-published-workspace/example/13920602-f345156c-f083-4572-8d4a-bee22a3fdea1
var fmsMapping=[
]

function showPitScouting(el,team){
	promisePitScouting().then(pitData => {
		applyTranslations()
	})

}

function showSubjectiveScouting(el,team){
	promiseSubjectiveScouting().then(subjectiveData => {
		applyTranslations()
	})
}

var importFunctions={
}
