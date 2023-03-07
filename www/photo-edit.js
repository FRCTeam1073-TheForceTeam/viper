$(document).ready(function(){
	$('#delete').click(function(e){
		if (!confirm("Really delete image?")){
			e.preventDefault()
			return false
		}
	})
	function fromLocationHash(){
		if (/^\#20[0-9]{2}\/[0-9]+(\-[a-z]+)?\.jpg$/.test(location.hash)){
			var file = location.hash.substring(1)
			$('#photo').show().attr('src',"/data/"+file+"?"+new Date().getTime()).on('error',function(){
				$(this).hide()
				$('h1').text("Photo Deleted")
			}).on('complete',function(){
				$('h1').text("Edit Photo")
			})
			$('#file').val(file)
			if (parent && parent.photoChange) parent.photoChange(file)
		}
	}
	$(window).on('hashchange', fromLocationHash)
	fromLocationHash()
})
