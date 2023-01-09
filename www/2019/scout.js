$(document).ready(function(){
	$(".toggle").click(function(e){
		e.preventDefault()
		var oldFields,
		newFields,
		index = parseInt($(this).attr('data-index')),
		children = $(this).children(),
		visible = 0
		for (var i=0; i<children.length; i++){
			if ($(children[i]).is(":visible")){
				visible = i
				oldFields = $(children[i]).attr('data-fields')
			}
			$(children[i]).hide()
		}
		visible++
		if (visible>=children.length) visible=0
		newFields = $(children[visible]).show().attr('data-fields')
		addToFields(oldFields, -1)
		addToFields(newFields, 1)
	})

	$('.hab td').click(function(){
		var value = $(this).attr('data-value')
		var hab = $(this).closest('.hab')
		if (value){
			var field = hab.attr('data-field')
			hab.find('td').text("")
			$(this).text("X")
			$(`input[name="${field}"]`).val(value)
		}
	})
})

function beforeShowScouting(){
	$('.toggle > *').hide()
	$('.toggle > *:first-child').show()
}

function addToFields(fields, amount){
	if (!fields) return
	fields = fields.split(/,/)
	for (var i=0; i<fields.length; i++){
		var field=fields[i],
		input = $(`input[name="${field}"]`)
		input.val(parseInt(input.val()||0)+amount)
	}
}