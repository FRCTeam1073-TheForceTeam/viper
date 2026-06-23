"use strict"

addI18n({
	local_config_title:{
		en:'Site Configuration',
		es:'Configuración del sitio',
		fr:'Configuration du site',
		pt:'Configuração do site',
		zh_tw:'網站配置',
		tr:'Site Yapılandırması',
		he:'תצורת האתר',
	},
	local_config_loading:{
		en:'Loading configuration...',
		es:'Cargando configuración...',
		fr:'Chargement de la configuration...',
		pt:'Carregando configuração...',
		zh_tw:'正在加載配置...',
		tr:'Yapılandırma yükleniyor...',
		he:'טעינת תצורה...',
	},
	local_config_team_number:{
		en:'Our Team Number',
		es:'Número de nuestro equipo',
		fr:'Numéro de notre équipe',
		pt:'Número da nossa equipe',
		zh_tw:'我們的團隊編號',
		tr:'Takım Numaramız',
		he:'מספר הקבוצה שלנו',
	},
	local_config_scouting_comments:{
		en:'Allow scouting comments',
		es:'Permitir comentarios de reconocimiento',
		fr:'Autoriser les commentaires de reconnaissance',
		pt:'Permitir comentários de reconhecimento',
		zh_tw:'允許偵察評論',
		tr:'Keşif yorumlarına izin ver',
		he:'אפשר הערות סקאוטינג',
	},
	local_config_review_requests:{
		en:'Allow review requests',
		es:'Permitir solicitudes de revisión',
		fr:'Autoriser les demandes d\'examen',
		pt:'Permitir solicitações de revisão',
		zh_tw:'允許審查請求',
		tr:'İnceleme isteklerine izin ver',
		he:'אפשר בקשות סקירה',
	},
	local_config_transfer_hosts:{
		en:'Transfer Hosts',
		es:'Hosts de transferencia',
		fr:'Hôtes de transfert',
		pt:'Hosts de transferência',
		zh_tw:'傳輸主機',
		tr:'Transfer Konakları',
		he:'מארחי העברה',
	},
	local_config_transfer_hosts_help:{
		en:'Enter each hostname or IP address on a separate line (e.g., localhost, example.com, 192.168.1.1:8080)',
		es:'Ingrese cada nombre de host o dirección IP en una línea separada (p.ej., localhost, example.com, 192.168.1.1:8080)',
		fr:'Entrez chaque nom d\'hôte ou adresse IP sur une ligne distincte',
		pt:'Digite cada nome de host ou endereço IP em uma linha separada',
		zh_tw:'每行輸入一個主機名或 IP 地址',
		tr:'Her ana bilgisayar adını veya IP adresini ayrı bir satıra girin',
		he:'הזן כל שם מארח או כתובת IP בשורה נפרדת',
	},
	local_config_save:{
		en:'Save Configuration',
		es:'Guardar configuración',
		fr:'Enregistrer la configuration',
		pt:'Salvar configuração',
		zh_tw:'保存配置',
		tr:'Yapılandırmayı Kaydet',
		he:'שמור תצורה',
	},
	local_config_saved:{
		en:'Configuration saved successfully',
		es:'Configuración guardada correctamente',
		fr:'Configuration enregistrée avec succès',
		pt:'Configuração salva com êxito',
		zh_tw:'配置保存成功',
		tr:'Yapılandırma başarıyla kaydedildi',
		he:'התצורה נשמרה בהצלחה',
	},
	local_config_error:{
		en:'Error saving configuration: _ERROR_',
		es:'Error al guardar la configuración: _ERROR_',
		fr:'Erreur lors de l\'enregistrement de la configuration : _ERROR_',
		pt:'Erro ao salvar a configuração: _ERROR_',
		zh_tw:'保存配置出錯：_ERROR_',
		tr:'Yapılandırma kaydedilirken hata oluştu: _ERROR_',
		he:'שגיאה בשמירת התצורה: _ERROR_',
	},
	local_config_validation_error:{
		en:'Validation error: _ERROR_',
		es:'Error de validación: _ERROR_',
		fr:'Erreur de validation : _ERROR_',
		pt:'Erro de validação: _ERROR_',
		zh_tw:'驗證錯誤：_ERROR_',
		tr:'Doğrulama hatası: _ERROR_',
		he:'שגיאת אימות: _ERROR_',
	},
	local_config_need_admin:{
		en:'You must be logged in as an administrator to edit this configuration. Please login when prompted.',
		es:'Debe estar conectado como administrador para editar esta configuración. Por favor, inicie sesión cuando se le solicite.',
		fr:'Vous devez être connecté en tant qu\'administrateur pour modifier cette configuration.',
		pt:'Você deve estar conectado como administrador para editar esta configuração.',
		zh_tw:'您必須以管理員身份登錄才能編輯此配置。',
		tr:'Bu yapılandırmayı düzenlemek için yönetici olarak giriş yapmalısınız.',
		he:'עליך להיות מחובר כמנהל כדי לערוך את התצורה זו.',
	},
	local_config_load_error:{
		en:'Error loading configuration',
		es:'Error al cargar la configuración',
		fr:'Erreur lors du chargement de la configuration',
		pt:'Erro ao carregar a configuração',
		zh_tw:'加載配置出錯',
		tr:'Yapılandırma yüklenirken hata oluştu',
		he:'שגיאה בטעינת התצורה',
	},
	local_config_invalid_transfer_host:{
		en:'Invalid transfer host: _HOST_',
		es:'Host de transferencia inválido: _HOST_',
		fr:'Hôte de transfert invalide : _HOST_',
		pt:'Host de transferência inválido: _HOST_',
		zh_tw:'無效的傳輸主機：_HOST_',
		tr:'Geçersiz transfer konağı: _HOST_',
		he:'מארח העברה לא חוקי: _HOST_',
	},
	local_config_invalid_team_number:{
		en:'Team number must be 0-99999',
		es:'El número de equipo debe ser 0-99999',
		fr:'Le numéro d\'équipe doit être 0-99999',
		pt:'O número da equipe deve ser 0-99999',
		zh_tw:'隊伍編號必須為 0-99999',
		tr:'Takım numarası 0-99999 olmalıdır',
		he:'מספר הקבוצה חייב להיות 0-99999',
	},
})

$(document).ready(function(){
	// Check for saved notification from redirect
	if (window.location.hash === '#saved'){
		showSuccess(translate('local_config_saved'))
		setTimeout(function(){
			$('#message-area').fadeOut(function(){
				window.location.hash = ''
			})
		}, 1000)
	}

	readConfiguration()
	applyTranslations()

	$('#local-config-form').on('submit', function(e){
		return saveConfiguration()
	})
})

function readConfiguration(){
	// Wait for local.js to be loaded, then read the global variables
	if (window.localJsLoaded){
		populateForm({
			ourTeam: window.ourTeam,
			showScoutingComments: window.showScoutingComments,
			showReviewRequest: window.showReviewRequest,
			transferHosts: window.transferHosts,
		})
		$('#loading').hide()
		$('#local-config-form').show()
		applyTranslations()
	} else {
		// If local.js hasn't loaded yet, try again in a moment
		setTimeout(readConfiguration, 100)
	}
}

function populateForm(config){
	// Set ourTeam
	$('#form-ourTeam').val(config.ourTeam !== undefined ? config.ourTeam : '')

	// Set boolean checkboxes with safe defaults
	$('#form-showScoutingComments').prop('checked', !!config.showScoutingComments)
	$('#form-showReviewRequest').prop('checked', config.showReviewRequest !== false)

	// Set transferHosts as line-separated, defaulting to empty array
	var hosts = config.transferHosts && Array.isArray(config.transferHosts) ? config.transferHosts : []
	$('#form-transferHosts').val(hosts.join('\n'))
}

function saveConfiguration(){
	var errors = validateForm()
	if (errors.length > 0){
		showError(translate('local_config_validation_error', {error: errors.join('; ')}))
		return false
	}
	// Convert textarea lines to JSON array and put in hidden input for CGI
	var hosts = $('#form-transferHosts').val()
		.split('\n')
		.map(function(s){ return s.trim() })
		.filter(function(s){ return s.length > 0 })
	$('#transferHosts-json').val(JSON.stringify(hosts))
	return true
}

function validateForm(){
	var errors = []

	// Validate ourTeam
	var team = $('#form-ourTeam').val()
	if (team && team !== ''){
		var teamNum = parseInt(team)
		if (isNaN(teamNum) || teamNum < 0 || teamNum > 99999){
			errors.push(translate('local_config_invalid_team_number'))
		}
	}

	// Validate transferHosts
	var hosts = $('#form-transferHosts').val()
		.split('\n')
		.map(function(s){ return s.trim() })
		.filter(function(s){ return s.length > 0 })

	hosts.forEach(function(host){
		if (!/^((https?:\/\/)?)([a-zA-Z0-9\-\.\:]+)(\/?)$/.test(host)){
			errors.push(translate('local_config_invalid_transfer_host', {host: host}))
		}
	})

	return errors
}

function showSuccess(message){
	var msgArea = $('#message-area')
	msgArea.html('')
		.append($('<p class=success>').text(message))
}

function showError(message){
	var msgArea = $('#message-area')
	msgArea.html('')
		.append($('<p class=error>').text(message))
}
