import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/colors.dart';
import '../../../../providers/app_providers.dart';
import '../../providers/scouting_data_provider.dart';
import '../../../../providers/field_side_provider.dart';
import '../../../../providers/locale_provider.dart';
import '../../../../providers/timeline_provider.dart';
import '../../../../providers/match_timer_provider.dart';
import '../../providers/undo_coordinator.dart';
import '../../../../providers/button_position_provider.dart';
import '../../../../services/localization.dart';
import '../../widgets/tele_field_overlay.dart';
import '../../widgets/values_table.dart';
import '../../../../widgets/timeline_table.dart';
import '../../../../widgets/popup_floater.dart';
import '../../../../models/field_button.dart';
import '../../../../providers/floating_popup_provider.dart';

typedef TeleTabRecord = ({
	String activeZone,
	String activeFuelTarget,
	int fuelScore,
	int fuelAllianceDump,
	int fuelOutpost,
	int fuelNeutralAlliancePass,
	int fuelOpponentNeutralPass,
	int fuelOpponentAlliancePass,
	int allianceTime,
	int neutralTime,
	int opponentTime,
	int climbLevel,
});

/// Initialize Tele Tab translations
void _initTeleTabTranslations() {
	AppLocalizations.addI18n({
		// Tab header
		'tele_heading': {
			'en': 'Teleop Period',
			'es': 'Período de Teleoperación',
			'pt': 'Período de Teleoperação',
			'fr': 'Période Téléopérée',
			'zh_tw': '遙控操作期間',
			'he': 'תקופת טלאופ',
			'tr': 'Teleop Dönemi',
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

		// Movement labels
		'trench_outpost_neutral_to_opponent': {
			'en': 'Trench Outpost → Opponent',
			'es': 'Trinchera Puesto Avanzado → Oponente',
			'pt': 'Trincheira Avanço → Oponente',
			'fr': 'Tranchée Avant-Poste → Opposant',
			'zh_tw': '壕溝哨站 → 對手',
			'he': 'משק עמוק צפוי → יריב',
			'tr': 'Hendek Karakol → Rakip',
		},
		'bump_outpost_neutral_to_opponent': {
			'en': 'Bump Outpost → Opponent',
			'es': 'Golpe Puesto Avanzado → Oponente',
			'pt': 'Bump Avanço → Oponente',
			'fr': 'Bump Avant-Poste → Opposant',
			'zh_tw': '碰撞哨站 → 對手',
			'he': 'דחיפה אחסון צפוי → יריב',
			'tr': 'Bump Karakol → Rakip',
		},
		'bump_depot_neutral_to_opponent': {
			'en': 'Bump Depot → Opponent',
			'es': 'Golpe Depósito → Oponente',
			'pt': 'Bump Depósito → Oponente',
			'fr': 'Bump Dépôt → Opposant',
			'zh_tw': '碰撞倉庫 → 對手',
			'he': 'דחיפה אחסון → יריב',
			'tr': 'Bump Depo → Rakip',
		},
		'trench_depot_neutral_to_opponent': {
			'en': 'Trench Depot → Opponent',
			'es': 'Trinchera Depósito → Oponente',
			'pt': 'Trincheira Depósito → Oponente',
			'fr': 'Tranchée Dépôt → Opposant',
			'zh_tw': '壕溝倉庫 → 對手',
			'he': 'משק אחסון עמוק → יריב',
			'tr': 'Hendek Depo → Rakip',
		},
		'trench_outpost_opponent_to_neutral': {
			'en': 'Trench Outpost ← Opponent',
			'es': 'Trinchera Puesto Avanzado ← Oponente',
			'pt': 'Trincheira Avanço ← Oponente',
			'fr': 'Tranchée Avant-Poste ← Opposant',
			'zh_tw': '壕溝哨站 ← 對手',
			'he': 'משק עמוק צפוי ← יריב',
			'tr': 'Hendek Karakol ← Rakip',
		},
		'bump_outpost_opponent_to_neutral': {
			'en': 'Bump Outpost ← Opponent',
			'es': 'Golpe Puesto Avanzado ← Oponente',
			'pt': 'Bump Avanço ← Oponente',
			'fr': 'Bump Avant-Poste ← Opposant',
			'zh_tw': '碰撞哨站 ← 對手',
			'he': 'דחיפה אחסון צפוי ← יריב',
			'tr': 'Bump Karakol ← Rakip',
		},
		'bump_depot_opponent_to_neutral': {
			'en': 'Bump Depot ← Opponent',
			'es': 'Golpe Depósito ← Oponente',
			'pt': 'Bump Depósito ← Oponente',
			'fr': 'Bump Dépôt ← Opposant',
			'zh_tw': '碰撞倉庫 ← 對手',
			'he': 'דחיפה אחסון ← יריב',
			'tr': 'Bump Depo ← Rakip',
		},
		'trench_depot_opponent_to_neutral': {
			'en': 'Trench Depot ← Opponent',
			'es': 'Trinchera Depósito ← Oponente',
			'pt': 'Trincheira Depósito ← Oponente',
			'fr': 'Tranchée Dépôt ← Opposant',
			'zh_tw': '壕溝倉庫 ← 對手',
			'he': 'משק אחסון עמוק ← יריב',
			'tr': 'Hendek Depo ← Rakip',
		},

		// Fuel labels
		'fuel_alliance_dump': {
			'en': 'Fuel Alliance Dump',
			'es': 'Descarga de Alianza',
			'pt': 'Descarga de Aliança',
			'fr': 'Vidage Alliance',
			'zh_tw': '聯盟傾倒',
			'he': 'זריקת ברית',
			'tr': 'İttifak Boşaltma',
		},
		'fuel_outpost': {
			'en': 'Fuel Outpost',
			'es': 'Combustible Puesto Avanzado',
			'pt': 'Combustível Avanço',
			'fr': 'Carburant Avant-Poste',
			'zh_tw': '燃料前哨',
			'he': 'דלק אחסון צפוי',
			'tr': 'Yakıt Karakolu',
		},
		'fuel_opponent_alliance_pass': {
			'en': 'Opponent Alliance Pass',
			'es': 'Pase de Alianza del Oponente',
			'pt': 'Passe de Aliança do Oponente',
			'fr': 'Passe Alliance Adversaire',
			'zh_tw': '對手聯盟通道',
			'he': 'מעבר ברית של היריב',
			'tr': 'Rakip İttifak Geçiti',
		},
		'fuel_opponent_neutral_pass': {
			'en': 'Opponent Neutral Pass',
			'es': 'Pase Neutral del Oponente',
			'pt': 'Passe Neutra do Oponente',
			'fr': 'Passe Neutre Adversaire',
			'zh_tw': '對手中立通道',
			'he': 'מעבר ניטראלי של היריב',
			'tr': 'Rakip Nötr Geçiti',
		},

		// Zone time labels
		'opponent_time': {
			'en': 'Opponent Time',
			'es': 'Tiempo del Oponente',
			'pt': 'Tempo do Oponente',
			'fr': 'Temps Adversaire',
			'zh_tw': '對手時間',
			'he': 'זמן יריב',
			'tr': 'Rakip Süresi',
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

		// Shared tele labels (from web app analysis)
		'fuel_score': {
			'en': 'Fuel Score',
			'es': 'Puntuación de Combustible',
			'pt': 'Pontuação de Combustível',
			'fr': 'Score de Carburant',
			'zh_tw': '燃料評分',
			'he': 'ניקוד דלק',
			'tr': 'Yakıt Puanı',
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

		// Movement labels for tele (reuse shared ones where available)
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

		// Counter table section headings
		'tele_alliance_to_neutral': {
			'en': 'Alliance to Neutral',
			'es': 'Alianza a Neutral',
			'pt': 'Aliança para Neutro',
			'fr': 'Alliance à Neutre',
			'zh_tw': '聯盟到中立',
			'he': 'ברית לניטראלי',
			'tr': 'İttifak\'tan Tarafsız\'a',
		},
		'tele_neutral_to_alliance': {
			'en': 'Neutral to Alliance',
			'es': 'Neutral a Alianza',
			'pt': 'Neutro para Aliança',
			'fr': 'Neutre à l\'Alliance',
			'zh_tw': '中立到聯盟',
			'he': 'ניטראלי לברית',
			'tr': 'Tarafsız\'tan İttifak\'a',
		},
		'tele_neutral_to_opponent': {
			'en': 'Neutral to Opponent',
			'es': 'Neutral a Oponente',
			'pt': 'Neutro para Oponente',
			'fr': 'Neutre à l\'Opposant',
			'zh_tw': '中立到對手',
			'he': 'ניטראלי ליריב',
			'tr': 'Tarafsız\'tan Rakip\'e',
		},
		'tele_opponent_to_neutral': {
			'en': 'Opponent to Neutral',
			'es': 'Oponente a Neutral',
			'pt': 'Oponente para Neutro',
			'fr': 'Opposant à Neutre',
			'zh_tw': '對手到中立',
			'he': 'יריב לניטראלי',
			'tr': 'Rakip\'ten Tarafsız\'a',
		},

		// Field name translations (for values table)
		'tele_fuel_score': {
			'en': 'Fuel scored in hub',
			'he': 'דלק נקודות בחישוקן',
			'tr': 'Yakıt merkez sepete puanlandı',
			'zh_tw': '燃料在樞紐中得分',
			'fr': 'Carburant marqué dans le hub',
			'pt': 'Combustível marcado no hub',
			'es': 'Combustible anotado en el hub',
		},
		'tele_fuel_alliance_dump': {
			'en': 'Fuel dumped in the alliance zone',
			'he': 'דלק שנזרק לאזור הברית',
			'tr': 'Yakıt ittifak bölgesine dökülmüş',
			'zh_tw': '燃料傾倒在聯盟區域中',
			'fr': 'Carburant versé dans la zone d\'alliance',
			'pt': 'Combustível despejado na zona de aliança',
			'es': 'Combustible vertido en la zona de alianza',
		},
		'tele_fuel_outpost': {
			'en': 'Fuel fed to outpost',
			'he': 'דלק ניזון ל-avanpost',
			'tr': 'Yakıt ileriye görevlendirildi',
			'zh_tw': '燃料供給前哨站',
			'fr': 'Carburant approvisionné au poste avancé',
			'pt': 'Combustível alimentado para o avançado',
			'es': 'Combustible suministrado a la avanzada',
		},
		'tele_fuel_neutral_alliance_pass': {
			'en': 'Fuel passed or pushed to the alliance zone from the neutral zone',
			'he': 'דלק עבר או נדחף לאזור הברית מהאזור הנייטרלי',
			'tr': 'Yakıt nötr bölgeden ittifak bölgesine geçirildi veya itildi',
			'zh_tw': '燃料從中立區傳遞或推送到聯盟區',
			'fr':
					'Carburant passé ou poussé vers la zone d\'alliance à partir de la zone neutre',
			'pt':
					'Combustível passado ou empurrado para a zona de aliança da zona neutra',
			'es':
					'Combustible pasado o empujado a la zona de alianza desde la zona neutral',
		},
		'tele_fuel_opponent_neutral_pass': {
			'en':
					'Fuel passed or pushed to the neutral zone from the opponent\'s zone',
			'he': 'דלק עבר או נדחף לאזור הנייטרלי מהאזור של היריב',
			'tr': 'Yakıt rakibin bölgesinden nötr bölgeye geçirildi veya itildi',
			'zh_tw': '燃料從對手的區域傳遞或推送到中立區',
			'fr':
					'Carburant passé ou poussé vers la zone neutre à partir de la zone adverse',
			'pt':
					'Combustível passado ou empurrado para a zona neutra da zona do oponente',
			'es':
					'Combustible pasado o empujado a la zona neutral desde la zona del oponente',
		},
		'tele_fuel_opponent_alliance_pass': {
			'en':
					'Fuel passed or pushed to the alliance zone from the opponent\'s zone',
			'he': 'דלק עבר או נדחף לאזור הברית מהאזור של היריב',
			'tr': 'Yakıt rakibin bölgesinden ittifak bölgesine geçirildi veya itildi',
			'zh_tw': '燃料從對手的區域傳遞或推送到聯盟區',
			'fr':
					'Carburant passé ou poussé vers la zone d\'alliance à partir de la zone adverse',
			'pt':
					'Combustível passado ou empurrado para a zona de aliança da zona do oponente',
			'es':
					'Combustible pasado o empujado a la zona de alianza desde la zona del oponente',
		},
		'tele_alliance_time': {
			'en': 'Time spent in alliance zone during teleop (seconds)',
			'he': 'זמן שהייה באזור הברית במהלך teleop (שניות)',
			'tr': 'Teleop sırasında ittifak bölgesinde geçirilen süre (saniye)',
			'zh_tw': '遠程操作期間在聯盟區域度過的時間(秒)',
			'fr':
					'Temps passé dans la zone d\'alliance pendant le téléopération (secondes)',
			'pt': 'Tempo gasto na zona de aliança durante o teleop (segundos)',
			'es': 'Tiempo invertido en la zona de alianza durante teleop (segundos)',
		},
		'tele_neutral_time': {
			'en': 'Time spent in neutral zone during teleop (seconds)',
			'he': 'זמן שהייה באזור הנייטרלי במהלך teleop (שניות)',
			'tr': 'Teleop sırasında nötr bölgede geçirilen süre (saniye)',
			'zh_tw': '遠程操作期間在中立區域度過的時間(秒)',
			'fr':
					'Temps passé dans la zone neutre pendant le téléopération (secondes)',
			'pt': 'Tempo gasto na zona neutra durante o teleop (segundos)',
			'es': 'Tiempo invertido en la zona neutral durante teleop (segundos)',
		},
		'tele_opponent_time': {
			'en': 'Time spent in opponent zone during teleop (seconds)',
			'he': 'זמן שהייה באזור של היריב במהלך teleop (שניות)',
			'tr': 'Teleop sırasında rakip bölgesinde geçirilen süre (saniye)',
			'zh_tw': '遠程操作期間在對手區域度過的時間(秒)',
			'fr':
					'Temps passé dans la zone adverse pendant le téléopération (secondes)',
			'pt': 'Tempo gasto na zona do oponente durante o teleop (segundos)',
			'es':
					'Tiempo invertido en la zona del oponente durante teleop (segundos)',
		},

		// Tele zone change field translations (values table)
		'tele_trench_depot_alliance_to_neutral': {
			'en': 'Trench (depot side) alliance to neutral',
			'he': 'תעלה (צד הרחוק) ברית לנייטרלי',
			'tr': 'Hendek (depo tarafı) ittifaktan nötre',
			'zh_tw': '戰壕(仓库方)聯盟到中立',
			'fr': 'Tranchée (côté dépôt) alliance à neutre',
			'pt': 'Trincheira (lado do depósito) aliança a neutro',
			'es': 'Trinchera (lado del depósito) alianza a neutral',
		},
		'tele_bump_depot_alliance_to_neutral': {
			'en': 'Bump (depot side) alliance to neutral',
			'he': 'בליטה (צד הרחוק) ברית לנייטרלי',
			'tr': 'Çarpma (depo tarafı) ittifaktan nötre',
			'zh_tw': '碰撞(仓库方)聯盟到中立',
			'fr': 'Bosse (côté dépôt) alliance à neutre',
			'pt': 'Saliência (lado do depósito) aliança a neutro',
			'es': 'Protuberancia (lado del depósito) alianza a neutral',
		},
		'tele_bump_outpost_alliance_to_neutral': {
			'en': 'Bump (outpost side) alliance to neutral',
			'he': 'בליטה (צד ה-outpost) ברית לנייטרלי',
			'tr': 'Çarpma (ileri görev tarafı) ittifaktan nötre',
			'zh_tw': '碰撞(前哨站側)聯盟到中立',
			'fr': 'Bosse (côté avant-poste) alliance à neutre',
			'pt': 'Saliência (lado do avançado) aliança a neutro',
			'es': 'Protuberancia (lado del avanzada) alianza a neutral',
		},
		'tele_trench_outpost_alliance_to_neutral': {
			'en': 'Trench (outpost side) alliance to neutral',
			'he': 'תעלה (צד ה-outpost) ברית לנייטרלי',
			'tr': 'Hendek (ileri görev tarafı) ittifaktan nötre',
			'zh_tw': '戰壕(前哨站側)聯盟到中立',
			'fr': 'Tranchée (côté avant-poste) alliance à neutre',
			'pt': 'Trincheira (lado do avançado) aliança a neutro',
			'es': 'Trinchera (lado del avanzada) alianza a neutral',
		},
		'tele_trench_depot_neutral_to_alliance': {
			'en': 'Trench (depot side) neutral to alliance',
			'he': 'תעלה (צד הרחוק) נייטרלי לברית',
			'tr': 'Hendek (depo tarafı) nötrden ittifaka',
			'zh_tw': '戰壕(仓库方)中立到聯盟',
			'fr': 'Tranchée (côté dépôt) neutre à alliance',
			'pt': 'Trincheira (lado do depósito) neutro a aliança',
			'es': 'Trinchera (lado del depósito) neutral a alianza',
		},
		'tele_bump_depot_neutral_to_alliance': {
			'en': 'Bump (depot side) neutral to alliance',
			'he': 'בליטה (צד הרחוק) נייטרלי לברית',
			'tr': 'Çarpma (depo tarafı) nötrden ittifaka',
			'zh_tw': '碰撞(仓库方)中立到聯盟',
			'fr': 'Bosse (côté dépôt) neutre à alliance',
			'pt': 'Saliência (lado do depósito) neutro a aliança',
			'es': 'Protuberancia (lado del depósito) neutral a alianza',
		},
		'tele_bump_outpost_neutral_to_alliance': {
			'en': 'Bump (outpost side) neutral to alliance',
			'he': 'בליטה (צד ה-outpost) נייטרלי לברית',
			'tr': 'Çarpma (ileri görev tarafı) nötrden ittifaka',
			'zh_tw': '碰撞(前哨站側)中立到聯盟',
			'fr': 'Bosse (côté avant-poste) neutre à alliance',
			'pt': 'Saliência (lado do avançado) neutro a aliança',
			'es': 'Protuberancia (lado del avanzada) neutral a alianza',
		},
		'tele_trench_outpost_neutral_to_alliance': {
			'en': 'Trench (outpost side) neutral to alliance',
			'he': 'תעלה (צד ה-outpost) נייטרלי לברית',
			'tr': 'Hendek (ileri görev tarafı) nötrden ittifaka',
			'zh_tw': '戰壕(前哨站側)中立到聯盟',
			'fr': 'Tranchée (côté avant-poste) neutre à alliance',
			'pt': 'Trincheira (lado do avançado) neutro a aliança',
			'es': 'Trinchera (lado del avanzada) neutral a alianza',
		},
		'tele_trench_outpost_neutral_to_opponent': {
			'en': 'Trench (outpost side) neutral to opponent',
			'he': 'תעלה (צד ה-outpost) נייטרלי ליריב',
			'tr': 'Hendek (ileri görev tarafı) nötrden rakibe',
			'zh_tw': '戰壕(前哨站側)中立到對手',
			'fr': 'Tranchée (côté avant-poste) neutre à adversaire',
			'pt': 'Trincheira (lado do avançado) neutro a oponente',
			'es': 'Trinchera (lado del avanzada) neutral a oponente',
		},
		'tele_bump_outpost_neutral_to_opponent': {
			'en': 'Bump (outpost side) neutral to opponent',
			'he': 'בליטה (צד ה-outpost) נייטרלי ליריב',
			'tr': 'Çarpma (ileri görev tarafı) nötrden rakibe',
			'zh_tw': '碰撞(前哨站側)中立到對手',
			'fr': 'Bosse (côté avant-poste) neutre à adversaire',
			'pt': 'Saliência (lado do avançado) neutro a oponente',
			'es': 'Protuberancia (lado del avanzada) neutral a oponente',
		},
		'tele_bump_depot_neutral_to_opponent': {
			'en': 'Bump (depot side) neutral to opponent',
			'he': 'בליטה (צד הרחוק) נייטרלי ליריב',
			'tr': 'Çarpma (depo tarafı) nötrden rakibe',
			'zh_tw': '碰撞(仓库方)中立到對手',
			'fr': 'Bosse (côté dépôt) neutre à adversaire',
			'pt': 'Saliência (lado do depósito) neutro a oponente',
			'es': 'Protuberancia (lado del depósito) neutral a oponente',
		},
		'tele_trench_depot_neutral_to_opponent': {
			'en': 'Trench (depot side) neutral to opponent',
			'he': 'תעלה (צד הרחוק) נייטרלי ליריב',
			'tr': 'Hendek (depo tarafı) nötrden rakibe',
			'zh_tw': '戰壕(仓库方)中立到對手',
			'fr': 'Tranchée (côté dépôt) neutre à adversaire',
			'pt': 'Trincheira (lado do depósito) neutro a oponente',
			'es': 'Trinchera (lado del depósito) neutral a oponente',
		},
		'tele_trench_outpost_opponent_to_neutral': {
			'en': 'Trench (outpost side) opponent to neutral',
			'he': 'תעלה (צד ה-outpost) יריב לנייטרלי',
			'tr': 'Hendek (ileri görev tarafı) rakipten nötre',
			'zh_tw': '戰壕(前哨站側)對手到中立',
			'fr': 'Tranchée (côté avant-poste) adversaire à neutre',
			'pt': 'Trincheira (lado do avançado) oponente a neutro',
			'es': 'Trinchera (lado del avanzada) oponente a neutral',
		},
		'tele_bump_outpost_opponent_to_neutral': {
			'en': 'Bump (outpost side) opponent to neutral',
			'he': 'בליטה (צד ה-outpost) יריב לנייטרלי',
			'tr': 'Çarpma (ileri görev tarafı) rakipten nötre',
			'zh_tw': '碰撞(前哨站側)對手到中立',
			'fr': 'Bosse (côté avant-poste) adversaire à neutre',
			'pt': 'Saliência (lado do avançado) oponente a neutro',
			'es': 'Protuberancia (lado del avanzada) oponente a neutral',
		},
		'tele_bump_depot_opponent_to_neutral': {
			'en': 'Bump (depot side) opponent to neutral',
			'he': 'בליטה (צד הרחוק) יריב לנייטרלי',
			'tr': 'Çarpma (depo tarafı) rakipten nötre',
			'zh_tw': '碰撞(仓库方)對手到中立',
			'fr': 'Bosse (côté dépôt) adversaire à neutre',
			'pt': 'Saliência (lado do depósito) oponente a neutro',
			'es': 'Protuberancia (lado del depósito) oponente a neutral',
		},
		'tele_trench_depot_opponent_to_neutral': {
			'en': 'Trench (depot side) opponent to neutral',
			'he': 'תעלה (צד הרחוק) יריב לנייטרלי',
			'tr': 'Hendek (depo tarafı) rakipten nötre',
			'zh_tw': '戰壕(仓库方)對手到中立',
			'fr': 'Tranchée (côté dépôt) adversaire à neutre',
			'pt': 'Trincheira (lado do depósito) oponente a neutro',
			'es': 'Trinchera (lado del depósito) oponente a neutral',
		},
	});
}

class TeleopTab extends ConsumerStatefulWidget {
	final String eventId;
	final String? matchNumber;
	final String? teamNumber;
	final VoidCallback onProceedToEndGame;

	const TeleopTab({
		super.key,
		required this.eventId,
		required this.matchNumber,
		required this.teamNumber,
		required this.onProceedToEndGame,
	});

	@override
	ConsumerState<TeleopTab> createState() => _TeleopTabState();
}

class _TeleopTabState extends ConsumerState<TeleopTab> {
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

	/// Get team color based on bot position
	Color _getTeamColor(String? botPosition) {
		if (botPosition == null) return AppColors.blueTeamColor;
		return botPosition.startsWith('R')
				? AppColors.redTeamColor
				: AppColors.blueTeamColor;
	}

	/// Get responsive font size based on screen width
	double _getResponsiveFontSize(double baseSize) {
		final screenWidth = MediaQuery.of(context).size.width;
		if (screenWidth < 400) return baseSize * 0.85;
		return baseSize;
	}

	@override
	void initState() {
		super.initState();
		_initTeleTabTranslations();
		_focusNode = FocusNode();
		_focusNode.addListener(_onFocusChanged);

		// Access scouting data to ensure descriptors are registered
		ref.read(scoutingDataProvider);

		// Instantiate buttons to trigger descriptor registration
		for (final btn in teleZoneChangeButtons) {
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
		for (final target in teleFuelTargets) {
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

	/// Calculate the position for an undo floater by looking up the button's actual position
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

	/// Start match timer with offset for auto period + gap (20s + 3s = 23s)
	/// Used when button is pressed before timer was started in auto
	void _startMatchIfNeeded() {
		final currentTime = ref.read(matchTimerProvider);
		if (currentTime == null) {
			// Set timer to 23 seconds ago so clock shows ~23 seconds
			final now = DateTime.now();
			final autoAndGapDuration = const Duration(seconds: 23);
			final startTime = now.subtract(autoAndGapDuration);
			ref.read(matchTimerProvider.notifier).setStartTime(startTime);
		}
	}

	@override
	Widget build(BuildContext context) {
		final fieldSide = ref.watch(selectedFieldSideProvider);
		final scoutingData = ref.watch(scoutingDataProvider);
		final botPosition = ref.watch(selectedBotPositionProvider);

		// Debug: Print positioning state when Tele tab is shown
		final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

		// In landscape, constrain field width based on screen height to maintain aspect ratio and leave room for controls
		double? constrainedFieldWidth;
		if (isLandscape) {
			final screenHeight = MediaQuery.of(context).size.height;
			final maxFieldHeight = screenHeight * 0.5;
			constrainedFieldWidth = maxFieldHeight * 1.875; // Maintain 1.875:1 aspect ratio
		}

		// Instantiate overlay early so buttons register their descriptors
		final fieldOverlay = TeleFieldOverlay(
			key: _fieldOverlayKey,
			fieldWidth: constrainedFieldWidth,
			fieldSide: fieldSide,
			activeZone: ref.watch(activeZoneProvider),
			climbLevel: scoutingData.getFieldValue('tele_climb_level').asInt(),
			botPosition: botPosition,
			activeFuelTarget: ref.watch(activeFuelTargetProvider),
			onMovementTapped: (field, action, globalPosition) {
				_startMatchIfNeeded();
				ref
						.read(scoutingDataProvider.notifier)
						.recordTeleAction(field: field, value: 1);
				// Show floating popup at the button that was tapped
				final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
				if (stackBox != null) {
					// Convert button's global position to stack-relative coordinates
					final stackGlobalOffset = stackBox.localToGlobal(Offset.zero);
					final buttonStackRelative = globalPosition - stackGlobalOffset;

					ref.read(floatingPopupProvider.notifier).addPopup('+1', buttonStackRelative.dx, buttonStackRelative.dy);
				}
			},
			onClimbTapped: () {
				_startMatchIfNeeded();
				final currentClimbLevel = scoutingData
						.getFieldValue('tele_climb_level')
						.asInt();
				if (currentClimbLevel < 3) {
					ref
							.read(scoutingDataProvider.notifier)
							.recordTeleAction(
								field: 'tele_climb_level',
								value: currentClimbLevel + 1,
							);
					// Show floating popup at left side of field, offset from top
					try {
						final overlayBox = _fieldOverlayKey.currentContext?.findRenderObject() as RenderBox?;
						if (overlayBox != null) {
							final offset = overlayBox.localToGlobal(Offset.zero);
							final popupX = offset.dx + 40;
							final popupY = offset.dy + 40;
							ref.read(floatingPopupProvider.notifier).addPopup('+1', popupX, popupY);
						}
					} catch (e) {
						// Silently fail
					}
				}
			},
			onFuelTargetTapped: (targetName) {
				ref
						.read(scoutingDataProvider.notifier)
						.changeTeleFuelTarget(targetName);
			},
		);

		// Now access field values (buttons are registered)
		final activeZone = ref.watch(activeZoneProvider);
		var activeFuelTarget = ref.watch(activeFuelTargetProvider);

		// Ensure fuel target is valid for tele phase and zone
		final validTeleTargets = {'hub', 'allianceDump', 'outpost', 'neutralAlliancePass', 'opponentAlliancePass', 'opponentNeutralPass'};
		// Map zone to valid targets for that zone
		final allianceTargets = {'hub', 'allianceDump', 'outpost'};
		final neutralTargets = {'neutralAlliancePass'};
		final opponentTargets = {'opponentAlliancePass', 'opponentNeutralPass'};
		final validTargetsForZone = activeZone == 'alliance' ? allianceTargets :
			activeZone == 'neutral' ? neutralTargets :
			opponentTargets;

		if (!validTeleTargets.contains(activeFuelTarget) || !validTargetsForZone.contains(activeFuelTarget)) {
			// Map zone to valid tele target if coming from auto or zone changed
		final newTarget = activeZone == 'neutral' ? 'neutralAlliancePass' :
			activeZone == 'opponent' ? 'opponentNeutralPass' : 'hub';
			activeFuelTarget = newTarget;
			if (mounted) {
				Future(() {
					if (mounted) {
						ref.read(activeFuelTargetProvider.notifier).changeTarget(newTarget);
					}
				});
			}
		}

		final teleState = (
			activeZone: activeZone,
			activeFuelTarget: activeFuelTarget,
			fuelScore: scoutingData.getFieldValue('tele_fuel_score').asInt(),
			fuelAllianceDump: scoutingData
					.getFieldValue('tele_fuel_alliance_dump')
					.asInt(),
			fuelOutpost: scoutingData.getFieldValue('tele_fuel_outpost').asInt(),
			fuelNeutralAlliancePass: scoutingData
					.getFieldValue('tele_fuel_neutral_alliance_pass')
					.asInt(),
			fuelOpponentNeutralPass: scoutingData
					.getFieldValue('tele_fuel_opponent_neutral_pass')
					.asInt(),
			fuelOpponentAlliancePass: scoutingData
					.getFieldValue('tele_fuel_opponent_alliance_pass')
					.asInt(),
			allianceTime: scoutingData.getFieldValue('tele_alliance_time').asInt(),
			neutralTime: scoutingData.getFieldValue('tele_neutral_time').asInt(),
			opponentTime: scoutingData.getFieldValue('tele_opponent_time').asInt(),
			climbLevel: scoutingData.getFieldValue('tele_climb_level').asInt(),
		);
		final teamColor = _getTeamColor(botPosition);
		final floatingPopups = ref.watch(floatingPopupProvider);

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
								// Field Overlay
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
											// LEFT COLUMN: Fuel and Tables
											Expanded(
												flex: 3,
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.center,
													children: [
														// Fuel buttons row
														Row(
															mainAxisAlignment: MainAxisAlignment.center,
															children: [
																_buildFuelButton('1', 1, teleState, ref),
																const SizedBox(width: 8),
																_buildFuelButton('5', 5, teleState, ref),
																const SizedBox(width: 8),
																_buildFuelButton('10', 10, teleState, ref),
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
											// RIGHT COLUMN: Info
											Expanded(
												flex: 1,
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.stretch,
													children: [
														// Undo button (always enabled to undo either timeline events or timer start)
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
															key: _undoButtonKey,
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
														// Robot indicator
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
														// End game button
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
															onPressed: widget.onProceedToEndGame,
															child: Text(
																'End Game »',
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
										key: const ValueKey('tele_values_table'),
										fieldSelector: (d) => d.teleValuesTableDescription,
									),

								// Timeline Table
								if (_timelineExpanded)
									TimelineTable(
										key: const ValueKey('tele_timeline_table'),
										events: ref.watch(timelineProvider),
									),
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
		TeleTabRecord teleState,
		WidgetRef ref,
	) {
		final buttonKey = GlobalKey();

		// Map activeFuelTarget to field name
		String getFuelField() {
			switch (teleState.activeFuelTarget) {
				case 'hub':
					return 'tele_fuel_score';
				case 'allianceDump':
					return 'tele_fuel_alliance_dump';
				case 'outpost':
					return 'tele_fuel_outpost';
				case 'neutralAlliancePass':
					return 'tele_fuel_neutral_alliance_pass';
				case 'opponentNeutralPass':
					return 'tele_fuel_opponent_neutral_pass';
				case 'opponentAlliancePass':
					return 'tele_fuel_opponent_alliance_pass';
				default:
					return 'tele_fuel_score';
			}
		}

		final field = getFuelField();

		return SizedBox(
			width: 70,
			height: 70,
			child: ElevatedButton(
				key: buttonKey,
				style: ElevatedButton.styleFrom(
					backgroundColor: const Color(0xFFF1CE03),
					foregroundColor: Colors.black87,
					padding: EdgeInsets.zero,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(50),
					),
				),
				onPressed: () {
					_startMatchIfNeeded();
					ref.read(scoutingDataProvider.notifier).recordTeleAction(field: field, value: amount);
				},
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

	/// Build max fuel display and optional reset button
	Widget _buildMaxFuelDisplay(WidgetRef ref) {
		final scoutingData = ref.watch(scoutingDataProvider);
		final fuelScore = scoutingData.getFieldValue('tele_fuel_score').asInt();
		final totalFuel = fuelScore; // Placeholder: accumulate all fuel sources

		return Padding(
			padding: const EdgeInsets.only(right: 8),
			child: Text(
				'${_translate('fuel_capacity_label')} $totalFuel',
				style: TextStyle(
					fontSize: _getResponsiveFontSize(12),
					fontWeight: FontWeight.w500,
				),
			),
		);
	}
}
