"use strict"

addI18n({
	event_downloaded_title:{
		en:'_EVENT_ API Data',
		fr:'Données API _ÉVÉNEMENT_',
		zh_tw:'_EVENT_ API 數據',
		tr:'_EVENT_ API Verileri',
		pt:'_EVENTO_ Dados da API',
		he:'_EVENT_ נתוני API',
	},
	event_download_instruction:{
		en:'How would you like to use the data?',
		fr:'Comment souhaitez-vous utiliser ces données ?',
		zh_tw:'您希望如何使用這些數據？',
		tr:'Verileri nasıl kullanmak istersiniz?',
		pt:'Como você gostaria de usar os dados?',
		he:'כיצד תרצה להשתמש בנתונים?',
	},
	update_schedule_link:{
		en:'Update schedule',
		fr:'Mettre à jour le calendrier',
		zh_tw:'更新時間表',
		tr:'Programı güncelle',
		pt:'Atualizar cronograma',
		he:'עדכן את לוח הזמנים',
	},
	compare_scouting_link:{
		en:'Compare scouting data',
		fr:'Comparer les données de repérage',
		zh_tw:'比較偵察數據',
		tr:'İzleme verilerini karşılaştır',
		pt:'Comparar dados de olheiros',
		he:'השווה נתוני צופים',
	},
	scouter_rankings_link:{
		en:'See scouter rankings',
		fr:'Consulter le classement des recruteurs',
		zh_tw:'查看球探排名',
		tr:'İzci sıralamalarını gör',
		pt:'Ver classificações de olheiros',
		he:'ראה דירוג צופים',
	},
	view_event_link:{
		en:'View the event page',
		fr:'Consulter la page de l\'événement',
		zh_tw:'查看活動頁面',
		tr:'Etkinlik sayfasını görüntüle',
		pt:'Visualizar a página do evento',
		he:'צפו בדף האירוע',
	},
})

$(document).ready(function(){
	$('h1,title').attr('data-event',eventName)
	$('a').each(function(){
		$(this).attr('href',$(this).attr('href').replace(/EVENT/,eventId))
	})
	applyTranslations()
})
