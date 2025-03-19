"use strict"

addI18n({
	photo_edit_title:{
		en:'Edit Photo',
		fr:'Modifier la photo',
		tr:'Fotoğrafı Düzenle',
		pt:'Editar foto',
		he:'ערוך תמונה',
		zh_tw:'編輯照片',
	},
	photo_deleted:{
		en:'Photo Deleted',
		fr:'Photo supprimée',
		tr:'Fotoğraf Silindi',
		pt:'Foto excluída',
		he:'התמונה נמחקה',
		zh_tw:'照片已刪除',
	},
	delete_photo_confirm:{
		en:'Really delete photo?',
		fr:'Voulez-vous vraiment supprimer la photo ?',
		tr:'Fotoğraf gerçekten silinsin mi?',
		pt:'Realmente excluir foto?',
		he:'באמת למחוק תמונה?',
		zh_tw:'真的刪除照片嗎？',
	},
})

$(document).ready(function(){
	$('#delete').click(function(e){
		if (!confirm(translate('delete_photo_confirm'))){
			e.preventDefault()
			return false
		}
	})
	function fromLocationHash(){
		if (/^\#20[0-9]{2}(-[0-9]{2})?\/[0-9]+(\-[a-z]+)?\.jpg$/.test(location.hash)){
			var file = location.hash.substring(1)
			$('h1').attr('data-i18n','photo_edit_title')
			$('form,img').show()
			$('#photo').show().attr('src',"/data/"+file+"?"+new Date().getTime()).on('error',function(){
				$('h1').attr('data-i18n','photo_deleted')
				$('form,img').hide()
				applyTranslations()
			})
			$('#file').val(file)
			if (parent && parent.photoChange) parent.photoChange(file)
			applyTranslations()
		}
	}
	$(window).on('hashchange', fromLocationHash)
	fromLocationHash()
})
