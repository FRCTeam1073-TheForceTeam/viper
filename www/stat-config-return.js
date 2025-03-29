"use strict"

addI18n({
	stat_config_return_title:{
		en:'Configuration Saved',
		tr:'Yapılandırma Kaydedildi',
		pt:'Configuração salva',
		fr:'Configuration enregistrée',
		he:'התצורה נשמרה',
		zh_tw:'配置已儲存',
	},
	redirect_message:{
		en:'Redirecting back, please wait...',
		tr:'Geri yönlendiriliyor, lütfen bekleyin...',
		pt:'Redirecionando de volta, aguarde...',
		fr:'Redirection en cours, veuillez patienter…',
		he:'מפנה חזרה, אנא המתן...',
		zh_tw:'正在重定向回來，請等待...',
	},
})

if(/^\#\/([a-z]+\.html([\#\?][\#\?a-zA-Z0-9\-\_\=\&]+)?)?$/.test(location.hash)){
	setTimeout(function(){
		location.href=location.hash.replace(/^#/,'')
	},3000)
}
