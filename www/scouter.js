"use strict"

addI18n({
	scouter_page_title:{
		en:'_EVENT_ Scouters',
		pt:'_EVENT_ Scouters',
		he:'_EVENT_ צופים',
		tr:'_EVENT_ Scouters',
		zh_tw:'_EVENT_偵察員',
		fr:'_EVENT_ Animateurs',
		es:'_EVENT_ Scout',
	},
	scouter_heading:{
		en:'Scouter',
		pt:'Scouter',
		he:'צופית',
		tr:'Scouter',
		zh_tw:'偵查員',
		fr:'Animateur',
		es:'Scout',
	},
	score_heading:{
		en:'Score',
		pt:'Pontuação',
		he:'ציון',
		tr:'Puan',
		zh_tw:'評分',
		fr:'Score',
		es:'Puntuación',
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
	score_info_title:{
		en:'How Score Works',
		pt:'Como o Score Funciona',
		he:'איך הציון מחושב',
		tr:'Puan Nasıl Hesaplanır',
		zh_tw:'評分如何計算',
		fr:'Comment le Score Fonctionne',
		es:'Cómo se Calcula la Puntuación',
	},
	score_info_body:{
		en:'Score blends how many matches a scouter covered with how accurate they were against the official FMS scores. More matches and lower average error both raise it, so the best scout is productive and reliable.',
		pt:'O Score combina quantas partidas um scouter cobriu com a precisão em relação às pontuações oficiais do FMS. Mais partidas e menor erro médio aumentam o valor, então o melhor scout é produtivo e confiável.',
		he:'הציון משלב כמה משחקים הצופה כיסה עם מידת הדיוק שלו מול ניקוד ה-FMS הרשמי. יותר משחקים ושגיאה ממוצעת נמוכה מעלים אותו, כך שהצופה הטוב ביותר הוא פורה ואמין.',
		tr:'Puan, bir gözlemcinin kaç maçı kapsadığını resmi FMS skorlarına göre ne kadar isabetli olduğuyla birleştirir. Daha fazla maç ve daha düşük ortalama hata puanı yükseltir, yani en iyi gözlemci üretken ve güvenilirdir.',
		zh_tw:'評分結合偵察員涵蓋的比賽數量與其相對於官方 FMS 分數的準確度。更多比賽和更低的平均誤差都會提高評分，因此最佳偵察員兼具產量與可靠度。',
		fr:'Le Score combine le nombre de matchs couverts par un animateur avec sa précision par rapport aux scores officiels FMS. Plus de matchs et une erreur moyenne plus faible l’augmentent, le meilleur animateur est donc productif et fiable.',
		es:'La Puntuación combina cuántos partidos cubrió un scout con su precisión frente a las puntuaciones oficiales del FMS. Más partidos y un menor error promedio la aumentan, así que el mejor scout es productivo y fiable.',
	},
	score_info_dash:{
		en:'A “—” means the scouter has no FMS-verified matches yet, so no score can be calculated.',
		pt:'Um “—” significa que o scouter ainda não tem partidas verificadas pelo FMS, portanto nenhum score pode ser calculado.',
		he:'הסימן ”—“ מציין שלצופה אין עדיין משחקים מאומתים מול FMS, ולכן לא ניתן לחשב ציון.',
		tr:'“—” işareti, gözlemcinin henüz FMS ile doğrulanmış maçı olmadığını, bu yüzden puan hesaplanamadığını gösterir.',
		zh_tw:'「—」表示該偵察員尚無經 FMS 驗證的比賽，因此無法計算評分。',
		fr:'Un « — » signifie que l’animateur n’a pas encore de matchs vérifiés par le FMS, donc aucun score ne peut être calculé.',
		es:'Un “—” significa que el scout aún no tiene partidos verificados por el FMS, por lo que no se puede calcular ninguna puntuación.',
	},
})

addTranslationContext({event:eventName})

var scouterRows = [],
sortColumn = 'score',
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
	$('#scouterStats').closest('table').on('click','th.sortable',function(){
		var col = $(this).data('sort')
		if (col == sortColumn) sortAsc = !sortAsc
		else { sortColumn = col; sortAsc = false }
		renderScouters()
	})
	showScouters()
})

function showScouters(){
	promiseScoutScoreCompare().then(values=>{
		var [scouterStats, matchStats] = values
		scouterRows = Object.keys(scouterStats).map(key=>{
			var s = scouterStats[key]
			s.score = compositeScore(s)
			return s
		})
		renderScouters()
	})
}

function renderScouters(){
	var dir = sortAsc ? 1 : -1
	scouterRows.sort((a,b)=>{
		var x = a[sortColumn], y = b[sortColumn]
		x = (x==null||isNaN(x)) ? -Infinity : x
		y = (y==null||isNaN(y)) ? -Infinity : y
		return dir*(x-y)
	})
	var table = $('#scouterStats').html("")
	scouterRows.forEach(s=>{
		table.append(
			$('<tr>')
			.append($('<td>').text(s.name))
			.append($('<td>').text(s.matches))
			.append($('<td>').text(s.avgError))
			.append($('<td>').addClass('scoreCell').text(s.score==null?'—':s.score.toFixed(1)))
		)
	})
	$('th.sortable').removeClass('sortedAsc sortedDesc')
	$('th.sortable[data-sort="'+sortColumn+'"]').addClass(sortAsc?'sortedAsc':'sortedDesc')
}
