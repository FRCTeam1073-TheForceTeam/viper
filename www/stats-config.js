"use strict"

function isArray(o){
	return typeof o === 'object' && o instanceof Array
}

function isMap(o){
	return typeof o === 'object' && !(o instanceof Array)
}

function isString(o){
	return typeof o === 'string'
}

var numericGraphTypes=new Set(['%','avg','count','capability','fraction','minmax','num','ratio'])

var graphTypes={
	"bar":{
		name: "Bar chart",
		types: numericGraphTypes,
		modes: new Set(['aggregate','team'])
	},
	"boxplot":{
		name: "Box plot",
		types: new Set(['%','avg','count','minmax']),
		modes: new Set(['aggregate'])
	},
	"heatmap":{
		name: "Heatmap",
		types: new Set(['heatmap']),
		modes: new Set(['aggregate','team'])
	},
	"stacked":{
		name: "Stacked bars",
		types: numericGraphTypes,
		modes: new Set(['aggregate','team'])
	},
	"stacked_percent":{
		name: "Stacked percents",
		types: new Set(['count']),
		modes: new Set(['aggregate'])
	},
	"timeline":{
		name: "Timeline",
		types: new Set(['timeline']),
		modes: new Set(['team'])
	},
}

class StatsConfig {
	constructor(conf){
		this.statsConfigKey=conf.statsConfigKey
		this.getStatsConfig=conf.getStatsConfig
		this.hasSections=!!conf.hasSections
		this.hasGraphs=!!conf.hasGraphs
		this.hasWhiteboard=!!conf.hasWhiteboard
		this.drawFunction=conf.drawFunction
		this.fileName=conf.fileName
		this.defaultConfig=conf.defaultConfig
		this.downloadBlobs=conf.downloadBlobs
		this.mode=conf.mode
		this.team=conf.team
	}

	validateJson(json){
		if (!this.hasSections){
			if (!isArray(json)) throw('JSON is not an array')
			json.forEach(this.validateItem.bind(this))
		} else {
			if (!isMap(json)) throw('JSON is not a map')
			Object.keys(json).forEach(section=>this.validateItem(json[section],section))
		}
	}

	validateItem(item, name){
		if (!this.hasSections){
			if (!isString(item)) throw (`${item} is not a string`)
			if (!statInfo[item]) throw (`Unknown data: ${item}`)
		} else if (!this.hasGraphs){
			if (!isArray(item)) throw (`Expected :[ following "${name}"`)
			item.forEach(function(field){
				if (!isString(field)) throw (`${name} is not all strings`)
				if (!statInfo[field]) throw (`Unknown data: ${field}`)
			})
		} else {
			if (!isMap(item)) throw (`Expected :{ following "${name}"`)
			if (!isString(item.graph)) throw (`${name}.graph is not a string`)
			if (!isArray(item.data)) throw (`${name}.data is not an array`)
			if (item.data.length==0) throw (`${name}.data is empty`)
			item.data.forEach(function(field){
				if (!isString(field)) throw (`${name}.data is not all strings`)
				if (!statInfo[field]) throw (`Unknown data: ${field}`)
			})
			if (Object.keys(item).length != 2) throw (`Expected only graph and data in "${name}"`)
		}
	}

	getLocalStatsConfig(){
		var s=localStorage.getItem(this.statsConfigKey)
		if (s && s != 'undefined'){
			try {
				s=JSON.parse(s)
				if (Object.keys(s).length) return s
			} catch (e){
				console.error(e)
			}
		}
		return null
	}

	saveJson(){
		try{
			var json=JSON.parse($('#stats-export-json').val())
			this.validateJson(json)
			localStorage.setItem(this.statsConfigKey, JSON.stringify(json))
		} catch(e){
			throw e
			alert(e)
		}
		closeLightBox()
		this.drawFunction()
		return false
	}

	showExportDialog(){
		var dialog=$('#stats-export')
		if (!dialog.length){
			dialog=$('<div id=stats-export class=lightBoxCenterContent>')
			.append(
				$('<textarea id=stats-export-json style=display:block;width:98vw;max-width:30em;height:90vh;max-height:60em>')
			).append($('<button>Save</button>').click(this.saveJson.bind(this)))
			.append($('<button>Cancel</button>').click(closeLightBox))
			$('body').append(dialog)
		}
		$('#stats-export-json').val(JSON.stringify(this.getStatsConfig(),null,2))
		showLightBox(dialog)
		return false
	}

	save(){
		var fields=$("#stats-config-fields li").map(function(){return $(this).attr("data-field")}).get(),
		stats=this.getStatsConfig()
		if (!fields.length) return alert("Error: No fields in list")
		if (this.hasSections){
			var sectionName=$('#stats-config-section-name'),
			oldSectionName=sectionName.attr('old-name'),
			newSectionName=sectionName.val()
			if (!newSectionName) return alert("Error: Name not specified")
			if (oldSectionName != newSectionName) delete stats[oldSectionName]
			if (this.hasGraphs){
				stats[newSectionName]={
					graph: $('#stats-config-graph-type').val(),
					data: fields
				}
			} else {
				stats[newSectionName]=fields
			}
		} else {
			stats=fields
		}
		localStorage.setItem(this.statsConfigKey, JSON.stringify(stats))
		closeLightBox()
		this.drawFunction()
	}

	handleAddFieldChange(e){
		var field=$(e.target).val()
		if (field) this.addFieldToStatsConfig(field)
		$(e.target).val('')
	}

	appendFieldList(dialog){
		dialog.append($('<ul id=stats-config-fields>'))
		.append('Add: ').append($('<select id=stats-config-add-field>').change(this.handleAddFieldChange.bind(this)))
		.append(
			$('<p>').append($('<button>Save</button>').click(this.save.bind(this)))
			.append(" ").append($('<button>Cancel</button>').click(closeLightBox))
		)
	}

	saveToServer(){
		var form=$('#stats-config-save-form')
		if (!form.length){
			form=$('<form method=POST action=/admin/stats-config.cgi id=stats-config-save-form>')
			.append($('<input type=hidden name=return>').val(location.pathname+location.search+location.hash))
			.append($('<input type=hidden name=season>').val(eventYear))
			.append($('<input type=hidden name=type>').val(this.fileName))
			.append($('<input type=hidden name=conf>'))
			$('body').append(form)
		}
		form.find('[name="conf"]').val(JSON.stringify(this.getStatsConfig()))
		form.submit()
		return false
	}

	revertPersonalCustomizations(){
		if (confirm("Are you sure you want delete ALL your personal custom graph configuration?")){
			localStorage.removeItem(this.statsConfigKey)
			closeLightBox()
			this.drawFunction()
		}
		return false
	}

	revertAllCustomizations(){
		if (confirm("Are you sure you want delete ALL your personal AND team's custom graph configuration?")){
			localStorage.setItem(this.statsConfigKey, JSON.stringify(this.defaultConfig))
			closeLightBox()
			this.drawFunction()
		}
		return false
	}

	handleChangeGraphType(e){
		var me=this,
		type = $(e.target).val()
		$('#stats-config-fields li').each(function(){
			var field = $(this).attr('data-field')
			if (!me.graphTypeOk(field,type))$(this).remove()
		})
		this.populateAddFields()
	}

	graphTypeOk(field,types){
		var modes = new Set()
		if (typeof types == 'string'){
			types=graphTypes[types]
			modes=types.modes
			types=types.types
		}
		return statInfo[field] && statInfo[field].type && types.has(statInfo[field].type) && (!this.mode || modes.has(this.mode))
	}

	showEditSectionDialog(e){
		var me=this,
		section=$(e.target).attr('data-section'),
		dialog=$('#stats-config-edit')
		if (!dialog.length){
			dialog=$('<div id=stats-config-edit class=lightBoxCenterContent style=display:none>')
			.append($(`<p><input id=stats-config-section-name type=text style=width:100% placeholder="Name of ${this.hasGraphs?'graph':'section'}"></p>`))
			if (me.hasGraphs)dialog.append($('<p>').append($('<select id=stats-config-graph-type>').change(this.handleChangeGraphType.bind(this))))
			this.appendFieldList(dialog)
			$('body').append(dialog)
			if(me.hasGraphs){
				Object.keys(graphTypes).forEach(function(graphType){
					var available = false
					for (var field in statInfo){
						if (me.graphTypeOk(field,graphType)){
							available=true
							break
						}
					}
					if (available)$('#stats-config-graph-type').append($('<option>').attr('value',graphType).text(graphTypes[graphType].name))
				})
			}
		}
		$('#stats-config-section-name').val(section||"")
		var stats=me.getStatsConfig()[section]||(me.hasGraphs?{graph:"bar",data:[]}:[]),
		fields=me.hasGraphs?stats.data:stats
		if(me.hasGraphs)$('#stats-config-graph-type').val(stats.graph)
		me.populateFields(fields)
		showLightBox(dialog)
		return false
	}

	removeSection(e){
		var section=$(e.target).attr('data-section')
		if (confirm("Are you sure you want to remove this graph?")){
			var stats=this.getStatsConfig()
			delete stats[section]
			localStorage.setItem(this.statsConfigKey, JSON.stringify(stats))
			closeLightBox()
			showStats()
		}
		return false
	}

	populateFields(fields){
		$('#stats-config-fields').html("")
		fields.forEach(field=>this.addFieldToStatsConfig(field))
		this.populateAddFields()
	}

	addFieldToStatsConfig(field){
		$('#stats-config-fields').append(
			$('<li>')
			.attr('data-field',field)
			.text(" " + statInfo[field].name).prepend(
				$('<button style=color:red>').text('✘').click(function(){
					$(this).closest('li').remove()
				})
			)
		)
	}

	populateAddFields(){
		var select=$('#stats-config-add-field'),
		config=this,
		types=config.hasGraphs? new Set(graphTypes[$('#stats-config-graph-type').val()].types):new Set(numericGraphTypes),
		statNames=Object.keys(statInfo)
		statNames.sort((a,b)=>statInfo[a].name.localeCompare(statInfo[b].name))
		select.html("")
		select.append($('<option>').attr('value',"").attr('selected','true'))
		statNames.forEach(function(stat){
			var info=statInfo[stat]
			if (types.has(info.type) || (config.hasWhiteboard && info.whiteboard_end)){
				select.append($('<option>').attr('value',stat).text(`${info.name} (${info.type})`))
			}
		})
	}

	setTeam(team){
		this.team=team
	}

	showConfigDialog(e){
		var section=$(e.target).attr('data-section'),
		dialog=$('#stats-config')
		if (!dialog.length){
			dialog=$('<div id=stats-config class=lightBoxCenterContent style=display:none>')
			if(this.hasSections){
				var sectionLinks=$('<ul>')
				if (this.hasGraphs && this.downloadBlobs)sectionLinks.append($('<li>').append($('<a id=download-data-link>Download Data</a>')))
				sectionLinks.append($('<li>').append($('<a class=needs-section-attr href=#edit>Edit</a>').click(this.showEditSectionDialog.bind(this))))
				.append($('<li>').append($('<a class=needs-section-attr href=#remove>Remove</a>').click(this.removeSection.bind(this))))
				dialog.append($('<h2 class=needs-section-text>'))
				.append(sectionLinks)
				.append($('<h2>').text(this.hasGraphs?"Manage Graphs":"Manage Stats"))
			} else {
				this.appendFieldList(dialog)
			}
			var manageAllList = $('<ul>')
			if (this.hasSections)manageAllList.append($('<li>').append($(`<a href=#edit-json>Add ${this.hasGraphs?"Graph":"Section"}</a>`).click(this.showEditSectionDialog.bind(this))))

			manageAllList
			.append($('<li>').append($('<a href=#edit-json>Edit JSON</a>').click(this.showExportDialog.bind(this))))
			.append($('<li>').append($('<a href=#save-server>Save to Server</a>').click(this.saveToServer.bind(this))))
			.append($('<li>').append($('<a href=#revert-personal>Revert Personal Customizations</a>').click(this.revertPersonalCustomizations.bind(this))))
			.append($('<li>').append($('<a href=#revert-all>Revert All Customizations</a>').click(this.revertAllCustomizations.bind(this))))
			dialog.append(manageAllList)
			$('body').append(dialog)
		}
		var stats=this.getStatsConfig()
		if(this.hasSections){
			stats=stats[section]||(this.hasGraphs?{graph:'bar',data:[]}:[])
			$('.needs-section-attr').attr('data-section',section)
			$('.needs-section-text').text(section)
		} else {
			this.populateFields(stats)
		}
		if (this.hasGraphs && this.downloadBlobs){
			$('#download-data-link').attr('href',
				window.URL.createObjectURL(this.downloadBlobs[section])
			).attr('download',
				`${eventId}.${this.team?this.team+".":""}${section.toLowerCase().replace(/[^a-zA-Z0-9 ]/,"").replace(" ","_")}.csv`
			)
		}
		showLightBox(dialog)
	}
}
