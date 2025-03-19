"use strict"

addI18n({
	export_title:{
		en:'Export _EVENT_ data',
		tr:'_EVENT_ verilerini dışa aktar',
		he:'ייצא נתונים של _EVENT_',
		pt:'Exportar dados _EVENT_',
		zh_tw:'導出_EVENT_數據',
		fr:'Exporter les données _EVENT_',
	},
	with_images_heading:{
		en:'With Images',
		tr:'Görüntülerle',
		he:'עם תמונות',
		pt:'Com imagens',
		zh_tw:'帶有圖片',
		fr:'Avec images',
	},
	with_images_download_description:{
		en:'Download all data and images for this event in JSON format:',
		tr:'Bu etkinlik için tüm verileri ve görüntüleri JSON formatında indirin:',
		he:'הורד את כל הנתונים והתמונות עבור אירוע זה בפורמט JSON:',
		pt:'Baixe todos os dados e imagens para este evento no formato JSON:',
		zh_tw:'以 JSON 格式下載此事件的所有資料和圖像：',
		fr:'Télécharger toutes les données et images de cet événement au format JSON :',
	},
	with_images_download_link:{
		en:'Download Full Event',
		tr:'Tam Etkinliği İndir',
		he:'הורד את האירוע המלא',
		pt:'Baixe o evento completo',
		zh_tw:'下載完整活動',
		fr:'Télécharger l\'événement complet',
	},
	with_images_transfer_description:{
		en:'Transfer all the event data and images to another Viper instance.',
		tr:'Tüm etkinlik verilerini ve görüntüleri başka bir Viper örneğine aktarın.',
		he:'העבר את כל נתוני האירוע והתמונות למופע אחר של Viper.',
		pt:'Transfira todos os dados e imagens do evento para outra instância do Viper.',
		zh_tw:'將所有事件資料和影像傳輸到另一個 Viper 實例。',
		fr:'Transférer toutes les données et images de l\'événement vers une autre instance Viper.',
	},
	with_images_transfer_button:{
		en:'Transfer Full Event',
		tr:'Tam Etkinliği Aktar',
		he:'העבר את האירוע המלא',
		pt:'Transfira o evento completo',
		zh_tw:'轉移完整事件',
		fr:'Transférer l\'événement complet',
	},
	without_images_heading:{
		en:'Without Images',
		tr:'Görüntüler Olmadan',
		he:'בלי תמונות',
		pt:'Sem imagens',
		zh_tw:'無影像',
		fr:'Sans images',
	},
	without_images_download_description:{
		en:'Download all data (but no images) for this event in JSON format',
		tr:'Bu etkinlik için tüm verileri (ancak görüntüleri değil) JSON formatında indirin',
		he:'הורד את כל הנתונים (אך ללא תמונות) עבור האירוע הזה בפורמט JSON',
		pt:'Baixe todos os dados (mas nenhuma imagem) para este evento no formato JSON',
		zh_tw:'以 JSON 格式下載此事件的所有資料（但不包含圖像）',
		fr:'Télécharger toutes les données (sauf les images) de cet événement au format JSON',
	},
	without_images_download_link:{
		en:'Download Data',
		tr:'Verileri İndir',
		he:'הורד נתונים',
		pt:'Baixe os dados',
		zh_tw:'下載數據',
		fr:'Télécharger les données',
	},
	without_images_transfer_description:{
		en:'Transfer all the data to another Viper instance.',
		tr:'Tüm verileri başka bir Viper örneğine aktarın.',
		he:'העבר את כל הנתונים למופע אחר של Viper.',
		pt:'Transfira todos os dados para outra instância do Viper.',
		zh_tw:'將所有資料傳輸到另一個 Viper 實例。',
		fr:'Transférer toutes les données vers une autre instance Viper.',
	},
	without_images_transfer_button:{
		en:'Transfer Data',
		tr:'Verileri Aktar',
		he:'העברת נתונים',
		pt:'Transfira os dados',
		zh_tw:'傳輸資料',
		fr:'Transférer les données',
	},
})

addTranslationContext({
	event:eventName
})

var hosts={}

function addHost(host){
	if (host && !hosts[host]){
		hosts[host]=1
		$('.hostOptions').append($('<li>').text(host).click(setHost))
	}
}

function setHost(){
	var input=$(this).closest('form').find('.siteInput')
	input.val($(this).text())
	hostSet(input)
}

function hostSet(input){
	var url = input.val()
	if (/^((https?\/\/)?)([a-zA-Z0-9\-\.\:]+)(\/?)$/.test(url)){
		var hosts = (localStorage.getItem("transferHosts")||"").split(/,/),
		hostList = hosts.reduce((m,o)=>(m[o]=o,m),{})
		if (!hostList.hasOwnProperty(url)){
			hosts.push(url)
			hosts = hosts.slice(-5)
			localStorage.setItem("transferHosts",hosts.join(","))
		}
		addHost(url)
	}
	if (!url) url = "example.viperscout.com"
	if (!/^https?\:\/\//.test(url)){
		var prefix = "http"
		if (/\./.test(url)) prefix="https" // fully qualified domain
		if (/^[0-9\.\:]+$/.test(url)) prefix="http" // IP address
		url = `${prefix}://${url}`
	}
	url = url.replace(/\/$/,"")
	url += "/admin/import.cgi"
	input.closest('form').attr('action',url)

}

$(document).ready(function(){
	var dataFull = {},
	dataText = {},
	fullFileCount = -1,
	textFileCount = -1
	if (!eventId) return $('#contents').text('No event ID')
	promiseEventFiles().then(fileList => {
		fullFileCount = fileList.length
		if (!fullFileCount) return $('#contents').text(`No ${eventId} files`)
		var textFiles = 0
		fileList.forEach(file=>{
			if (/\.jpg$/.test(file)){
				toDataURL(file, dataUrl => {
					dataFull[file] = dataUrl
				})
			} else {
				textFiles++
				promiseEventAjax(file).then(text => {
					dataFull[file] = text||""
					dataText[file] = text||""
				})
			}
		})
		textFileCount = textFiles
	})
	$('.siteInput').change(function(){
		hostSet($(this))
	})
	$('#showInstructions').click(function(){
		showLightBox($('#instructions'))
		return false
	})
	$('title,h1').each(function(){
		$(this).text($(this).text().replace(/EVENT/, eventName))
	})
	function fullDataLoaded(){
		if (Object.keys(dataFull).length != fullFileCount){
			setTimeout(fullDataLoaded,100)
			return
		}
		var json = JSON.stringify(dataFull)
		$('#downloadImages')
			.attr('href', window.URL.createObjectURL(new Blob([json], {type: 'text/json;charset=utf-8'})))
			.attr('download',`${eventId}.full.json`)
		$('#transferJsonImages').val(json)
		$('#loadingImages').hide()
		$('#submitImages').removeAttr('disabled')
	}
	fullDataLoaded()
	function textDataLoaded(){
		if (Object.keys(dataText).length != textFileCount){
			setTimeout(textDataLoaded,100)
			return
		}
		var json = JSON.stringify(dataText)
		$('#downloadData')
			.attr('href', window.URL.createObjectURL(new Blob([json], {type: 'text/json;charset=utf-8'})))
			.attr('download',`${eventId}.dat.json`)
		$('#transferJsonData').val(json)
		$('#loadingData').hide()
		$('#submitData').removeAttr('disabled')
	}
	textDataLoaded()
	;(localStorage.getItem("transferHosts")||"").split(",").forEach(addHost)
	if (window.transferHosts) window.transferHosts.forEach(addHost)
	addHost('localhost')
	$('form').submit(function(e){
		if($(this).find('[disabled]')){
			e.preventDefault()
			return false
		}
		return true
	})
})

// https://stackoverflow.com/a/20285053
function toDataURL(url, callback){
	var xhr = new XMLHttpRequest()
	xhr.onload = function(){
		var reader = new FileReader()
		reader.onloadend = function(){
			var url = reader.result
			if (!url.startsWith("data:image/jpeg;base64")) url = ""
			callback(url)
		}
		reader.readAsDataURL(xhr.response)
	}
	xhr.open('GET', url)
	xhr.responseType = 'blob'
	xhr.send()
}
