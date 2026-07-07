import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/colors.dart';
import '../../../../providers/app_providers.dart';
import '../../providers/scouting_data_provider.dart';
import '../../../../providers/field_side_provider.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../providers/timeline_provider.dart';
import '../../providers/undo_coordinator.dart';
import '../../../../providers/button_position_provider.dart';
import '../../../../services/localization.dart';
import '../../widgets/auto_field_overlay.dart';
import '../../widgets/values_table.dart';
import '../../../../widgets/timeline_table.dart';
import '../../../../widgets/popup_floater.dart';
import '../../../../models/field_button.dart';
import '../../../../providers/floating_popup_provider.dart';

typedef AutoTabRecord = ({
	String activeZone,
	String activeFuelTarget,
	int trenchDepotAllianceToNeutral,
	int bumpDepotAllianceToNeutral,
	int bumpOutpostAllianceToNeutral,
	int trenchOutpostAllianceToNeutral,
	int trenchDepotNeutralToAlliance,
	int bumpDepotNeutralToAlliance,
	int bumpOutpostNeutralToAlliance,
	int trenchOutpostNeutralToAlliance,
	int fuelScore,
	int fuelNeutralAlliancePass,
	int climbLevel,
	int allianceTime,
	int neutralTime,
});

/// Initialize Auto Tab translations
void _initAutoTabTranslations() {
	AppLocalizations.addI18n({
		// Tab header
		'auto_heading': {
			'en': 'Autonomous Period',
			'es': 'Período Autónomo',
			'pt': 'Período Autônomo',
			'fr': 'Période Autonome',
			'zh_tw': '自主期間',
			'he': 'תקופת אוטונומיה',
			'tr': 'Otonom Dönem',
		},

		// Section headers
		'field_interactions': {
			'en': 'Field Interactions',
			'es': 'Interacciones de Campo',
			'pt': 'Interações de Campo',
			'fr': 'Interactions sur le Terrain',
			'zh_tw': '場地交互',
			'he': 'אינטראקציות שדה',
			'tr': 'Saha Etkileşimleri',
		},
		'fuel_scoring': {
			'en': 'Fuel Scoring',
			'es': 'Puntuación de Combustible',
			'pt': 'Pontuação de Combustível',
			'fr': 'Marquage de Carburant',
			'zh_tw': '燃料評分',
			'he': 'ניקוד דלק',
			'tr': 'Yakıt Puanlaması',
		},
		'collection': {
			'en': 'Collection',
			'es': 'Recogida',
			'pt': 'Coleta',
			'fr': 'Collecte',
			'zh_tw': '收集',
			'he': 'אוסף',
			'tr': 'Koleksiyon',
		},
		'climb': {
			'en': 'Climb',
			'es': 'Escalada',
			'pt': 'Escalada',
			'fr': 'Escalade',
			'zh_tw': '攀爬',
			'he': 'טיפוס',
			'tr': 'Tırmanış',
		},
		'timeline': {
			'en': 'Timeline',
			'es': 'Cronograma',
			'pt': 'Cronograma',
			'fr': 'Chronologie',
			'zh_tw': '時間表',
			'he': 'ציר הזמן',
			'tr': 'Zaman Çizelgesi',
		},
		'values': {
			'en': 'Values',
			'es': 'Valores',
			'pt': 'Valores',
			'fr': 'Valeurs',
			'zh_tw': '值',
			'he': 'ערכים',
			'tr': 'Değerler',
		},

		// Field interaction labels (movement counters)
		'trench_depot_alliance_to_neutral': {
			'en': 'Trench Depot → Neutral',
			'es': 'Trinchera Depósito → Neutral',
			'pt': 'Trincheira Depósito → Neutro',
			'fr': 'Tranchée Dépôt → Neutre',
			'zh_tw': '壕溝倉庫 → 中立',
			'he': 'משק אחסון עמוק → ניטראלי',
			'tr': 'Hendek Depo → Tarafsız',
		},
		'bump_depot_alliance_to_neutral': {
			'en': 'Bump Depot → Neutral',
			'es': 'Golpe Depósito → Neutral',
			'pt': 'Bump Depósito → Neutro',
			'fr': 'Bump Dépôt → Neutre',
			'zh_tw': '碰撞倉庫 → 中立',
			'he': 'דחיפה אחסון → ניטראלי',
			'tr': 'Bump Depo → Tarafsız',
		},
		'bump_outpost_alliance_to_neutral': {
			'en': 'Bump Outpost → Neutral',
			'es': 'Golpe Puesto Avanzado → Neutral',
			'pt': 'Bump Avanço → Neutro',
			'fr': 'Bump Avant-Poste → Neutre',
			'zh_tw': '碰撞哨站 → 中立',
			'he': 'דחיפה אחסון צפוי → ניטראלי',
			'tr': 'Bump Karakol → Tarafsız',
		},
		'trench_outpost_alliance_to_neutral': {
			'en': 'Trench Outpost → Neutral',
			'es': 'Trinchera Puesto Avanzado → Neutral',
			'pt': 'Trincheira Avanço → Neutro',
			'fr': 'Tranchée Avant-Poste → Neutre',
			'zh_tw': '壕溝哨站 → 中立',
			'he': 'משק עמוק צפוי → ניטראלי',
			'tr': 'Hendek Karakol → Tarafsız',
		},
		'trench_depot_neutral_to_alliance': {
			'en': 'Trench Depot ← Neutral',
			'es': 'Trinchera Depósito ← Neutral',
			'pt': 'Trincheira Depósito ← Neutro',
			'fr': 'Tranchée Dépôt ← Neutre',
			'zh_tw': '壕溝倉庫 ← 中立',
			'he': 'משק אחסון עמוק ← ניטראלי',
			'tr': 'Hendek Depo ← Tarafsız',
		},
		'bump_depot_neutral_to_alliance': {
			'en': 'Bump Depot ← Neutral',
			'es': 'Golpe Depósito ← Neutral',
			'pt': 'Bump Depósito ← Neutro',
			'fr': 'Bump Dépôt ← Neutre',
			'zh_tw': '碰撞倉庫 ← 中立',
			'he': 'דחיפה אחסון ← ניטראלי',
			'tr': 'Bump Depo ← Tarafsız',
		},
		'bump_outpost_neutral_to_alliance': {
			'en': 'Bump Outpost ← Neutral',
			'es': 'Golpe Puesto Avanzado ← Neutral',
			'pt': 'Bump Avanço ← Neutro',
			'fr': 'Bump Avant-Poste ← Neutre',
			'zh_tw': '碰撞哨站 ← 中立',
			'he': 'דחיפה אחסון צפוי ← ניטראלי',
			'tr': 'Bump Karakol ← Tarafsız',
		},
		'trench_outpost_neutral_to_alliance': {
			'en': 'Trench Outpost ← Neutral',
			'es': 'Trinchera Puesto Avanzado ← Neutral',
			'pt': 'Trincheira Avanço ← Neutro',
			'fr': 'Tranchée Avant-poste Neutre à l\'alliance en auto',
			'zh_tw': '壕溝哨站 ← 中立',
			'he': 'משק עמוק צפוי ← ניטראלי',
			'tr': 'Hendek Karakol ← Tarafsız',
		},

		// Fuel scoring labels
		'fuel_hub_score': {
			'en': 'Fuel in Hub',
			'es': 'Combustible en Centro',
			'pt': 'Combustível no Hub',
			'fr': 'Carburant au Centre',
			'zh_tw': '燃料在集線器',
			'he': 'דלק בחוביל',
			'tr': 'Hub\'da Yakıt',
		},
		'fuel_neutral_pass': {
			'en': 'Neutral Pass',
			'es': 'Pase Neutral',
			'pt': 'Passagem Neutra',
			'fr': 'Passe Neutre',
			'zh_tw': '中立通行',
			'he': 'מעבר ניטראלי',
			'tr': 'Tarafsız Geçiş',
		},

		// Collection labels
		'collect_from_outpost': {
			'en': 'Collect from Outpost',
			'es': 'Recoger del Puesto Avanzado',
			'pt': 'Recolher do Avanço',
			'fr': 'Collecter de l\'Avant-Poste',
			'zh_tw': '從哨站收集',
			'he': 'אסוף מהאחסון',
			'tr': 'Karakoldan Topla',
		},
		'collect_from_depot': {
			'en': 'Collect from Depot',
			'es': 'Recoger del Depósito',
			'pt': 'Recolher do Depósito',
			'fr': 'Collecter du Dépôt',
			'zh_tw': '從倉庫收集',
			'he': 'אסוף מהמשק',
			'tr': 'Depodan Topla',
		},

		// Climb labels
		'no_climb': {
			'en': 'No Climb',
			'es': 'Sin Escalada',
			'pt': 'Sem Escalada',
			'fr': 'Pas d\'Escalade',
			'zh_tw': '沒有攀爬',
			'he': 'אין טיפוס',
			'tr': 'Tırmanış Yok',
		},
		'low_rung': {
			'en': 'Low Rung',
			'es': 'Peldaño Bajo',
			'pt': 'Degrau Baixo',
			'fr': 'Échelon Bas',
			'zh_tw': '低杆',
			'he': 'מקל נמוך',
			'tr': 'Düşük Alet',
		},
		'mid_rung': {
			'en': 'Mid Rung',
			'es': 'Peldaño Medio',
			'pt': 'Degrau Médio',
			'fr': 'Échelon Moyen',
			'zh_tw': '中杆',
			'he': 'מקל בינוני',
			'tr': 'Orta Alet',
		},
		'high_rung': {
			'en': 'High Rung',
			'es': 'Peldaño Alto',
			'pt': 'Degrau Alto',
			'fr': 'Échelon Haut',
			'zh_tw': '高杆',
			'he': 'מקל גבוה',
			'tr': 'Yüksek Alet',
		},
		'traversal_rung': {
			'en': 'Traversal Rung',
			'es': 'Peldaño de Travesía',
			'pt': 'Degrau de Travessia',
			'fr': 'Échelon de Traversée',
			'zh_tw': '橫越杆',
			'he': 'מקל חצייה',
			'tr': 'Geçiş Aleti',
		},

		// Timeline display
		'timeline_empty': {
			'en': 'No actions recorded yet',
			'es': 'No hay acciones registradas',
			'pt': 'Nenhuma ação registrada',
			'fr': 'Aucune action enregistrée',
			'zh_tw': '尚未記錄操作',
			'he': 'לא הוקלטה פעולה',
			'tr': 'Henüz hiçbir eylem kaydedilmedi',
		},
		'timeline_time_header': {
			'en': 'Time',
			'es': 'Tiempo',
			'pt': 'Hora',
			'fr': 'Heure',
			'zh_tw': '時間',
			'he': 'זְמַן',
			'tr': 'Zaman',
		},
		'timeline_action_header': {
			'en': 'Action',
			'es': 'Acción',
			'pt': 'Ação',
			'fr': 'Action',
			'zh_tw': '動作',
			'he': 'פעולה',
			'tr': 'Hareket',
		},
		'timeline_value_header': {
			'en': 'Value',
			'es': 'Valor',
			'pt': 'Valor',
			'fr': 'Valeur',
			'zh_tw': '價值',
			'he': 'ערך',
			'tr': 'Değer',
		},

		// Values table row labels (simplified for table display)
		'auto_fuel_score': {
			'en': 'Fuel Score',
			'es': 'Puntuación de Combustible',
			'pt': 'Pontuação de Combustível',
			'fr': 'Score de Carburant',
			'zh_tw': '燃料評分',
			'he': 'ניקוד דלק',
			'tr': 'Yakıt Puanı',
		},
		'auto_fuel_neutral_pass': {
			'en': 'Fuel Neutral Pass',
			'es': 'Pase Neutral de Combustible',
			'pt': 'Passe Neutro de Combustível',
			'fr': 'Passage Neutre du Carburant',
			'zh_tw': '燃料中立通道',
			'he': 'מעבר דלק ניטראלי',
			'tr': 'Yakıt Tarafsız Geçit',
		},
		'auto_trench_depot': {
			'en': 'Trench Depot',
			'es': 'Trinchera Depósito',
			'pt': 'Trincheira Depósito',
			'fr': 'Tranchée Dépôt',
			'zh_tw': '壕溝倉庫',
			'he': 'משק אחסון עמוק',
			'tr': 'Hendek Depo',
		},
		'auto_bump_depot': {
			'en': 'Bump Depot',
			'es': 'Golpe Depósito',
			'pt': 'Bump Depósito',
			'fr': 'Bump Dépôt',
			'zh_tw': '碰撞倉庫',
			'he': 'דחיפה אחסון',
			'tr': 'Bump Depo',
		},
		'auto_bump_outpost': {
			'en': 'Bump Outpost',
			'es': 'Golpe Puesto Avanzado',
			'pt': 'Bump Avanço',
			'fr': 'Bump Avant-Poste',
			'zh_tw': '碰撞哨站',
			'he': 'דחיפה אחסון צפוי',
			'tr': 'Bump Karakol',
		},
		'auto_trench_outpost': {
			'en': 'Trench Outpost',
			'es': 'Trinchera Puesto Avanzado',
			'pt': 'Trincheira Avanço',
			'fr': 'Tranchée Avant-Poste',
			'zh_tw': '壕溝哨站',
			'he': 'משק עמוק צפוי',
			'tr': 'Hendek Karakol',
		},
		'auto_alliance_time': {
			'en': 'Alliance Time',
			'es': 'Tiempo de Alianza',
			'pt': 'Tempo da Aliança',
			'fr': 'Temps d\'Alliance',
			'zh_tw': '聯盟時間',
			'he': 'זמן הברית',
			'tr': 'İttifak Süresi',
		},
		'auto_neutral_time': {
			'en': 'Neutral Time',
			'es': 'Tiempo Neutral',
			'pt': 'Tempo Neutro',
			'fr': 'Temps Neutre',
			'zh_tw': '中立時間',
			'he': 'זמן ניטראלי',
			'tr': 'Tarafsız Süresi',
		},

		// Web app counter descriptions (for values table)
		'fuel_score': {
			'en': 'Fuel Score',
			'es': 'Puntuación de Combustible',
			'pt': 'Pontuação de Combustível',
			'fr': 'Score de Carburant',
			'zh_tw': '燃料評分',
			'he': 'ניקוד דלק',
			'tr': 'Yakıt Puanı',
		},
		'alliance_time': {
			'en': 'Alliance Time',
			'es': 'Tiempo de Alianza',
			'pt': 'Tempo da Aliança',
			'fr': 'Temps d\'Alliance',
			'zh_tw': '聯盟時間',
			'he': 'זמן הברית',
			'tr': 'İttifak Süresi',
		},
		'neutral_time': {
			'en': 'Neutral Time',
			'es': 'Tiempo Neutral',
			'pt': 'Tiempo Neutral',
			'fr': 'Temps Neutre',
			'zh_tw': '中立時間',
			'he': 'זמן ניטראלי',
			'tr': 'Tarafsız Süresi',
		},

		// Action buttons
		'undo': {
			'en': 'Undo',
			'es': 'Deshacer',
			'pt': 'Desfazer',
			'fr': 'Annuler',
			'zh_tw': '撤銷',
			'he': 'בטל',
			'tr': 'Geri Al',
		},
		'reset': {
			'en': 'Reset',
			'es': 'Reiniciar',
			'pt': 'Redefinir',
			'fr': 'Réinitialiser',
			'zh_tw': '重置',
			'he': 'אתחול',
			'tr': 'Sıfırla',
		},
		'start_auto': {
			'en': 'Start Auto Timer',
			'es': 'Iniciar temporizador automático',
			'pt': 'Iniciar cronômetro automático',
			'fr': 'Démarrer le minuteur automatique',
			'zh_tw': '啟動自動計時器',
			'he': 'התחל טיימר אוטומטי',
			'tr': 'Otomatik Zamanlayıcı Başlat',
		},
		'stop_auto': {
			'en': 'Stop Auto Timer',
			'es': 'Detener temporizador automático',
			'pt': 'Parar cronômetro automático',
			'fr': 'Arrêter le minuteur automatique',
			'zh_tw': '停止自動計時器',
			'he': 'עצור טיימר אוטומטי',
			'tr': 'Otomatik Zamanlayıcı Durdur',
		},

		// Max fuel label
		'fuel_capacity_label': {
			'en': 'Max fuel:',
			'es': 'Capacidad de combustible:',
			'pt': 'Combustível máximo:',
			'fr': 'Carburant max :',
			'zh_tw': '最大燃料：',
			'he': 'דלק מקסימלי:',
			'tr': 'Maksimum yakıt:',
		},

		// Summary text
		'auto_summary': {
			'en': 'Auto Summary',
			'es': 'Resumen Automático',
			'pt': 'Resumo Automático',
			'fr': 'Résumé Automatique',
			'zh_tw': '自動摘要',
			'he': 'סיכום אוטומטי',
			'tr': 'Otomatik Özet',
		},
		'total_points': {
			'en': 'Total Points',
			'es': 'Puntos Totales',
			'pt': 'Pontos Totais',
			'fr': 'Total Points',
			'zh_tw': '總分',
			'he': 'סה"כ נקודות',
			'tr': 'Toplam Puan',
		},
		'proceed_tele_button': {
			'en': 'Teleop »',
			'es': 'Proceder a teleop',
			'pt': 'Teleop »',
			'fr': 'Télé »',
			'zh_tw': '遠端操作 »',
			'he': 'טלאופ »',
			'tr': 'Teleop »',
		},
		'start_auto_button': {
			'en': 'Start Auto',
			'es': 'Comenzar Auto',
			'pt': 'Começar Auto',
			'fr': 'Démarrer Auto',
			'zh_tw': '開始自動',
			'he': 'התחל אוטו',
			'tr': 'Otomatiği Başlat',
		},

		// Timeline action translations from aggregate-stats.js
		'auto_trench_depot_alliance_to_neutral': {
			'en': 'Trench (Depot Side) Alliance To Neutral in Auto',
			'es': 'Trinchera Depósito Alianza a Neutral en Auto',
			'pt': 'Trincheira Depósito Aliança para Neutro no Auto',
			'fr': 'Tranchée Dépôt Alliance à neutre en auto',
			'zh_tw': '自動將聯盟壕溝倉庫轉為中立',
			'he': 'לחפור מחסן ברית לנייטרלי באוטומט',
			'tr': 'Otomatik Olarak İttifak Hendeği Depoyu Nötr Yap',
		},
		'auto_bump_depot_alliance_to_neutral': {
			'en': 'Bump (Depot Side) Alliance To Neutral in Auto',
			'es': 'Golpe Depósito Alianza a Neutral en Auto',
			'pt': 'Saliência Depósito Aliança para Neutro no Auto',
			'fr': 'Pousser le dépôt de l\'alliance à neutre en auto',
			'zh_tw': '自動將聯盟倉庫撞擊為中立',
			'he': 'לדחוף את מחסן הברית לנייטרלי באוטומט',
			'tr': 'Otomatik Olarak İttifak Deposunu Nötr Yap',
		},
		'auto_bump_outpost_alliance_to_neutral': {
			'en': 'Bump (Outpost Side) Alliance To Neutral in Auto',
			'es': 'Golpe Puesto Avanzado Alianza a Neutral en Auto',
			'pt': 'Saliência Avanço Aliança para Neutro no Auto',
			'fr': 'Pousser l\'avant-poste de l\'alliance à neutre en auto',
			'zh_tw': '自動將聯盟前哨撞擊為中立',
			'he': 'לדחוף את מוצב הברית לנייטרלי באוטומט',
			'tr': 'Otomatik Olarak İttifak Karakolunu Nötr Yap',
		},
		'auto_trench_outpost_alliance_to_neutral': {
			'en': 'Trench (Outpost Side) Alliance To Neutral in Auto',
			'es': 'Trinchera Puesto Avanzado Alianza a Neutral en Auto',
			'pt': 'Trincheira Avanço Aliança para Neutro no Auto',
			'fr': 'Tranchée Avant-poste Alliance à neutre en auto',
			'zh_tw': '自動將聯盟壕溝前哨轉為中立',
			'he': 'לחפור מוצב ברית לנייטרלי באוטומט',
			'tr': 'Otomatik Olarak İttifak Hendeği Karakolunu Nötr Yap',
		},
		'auto_trench_depot_neutral_to_alliance': {
			'en': 'Trench (Depot Side) Neutral To Alliance in Auto',
			'es': 'Trinchera Depósito Neutral a Alianza en Auto',
			'pt': 'Trincheira Depósito Neutro para Aliança no Auto',
			'fr': 'Tranchée Dépôt Neutre à l\'alliance en auto',
			'zh_tw': '自動將中立壕溝倉庫轉到聯盟',
			'he': 'לחפור מחסן נייטרלי לברית באוטומט',
			'tr': 'Otomatik Olarak Nötr Hendeği Depoyu İttifak Yap',
		},
		'auto_bump_depot_neutral_to_alliance': {
			'en': 'Bump (Depot Side) Neutral To Alliance in Auto',
			'es': 'Golpe Depósito Neutral a Alianza en Auto',
			'pt': 'Saliência Depósito Neutro para Aliança no Auto',
			'fr': 'Pousser le dépôt neutre à l\'alliance en auto',
			'zh_tw': '自動將中立倉庫撞擊到聯盟',
			'he': 'לדחוף מחסן נייטרלי לברית באוטומט',
			'tr': 'Otomatik Olarak Nötr Depoyu İttifak Yap',
		},
		'auto_bump_outpost_neutral_to_alliance': {
			'en': 'Bump (Outpost Side) Neutral To Alliance in Auto',
			'es': 'Golpe Puesto Avanzado Neutral a Alianza en Auto',
			'pt': 'Saliência Avanço Neutro para Aliança no Auto',
			'fr': 'Pousser l\'avant-poste neutre à l\'alliance en auto',
			'zh_tw': '自動將中立前哨撞擊到聯盟',
			'he': 'לדחוף מוצב נייטרלי לברית באוטומט',
			'tr': 'Otomatik Olarak Nötr Karakolu İttifak Yap',
		},
		'auto_trench_outpost_neutral_to_alliance': {
			'en': 'Trench (Outpost Side) Neutral To Alliance in Auto',
			'es': 'Trinchera Puesto Avanzado Neutral a Alianza en Auto',
			'pt': 'Trincheira Avanço Neutro para Aliança no Auto',
			'fr': 'Tranchée Avant-poste Neutre à l\'alliance en auto',
			'zh_tw': '自動將中立壕溝前哨轉到聯盟',
			'he': 'לחפור מוצב נייטרלי לברית באוטומט',
			'tr': 'Otomatik Olarak Nötr Hendeği Karakolu İttifak Yap',
		},
		'action_auto_fuel_score': {
			'en': 'Fuel Scored in Hub',
			'es': 'Combustible Anotado en Centro',
			'pt': 'Combustível Marcado no Hub',
			'fr': 'Carburant marqué dans le hub',
			'zh_tw': '燃料在樞紐中得分',
			'he': 'דלק נקודות בחישוקן',
			'tr': 'Yakıt merkez sepete puanlandı',
		},
		'auto_fuel_neutral_alliance_pass': {
			'en': 'Fuel Passed or Pushed to Alliance Zone from Neutral',
			'es': 'Combustible Pasado o Empujado a Zona de Alianza desde Neutral',
			'pt': 'Combustível Passado ou Empurrado para Zona de Aliança do Neutro',
			'fr':
					'Carburant passé ou poussé vers la zone d\'alliance à partir de la zone neutre',
			'zh_tw': '燃料從中立區傳遞或推送到聯盟區',
			'he': 'דלק עבר או נדחף לאזור הברית מהאזור הנייטרלי',
			'tr': 'Yakıt nötr bölgeden ittifak bölgesine geçirildi veya itildi',
		},
		'auto_collect_depot': {
			'en': 'Collected Depot in Auto',
			'es': 'Depósito Recolectado en Auto',
			'pt': 'Depósito Coletado no Auto',
			'fr': 'Dépôt collecté en auto',
			'zh_tw': '自動收集倉庫',
			'he': 'אוסף מחסן באוטומט',
			'tr': 'Otomatik Olarak Depo Toplandı',
		},
		'auto_collect_outpost': {
			'en': 'Collected Outpost in Auto',
			'es': 'Puesto Avanzado Recolectado en Auto',
			'pt': 'Avanço Coletado no Auto',
			'fr': 'Avant-poste collecté en auto',
			'zh_tw': '自動收集前哨',
			'he': 'אוסף מוצב באוטומט',
			'tr': 'Otomatik Olarak Karakol Toplandı',
		},
	});
}

class AutoTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final DateTime? matchStartTime;
	final Function(DateTime)? onStartMatch;
	final VoidCallback onProceedToTele;

	const AutoTab({
		super.key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		this.matchStartTime,
		this.onStartMatch,
		required this.onProceedToTele,
	});

	@override
	ConsumerState<AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends ConsumerState<AutoTab> {
	bool _valuesExpanded = false;
	bool _timelineExpanded = false;
	late FocusNode _focusNode;
	final GlobalKey _undoButtonKey = GlobalKey();
	final GlobalKey _fieldOverlayKey = GlobalKey();
	final GlobalKey _stackKey = GlobalKey();

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(
			key,
			locale: locale,
			variables: variables,
		);
	}

	/// Get team color based on bot position (red vs blue team)
	Color _getTeamColor(String? botPosition) {
		if (botPosition == null) return AppColors.blueTeamColor;
		// Red team positions start with 'R', Blue with 'B'
		return botPosition.startsWith('R')
				? AppColors.redTeamColor
				: AppColors.blueTeamColor;
	}

	/// Get responsive font size based on screen width
	double _getResponsiveFontSize(double baseSize) {
		final screenWidth = MediaQuery.of(context).size.width;
		if (screenWidth < 400) return baseSize * 0.85; // Mobile
		return baseSize;
	}

	/// Start the match timer if not already started
	void _startMatchIfNeeded() {
		if (widget.matchStartTime == null) {
			final now = DateTime.now();
			widget.onStartMatch?.call(now);
			// Sync provider's start time with UI timer start
			ref.read(scoutingDataProvider.notifier).syncStartTime(now);
		}
	}

	@override
	void initState() {
		super.initState();
		// Initialize i18n for auto tab
		_initAutoTabTranslations();
		_focusNode = FocusNode();
		_focusNode.addListener(_onFocusChanged);

		// Access scouting data to ensure descriptors are registered
		ref.read(scoutingDataProvider);

		// Instantiate field buttons to trigger descriptor registration
		for (final btn in autoZoneChangeButtons) {
			FieldButton(
				field: btn.field,
				label: btn.label,
				rightPercent: btn.rightPercent,
				leftPercent: btn.leftPercent,
				bottomPercent: btn.bottomPercent,
				topPercent: btn.topPercent,
				imagePath: btn.imagePath,
				zone: btn.zone,
				widthPercent: btn.widthPercent,
				aspectRatio: btn.aspectRatio,
				descriptor: btn.descriptor,
			);
		}
		for (final target in autoFuelTargets) {
			FieldButton(
				field: target.field,
				label: target.label,
				rightPercent: target.rightPercent,
				leftPercent: target.leftPercent,
				bottomPercent: target.bottomPercent,
				topPercent: target.topPercent,
				imagePath: target.imagePath,
				zone: target.zone,
				widthPercent: target.widthPercent,
				aspectRatio: target.aspectRatio,
				descriptor: target.descriptor,
			);
		}
	}

	void _onFocusChanged() {}

	/// Calculate the position for an undo floater by looking up the button's stored position
	Offset? _getUndoPopupPosition(String field) {
		try {
			// Look up button position from the provider (stored relative to field overlay)
			var position = ref.read(buttonPositionProvider)[field];
			if (position == null) {
				return null;
			}

			// Convert from field-overlay-relative to outer-stack-relative coordinates
			final fieldOverlayBox = _fieldOverlayKey.currentContext?.findRenderObject() as RenderBox?;
			final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;

			if (fieldOverlayBox != null && stackBox != null) {
				// Get the field overlay's position within the outer stack
				final fieldOverlayGlobal = fieldOverlayBox.localToGlobal(Offset.zero);
				final stackGlobal = stackBox.localToGlobal(Offset.zero);
				final fieldOverlayOffset = fieldOverlayGlobal - stackGlobal;

				// Add the field overlay's offset to get stack-relative coordinates
				position = position + fieldOverlayOffset;
			} else {
			}

			return position;
		} catch (e) {
			return null;
		}
	}

	@override
	void dispose() {
		_focusNode.removeListener(_onFocusChanged);
		_focusNode.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final fieldSide = ref.watch(selectedFieldSideProvider);
		final activeZone = ref.watch(activeZoneProvider);
		final scoutingData = ref.watch(scoutingDataProvider);
		final botPosition = ref.watch(selectedBotPositionProvider);
		final climbLevel = scoutingData.getFieldValue('auto_climb_level').asInt();

		// Reset zone if it's invalid for auto phase (opponent should never happen in auto)
		if (activeZone == 'opponent') {
			WidgetsBinding.instance.addPostFrameCallback((_) {
				ref.read(activeZoneProvider.notifier).changeZone('alliance');
			});
		}

		// Debug: Print positioning state when Auto tab is shown
		final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

		// In landscape, constrain field width based on screen height to maintain aspect ratio and leave room for controls
		double? constrainedFieldWidth;
		if (isLandscape) {
			final screenHeight = MediaQuery.of(context).size.height;
			final maxFieldHeight = screenHeight * 0.5;
			constrainedFieldWidth = maxFieldHeight * 1.875; // Maintain 1.875:1 aspect ratio
		}

		// Instantiate overlay early so buttons register their descriptors
		final fieldOverlay = AutoFieldOverlay(
			key: _fieldOverlayKey,
			fieldWidth: constrainedFieldWidth,
			fieldSide: fieldSide,
			activeZone: activeZone,
			climbLevel: climbLevel,
			botPosition: botPosition,
			showStartButton: widget.matchStartTime == null,
			onMovementTapped: (field, action, globalPosition) {
				_startMatchIfNeeded();
				ref
						.read(scoutingDataProvider.notifier)
						.recordAutoAction(field: field, value: 1);
				// Show floating popup at the button that was tapped
				final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
				if (stackBox != null) {
					// Convert button's global position to stack-relative coordinates
					final stackGlobalOffset = stackBox.localToGlobal(Offset.zero);
					final buttonStackRelative = globalPosition - stackGlobalOffset;

					ref.read(floatingPopupProvider.notifier).addPopup('+1', buttonStackRelative.dx, buttonStackRelative.dy);
				}
			},
			onClimbToggled: () {
				_startMatchIfNeeded();
				if (climbLevel < 1) {
					ref
							.read(scoutingDataProvider.notifier)
							.recordAutoAction(
								field: 'auto_climb_level',
								value: climbLevel + 1,
							);
					// Show floating popup at left side of field, offset from top
					final overlayBox = _fieldOverlayKey.currentContext?.findRenderObject() as RenderBox?;
					if (overlayBox != null) {
						final offset = overlayBox.localToGlobal(Offset.zero);
						final popupX = offset.dx + 40;
						final popupY = offset.dy + 40;
						ref.read(floatingPopupProvider.notifier).addPopup('+1', popupX, popupY);
					}
				}
			},
			onStartAutoTapped: () {
				_startMatchIfNeeded();
			},
			activeFuelTarget: ref.watch(activeFuelTargetProvider),
			onFuelTargetTapped: (targetName) {
				ref
						.read(scoutingDataProvider.notifier)
						.changeAutoFuelTarget(targetName);
			},
			startAutoButtonLabel: _translate('start_auto_button'),
			model: scoutingData,
			onRecordAction: (field, value) {
				_startMatchIfNeeded();
				ref
						.read(scoutingDataProvider.notifier)
						.recordAutoAction(field: field, value: value);
			},
		);

		// Now access field values (buttons are registered)

		final teamColor = _getTeamColor(botPosition);
		final floatingPopups = ref.watch(floatingPopupProvider);
		var activeFuelTarget = ref.watch(activeFuelTargetProvider);

		// Ensure fuel target is valid for auto phase and zone
		final validAutoTargets = {'hub', 'alliancePass'};
		if (!validAutoTargets.contains(activeFuelTarget)) {
			// Map zone to valid auto target if coming from tele
			final newTarget = activeZone == 'neutral' ? 'alliancePass' : 'hub';
			activeFuelTarget = newTarget;
			if (mounted) {
				Future(() {
					if (mounted) {
						ref.read(activeFuelTargetProvider.notifier).changeTarget(newTarget);
					}
				});
			}
		}

		return Stack(
			key: _stackKey,
			children: [
				Focus(
					focusNode: _focusNode,
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(vertical: 8),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
						// Field Overlay with all integrated controls
						// (movement buttons, fuel overlays, zone toggles, climb selector)
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Center(
								child: fieldOverlay,
							),
						),

						const SizedBox(height: 16),

						// Two-column layout: fuel and info
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child: Row(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// LEFT COLUMN: Fuel and Table Toggles
									Expanded(
										flex: 3,
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.center,
											children: [
												// Fuel buttons row
												Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														_buildFuelButton('1', 1, activeFuelTarget, ref),
														const SizedBox(width: 8),
														_buildFuelButton('5', 5, activeFuelTarget, ref),
														const SizedBox(width: 8),
														_buildFuelButton('10', 10, activeFuelTarget, ref),
													],
												),
												const SizedBox(height: 8),
												const SizedBox(height: 8),
												// Max fuel display and toggle buttons row
												Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														_buildMaxFuelDisplay(ref),
														TextButton(
															onPressed: () {
																setState(
																	() => _valuesExpanded = !_valuesExpanded,
																);
															},
															child: Text(
																'${_valuesExpanded ? '▼' : '▶'} ${_translate('values')}',
															),
														),
														const SizedBox(width: 8),
														TextButton(
															onPressed: () {
																setState(
																	() => _timelineExpanded = !_timelineExpanded,
																);
															},
															child: Text(
																'${_timelineExpanded ? '▼' : '▶'} ${_translate('timeline')}',
															),
														),
													],
												),
											],
										),
									),
									const SizedBox(width: 16),
									// RIGHT COLUMN: Info Section (vertically stacked)
									Expanded(
										flex: 1,
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.stretch,
											children: [
												// Undo button (always enabled to undo either timeline events or timer start)
												FilledButton(
													key: _undoButtonKey,
													style: FilledButton.styleFrom(
														backgroundColor: AppColors.buttonBgColor,
														foregroundColor: AppColors.buttonFgColor,
														padding: const EdgeInsets.symmetric(
															vertical: 12,
															horizontal: 16,
														),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(8),
														),
													),
													onPressed: () {
														undoLastAction(
															ref,
															context,
															_undoButtonKey,
															getUndoPosition: _getUndoPopupPosition,
														);
													},
													child: Text(
														_translate('undo'),
														style: TextStyle(
															fontSize: _getResponsiveFontSize(12),
														),
													),
												),
												const SizedBox(height: 8),
												// Robot/Team indicator - team color background with contrasting text
												Container(
													padding: const EdgeInsets.symmetric(
														vertical: 10,
														horizontal: 12,
													),
													decoration: BoxDecoration(
														color: teamColor,
														borderRadius: BorderRadius.circular(4),
													),
													child: Center(
														child: Text(
															'$botPosition ${widget.teamNumber ?? ''}',
															style: TextStyle(
																fontSize: _getResponsiveFontSize(12),
																fontWeight: FontWeight.bold,
																color: AppColors.mainFgColor,
															),
														),
													),
												),
												const SizedBox(height: 8),
												// Tele button
												FilledButton(
													style: FilledButton.styleFrom(
														backgroundColor: AppColors.buttonBgColor,
														foregroundColor: AppColors.buttonFgColor,
														padding: const EdgeInsets.symmetric(
															vertical: 12,
															horizontal: 16,
														),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(8),
														),
													),
													onPressed: widget.onProceedToTele,
													child: Text(
														_translate('proceed_tele_button'),
														style: TextStyle(
															fontSize: _getResponsiveFontSize(12),
														),
													),
												),
											],
										),
									),
								],
							),
						),

						// Values Table (readonly counters)
						if (_valuesExpanded)
							ValuesTable(
								key: const ValueKey('auto_values_table'),
								fieldSelector: (d) => d.autoValuesTableDescription,
							),

						// Timeline Table
						if (_timelineExpanded)
							TimelineTable(
								key: const ValueKey('auto_timeline_table'),
								events: ref.watch(timelineProvider),
							),

						const SizedBox(height: 16),
					],
				),
			),
			),
				// Floating popups layer
				...floatingPopups.map((popup) {
					return PopupFloater(
						key: ValueKey(popup.id),
						text: popup.text,
						initialX: popup.initialX,
						initialY: popup.initialY,
						onAnimationComplete: () {
							ref.read(floatingPopupProvider.notifier).removePopup(popup.id);
						},
					);
				}),
			],
		);
	}

	/// Build a fuel quick-add button
	Widget _buildFuelButton(
		String label,
		int amount,
		String activeFuelTarget,
		WidgetRef ref,
	) {
		final buttonKey = GlobalKey();

		return SizedBox(
			width: 70,
			height: 70,
			child: ElevatedButton(
				key: buttonKey,
				onPressed: () {
					// Start match timer if not already started
					_startMatchIfNeeded();

					// Use the correct fuel counter based on active target
					final fuelField = activeFuelTarget == 'hub'
							? 'auto_fuel_score'
							: 'auto_fuel_neutral_alliance_pass';

					ref
							.read(scoutingDataProvider.notifier)
							.recordAutoAction(field: fuelField, value: amount);

					// Show floating popup at the active fuel target position in the field overlay
					final overlayBox = _fieldOverlayKey.currentContext?.findRenderObject() as RenderBox?;
					final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
					if (overlayBox != null && stackBox != null) {
						// Get overlay position and size
						final overlayGlobalOffset = overlayBox.localToGlobal(Offset.zero);
						final stackGlobalOffset = stackBox.localToGlobal(Offset.zero);
						final overlayStackRelative = overlayGlobalOffset - stackGlobalOffset;

						// Calculate fuel target position based on active target
						// Hub: rightPercent=26.0, topPercent=42.0
						// AlliancePass: rightPercent=13.0, bottomPercent=7.0
						double targetX, targetY;
						if (activeFuelTarget == 'hub') {
							targetX = overlayStackRelative.dx + (overlayBox.size.width * (1 - 0.26));
							targetY = overlayStackRelative.dy + (overlayBox.size.height * 0.42);
						} else {
							// alliancePass
							targetX = overlayStackRelative.dx + (overlayBox.size.width * (1 - 0.13));
							targetY = overlayStackRelative.dy + (overlayBox.size.height * (1 - 0.07));
						}

						ref.read(floatingPopupProvider.notifier).addPopup('+$amount', targetX, targetY);
					}
			},
				style: ElevatedButton.styleFrom(
					backgroundColor: const Color(0xFFF1CE03),
					foregroundColor: Colors.black87,
					padding: EdgeInsets.zero,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(50),
					),
				),
				child: Text(
					label,
					style: TextStyle(
						fontSize: _getResponsiveFontSize(18),
						fontWeight: FontWeight.bold,
					),
				),
			),
		);
	}

	/// Build max fuel display widget from pit scouting data
	Widget _buildMaxFuelDisplay(WidgetRef ref) {
		return ref
				.watch(pitScoutingDataProvider)
				.when(
					data: (pitData) {
						final teamNumber = widget.teamNumber;
						if (teamNumber == null) {
							return const SizedBox.shrink();
						}

						final teamData = pitData[teamNumber] as Map<String, dynamic>?;
						final fuelCapacity =
								int.tryParse((teamData?['fuel_capacity'] ?? '0').toString()) ??
								0;

						if (fuelCapacity <= 0) {
							return const SizedBox.shrink();
						}

						return Padding(
							padding: const EdgeInsets.only(right: 8),
							child: Text(
								'${_translate('fuel_capacity_label')} $fuelCapacity',
								style: TextStyle(
									fontSize: _getResponsiveFontSize(12),
									fontWeight: FontWeight.w500,
								),
							),
						);
					},
					loading: () => const SizedBox.shrink(),
					error: (e, st) => const SizedBox.shrink(),
				);
	}
}
