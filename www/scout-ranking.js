"use strict"

addI18n({
	scout_ranking_page_title:{
		en:'_EVENT_ Scout Rankings',
		pt:'Classificação de Scouter do _EVENT_',
		he:'דירוגי צופים של _EVENT_',
		tr:'_EVENT_ Scouter Sıralamaları',
		zh_tw:'_EVENT_ 偵察員排名',
		fr:'Classement des Scouters de _EVENT_',
		es:'Clasificación de Scouter de _EVENT_',
	},
	scout_heading:{
		en:'Scout',
	},
	matches_heading:{
		en:'Matches',
		pt:'Partidas',
		he:'גפרורים',
		tr:'Maçlar',
		zh_tw:'火柴',
		fr:'Matchs',
		es:'Partidos',
	},
	error_heading:{
		en:'Average Error',
		pt:'Erro médio',
		he:'שגיאה ממוצעת',
		tr:'Ortalama Hata',
		zh_tw:'平均誤差',
		fr:'Erreur moyenne',
		es:'Error promedio',
	},
	score_heading:{
		en:'Productivity',
		pt:'Produtividade',
		he:'פרודוקטיביות',
		tr:'Verimlilik',
		zh_tw:'生產力',
		fr:'Productivité',
		es:'Productividad',
	},
	score_info_title:{
		en:'How Productivity Works',
		pt:'Como a Produtividade Funciona',
		he:'איך פרודוקטיביות מחושבת',
		tr:'Verimlilik Nasıl Hesaplanır',
		zh_tw:'生產力如何計算',
		fr:'Comment la Productivité Fonctionne',
		es:'Cómo Funciona la Productividad',
	},
	score_info_body:{
		en:'The productivity metric blends how many matches a scout covered with how accurate they were against the official FMS scores. More matches and lower average error both raise it, making the best scout dedicated and accurate.',
		pt:'A métrica de produtividade combina quantas partidas um scout cobriu com a precisão em relação às pontuações oficiais do FMS. Mais partidas e menor erro médio aumentam o valor, tornando o melhor scout dedicado e preciso.',
		he:'מדד הפרודוקטיביות משלב כמה משחקים צופה הכיסה עם מידת הדיוק שלו מול ניקוד ה-FMS הרשמי. יותר משחקים ושגיאה ממוצעת נמוכה מעלים אותו, מה שהופך את הצופה הטוב ביותר למסור ודיוק.',
		tr:'Verimlilik metriği, bir gözlemcinin kaç maç kapsadığını resmi FMS skorlarına göre ne kadar isabetli olduğuyla birleştirir. Daha fazla maç ve daha düşük ortalama hata onu artırır, en iyi gözlemciyi adanmış ve hassas hale getirir.',
		zh_tw:'生產力指標結合偵察員涵蓋的比賽數量與其相對於官方 FMS 分數的準確度。更多比賽和更低的平均誤差都會提高生產力，使最佳偵察員既敬業且準確。',
		fr:"La métrique de productivité combine le nombre de matchs couverts par un scout avec sa précision par rapport aux scores officiels FMS. Plus de matchs et une erreur moyenne plus faible l'augmentent, rendant le meilleur scout dévoué et fiable.",
		es:"La métrica de productividad combina cuántos partidos cubrió un scout con su precisión frente a las puntuaciones oficiales del FMS. Más partidos y un menor error promedio la aumentan, haciendo que el mejor scout sea dedicado y preciso.",
	},
	error_info_title:{
		en:'How Average Error Works',
		pt:'Como o Erro Médio Funciona',
		he:'איך השגיאה הממוצעת מחושבת',
		tr:'Ortalama Hata Nasıl Hesaplanır',
		zh_tw:'平均誤差如何計算',
		fr:'Comment l\'Erreur Moyenne Fonctionne',
		es:'Cómo Funciona el Error Promedio',
	},
	error_info_body:{
		en:'Average error measures how far a scout\'s scoring was from official FMS scores across their matches. It\'s the mean absolute difference between what they and the other scouts for the alliance recorded and what was official. Lower values indicate more accurate scouting. Average error may be missing if FMS data is not downloaded from the API or if the scout never scouted alliances with full scouting coverage.',
		pt:'O erro médio mede o quão distante a pontuação de um scout estava das pontuações oficiais do FMS em suas partidas. É a diferença absoluta média entre o que ele e os outros scouts da aliança registraram e o que era oficial. Valores mais baixos indicam scouting mais preciso. O erro médio pode estar ausente se os dados do FMS não forem baixados da API ou se o scout nunca tiver feito scout de alianças com cobertura completa de scouting.',
		he:'שגיאה ממוצעת מודדת עד כמה הניקוד של צופה היה רחוק מניקוד ה-FMS הרשמי על פני המשחקים שלהם. זוהי ההפרש המוחלט הממוצע בין מה שהם וצופי האליאנס האחרים רשמו למה שהיה רשמי. ערכים נמוכים יותר מצביעים על סיור מדויק יותר. ייתכן שהשגיאה הממוצעת תהיה חסרה אם נתוני FMS לא הורדו מ-API או אם הצופה לא עשה סיור של אליאנסים עם כיסוי סיור מלא.',
		tr:'Ortalama hata, bir gözlemcinin resmi FMS skorlarından ne kadar uzakta olduğunu onların maçları arasında ölçer. Bu, kaydettikleri ve ittifak için diğer gözlemcilerin kaydettikleri ile resmi olanlar arasındaki ortalama mutlak farktır. Daha düşük değerler daha doğru gözlemi gösterir. Ortalama hata, FMS verileri API\'den indirilmemişse veya gözlemci hiçbir zaman tam gözlem kapsamına sahip ittifakları gözlemlemiş değilse eksik olabilir.',
		zh_tw:'平均誤差衡量的是偵察員的分數與其比賽中官方 FMS 分數的差距。這是他們和聯盟其他偵察員記錄內容與官方內容之間的平均絕對差。較低的值表示偵察更準確。如果未從 API 下載 FMS 數據，或如果偵察員從未偵察過具有完整偵察覆蓋的聯盟，平均誤差可能會缺失。',
		fr:'L\'erreur moyenne mesure à quel point le score d\'un scout s\'écartait des scores FMS officiels dans ses matchs. C\'est la différence absolue moyenne entre ce que lui et les autres scouts de l\'alliance ont enregistré et ce qui était officiel. Les valeurs les plus basses indiquent un scouting plus précis. L\'erreur moyenne peut être manquante si les données FMS ne sont pas téléchargées depuis l\'API ou si le scout n\'a jamais été le scout d\'alliances avec une couverture complète de scouting.',
		es:'El error promedio mide cuánto se alejó la puntuación de un scout de las puntuaciones oficiales del FMS en sus partidos. Es la diferencia absoluta media entre lo que él y los otros scouts de la alianza registraron y lo que era oficial. Los valores más bajos indican un scouting más preciso. El error promedio puede faltar si los datos de FMS no se descargan de la API o si el scout nunca scouts de alianzas con cobertura completa de scouting.',
	},
})

addTranslationContext({event:eventName})

var scouterRows = [],
sortColumn = 'matches',
sortAsc = false

// Composite "best scout" score: rewards volume (log, so grinding has
// diminishing returns) gated by accuracy. Needs error data to judge a
// scouter, so anyone with no scored matches gets no score.
var ERROR_SOFTENER = 5
function compositeScore(s){
	if (!s.scoredMatches || s.avgError == null || isNaN(s.avgError)) return null
	return Math.log2(s.matches+1) * 100/(s.avgError+ERROR_SOFTENER)
}

$(document).ready(function(){
	$('th.sortable').click(function(){
		var col = $(this).data('sort')
		if (col == sortColumn) sortAsc = !sortAsc
		else { sortColumn = col; sortAsc = false }
		renderScoutRankings()
	})
	$('#scoreInfoTrigger').click(function(e){
		e.stopPropagation()
		showLightBox($('#scoreInfoLightbox'))
	})
	$('#errorInfoTrigger').click(function(e){
		e.stopPropagation()
		showLightBox($('#errorInfoLightbox'))
	})
	showScoutRankings()
})

function showScoutRankings(){
	promiseScoutScoreCompare().then(values=>{
		var [scouterStats, matchStats] = values
		scouterRows = Object.keys(scouterStats).map(key=>{
			var s = scouterStats[key]
			s.score = compositeScore(s)
			return s
		})
		renderScoutRankings()
	})
}

function renderScoutRankings(){
	var dir = sortAsc ? 1 : -1
	scouterRows.sort((a,b)=>{
		var x = a[sortColumn], y = b[sortColumn]
		x = (x==null||isNaN(x)) ? -Infinity : x
		y = (y==null||isNaN(y)) ? -Infinity : y
		return dir*(x-y)
	})
	var tbody = $('#rankings').html("")
	scouterRows.forEach(s=>{
		tbody.append(
			$('<tr>')
			.append($('<td>').text(s.name))
			.append($('<td>').text(s.matches))
			.append($('<td>').text(s.avgError))
			.append($('<td>').addClass('scoreCell').text(s.score==null?'':s.score.toFixed(1)))
		)
	})
	$('th.sortable').removeClass('sortedAsc sortedDesc')
	$('th.sortable[data-sort="'+sortColumn+'"]').addClass(sortAsc?'sortedAsc':'sortedDesc')
}
