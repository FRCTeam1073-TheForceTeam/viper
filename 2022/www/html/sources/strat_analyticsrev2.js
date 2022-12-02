matchList = {}


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

function update_json() {
    fetch("../sources/matchList.json")
        .then(function (response) {
            let responseJSON = response.json()
            console.log(responseJSON)
        })
}
