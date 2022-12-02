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
    let camera_button = document.querySelector("#start-camera");
    let video = document.querySelector("#video");
    let click_button = document.querySelector("#click-photo");
    let canvas = document.querySelector("#canvas");

    camera_button.addEventListener('click', async function () {
        let stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
        video.srcObject = stream;
    });

    click_button.addEventListener('click', function () {
        canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
        let image_data_url = canvas.toDataURL('image/jpeg');

        // data url of the image
        console.log(image_data_url);
    });
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
    document.getElementById(view).style.display = "block";
    console.log(new_page)
}