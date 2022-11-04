$(document).ready(function(){
    $('#blueAllianceSource').submit(function(){
        var re= /(?:\/match\/(20[0-9]{2}[a-zA-Z0-9]+)_qm([0-9]+))|(?:\/team\/([0-9]+)\/20)/g,
        m, event, qualifier, schedule = [["Match","R1","R2","R3","B1","B2","B3"]]
        do {
            m = re.exec($('textarea').val());            
            if (m) {
                if (m[1]){
                    event = m[1]
                    qualifier = parseInt(m[2])
                    if (!schedule[qualifier]) schedule[qualifier] = ["qm"+qualifier]
                } else if (qualifier && schedule[qualifier].length < 7){
                    schedule[qualifier].push(m[3])
                }
            }
        } while (m);
        if (schedule.length == 1){
            alert("No data found!")
        }
        var csv = ""
        for (var i=0; i<schedule.length; i++){
            row = schedule[i]
            if (row.length != 7){
                console.log(row)
                alert("Could not find six teams for match: " + row[0])
                return false
            }
            csv += row.join(",") + "\n"
        }
        $('#eventInp').val(event)
        $('#csvInp').val(csv)
        $('#csvForm').submit()
        return false
    })
})