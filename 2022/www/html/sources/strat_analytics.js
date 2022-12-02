function page_change(new_page) {
    var doc = document.getElementsByClassName("page");
    for (let i = 0; i < doc.length; i++) {
        if (doc[i].style.display == "block") {
            doc[i].style.display = "none";
        };
    };
    document.getElementById(new_page).style.display = "block";
    console.log(new_page)
}

document.onload = setTimeout(() => { updater(); }, 1000);

function updater() {
    console.log("Updating");
    var img = document.querySelector("#fieldimg");
    var divs = document.getElementsByClassName("FieldImg");
    console.log(divs.length);
    for (let i = 0; i < divs.length; i++) {
        if (divs[i].childElementCount == 0) {
            let clone = img.cloneNode(true);
            divs[i].appendChild(clone);
        }
    }
}
function overlay_on(id) {
    document.getElementById(id).style.display = "block";
}

function overlay_off() {
    var doc = document.getElementsByClassName("overlay");
    for (let i = 0; i < doc.length; i++) {
        if (doc[i].style.display == "block") {
            doc[i].style.display = "none";
        };
    };
}

function team_metric_change(view) {
    var doc = document.getElementsByClassName("team_metric");
    for (let i = 0; i < doc.length; i++) {
        if (doc[i].style.display == "block") {
            doc[i].style.display = "none";
        };
    };
    var doc = document.getElementsByClassName("team_metric");
    for (let i = 0; i < doc.length; i++) {
        if (doc[i].id == view) {
            doc[i].style.display = "block";
        };
    };
    console.log(view)
}