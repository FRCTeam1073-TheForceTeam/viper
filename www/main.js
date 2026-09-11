"use strict"

const I18N={},
onApplyTranslation=[],
translationContext={}

addI18n({
	role_required_heading:{
		en:'Administrators only',
		tr:'Yalnizca yoneticiler',
		pt:'Apenas administradores',
		zh_tw:'僅限管理員',
		fr:'Administrateurs uniquement',
		he:'למנהלים בלבד',
		es:'Solo administradores',
	},
	role_required_message:{
		en:'This page changes event data, so it needs an administrator account. You are signed in as _USERNAME_.',
		tr:'Bu sayfa etkinlik verilerini degistirir, bu nedenle bir yonetici hesabi gerekir. _USERNAME_ olarak oturum actiniz.',
		pt:'Esta pagina altera dados do evento, portanto requer uma conta de administrador. Voce esta conectado como _USERNAME_.',
		zh_tw:'此頁面會變更賽事資料，需要管理員帳號。您目前的登入身分是 _USERNAME_。',
		fr:'Cette page modifie les donnees de l’evenement et requiert donc un compte administrateur. Vous etes connecte en tant que _USERNAME_.',
		he:'דף זה משנה נתוני אירוע ולכן נדרש חשבון מנהל. אתה מחובר כ-_USERNAME_.',
		es:'Esta pagina modifica datos del evento, por lo que requiere una cuenta de administrador. Has iniciado sesion como _USERNAME_.',
	},
	role_required_home:{
		en:'Go to the home page',
		tr:'Ana sayfaya git',
		pt:'Ir para a pagina inicial',
		zh_tw:'前往首頁',
		fr:'Aller a la page d’accueil',
		he:'עבור לדף הבית',
		es:'Ir a la pagina de inicio',
	},
	text_direction:{
		en:'ltr',
		he:'rtl',
		pt:'ltr',
		fr:'ltr',
		tr:'ltr',
		zh_tw:'ltr',
		es:'ltr',
	},
	date_locale:{
		en:'en-US',
		he:'he-IL',
		pt:'pt-BR',
		fr:'fr-CA',
		tr:'tr-TR',
		zh_tw:'zh-TW',
		es:'es-ES',
	},
	home_link:{
		en:'Event List',
		he:'רשימת אירועים',
		pt:'Lista de eventos',
		fr:'Liste des événements',
		tr:'Etkinlik Listesi',
		zh_tw:'事件列表',
		es:'Lista de Eventos',
	},
	upload_data_link:{
		en:'Upload Data',
		he:'העלה נתונים',
		pt:'Carregar dados',
		fr:'Télécharger des données',
		tr:'Veri Yükle',
		zh_tw:'上傳數據',
		es:'Cargar Datos',
	},
	about_link:{
		en:'About this app',
		he:'על האפליקציה הזו',
		pt:'Sobre este aplicativo',
		fr:'À propos de cette application',
		tr:'Bu uygulama hakkında',
		zh_tw:'關於此應用程式',
		es:'Acerca de esta aplicación',
	},
	site_configuration_link:{
		en:'Site configuration',
		he:'תצורת אתר',
		pt:'Configuração do site',
		fr:'Configuration du site',
		tr:'Site yapılandırması',
		zh_tw:'網站配置',
		es:'Configuración del sitio',
	},
	my_team_num:{
		en:'My team #',
		he:'הצוות שלי #',
		pt:'Minha equipe #',
		fr:'Mon équipe #',
		tr:'Takımım #',
		zh_tw:'我的團隊',
		es:'Mi equipo #',
	},
	instructions:{
		en:'Instructions',
		he:'הוראות',
		pt:'Instruções',
		fr:'Instructions',
		tr:'Talimatlar',
		zh_tw:'指示',
		es:'Instrucciones',
	},
	match:{
		en:'Match',
		he:'לְהַתְאִים',
		pt:'Partida',
		fr:'Match',
		tr:'Maç',
		zh_tw:'匹配',
		es:'Partido',
	},
	mt_pm:{
		en:'Prac­tice ',
		he:'לְתַרְגֵל',
		pt:'Prá­tica ',
		fr:'Ent­raîn­ement ',
		tr:'Uygulama ',
		zh_tw:'實踐',
		es:'Práctica ',
	},
	mt_qm:{
		en:'Qual­ific­ation ',
		he:'הַכשָׁרָה',
		pt:'Qua­lifi­cação ',
		fr:'Qual­ific­ation ',
		tr:'Eleme ',
		zh_tw:'資格',
		es:'Clasificación ',
	},
	mt_qf:{
		en:'Quar­ter-final ',
		he:'רֶבַע הַגְמָר',
		pt:'Quar­tas de final ',
		fr:'Quart de finale ',
		tr:'Çeyrek final ',
		zh_tw:'四分之一決賽',
		es:'Cuartos de Final ',
	},
	mt_sf:{
		en:'Semi-final ',
		he:'חצי גמר',
		pt:'Semi­final ',
		fr:'Demi-finale ',
		tr:'Yarı final ',
		zh_tw:'準決賽',
		es:'Semifinal ',
	},
	mt_1p:{
		en:'Play­offs first round ',
		he:'סיבוב ראשון בפלייאוף',
		pt:'Prim­eira rod­ada do play­off ',
		fr:'Prem­ier tour des play­offs ',
		tr:'Playoff birinci tur ',
		zh_tw:'季後賽第一輪',
		es:'Primera ronda de Playoffs ',
	},
	mt_2p:{
		en:'Play­offs second round ',
		he:'סיבוב שני בפלייאוף',
		pt:'Seg­unda rod­ada do play­off ',
		fr:'Deux­ième tour des play­offs ',
		tr:'Playoff ikinci tur ',
		zh_tw:'季後賽第二輪',
		es:'Segunda ronda de Playoffs ',
	},
	mt_3p:{
		en:'Play­offs third round ',
		he:'סיבוב שלישי בפלייאוף',
		pt:'Ter­ceira ro­dada do play­off ',
		fr:'Trois­ième tour des play­offs ',
		tr:'Playoff üçüncü tur ',
		zh_tw:'季後賽第三輪',
		es:'Tercera ronda de Playoffs ',
	},
	mt_4p:{
		en:'Play­offs fourth round ',
		he:'סיבוב רביעי בפלייאוף',
		pt:'Quarta ro­dada do play­off ',
		fr:'Quat­rième tour des play­offs ',
		tr:'Playoff dördüncü tur ',
		zh_tw:'季後賽第四輪',
		es:'Cuarta ronda de Playoffs ',
	},
	mt_5p:{
		en:'Play­offs fifth round ',
		he:'סיבוב חמישי בפלייאוף',
		pt:'Quinta ro­dada do play­off',
		fr:'Cinq­uième tour des play­offs ',
		tr:'Playoff beşinci tur ',
		zh_tw:'季後賽第五輪',
		es:'Quinta ronda de Playoffs ',
	},
	mt_f:{
		en:'Final ',
		he:'סוֹפִי',
		pt:'Final ',
		fr:'Finale ',
		tr:'Final ',
		zh_tw:'最終的',
		es:'Final ',
	},
	mts_pm:{
		en:'Prac ',
		he:'לְתַרְגֵל',
		pt:'Prá­t ',
		fr:'Ent ',
		tr:'Uyg ',
		zh_tw:'實踐',
		es:'Prác. ',
	},
	mts_qm:{
		en:'Qual ',
		he:'הַכשָׁרָה',
		pt:'Qual ',
		fr:'Qual ',
		tr:'Elem ',
		zh_tw:'資格',
		es:'Clsf. ',
	},
	mts_qf:{
		en:'QF ',
		he:'רֶבַע הַגְמָר',
		pt:'QF',
		fr:'QF ',
		tr:'ÇF ',
		zh_tw:'四分之一決賽',
		es:'CF ',
	},
	mts_sf:{
		en:'SF ',
		he:'חצי גמר',
		pt:'SF',
		fr:'DF ',
		tr:'YF',
		zh_tw:'準決賽',
		es:'SF ',
	},
	mts_1p:{
		en:'Play­off R1 M',
		he:'סיבוב ראשון בפלייאוף',
		pt:'Play­off R1 M',
		fr:'Prem­ier tour des play­offs ',
		tr:'Play­off R1 M',
		zh_tw:'季後賽 R1 M',
		es:'Playoff R1 P',
	},
	mts_2p:{
		en:'Play­off R2 M',
		he:'סיבוב שני בפלייאוף',
		pt:'Play­off R2 M',
		fr:'Deux­ième tour des play­offs ',
		tr:'Play­off R2 M',
		zh_tw:'季後賽 R2 M',
		es:'Playoff R2 P',
	},
	mts_3p:{
		en:'Play­off R3 M',
		he:'סיבוב שלישי בפלייאוף',
		pt:'Play­off R3 M',
		fr:'Trois­ième tour des play­offs ',
		tr:'Play­off R3 M',
		zh_tw:'季後賽 R3 M',
		es:'Playoff R3 P',
	},
	mts_4p:{
		en:'Play­off R4 M',
		he:'סיבוב רביעי בפלייאוף',
		pt:'Play­off R4 M',
		fr:'Quat­rième tour des play­offs ',
		tr:'Play­off R4 M',
		zh_tw:'季後賽 R4 M',
		es:'Playoff R4 P',
	},
	mts_5p:{
		en:'Play­off R5 M',
		he:'סיבוב חמישי בפלייאוף',
		pt:'Play­off R5 M',
		fr:'Cinq­uième tour des play­offs ',
		tr:'Play­off R5 M',
		zh_tw:'季後賽 R5 M',
		es:'Playoff R5 P',
	},
	mts_f:{
		en:'Final ',
		he:'סוֹפִי',
		pt:'Final ',
		fr:'Finale ',
		tr:'Final ',
		zh_tw:'最終的',
		es:'F ',
	},
	cancel_button:{
		en:'Cancel',
		he:'לְבַטֵל',
		pt:'Cancelar',
		fr:'Annuler',
		tr:'İptal etmek',
		zh_tw:'取消',
		es:'Cancelar',
	},
	save_button:{
		en:'Save',
		pt:'Salvar',
		fr:'Enregistrer',
		zh_tw:'節省',
		he:'לְהַצִיל',
		tr:'Kaydet',
		es:'Guardar',
	},
	next_button:{
		en:'Next',
		he:'הַבָּא',
		pt:'Próximo',
		fr:'Aller ensuite',
		tr:'Sonraki',
		zh_tw:'下一個',
		es:'Siguiente',
	},
	edit_link:{
		en:'Edit',
		pt:'Editar',
		he:'לַעֲרוֹך',
		tr:'Düzenle',
		fr:'Modifier',
		zh_tw:'編輯',
		es:'Editar',
	},
	delete_button:{
		en:'Delete',
		tr:'Sil',
		he:'לִמְחוֹק',
		zh_tw:'刪除',
		fr:'Supprimer',
		pt:'Excluir',
		es:'Eliminar',
	},
	stats_include_practice:{
		en:'Stats include practice matches',
		he:'הסטטיסטיקה כוללת משחקי אימון',
		pt:'Estatísticas incluem partidas de treino',
		tr:'İstatistikler, antrenman maçlarını içerir',
		zh_tw:'統計數據包括練習賽',
		fr:'Statistiques incluant les matchs d\'entraînement',
		es:'Las estadísticas incluyen partidos de práctica',
	},
	stats_exclude_practice:{
		en:'Stats exclude practice matches',
		he:'הסטטיסטיקה אינה כוללת משחקי אימון',
		pt:'Estatísticas excluem partidas de treino',
		tr:'İstatistikler, antrenman maçlarını hariç tutar',
		zh_tw:'數據不包括練習賽',
		fr:'Statistiques excluant les matchs d\'entraînement',
		es:'Las estadísticas excluyen partidos de práctica',
	},
	display_graphs:{
		en:'Graphs',
		he:'גרפים',
		pt:'Gráficos',
		tr:'Grafikler',
		zh_tw:'圖表',
		fr:'Graphiques',
		es:'Gráficos',
	},
	display_table:{
		en:'Table',
		he:'לוּחַ',
		pt:'Tabela',
		tr:'Tablo',
		zh_tw:'桌子',
		fr:'Tableau',
		es:'Tabla',
	},
	red_heading:{
		en:'Red',
		tr:'Vermelho',
		he:'אָדוֹם',
		zh_tw:'紅色的',
		pt:'Vermelho',
		fr:'Rouge',
		es:'Rojo',
	},
	blue_heading:{
		en:'Blue',
		tr:'Azul',
		he:'כְּחוֹל',
		zh_tw:'藍色的',
		pt:'Azul',
		fr:'Bleu',
		es:'Azul',
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
	$('link[rel="preload"]').each(function(){
		var href = $(this).attr('href')
		if (/\.(png|jpg|jpeg|gif|webp)$/i.test(href??'')){
			var img = new Image()
			img.src = href
		}
	})

	$('*').addClass('no-transition')
	$('nav.left').append($('<button type=button class=nav-toggle aria-label="Toggle navigation"></button>').click(function(e){
		e.preventDefault()
		e.stopPropagation()
		var nav = $(this).closest('nav.left')
		nav.toggleClass('nav-hidden')
	})).toggleClass('nav-hidden', window.innerWidth / window.innerHeight < 2 / 3)
	$('*').each(function(){void this.offsetHeight}).removeClass('no-transition')

	promiseUser().then(function(){
		if (applyPageRoleGuard()) applyRoleGates()
	})

	if (!inIframe()){
		var hamburger = $('<div id=hamburger class=show-only-when-connected>☰</div>'),
		fullscreen = $('<div id=fullscreen>⛶</div>').click(toggleFullScreen),
		mainMenu = $('<div id=mainMenu class=lightBoxCenterContent>'),
		appBar = $('<header id=appBar>')
			.append($('<a id=appBarBrand href=/>').append('<img src=/viper.svg alt="">').append('<span>Viper</span>'))
			.append($('<nav id=appBarNav>')
				.append($('<a class=appBarLink href=/ data-i18n=home_link></a>'))
				.append($('<a class=appBarLink id=appBarEvent href=/ style=display:none></a>')))
			.append($('<div id=appBarActions>').append(fullscreen).append(hamburger))
		$('body').addClass('hasAppBar').append(appBar).append(mainMenu)
		hamburger.click(function(){showLightBox(mainMenu)})

		populateMainMenu()

		function populateMainMenu(){
			Promise.all([
				fetch('/main-menu.html').then(response=>response.text()).catch(()=>''),
				promiseUser()
			]).then(values =>{
				var [menuHtml, user] = values,
				userName = user.user,
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
				var showEvent = !!(eName && !/^20[0-9]{2}(-[0-9]{2})?combined$/.test(eId||""))
				$('#appBarEvent').toggle(showEvent).attr('href',`/event.html#event=${eId}`).text(eName)
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
				mainMenu.find('#site-configuration-link').closest('li').toggle(isAdmin())
				applyRoleGates(mainMenu)
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
			}).catch(e=>{
				console.error(e)
			})
		}
		$(window).on('hashchange',showMainMenuUploads)
	}
	$('body').append($('<div id=lightBoxBG>').click(closeLightBox))
		.append($('<button id=lightBoxClose aria-label=Close>✕</button>').click(closeLightBox))
		.on('keyup',function(e){
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

// ===== Signed-in user and role =====
// /user.cgi reports the REMOTE_USER Apache authenticated and which of the three
// configured roles it maps to (admin / scout / guest). Apache is the enforcement
// point -- these helpers only let the UI agree with it instead of offering
// buttons the server will refuse.
var promiseUserCache
function promiseUser(){
	if (!promiseUserCache) promiseUserCache = fetch('/user.cgi')
		.then(response => response.json())
		.catch(() => ({user:'-', role:'guest'}))
		.then(u => {
			window.currentUser = u.user || '-'
			window.currentRole = u.role || 'guest'
			return u
		})
	return promiseUserCache
}

function isAdmin(){ return window.currentRole == 'admin' }
function isScouter(){ return window.currentRole == 'admin' || window.currentRole == 'scout' }

// Declarative gating: data-role="admin" hides the element from everyone but an
// admin, data-role="scout" from everyone below a scouter. main.css hides
// [data-role] outright, so markup starts hidden and there is no flash of links
// the viewer may not use. Clearing the attribute is what reveals an element --
// rather than forcing a display value, which would fight the initHid/depend*
// toggles these same elements already carry. An element that stays gated keeps
// its attribute, and the !important rule outlives any later .show() on it.
// Re-run after rendering anything that adds gated markup.
function applyRoleGates(node){
	$(node||document).find('[data-role]').each(function(){
		var need = this.getAttribute('data-role')
		if (need == 'admin' ? isAdmin() : isScouter()) this.removeAttribute('data-role')
	})
}

// A page whose <body> carries data-require-role is only usable by that role.
// The writes behind these pages all go through /admin/ CGI, which Apache refuses
// anyway -- this is so a scouter who follows or types the URL gets a clear
// message instead of filling in a form that dies with a raw 401 on save.
function applyPageRoleGuard(){
	var need = document.body.getAttribute('data-require-role')
	if (!need) return true
	if (need == 'admin' ? isAdmin() : isScouter()) return true
	var denied = $('<div id=roleDenied>')
		.append($('<h1>').attr('data-i18n','role_required_heading'))
		.append($('<p>').attr('data-i18n','role_required_message'))
		.append($('<p>').append($('<a href=/>').attr('data-i18n','role_required_home')))
	$('body').children().not('#appBar,#mainMenu').remove()
	$('body').append(denied)
	addTranslationContext({username:window.currentUser=='-'?'?':window.currentUser})
	applyTranslations()
	document.title = translate('role_required_heading')
	return false
}

function showMainMenuUploads(){
	$('#hamburger').toggleClass("hasUploads", hasUploads())
	$('#mainMenu').find('.dependUpload').toggle(hasUploadsOrHistory()).toggleClass("hasUploads", hasUploads())
}

function getLocalTeam(){
	return localStorage.getItem('my-team') || window.ourTeam || 0
}

var openLightBoxContent = null

function closeLightBox(){
	openLightBoxContent = null
	$('#lightBoxBG,#lightBoxClose,.lightBoxCenterContent,.lightBoxFullContent').hide()
	$('html').removeClass('lightbox-open')
	return false
}

function showLightBox(content){
	closeLightBox()
	$('#lightBoxBG').css('width',$(document).width()+"px").css('height',$(document).height()+"px").show()
	// The hamburger main menu and instruction cards close by clicking off them (or Esc); no X needed
	if ($(content).attr('id')!=='mainMenu' && !$(content).hasClass('instructions')) $('#lightBoxClose').css('display','flex')
	applyTranslations()
	content.show()
	openLightBoxContent = content
	positionLightBoxClose()
	// Lock background page scroll so only the lightbox content (and its own scrollbar) shows
	$('html').addClass('lightbox-open')
	return false
}

// Sit the close button on the top-right corner of the panel that is open, rather
// than in the corner of the window. Panels differ in size -- a centred picker, a
// narrower instruction card -- so the corner is measured, not assumed.
function positionLightBoxClose(){
	var close = $('#lightBoxClose')
	if (!openLightBoxContent || !close.is(':visible')) return
	var el = openLightBoxContent[0]
	if (!el) return
	var box = el.getBoundingClientRect()
	if (!box.width && !box.height) return
	// One inset for both edges, in em of the root so it tracks the app's 2vmin
	// sizing rather than drifting on a bigger screen.
	var inset = parseFloat(window.getComputedStyle(document.documentElement).fontSize) * 0.4
	close.css({
		top: (box.top + inset) + 'px',
		left: (box.right - close.outerWidth() - inset) + 'px',
		right: 'auto'
	})
}

$(window).on('resize', positionLightBoxClose)

function toggleFullScreen() {
	if (!document.fullscreenElement) document.documentElement.requestFullscreen()
	else if (document.exitFullscreen) document.exitFullscreen()
	closeLightBox()
	return false
}

function hasUploads(){
	if (location.pathname == '/upload.html') return false
	for (var i in localStorage){
		if (/^20[0-9]{2}(([A-Za-z0-9\-]+)|_photo)_[_A-Za-z0-9\-]+/.test(i)&&!/(headers|AggregateGraphs|TeamStats|WhiteboardStats|PredictorStats)$/.test(i))return true
	}
	return false
}

function hasUploadsOrHistory(){
	if (hasUploads())return true
	for (var i in localStorage){
		if (/^((deleted|uploaded)_)/.test(i))return true
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
	if (message.includes('getLabelAndValue')) return true
	console.error(JSON.stringify({
		message:message,
		file:file,
		line:line,
		col:col,
		error:error,
	}))
	return false
}
window.addEventListener("unhandledrejection",e=>{throw e.reason})
