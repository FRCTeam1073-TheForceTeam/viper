import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../constants/colors.dart';
import '../../data/database/scout_database.dart';
import '../../providers/app_providers.dart';
import '../../providers/auto_tab_controller.dart';
import '../../providers/field_side_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/scout_data_helper.dart';
import '../../services/localization.dart';
import '../../widgets/auto_field_overlay.dart';
import '../../widgets/auto_values_table.dart';
import '../../widgets/auto_timeline_table.dart';

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
			'fr': 'Tranchée Avant-Poste ← Neutre',
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
			'pt': 'Tempo Neutro',
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
		'auto_fuel_score': {
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
			'fr': 'Carburant passé ou poussé vers la zone d\'alliance à partir de la zone neutre',
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

	const AutoTab({
		Key? key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		this.matchStartTime,
		this.onStartMatch,
	}) : super(key: key);

	@override
	ConsumerState<AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends ConsumerState<AutoTab> {
	ScoutData? _currentScout;
	bool _valuesExpanded = false;
	bool _timelineExpanded = false;
	bool _listenerRegistered = false;

	String _translate(String key, {Map<String, String>? variables}) {
		final locale = ref.read(selectedLocaleProvider);
		return AppLocalizations.translate(key, locale: locale, variables: variables);
	}

	/// Get team color based on bot position (red vs blue team)
	Color _getTeamColor(String? botPosition) {
		if (botPosition == null) return AppColors.blueTeamColor;
		// Red team positions start with 'R', Blue with 'B'
		return botPosition.startsWith('R') ? AppColors.redTeamColor : AppColors.blueTeamColor;
	}

	/// Get responsive font size based on screen width
	double _getResponsiveFontSize(double baseSize) {
		final screenWidth = MediaQuery.of(context).size.width;
		if (screenWidth < 400) return baseSize * 0.85; // Mobile
		return baseSize;
	}

	/// Get responsive padding based on screen width
	EdgeInsets _getResponsivePadding() {
		final screenWidth = MediaQuery.of(context).size.width;
		if (screenWidth < 400) return const EdgeInsets.all(8);
		return const EdgeInsets.all(12);
	}

	/// Start the match timer if not already started
	void _startMatchIfNeeded() {
		if (widget.matchStartTime == null) {
			final now = DateTime.now();
			widget.onStartMatch?.call(now);
			// Sync provider's autoStartTime with UI timer start
			ref.read(autoTabControllerProvider.notifier).syncStartTime(now);
		}
	}

	@override
	void initState() {
		super.initState();
		// Initialize i18n for auto tab
		_initAutoTabTranslations();
		_loadScout();
	}

	@override
	void deactivate() {
		// Save before widget is deactivated (removed from tree)
		_saveTab();
		super.deactivate();
	}

	@override
	void dispose() {
		super.dispose();
	}

	Future<void> _loadScout() async {
		if (widget.matchNumber != null && widget.teamNumber != null) {
			final db = await ref.read(databaseProvider.future);
			final scout = await db.getScout(
				widget.eventId,
				widget.matchNumber!,
				widget.teamNumber!,
			);
			if (scout != null && mounted) {
				setState(() {
					_currentScout = scout;
				});

				// Load auto data into controller
				final controller = ref.read(autoTabControllerProvider.notifier);
				final autoData = {
					'auto_trench_depot_alliance_to_neutral': scout.autoTrenchDepotAllianceToNeutral ?? 0,
					'auto_bump_depot_alliance_to_neutral': scout.autoBumpDepotAllianceToNeutral ?? 0,
					'auto_bump_outpost_alliance_to_neutral': scout.autoBumpOutpostAllianceToNeutral ?? 0,
					'auto_trench_outpost_alliance_to_neutral': scout.autoTrenchOutpostAllianceToNeutral ?? 0,
					'auto_trench_depot_neutral_to_alliance': scout.autoTrenchDepotNeutralToAlliance ?? 0,
					'auto_bump_depot_neutral_to_alliance': scout.autoBumpDepotNeutralToAlliance ?? 0,
					'auto_bump_outpost_neutral_to_alliance': scout.autoBumpOutpostNeutralToAlliance ?? 0,
					'auto_trench_outpost_neutral_to_alliance': scout.autoTrenchOutpostNeutralToAlliance ?? 0,
					'auto_fuel_score': scout.autoFuelScore ?? 0,
					'auto_fuel_neutral_alliance_pass': scout.autoFuelNeutralAlliancePass ?? 0,
					'auto_collect_outpost': scout.autoCollectOutpost ?? 0, // Pass raw int, fromJson will convert
					'auto_collect_depot': scout.autoCollectDepot ?? 0, // Pass raw int, fromJson will convert
					'auto_alliance_time': scout.autoAllianceTime ?? 0,
					'auto_neutral_time': scout.autoNeutralTime ?? 0,
					'auto_climb_level': scout.autoClimbLevel ?? 0,
					'timeline': scout.timeline,
				};
				controller.loadFromData(autoData);
			}
		}
	}

	Future<void> _saveTab() async {
		if (widget.matchNumber == null || widget.teamNumber == null) return;

		final db = await ref.read(databaseProvider.future);
		final autoState = ref.read(autoTabControllerProvider);

		// Guard: don't save if all counters are zero and timeline is empty (indicates incomplete state)
		final allCountersZero = autoState.trenchDepotAllianceToNeutral == 0 &&
			autoState.bumpDepotAllianceToNeutral == 0 &&
			autoState.bumpOutpostAllianceToNeutral == 0 &&
			autoState.trenchOutpostAllianceToNeutral == 0 &&
			autoState.trenchDepotNeutralToAlliance == 0 &&
			autoState.bumpDepotNeutralToAlliance == 0 &&
			autoState.bumpOutpostNeutralToAlliance == 0 &&
			autoState.trenchOutpostNeutralToAlliance == 0 &&
			autoState.fuelScore == 0 &&
			autoState.fuelNeutralAlliancePass == 0 &&
			autoState.collectOutpost == 0 &&
			autoState.collectDepot == 0;

		// If we have existing data but now all counters are zero, skip the save to prevent overwriting
		if (allCountersZero && _currentScout != null && _currentScout!.autoFuelScore != null) {
			print('[AUTO_TAB] Skipping save - detected blank state, preserving existing data');
			return;
		}

		final existing = _currentScout ?? await db.getScout(
			widget.eventId,
			widget.matchNumber!,
			widget.teamNumber!,
		);

		final now = DateTime.now();
		// Format timeline using web app format (time:action or time:action:value, space-separated)
		final timelineStr = TimelineEvent.formatTimeline(autoState.timeline);

		final scout = existing != null
				? existing.copyWith(
					autoTrenchDepotAllianceToNeutral: autoState.trenchDepotAllianceToNeutral,
					autoBumpDepotAllianceToNeutral: autoState.bumpDepotAllianceToNeutral,
					autoBumpOutpostAllianceToNeutral: autoState.bumpOutpostAllianceToNeutral,
					autoTrenchOutpostAllianceToNeutral: autoState.trenchOutpostAllianceToNeutral,
					autoTrenchDepotNeutralToAlliance: autoState.trenchDepotNeutralToAlliance,
					autoBumpDepotNeutralToAlliance: autoState.bumpDepotNeutralToAlliance,
					autoBumpOutpostNeutralToAlliance: autoState.bumpOutpostNeutralToAlliance,
					autoTrenchOutpostNeutralToAlliance: autoState.trenchOutpostNeutralToAlliance,
					autoFuelScore: autoState.fuelScore,
					autoFuelNeutralAlliancePass: autoState.fuelNeutralAlliancePass,
					autoCollectOutpost: autoState.collectOutpost, // Already stored as int
					autoCollectDepot: autoState.collectDepot, // Already stored as int
					autoAllianceTime: autoState.allianceTime,
					autoNeutralTime: autoState.neutralTime,
					autoClimbLevel: Value(autoState.climbLevel),
					timeline: Value(timelineStr),
					updatedAt: now,
				)
				: ScoutDataHelper.createNewScout(
					event: widget.eventId,
					match: widget.matchNumber!,
					team: widget.teamNumber!,
			).copyWith(
				autoTrenchDepotAllianceToNeutral: autoState.trenchDepotAllianceToNeutral,
				autoBumpDepotAllianceToNeutral: autoState.bumpDepotAllianceToNeutral,
				autoBumpOutpostAllianceToNeutral: autoState.bumpOutpostAllianceToNeutral,
				autoTrenchOutpostAllianceToNeutral: autoState.trenchOutpostAllianceToNeutral,
				autoTrenchDepotNeutralToAlliance: autoState.trenchDepotNeutralToAlliance,
				autoBumpDepotNeutralToAlliance: autoState.bumpDepotNeutralToAlliance,
				autoBumpOutpostNeutralToAlliance: autoState.bumpOutpostNeutralToAlliance,
				autoTrenchOutpostNeutralToAlliance: autoState.trenchOutpostNeutralToAlliance,
				autoFuelScore: autoState.fuelScore,
				autoFuelNeutralAlliancePass: autoState.fuelNeutralAlliancePass,
				autoCollectOutpost: autoState.collectOutpost, // Already stored as int
				autoCollectDepot: autoState.collectDepot, // Already stored as int
				autoAllianceTime: autoState.allianceTime,
				autoNeutralTime: autoState.neutralTime,
				autoClimbLevel: Value(autoState.climbLevel),
				timeline: Value(timelineStr),
				updatedAt: now,
			);

		await db.upsertScout(scout);
		if (mounted) {
			setState(() => _currentScout = scout);
		}
	}

	/// Public method to save auto tab data (called before navigating away)
	Future<void> saveAutoData() => _saveTab();

	@override
	Widget build(BuildContext context) {
		final fieldSide = ref.watch(selectedFieldSideProvider);
		final autoState = ref.watch(autoTabControllerProvider);
		final botPosition = ref.watch(selectedBotPositionProvider);
		final teamColor = _getTeamColor(botPosition);

		// Auto-save whenever auto tab state changes (only register listener once)
		if (!_listenerRegistered) {
			_listenerRegistered = true;
			ref.listen<AutoTabState>(autoTabControllerProvider, (previous, next) {
				// Skip initial load
				if (previous != null && previous != next) {
					_saveTab();
				}
			});
		}

		return SingleChildScrollView(
			padding: const EdgeInsets.symmetric(vertical: 8),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					// Field Overlay with all integrated controls
					// (movement buttons, fuel overlays, zone toggles, climb selector)
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: AutoFieldOverlay(
							fieldSide: fieldSide,
							activeZone: autoState.activeZone,
							collectDepot: autoState.collectDepot == 1, // Convert int to bool
							collectOutpost: autoState.collectOutpost == 1, // Convert int to bool
							climbLevel: autoState.climbLevel,
							botPosition: botPosition,
							showStartButton: widget.matchStartTime == null,
							onMovementTapped: (field, action) {
								// Start match timer if not already started
								_startMatchIfNeeded();

								// Record the action (zone change is implicit in field name)
								ref.read(autoTabControllerProvider.notifier).recordAction(
									type: 'movement',
									field: field,
									value: 1,
									actionLabel: action,
									valueLabel: '+1',
								);
							},
							onCollectionToggled: (type, newValue) {
							_startMatchIfNeeded();
								final field = type == 'depot' ? 'auto_collect_depot' : 'auto_collect_outpost';
								ref.read(autoTabControllerProvider.notifier).recordAction(
									type: 'collection',
									field: field,
									value: newValue ? 1 : 0,
									actionLabel: 'Collect: $type',
									valueLabel: newValue ? 'on' : 'off',
								);
							},
							onClimbToggled: () {
								// Start match timer if not already started
								_startMatchIfNeeded();

								ref.read(autoTabControllerProvider.notifier).recordAction(
									type: 'climb',
									field: 'auto_climb_level',
									value: autoState.climbLevel == 0 ? 1 : 0,
									actionLabel: 'Climb',
									valueLabel: '${autoState.climbLevel == 0 ? 1 : 0}',
								);
							},
							onStartAutoTapped: () {
								_startMatchIfNeeded();
							},						activeFuelTarget: autoState.activeFuelTarget,
						onFuelTargetTapped: (targetName) {
							ref.read(autoTabControllerProvider.notifier).changeFuelTarget(targetName);
						},						startAutoButtonLabel: _translate('start_auto_button'),
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
										_buildFuelButton('1', 1, autoState, ref),
										const SizedBox(width: 8),
										_buildFuelButton('5', 5, autoState, ref),
										const SizedBox(width: 8),
										_buildFuelButton('10', 10, autoState, ref),
									],
								),
								const SizedBox(height: 8),
								// Values and timeline toggle buttons row
								Row(
								mainAxisAlignment: MainAxisAlignment.center,
									children: [
										TextButton(
											onPressed: () {
												setState(() => _valuesExpanded = !_valuesExpanded);
											},
											child: Text('${_valuesExpanded ? '▼' : '▶'} ${_translate('values')}'),
										),
										const SizedBox(width: 8),
										TextButton(
											onPressed: () {
												setState(() => _timelineExpanded = !_timelineExpanded);
											},
											child: Text('${_timelineExpanded ? '▼' : '▶'} ${_translate('timeline')}'),
										),
									],
								),
								const SizedBox(height: 12),
								// Values Table (readonly counters)
								if (_valuesExpanded) ...[
									AutoValuesTable(
										key: const ValueKey('auto_values_table'),
										trenchDepotAllianceToNeutral: autoState.trenchDepotAllianceToNeutral,
										bumpDepotAllianceToNeutral: autoState.bumpDepotAllianceToNeutral,
										bumpOutpostAllianceToNeutral: autoState.bumpOutpostAllianceToNeutral,
										trenchOutpostAllianceToNeutral: autoState.trenchOutpostAllianceToNeutral,
										trenchDepotNeutralToAlliance: autoState.trenchDepotNeutralToAlliance,
										bumpDepotNeutralToAlliance: autoState.bumpDepotNeutralToAlliance,
										bumpOutpostNeutralToAlliance: autoState.bumpOutpostNeutralToAlliance,
										trenchOutpostNeutralToAlliance: autoState.trenchOutpostNeutralToAlliance,
										fuelScore: autoState.fuelScore,
										fuelNeutralAlliancePass: autoState.fuelNeutralAlliancePass,
										allianceTime: autoState.allianceTime,
										neutralTime: autoState.neutralTime,
									),
									const SizedBox(height: 12),
								],
								// Timeline Table
								if (_timelineExpanded)
									AutoTimelineTable(
										key: const ValueKey('auto_timeline_table'),
										events: autoState.timeline,
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
								// Undo button
								FilledButton(
									style: FilledButton.styleFrom(
										backgroundColor: autoState.timeline.isNotEmpty
											? AppColors.buttonBgColor
											: Colors.grey.shade700,
										foregroundColor: autoState.timeline.isNotEmpty
											? AppColors.buttonFgColor
											: Colors.grey.shade500,
										padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									onPressed: autoState.timeline.isNotEmpty
										? () {
											ref.read(autoTabControllerProvider.notifier).undo();
										}
										: null,
									child: Text(
										_translate('undo'),
										style: TextStyle(fontSize: _getResponsiveFontSize(12)),
									),
								),
								const SizedBox(height: 8),
								// Robot/Team indicator - team color background with contrasting text
								Container(
									padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
										padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(8),
										),
									),
									onPressed: _saveTab,
									child: Text(
										_translate('proceed_tele_button'),
										style: TextStyle(fontSize: _getResponsiveFontSize(12)),
									),
								),
							],
						),
					),
				],
			),
		),

		const SizedBox(height: 16),
		],
		),
	);
	}

	/// Build a fuel quick-add button
	Widget _buildFuelButton(
		String label,
		int amount,
		AutoTabState autoState,
		WidgetRef ref,
	) {
		return SizedBox(
			width: 70,
			height: 70,
			child: ElevatedButton(
				onPressed: () {
					// Use the correct fuel counter based on active target
					final fuelField = autoState.activeFuelTarget == 'hub'
						? 'auto_fuel_score'
						: 'auto_fuel_neutral_alliance_pass';

					ref.read(autoTabControllerProvider.notifier).recordAction(
						type: 'fuel',
						field: fuelField,
						value: amount,
						actionLabel: 'Fuel',
						valueLabel: '+$amount',
					);
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
}
