"use strict"

const I18N={},
onApplyTranslation=[],
translationContext={}

addI18n({
	text_direction:{
		en:'ltr',
		he:'rtl',
		pt:'ltr',
		fr:'ltr',
		tr:'ltr',
		zh_tw:'ltr',
	},
	date_locale:{
		en:'en-US',
		he:'he-IL',
		pt:'pt-BR',
		fr:'fr-CA',
		tr:'tr-TR',
		zh_tw:'zh-TW',
	},
	home_link:{
		en:'Event List',
		he:'רשימת אירועים',
		pt:'Lista de eventos',
		fr:'Liste des événements',
		tr:'Etkinlik Listesi',
		zh_tw:'事件列表',
	},
	upload_data_link:{
		en:'Upload Data',
		he:'העלה נתונים',
		pt:'Carregar dados',
		fr:'Télécharger des données',
		tr:'Veri Yükle',
		zh_tw:'上傳數據',
	},
	about_link:{
		en:'About this app',
		he:'על האפליקציה הזו',
		pt:'Sobre este aplicativo',
		fr:'À propos de cette application',
		tr:'Bu uygulama hakkında',
		zh_tw:'關於此應用程式',
	},
	my_team_num:{
		en:'My team #',
		he:'הצוות שלי #',
		pt:'Minha equipe #',
		fr:'Mon équipe #',
		tr:'Takımım #',
		zh_tw:'我的團隊',
	},
	instructions:{
		en:'Instructions',
		he:'הוראות',
		pt:'Instruções',
		fr:'Instructions',
		tr:'Talimatlar',
		zh_tw:'指示',
	},
	match:{
		en:'Match',
		he:'לְהַתְאִים',
		pt:'Partida',
		fr:'Match',
		tr:'Maç',
		zh_tw:'匹配',
	},
	mt_pm:{
		en:'Prac­tice ',
		he:'לְתַרְגֵל',
		pt:'Prá­tica ',
		fr:'Ent­raîn­ement ',
		tr:'Uygulama ',
		zh_tw:'實踐',
	},
	mt_qm:{
		en:'Qual­ific­ation ',
		he:'הַכשָׁרָה',
		pt:'Qua­lifi­cação ',
		fr:'Qual­ific­ation ',
		tr:'Eleme ',
		zh_tw:'資格',
	},
	mt_qf:{
		en:'Quar­ter-final ',
		he:'רֶבַע הַגְמָר',
		pt:'Quar­tas de final ',
		fr:'Quart de finale ',
		tr:'Çeyrek final ',
		zh_tw:'四分之一決賽',
	},
	mt_sf:{
		en:'Semi-final ',
		he:'חצי גמר',
		pt:'Semi­final ',
		fr:'Demi-finale ',
		tr:'Yarı final ',
		zh_tw:'準決賽',
	},
	mt_1p:{
		en:'Play­offs first round ',
		he:'סיבוב ראשון בפלייאוף',
		pt:'Prim­eira rod­ada do play­off ',
		fr:'Prem­ier tour des play­offs ',
		tr:'Playoff birinci tur ',
		zh_tw:'季後賽第一輪',
	},
	mt_2p:{
		en:'Play­offs second round ',
		he:'סיבוב שני בפלייאוף',
		pt:'Seg­unda rod­ada do play­off ',
		fr:'Deux­ième tour des play­offs ',
		tr:'Playoff ikinci tur ',
		zh_tw:'季後賽第二輪',
	},
	mt_3p:{
		en:'Play­offs third round ',
		he:'סיבוב שלישי בפלייאוף',
		pt:'Ter­ceira ro­dada do play­off ',
		fr:'Trois­ième tour des play­offs ',
		tr:'Playoff üçüncü tur ',
		zh_tw:'季後賽第三輪',
	},
	mt_4p:{
		en:'Play­offs fourth round ',
		he:'סיבוב רביעי בפלייאוף',
		pt:'Quarta ro­dada do play­off ',
		fr:'Quat­rième tour des play­offs ',
		tr:'Playoff dördüncü tur ',
		zh_tw:'季後賽第四輪',
	},
	mt_5p:{
		en:'Play­offs fifth round ',
		he:'סיבוב חמישי בפלייאוף',
		pt:'Quinta ro­dada do play­off',
		fr:'Cinq­uième tour des play­offs ',
		tr:'Playoff beşinci tur ',
		zh_tw:'季後賽第五輪',
	},
	mt_f:{
		en:'Final ',
		he:'סוֹפִי',
		pt:'Final ',
		fr:'Finale ',
		tr:'Final ',
		zh_tw:'最終的',
	},
	mts_pm:{
		en:'Prac ',
		he:'לְתַרְגֵל',
		pt:'Prá­t ',
		fr:'Ent ',
		tr:'Uyg ',
		zh_tw:'實踐',
	},
	mts_qm:{
		en:'Qual ',
		he:'הַכשָׁרָה',
		pt:'Qual ',
		fr:'Qual ',
		tr:'Elem ',
		zh_tw:'資格',
	},
	mts_qf:{
		en:'QF ',
		he:'רֶבַע הַגְמָר',
		pt:'QF',
		fr:'QF ',
		tr:'ÇF ',
		zh_tw:'四分之一決賽',
	},
	mts_sf:{
		en:'SF ',
		he:'חצי גמר',
		pt:'SF',
		fr:'DF ',
		tr:'YF',
		zh_tw:'準決賽',
	},
	mts_1p:{
		en:'Play­off R1 M',
		he:'סיבוב ראשון בפלייאוף',
		pt:'Play­off R1 M',
		fr:'Prem­ier tour des play­offs ',
		tr:'Play­off R1 M',
		zh_tw:'季後賽 R1 M',
	},
	mts_2p:{
		en:'Play­off R2 M',
		he:'סיבוב שני בפלייאוף',
		pt:'Play­off R2 M',
		fr:'Deux­ième tour des play­offs ',
		tr:'Play­off R2 M',
		zh_tw:'季後賽 R2 M',
	},
	mts_3p:{
		en:'Play­off R3 M',
		he:'סיבוב שלישי בפלייאוף',
		pt:'Play­off R3 M',
		fr:'Trois­ième tour des play­offs ',
		tr:'Play­off R3 M',
		zh_tw:'季後賽 R3 M',
	},
	mts_4p:{
		en:'Play­off R4 M',
		he:'סיבוב רביעי בפלייאוף',
		pt:'Play­off R4 M',
		fr:'Quat­rième tour des play­offs ',
		tr:'Play­off R4 M',
		zh_tw:'季後賽 R4 M',
	},
	mts_5p:{
		en:'Play­off R5 M',
		he:'סיבוב חמישי בפלייאוף',
		pt:'Play­off R5 M',
		fr:'Cinq­uième tour des play­offs ',
		tr:'Play­off R5 M',
		zh_tw:'季後賽 R5 M',
	},
	mts_f:{
		en:'Final ',
		he:'סוֹפִי',
		pt:'Final ',
		fr:'Finale ',
		tr:'Final ',
		zh_tw:'最終的',
	},
	cancel_button:{
		en:'Cancel',
		he:'לְבַטֵל',
		pt:'Cancelar',
		fr:'Annuler',
		tr:'İptal etmek',
		zh_tw:'取消',
	},
	save_button:{
		en:'Save',
		pt:'Salvar',
		fr:'Enregistrer',
		zh_tw:'節省',
		he:'לְהַצִיל',
		tr:'Kaydet',
	},
	next_button:{
		en:'Next',
		he:'הַבָּא',
		pt:'Próximo',
		fr:'Aller ensuite',
		tr:'Sonraki',
		zh_tw:'下一個',
	},
	edit_link:{
		en:'Edit',
		pt:'Editar',
		he:'לַעֲרוֹך',
		tr:'Düzenle',
		fr:'Modifier',
		zh_tw:'編輯',
	},
	delete_button:{
		en:'Delete',
		tr:'Sil',
		he:'לִמְחוֹק',
		zh_tw:'刪除',
		fr:'Supprimer',
		pt:'Excluir',
	},
	stats_include_practice:{
		en:'Stats include practice matches',
		he:'הסטטיסטיקה כוללת משחקי אימון',
		pt:'Estatísticas incluem partidas de treino',
		tr:'İstatistikler, antrenman maçlarını içerir',
		zh_tw:'統計數據包括練習賽',
		fr:'Statistiques incluant les matchs d\'entraînement',
	},
	stats_exclude_practice:{
		en:'Stats exclude practice matches',
		he:'הסטטיסטיקה אינה כוללת משחקי אימון',
		pt:'Estatísticas excluem partidas de treino',
		tr:'İstatistikler, antrenman maçlarını hariç tutar',
		zh_tw:'數據不包括練習賽',
		fr:'Statistiques excluant les matchs d\'entraînement',
	},
	display_graphs:{
		en:'Graphs',
		he:'גרפים',
		pt:'Gráficos',
		tr:'Grafikler',
		zh_tw:'圖表',
		fr:'Graphiques',
	},
	display_table:{
		en:'Table',
		he:'לוּחַ',
		pt:'Tabela',
		tr:'Tablo',
		zh_tw:'桌子',
		fr:'Tableau',
	},
	red_heading:{
		en:'Red',
		tr:'Vermelho',
		he:'אָדוֹם',
		zh_tw:'紅色的',
		pt:'Vermelho',
		fr:'Rouge',
	},
	blue_heading:{
		en:'Blue',
		tr:'Azul',
		he:'כְּחוֹל',
		zh_tw:'藍色的',
		pt:'Azul',
		fr:'Bleu',
	},
})
var locale=computeLocale()

function addI18n(i){
	Object.assign(I18N,i)
}

function addTranslationContext(c){
	Object.assign(translationContext,c)
}

function computeLocale(){
	var l=localStorage.locale||navigator.language||'en'
	l=l.replace(/\-/g,"_")
	while(l){
		if(l=='qd'||Object.hasOwn(I18N.home_link,l)) return l
		l=l.replace(/[_]?[^_]*$/,"")
	}
	return 'en'
}

function translate(key,context,l){
	context=Object.assign({},translationContext,context||{})
	var g=I18N[key]||(window.statInfo||{})[key]||(window.teamGraphs||{})[key]||(window.aggregateGraphs||{})[key]||(window.matchPredictorSections||{})[key]||{}
	l||=locale
	if(l=='qd')return (g.en||g.name||key).replace(/[^ ]/g,'.')
	while(l){
		var t=g[l]||(locale=='en'?g.name:'')
		if(t){
			Object.entries(context).forEach(([key,value])=>{
				t=t.replace(`_${key.toUpperCase().replace(/[^A-Z0-9]/g,'')}_`,value)
			})
			t=t.replace(/_[A-Z]+_/g,"")
			return t
		}
		l=l.replace(/[_]?[^_]*$/,"")
	}
	return key
}

function getDate(s){
	if (!s) return ""
	var m = /[0-9]{4}-[0-9]{2}-[0-9]{2}/.exec(s)
	if (m) return m[0]
	return ""
}

function dateCompare(a,b){
	return getDate(b).localeCompare(getDate(a))
}

function translationAttributes(node){
	return Object.fromEntries(Array.from(node.attributes).map(i=>{
		if(!/^data-/.test(i.name))return null
		if(/^data-translate-/.test(i.name))return[i.name.replace(/^data-translate-/,''),translate(i.value)]
		return[i.name.replace(/^data-/,''),i.value]
	}).filter(a=>a!=null))
}

function applyTranslations(node){
	if(!node){
		node=$('html')
		onApplyTranslation.forEach(x=>x())
	}
	$('html').attr('dir',translate('text_direction')).attr('lang',locale.replace(/[_\-].*/,""))
	node.find('[data-i18n]').each(function(){
		$(this).text(translate($(this).attr('data-i18n'),translationAttributes(this)))
	})
	node.find('[data-i18n-value]').each(function(){
		$(this).attr('value',translate($(this).attr('data-i18n-value'),translationAttributes(this)))
	})
	node.find('[data-i18n-placeholder]').each(function(){
		$(this).attr('placeholder',translate($(this).attr('data-i18n-placeholder'),translationAttributes(this)))
	})
	node.find('[data-i18n-tooltip]').each(function(){
		$(this).attr('data-tooltip',translate($(this).attr('data-i18n-tooltip'),translationAttributes(this)))
	})
	try{
		$('iframe').each(function(){
			var w = $(this)[0].contentWindow
			if (w.locale && w.applyTranslations){
				w.locale=locale
				w.applyTranslations()
			}
		})
	}catch(x){
		console.error(x)
	}
}

$(document).ready(function(){
	if (!inIframe()){
		var hamburger = $('<div id=hamburger class=show-only-when-connected>☰</div>'),
		mainMenu = $('<div id=mainMenu class=lightBoxCenterContent>')
		$('body').append(hamburger).append(mainMenu)
		hamburger.click(function(){showLightBox(mainMenu)})

		populateMainMenu()

		function populateMainMenu(){
			Promise.all([
				fetch('/main-menu.html').then(response=>response.text()),
				fetch('/user.cgi').then(response=>response.text())
			]).then(values =>{
				var [menuHtml, userName] = values,
				lastEventId=localStorage.getItem('last_event_id'),
				eId = window.eventId||lastEventId||"",
				eName = window.eventName||(eId==lastEventId?localStorage.getItem('last_event_name'):"")||"",
				eYear = window.eventYear||(eId==lastEventId?localStorage.getItem('last_event_year'):"")||""
				mainMenu.html(
					menuHtml
						.replace(/EVENT_NAME/g,eName)
						.replace(/EVENT_ID/g,eId)
						.replace(/YEAR/g,eYear)
				)
				applyTranslations(mainMenu)
				mainMenu.find('.dependEvent').toggle(eName&&!/^20[0-9]{2}(-[0-9]{2})?combined$/.test(eId||""))
				mainMenu.find('.my-team-input').val(getLocalTeam()).change(function(){
					localStorage.setItem('my-team', parseInt($(this).val()))
					location.reload()
				})
				$('#locale-choose').val(locale).change(function(){
					localStorage.locale=locale=$(this).val()
					applyTranslations()

				})
				showMainMenuUploads()
				$('#logout-link').click(function(){
					var req = new XMLHttpRequest()
					req.open("GET", "/logout", true, 'logout')
					req.onload = _ => {
						if (req.readyState === 4) location.reload()
					}
					req.send()
					return false
				}).text(`Logout ${userName}`).closest('li').toggle(userName!='-')
				$('#error-logs-link').click(function(){
					var p=$('#show-errors')
					if(!p.length){
						p=$('<div id=show-errors class=lightBoxFullContent style=overflow:auto>')
						$('body').append(p)
					}
					p.text("")
					function f(s){
						if(s.hasOwnProperty('length')&&s.length==1)return f(s[0])
						if(typeof s === 'string')return s
						if(s.hasOwnProperty('message')) return s.message + '\n' + s.stack?.replace(/[\r\n].*/gm,'')
						return JSON.stringify(s)
					}
					console.history.error.forEach(m=>p.append($('<pre style="color:var(--button-disabled-decoration-color)">').text(f(m))))
					console.history.warn.forEach(m=>p.append($('<pre style="color:var(--highlight2-fg-color)">').text(f(m))))
					console.history.info.forEach(m=>p.append($('<pre style="color:var(--winner-color)">').text(f(m))))
					console.history.log.forEach(m=>p.append($('<pre>').text(f(m))))
					showLightBox(p)
					return false
				})
			})
		}
		$('body').append($('<div id=fullscreen>⛶</div>').click(toggleFullScreen))
		$(window).on('hashchange',showMainMenuUploads)
	}
	$('body').append($('<div id=lightBoxBG>').click(closeLightBox)).on('keyup',function(e){
		if (e.key=='Escape' && $('#lightBoxBG').is(":visible")){
			e.preventDefault()
			closeLightBox()
		}
	})
	applyTranslations()
	var site = location.host.replace(/^(www|viper|webscout)\./,"")
	if (!site || /^[0-9\.\:]*$/.test(site)){
		site = ""
	} else {
		var m = site.match(/^viper([^\.]+)\.([^\.]+)/)
		if (m){
			site = m[1][0].toUpperCase() + m[1].slice(1) + " " + m[2][0].toUpperCase() + m[2].slice(1)
		} else {
			site = site.replace(/\..*/,'')
			site = site[0].toUpperCase() + site.slice(1)
		}
	}
	var t = document.title
	if (t) t += ' — '
	t += 'Viper'
	if (site) t += ` ${site}`
	document.title = t
})

function showMainMenuUploads(){
	$('#hamburger').toggleClass("hasUploads", hasUploads())
	$('#mainMenu').find('.dependUpload').toggle(hasUploadsOrHistory()).toggleClass("hasUploads", hasUploads())
}

function getLocalTeam(){
	return localStorage.getItem('my-team') || window.ourTeam || 0
}

function closeLightBox(){
	$('#lightBoxBG,.lightBoxCenterContent,.lightBoxFullContent').hide()
	return false
}

function showLightBox(content){
	closeLightBox()
	$('#lightBoxBG').css('width',$(document).width()+"px").css('height',$(document).height()+"px").show()
	applyTranslations()
	content.show()
	return false
}

function toggleFullScreen() {
	if (!document.fullscreenElement) document.documentElement.requestFullscreen()
	else if (document.exitFullscreen) document.exitFullscreen()
	closeLightBox()
	return false
}

function hasUploads(){
	if (location.pathname == '/upload.html') return false
	for (var i in localStorage){
		if (/^20[0-9]{2}(([A-Za-z0-9\-]+)|_photo)_[_A-Za-z0-9\-]+/.test(i)&&!/headers$/.test(i)) return true
	}
	return false
}

function hasUploadsOrHistory(){
	for (var i in localStorage){
		if (/^((deleted|uploaded)_)?20[0-9]{2}[_A-Za-z0-9\-]+$/.test(i)&&!/headers$/.test(i)) return true
	}
	return false
}

function inIframe(){
	try {
		return window.self !== window.top
	} catch (e) {
		return true
	}
}

window.console=(function(oc){
	if (!oc)oc={}
	return{
		history:{
			log: [],
			info: [],
			warn: [],
			error: [],
		},
		x:function(l,a){
			$('#error-logs-link').closest('li').show()
			$('#hamburger').addClass('error').removeClass('show-only-when-connected')
			this.history[l].push(a)
			oc.hasOwnProperty(l)&&oc[l].apply(oc,a)
		},
		log:function(){this.x("log",arguments)},
		info:function(){this.x("info",arguments)},
		warn:function(){this.x("warn",arguments)},
		error:function(){this.x("error",arguments)},
	}
}(window.console))
window.onerror=(message,file,line,col,error)=>{
	console.error(JSON.stringify({
		message:message,
		file:file,
		line:line,
		col:col,
		error:error,
	}))
	return false
}
window.addEventListener("unhandledrejection",e=>{throw e})
