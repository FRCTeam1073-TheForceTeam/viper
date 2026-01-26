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

	scout.fuel_score = scout.auto_fuel_score + scout.tele_fuel_score
	scout.bump_depot_alliance_to_neutral = scout.auto_bump_depot_alliance_to_neutral + scout.tele_bump_depot_alliance_to_neutral
	scout.bump_depot_neutral_to_alliance = scout.auto_bump_depot_neutral_to_alliance + scout.tele_bump_depot_neutral_to_alliance
	scout.bump_outpost_alliance_to_neutral = scout.auto_bump_outpost_alliance_to_neutral + scout.tele_bump_outpost_alliance_to_neutral
	scout.bump_outpost_neutral_to_alliance = scout.auto_bump_outpost_neutral_to_alliance + scout.tele_bump_outpost_neutral_to_alliance
	scout.climb_level = scout.auto_climb_level + scout.tele_climb_level
	scout.climb_position = scout.auto_climb_position + scout.tele_climb_position
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
		type: '%',
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
		en: 'Start in Auto',
		type: '%',
		fr:'Démarrer en auto',
		pt:'Iniciar no Auto',
		zh_tw:'自動開始',
		tr:'Otomatik Başlangıç',
		he:'התחל באוטומט',
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
		type: '%',
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
	},
	auto_bump_alliance:{
		en:'Bump Alliance in Auto',
		type:'%',
	},
	auto_bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance in Auto',
		type:'%',
	},
	auto_bump_depot_opponent:{
		en:'Bump (Depot Side) Opponent in Auto',
		type:'%',
	},
	auto_bump_opponent:{
		en:'Bump Opponent in Auto',
		type:'%',
	},
	auto_bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance in Auto',
		type:'%',
	},
	auto_bump_outpost_opponent:{
		en:'Bump (Outpost Side) Opponent in Auto',
		type:'%',
	},
	auto_score:{
		en:'Score in Auto',
		type:'avg',
	},
	auto_to_alliance:{
		en:'To Alliance in Auto',
		type:'%',
	},
	auto_to_neutral:{
		en:'To Neutral in Auto',
		type:'%',
	},
	auto_to_opponent:{
		en:'To Opponent in Auto',
		type:'%',
	},
	auto_tower_score:{
		en:'Tower Score in Auto',
		type:'avg',
	},
	auto_trench:{
		en:'Trench in Auto',
		type:'%',
	},
	auto_trench_alliance:{
		en:'Trench Alliance in Auto',
		type:'%',
	},
	auto_trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance in Auto',
		type:'%',
	},
	auto_trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent in Auto',
		type:'%',
	},
	auto_trench_opponent:{
		en:'Trench Opponent in Auto',
		type:'%',
	},
	auto_trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance in Auto',
		type:'%',
	},
	auto_trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent in Auto',
		type:'%',
	},
	bump:{
		en:'Bump',
		type:'%',
	},
	bump_alliance:{
		en:'Bump Alliance',
		type:'%',
	},
	bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance',
		type:'%',
	},
	bump_depot_alliance_to_neutral:{
		en:'Bump (Depot Side) Alliance To Neutral',
		type:'%',
	},
	bump_depot_neutral_to_alliance:{
		en:'Bump (Depot Side) Neutral To Alliance',
		type:'%',
	},
	bump_depot_opponent:{
		en:'Bump (Depot Side) Opponent',
		type:'%',
	},
	bump_opponent:{
		en:'Bump Opponent',
		type:'%',
	},
	bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance',
		type:'%',
	},
	bump_outpost_alliance_to_neutral:{
		en:'Bump (Outpost Side) Alliance To Neutral',
		type:'%',
	},
	bump_outpost_neutral_to_alliance:{
		en:'Bump (Outpost Side) Neutral To Alliance',
		type:'%',
	},
	bump_outpost_opponent:{
		en:'Bump (Outpost Side) Opponent',
		type:'%',
	},
	climb_level:{
		en:'Climb Level',
		type:'%',
	},
	climb_position:{
		en:'Climb Position',
		type:'%',
	},
	collect_depot:{
		en:'Collected Depot',
		type:'avg',
	},
	collect_outpost:{
		en:'Collected Outpost',
		type:'avg',
	},
	fuel_neutral_alliance_pass:{
		en:'Fuel Neutral Alliance Pass',
		type:'%',
	},
	fuel_score:{
		en:'Fuel Score',
		type:'avg',
	},
	max_score:{
		en:'Max Score',
		type:'minmax',
	},
	min_score:{
		en:'Min Score',
		type:'minmax',
	},
	score:{
		en:'Score',
		type:'avg',
	},
	tele_bump:{
		en:'Bump in Teleop',
		type:'%',
	},
	tele_bump_alliance:{
		en:'Bump Alliance in Teleop',
		type:'%',
	},
	tele_bump_depot_alliance:{
		en:'Bump (Depot Side) Alliance in Teleop',
		type:'%',
	},
	tele_bump_depot_opponent:{
		en:'Bump (Depot Side) Opponent in Teleop',
		type:'%',
	},
	tele_bump_opponent:{
		en:'Bump Opponent in Teleop',
		type:'%',
	},
	tele_bump_outpost_alliance:{
		en:'Bump (Outpost Side) Alliance in Teleop',
		type:'%',
	},
	tele_bump_outpost_opponent:{
		en:'Bump (Outpost Side) Opponent in Teleop',
		type:'%',
	},
	tele_score:{
		en:'Score in Teleop',
		type:'avg',
	},
	tele_to_alliance:{
		en:'To Alliance in Teleop',
		type:'%',
	},
	tele_to_neutral:{
		en:'To Neutral in Teleop',
		type:'%',
	},
	tele_to_opponent:{
		en:'To Opponent in Teleop',
		type:'%',
	},
	tele_tower_score:{
		en:'Tower Score in Teleop',
		type:'avg',
	},
	tele_trench:{
		en:'Trench in Teleop',
		type:'%',
	},
	tele_trench_alliance:{
		en:'Trench Alliance in Teleop',
		type:'%',
	},
	tele_trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance in Teleop',
		type:'%',
	},
	tele_trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent in Teleop',
		type:'%',
	},
	tele_trench_opponent:{
		en:'Trench Opponent in Teleop',
		type:'%',
	},
	tele_trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance in Teleop',
		type:'%',
	},
	tele_trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent in Teleop',
		type:'%',
	},
	to_alliance:{
		en:'To Alliance',
		type:'%',
	},
	to_neutral:{
		en:'To Neutral',
		type:'%',
	},
	to_opponent:{
		en:'To Opponent',
		type:'%',
	},
	tower_score:{
		en:'Tower Score',
		type:'avg',
	},
	trench:{
		en:'Trench',
		type:'%',
	},
	trench_alliance:{
		en:'Trench Alliance',
		type:'%',
	},
	trench_depot_alliance:{
		en:'Trench (Depot Side) Alliance',
		type:'%',
	},
	trench_depot_alliance_to_neutral:{
		en:'Trench (Depot Side) Alliance To Neutral',
		type:'%',
	},
	trench_depot_neutral_to_alliance:{
		en:'Trench (Depot Side) Neutral To Alliance',
		type:'%',
	},
	trench_depot_opponent:{
		en:'Trench (Depot Side) Opponent',
		type:'%',
	},
	trench_opponent:{
		en:'Trench Opponent',
		type:'%',
	},
	trench_outpost_alliance:{
		en:'Trench (Outpost Side) Alliance',
		type:'%',
	},
	trench_outpost_alliance_to_neutral:{
		en:'Trench (Outpost Side) Alliance To Neutral',
		type:'%',
	},
	trench_outpost_neutral_to_alliance:{
		en:'Trench (Outpost Side) Neutral To Alliance',
		type:'%',
	},
	trench_outpost_opponent:{
		en:'Trench (Outpost Side) Opponent',
		type:'%',
	},
	zone_change:{
		en:'Zone Change',
		type:'%',
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
