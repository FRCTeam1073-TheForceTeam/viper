"use strict"

addI18n({
	add_event_title:{
		en:'Add an Event',
		pt:'Adicionar um evento',
		fr:'Ajouter un événement',
		tr:'Bir Etkinlik Ekle',
		zh_tw:'新增事件',
	},
	add_event_comp_type:{
		en:'Competition type:',
		pt:'Tipo de competição:',
		fr:'Type de compétition :',
		tr:'Yarışma türü:',
		zh_tw:'比賽類型：',
	},
	add_event_data_entry_title:{
		en:'Data entry',
		pt:'Entrada de dados',
		fr:'Saisie des données',
		tr:'Veri girişi',
		zh_tw:'資料輸入',
	},
	add_event_data_entry_description:{
		en:'Enter team numbers for each match.',
		pt:'Insira os números dos times para cada partida.',
		fr:'Saisissez les numéros d\'équipe pour chaque match.',
		tr:'Her maç için takım numaralarını girin.',
		zh_tw:'輸入每場比賽的球隊號碼。',
	},
	add_event_upload_title:{
		en:'Upload match schedule',
		pt:'Carregar cronograma de partidas',
		fr:'Téléchargez le calendrier des matchs',
		tr:'Maç programını yükle',
		zh_tw:'上傳比賽行程',
	},
	add_event_upload_description:{
		en:'Copy and paste a team list or a match schedule from FIRST Events, The Blue Alliance, or The Orange Alliance websites.',
		pt:'Copie e cole uma lista de times ou um cronograma de partidas dos sites FIRST Events, The Blue Alliance ou The Orange Alliance.',
		fr:'Copiez et collez une liste d\'équipe ou un calendrier de match depuis les sites web de FIRST Events, The Blue Alliance ou The Orange Alliance.',
		tr:'FIRST Events, The Blue Alliance veya The Orange Alliance web sitelerinden bir takım listesini veya maç programını kopyalayıp yapıştırın.',
		zh_tw:'從 FIRST Events、藍色聯盟或橙色聯盟網站複製並貼上球隊名單或比賽日程。',
	},
	add_event_api_title:{
		en:'From the _COMP_ API',
		pt:'Da API _COMP_',
		fr:'Depuis l\'API _COMP_',
		tr:'_COMP_ API\'sinden',
		zh_tw:'來自 _COMP_ API',
	},
	add_event_api_description:{
		en:' Select an event from the official list.',
		pt:'Selecione um evento da lista oficial.',
		fr:'Sélectionnez un événement dans la liste officielle.',
		tr:'Resmi listeden bir etkinlik seçin.',
		zh_tw:'從官方清單中選擇一個事件。',
	},
	add_event_import_title:{
		en:'Import from Viper',
		pt:'Importar do Viper',
		fr:'Importer depuis Viper',
		tr:'Viper\'dan içe aktar',
		zh_tw:'從 Viper 匯入',
	},
	add_event_import_description:{
		en:'Import data exported from another Viper instance.',
		pt:'Importar dados exportados de outra instância do Viper.',
		fr:'Importez les données exportées depuis une autre instance Viper.',
		tr:'Başka bir Viper örneğinden dışa aktarılan verileri içe aktar.',
		zh_tw:'匯入從另一個 Viper 實例匯出的資料。',
	},
	add_event_import_file:{
		en:'.json file:',
		pt:'Arquivo .json:',
		fr:'Fichier .json :',
		tr:'.json dosyası:',
		zh_tw:'.json 檔：',
	},
	add_event_import_upload:{
		en:'Upload',
		pt:'Carregar',
		fr:'Téléchargement',
		tr:'Yükle',
		zh_tw:'上傳',
	},
})

onApplyTranslation.push(setComp)

function setComp(){
	var comp = $('#comp').val(),
	season = new Date().getFullYear();
	if (comp == 'ftc'){
		if (new Date().getMonth <= 8) season--
		season += "-" + (season+1+"").slice(-2)
	}
	location.hash=comp
	$('a').each(function(){
		$(this).attr('href',$(this).attr('href').replace(/_COMP_|\bftc\b|\bfrc\b/gi, comp))
		$(this).attr('href',$(this).attr('href').replace(/_SEASON_|20[0-9]{2}(-[0-9]{2})?/g, season))
		$(this).text($(this).text().replace(/_COMP_|\bftc\b|\bfrc\b/gi, comp.toUpperCase()))
	})
}

$(document).ready(function(){
	var hash = location.hash.replace(/^#/,"")
	$(`#comp option[value="${hash}"]`).attr('selected', 'selected')
	$('#comp').change(setComp)
	setComp()
})
