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

addI18n({
	accounts_heading:{
		en:'Accounts',
		tr:'Hesaplar',
		pt:'Contas',
		zh_tw:'帳號',
		fr:'Comptes',
		he:'חשבונות',
		es:'Cuentas',
	},
	accounts_intro:{
		en:'Who can do what on this site. The web server enforces these, so changing them is done on the server rather than here.',
		tr:'Bu sitede kimin ne yapabilecegi. Bunlari web sunucusu uygular, bu yuzden degisiklikler burada degil sunucuda yapilir.',
		pt:'Quem pode fazer o que neste site. O servidor web aplica estas regras, por isso as alteracoes fazem-se no servidor e nao aqui.',
		zh_tw:'此網站上各帳號的權限。這些規則由網頁伺服器強制執行，因此變更需在伺服器上進行，而非在此頁面。',
		fr:'Qui peut faire quoi sur ce site. C’est le serveur web qui applique ces regles, les modifications se font donc sur le serveur et non ici.',
		he:'מי רשאי לעשות מה באתר זה. שרת האינטרנט אוכף זאת, ולכן שינויים מתבצעים בשרת ולא כאן.',
		es:'Quien puede hacer que en este sitio. El servidor web aplica estas reglas, por lo que los cambios se hacen en el servidor y no aqui.',
	},
	accounts_col_account:{
		en:'Account',
		tr:'Hesap',
		pt:'Conta',
		zh_tw:'帳號',
		fr:'Compte',
		he:'חשבון',
		es:'Cuenta',
	},
	accounts_col_role:{
		en:'Role',
		tr:'Rol',
		pt:'Funcao',
		zh_tw:'角色',
		fr:'Role',
		he:'תפקיד',
		es:'Funcion',
	},
	accounts_col_can:{
		en:'Can',
		tr:'Yetkiler',
		pt:'Pode',
		zh_tw:'權限',
		fr:'Peut',
		he:'הרשאות',
		es:'Puede',
	},
	accounts_can_admin:{
		en:'Everything: create events, edit data, manage playoffs',
		tr:'Her sey: etkinlik olusturma, veri duzenleme, playoff yonetimi',
		pt:'Tudo: criar eventos, editar dados, gerir playoffs',
		zh_tw:'全部權限：建立賽事、編輯資料、管理季後賽',
		fr:'Tout : creer des evenements, modifier les donnees, gerer les playoffs',
		he:'הכול: יצירת אירועים, עריכת נתונים, ניהול פלייאוף',
		es:'Todo: crear eventos, editar datos, gestionar playoffs',
	},
	accounts_can_scout:{
		en:'Upload scouting data and photos',
		tr:'Gozlem verisi ve fotograf yukleme',
		pt:'Carregar dados de scouting e fotografias',
		zh_tw:'上傳偵察資料與照片',
		fr:'Televerser des donnees de scouting et des photos',
		he:'העלאת נתוני סקאוטינג ותמונות',
		es:'Subir datos de scouting y fotos',
	},
	accounts_can_guest:{
		en:'View data only',
		tr:'Yalnizca veri goruntuleme',
		pt:'Apenas ver dados',
		zh_tw:'僅能檢視資料',
		fr:'Consulter les donnees uniquement',
		he:'צפייה בנתונים בלבד',
		es:'Solo ver datos',
	},
	accounts_you:{
		en:'you',
		tr:'siz',
		pt:'voce',
		zh_tw:'您',
		fr:'vous',
		he:'אתה',
		es:'tu',
	},
	accounts_howto_heading:{
		en:'Adding an administrator',
		tr:'Yonetici ekleme',
		pt:'Adicionar um administrador',
		zh_tw:'新增管理員',
		fr:'Ajouter un administrateur',
		he:'הוספת מנהל',
		es:'Anadir un administrador',
	},
	accounts_step_edit:{
		en:'On the server, add the account name to the administrator list in local.conf. Names are separated by spaces:',
		tr:'Sunucuda, hesap adini local.conf dosyasindaki yonetici listesine ekleyin. Adlar bosluklarla ayrilir:',
		pt:'No servidor, adicione o nome da conta a lista de administradores em local.conf. Os nomes sao separados por espacos:',
		zh_tw:'在伺服器上，將帳號名稱加入 local.conf 的管理員清單。名稱以空格分隔：',
		fr:'Sur le serveur, ajoutez le nom du compte a la liste des administrateurs dans local.conf. Les noms sont separes par des espaces :',
		he:'בשרת, הוסף את שם החשבון לרשימת המנהלים ב-local.conf. שמות מופרדים ברווחים:',
		es:'En el servidor, anade el nombre de la cuenta a la lista de administradores en local.conf. Los nombres se separan con espacios:',
	},
	accounts_step_run:{
		en:'Then apply it by running:',
		tr:'Ardindan sunu calistirarak uygulayin:',
		pt:'Depois aplique executando:',
		zh_tw:'接著執行以下指令套用：',
		fr:'Puis appliquez en executant :',
		he:'לאחר מכן החל את השינוי על ידי הרצת:',
		es:'Despues aplicalo ejecutando:',
	},
	accounts_step_password:{
		en:'It asks for a password for each new account, then reloads the web server. Existing accounts are left alone.',
		tr:'Her yeni hesap icin bir parola sorar, sonra web sunucusunu yeniden yukler. Mevcut hesaplar degistirilmez.',
		pt:'Pede uma palavra-passe para cada conta nova e recarrega o servidor web. As contas existentes nao sao alteradas.',
		zh_tw:'系統會為每個新帳號詢問密碼，然後重新載入網頁伺服器。既有帳號不會被更動。',
		fr:'Il demande un mot de passe pour chaque nouveau compte, puis recharge le serveur web. Les comptes existants ne sont pas modifies.',
		he:'התוכנית תבקש סיסמה לכל חשבון חדש ותטען מחדש את שרת האינטרנט. חשבונות קיימים לא ישתנו.',
		es:'Pide una contrasena para cada cuenta nueva y recarga el servidor web. Las cuentas existentes no se modifican.',
	},
	accounts_note:{
		en:'To change someone’s role, move their name between the guest, scouter and administrator lists and run the same command. Removing a name takes the access away but leaves the password in place.',
		tr:'Birinin rolunu degistirmek icin adini misafir, gozlemci ve yonetici listeleri arasinda tasiyin ve ayni komutu calistirin. Bir adi kaldirmak erisimi kaldirir ancak parolayi yerinde birakir.',
		pt:'Para mudar a funcao de alguem, mova o nome entre as listas de convidado, scouter e administrador e execute o mesmo comando. Remover um nome retira o acesso mas mantem a palavra-passe.',
		zh_tw:'若要變更某人的角色，將其名稱在訪客、偵察員與管理員清單之間移動，然後執行相同指令。移除名稱會收回存取權，但密碼仍會保留。',
		fr:'Pour changer le role d’une personne, deplacez son nom entre les listes invite, scouter et administrateur puis executez la meme commande. Retirer un nom supprime l’acces mais conserve le mot de passe.',
		he:'כדי לשנות תפקיד, העבר את השם בין רשימות האורח, הסקאוטר והמנהל והרץ את אותה הפקודה. הסרת שם מבטלת את הגישה אך הסיסמה נשמרת.',
		es:'Para cambiar la funcion de alguien, mueve su nombre entre las listas de invitado, scouter y administrador y ejecuta el mismo comando. Quitar un nombre retira el acceso pero conserva la contrasena.',
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
	showAccounts()
	applyTranslations()

	$('#local-config-form').on('submit', function(e){
		return saveConfiguration()
	})
})

// Lists who holds which role, and spells out how to change it. Read-only: the
// web server is what enforces these, from a config generated out of local.conf,
// so applying a change means regenerating that config and reloading the server.
function showAccounts(){
	fetch('/admin/accounts.cgi')
		.then(response => response.ok ? response.json() : null)
		.catch(() => null)
		.then(accounts => {
			if (!accounts) return
			var body = $('#accountsTable tbody').html(""),
			roles = [
				['admin', 'accounts_can_admin'],
				['scout', 'accounts_can_scout'],
				['guest', 'accounts_can_guest']
			]
			roles.forEach(function(role){
				(accounts[role[0]]||[]).forEach(function(name){
					var who = name + (name == accounts.you ? ' (' + translate('accounts_you') + ')' : '')
					body.append($('<tr>')
						.append($('<td class=accountName>').text(who))
						.append($('<td>').append($('<span class=roleTag>').addClass('role-'+role[0]).text(role[0])))
						.append($('<td>').attr('data-i18n', role[1])))
				})
			})
			// Show the line as it would look with a new name on the end, and the
			// real path on this server rather than a placeholder.
			$('#accountsConfLine').text('ADMIN_USER="' + ((accounts.admin||[]).join(' ')) + ' newperson"')
			$('#accountsCommand').text('cd ' + accounts.root + ' && ./script/apache-config.sh')
			$('#accounts').show()
			applyTranslations($('#accounts'))
		})
}

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
