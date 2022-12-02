#!/usr/bin/python3
import base64
import cgi
import numpy as np
import datetime
import os

"""
To do: (unknown, infinity)

Make preMatch

teamDiv
    Able to sort the columns

mathList
    lock headers



What is rung 0-4 key
"""
try:
    event = str(os.environ["QUERY_STRING"]).split("=")[1]
except:
    try:
        event=sys.argv[1]
    except:
        event="2022carv"
    
file = {
    "TIME": "../html/csv/" + event + ".tm",
    "MATCH": "../html/csv/" + event + ".txt",
    "QUALSCHEDULE": "./matchdata/" + event + ".dat",
    "ELIMSCHEDULE": "./matchdata/" + event + ".elims",
    "SEMISCHEDULE": "./matchdata/" + event + ".semis",
    "TEAMNAMES": "./neteams.txt",
}
# matchHeader = open(file["MATCH"]).readline().strip().split(",")
matchHeader = [
    "event",
    "match",
    "team",
    "taxi",
    "human",
    "auto_low_hub",
    "auto_high_hub",
    "auto_missed",
    "auto_bounce_out",
    "teleop_low_hub",
    "teleop_high_hub",
    "teleop_missed",
    "teleop_bounce_out",
    "shoot_from_hub",
    "shoot_from_field",
    "shoot_from_outer_LP",
    "shoot_from_wallLP",
    "rung",
    "defense",
    "defended",
    "fouls",
    "techfouls",
    "rank",
    "scouter",
    "comments",
]
matchDtype = [
    "|S10",
    "|S10",
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    int,
    "|S10",
    "|S256",
]
timeHeader = ["EVENT_MATCH", "TeamNumber", "TimeStamp", "TimeSinceLast", "Action"]


matchSchedule = []


class teamClass:
    def __init__(self, teamNumber) -> None:
        self.teamNumber: str = teamNumber
        self.teamName: str = ""
        self.rawMatchData: list = []
        self.rawTimeData: list = []
        self.TimeStateData: dict = {}
        self.MatchStats: dict = {
            "taxi": [],
            "human": [],
            "auto_low_hub": [],
            "auto_high_hub": [],
            "auto_missed": [],
            "auto_bounce_out": [],
            "teleop_low_hub": [],
            "teleop_high_hub": [],
            "teleop_missed": [],
            "teleop_bounce_out": [],
            "shoot_from_hub": [],
            "shoot_from_field": [],
            "shoot_from_outer_LP": [],
            "shoot_from_wallLP": [],
            "rung": [],
            "defense": [],
            "defended": [],
            "fouls": [],
            "techfouls": [],
            "rank": [],
            "pts": [],
            "auto_cargo": [],
            "teleop_cargo": [],
            "teleop_high_hub_defended": [],
            "teleop_low_hub_defended": [],
            "teleop_high_hub_defense": [],
            "teleop_low_hub_defense": [],
        }
        self.MatchStatsAgg: dict = {
            "taxi": metric(),
            "human": metric(),
            "auto_low_hub": metric(),
            "auto_high_hub": metric(),
            "auto_missed": metric(),
            "auto_bounce_out": metric(),
            "teleop_low_hub": metric(),
            "teleop_high_hub": metric(),
            "teleop_missed": metric(),
            "teleop_bounce_out": metric(),
            "shoot_from_hub": metric(),
            "shoot_from_field": metric(),
            "shoot_from_outer_LP": metric(),
            "shoot_from_wallLP": metric(),
            "rung": metric(),
            "defense": metric(),
            "defended": metric(),
            "fouls": metric(),
            "techfouls": metric(),
            "rank": metric(),
            "pts": metric(),
            "auto_cargo": metric(),
            "teleop_cargo": metric(),
            "teleop_high_hub_defended": metric(),
            "teleop_low_hub_defended": metric(),
            "teleop_high_hub_defense": metric(),
            "teleop_low_hub_defense": metric(),
        }
        self.Agg: dict = {"Pts": metric()}

    # Good needs comments
    def __str__(self):
        result = (
            "TeamNumber: "
            + self.teamNumber
            + "\n"
            + "TeamName: "
            + self.teamName
            + "\n"
            + "LenTimeData: "
            + str(len(self.rawTimeData))
            + "\n"
            + "LenMatchData: "
            + str(len(self.rawMatchData))
            + "\n"
        )
        return result

    # Good, needs time stats.
    def update(self):
        """
        Needs updating, now using metrics on each col
        Building the match data!
        To do this we will generate these metrics.
        - Auto Cargo Low/Hi Avgs
        - Auto Cargo Bo
        - Auto Taxi Avg - How reliable

        - Cargo
             - Lo/Hi Avg
             - Lo/Hi Q3
             - Lo/Hi Box
             - Min only if being defended.

        - Climb Avg
        """

        # Not sure if this is dumb or smart, I think this could be better as a numpy array but currenty is good bc it works....
        # Basically sorts the rawMatchData into a dictionary of lists of that data...No major purposes outside of sucking up memory.
        # Note to Justin: Definetly should look into adopting full numpy...
        for i, row in enumerate(self.rawMatchData):
            if row["defended"] != 0:
                self.rawMatchData[i]["teleop_high_hub_defended"] = row[
                    "teleop_high_hub"
                ]
                self.rawMatchData[i]["teleop_low_hub_defended"] = row["teleop_low_hub"]

            if row["defense"] != 0:
                self.rawMatchData[i]["teleop_high_hub_defense"] = row["teleop_high_hub"]
                self.rawMatchData[i]["teleop_low_hub_defense"] = row["teleop_low_hub"]

        # Building the metric clss out, and actually assigning numers to the stats in
        for k in self.MatchStatsAgg.keys():
            try:
                data = [x[k] for x in self.rawMatchData]
                self.MatchStatsAgg[k].Min = np.min(data)
                self.MatchStatsAgg[k].Q1 = round(np.quantile(data, 0.25), 2)
                self.MatchStatsAgg[k].Avg = round(np.mean(data), 2)
                self.MatchStatsAgg[k].Q3 = round(np.quantile(data, 0.75), 2)
                self.MatchStatsAgg[k].Max = np.max(data)
                self.MatchStatsAgg[k].Range = (
                    self.MatchStatsAgg[k].Max - self.MatchStatsAgg[k].Min
                )
                self.MatchStatsAgg[k].n = len(data)
                self.MatchStatsAgg[k].std = round(np.std(data), 2)
            except:
                self.MatchStatsAgg[k].Min = "--"
                self.MatchStatsAgg[k].Q1 = "--"
                self.MatchStatsAgg[k].Avg = "--"
                self.MatchStatsAgg[k].Q3 = "--"
                self.MatchStatsAgg[k].Max = 0
                self.MatchStatsAgg[k].Range = "--"
                self.MatchStatsAgg[k].n = "--"
                self.MatchStatsAgg[k].std = "--"


# Good Needs comments, and can grow
class metric:
    def __init__(self) -> None:
        self.Min = None
        self.Q1 = None
        self.Avg = None
        self.Q3 = None
        self.Max = None
        self.Range = None
        self.n = None
        self.std = None

    def __str__(self) -> str:
        return (
            "Min"
            + str(self.Min)
            + " Q1: "
            + str(self.Q1)
            + " Avg: "
            + str(self.Avg)
            + " Q3: "
            + str(self.Q3)
            + " Max: "
            + str(self.Max)
            + " Range: "
            + str(self.Range)
            + " n: "
            + str(self.n)
            + " std: "
            + str(self.std)
        )


# Defines the basic teams structure, and var
teams = {}  # type : dict(str, teamClass)


# Good - Added pts calc func call
def _parse_match_data():
    fread = open(file["MATCH"], "r").readlines()
    headers = fread[0].strip().split(",")
    # print(headers)
    for line in fread[1:]:
        # Generates line as a list, broken into approp sections
        line = line.strip().split(",", maxsplit=len(matchHeader) - 1)

        # Checks Line for appropiate length
        if len(line) != len(matchHeader):
            continue

        # Makes the notes human readable
        line[-1] = line[-1].replace("+", " ")
        line[-2] = line[-2].replace("+", " ")

        # Sets a sereis from the line into ints
        line = line[0:3] + [int(x) for x in line[3:23]] + line[23:]

        # Creates a dict mapping instead of a list
        result = dict()
        for i in range(len(headers)):
            result[headers[i]] = line[i]

        # Pts Calc
        result["pts"] = _pts_calc(result)

        # Calc the total scored cargo in auto and in tele
        result["auto_cargo"] = result["auto_high_hub"] + result["auto_low_hub"]
        result["teleop_cargo"] = result["teleop_high_hub"] + result["teleop_low_hub"]

        # Appends to the teams data in the teams list
        teams[result["team"]].rawMatchData.append(result)


# Good
def _parse_time_data():
    fread = open(file["TIME"], "r").readlines()
    for line in fread:
        # Does the primary split into a list of 3 items at max
        line = line.strip().split(",", maxsplit=2)

        # Checks the length of the line and ensures it has atleast one data point.
        if len(line) < 3:
            continue

        # Assigns teamNum, event, MatchNum, pos, and data.
        teamNum = line[1]
        event, MatchNum, pos = line[0].split("_")
        # Data is built from the last entry into the line and creates the list of entries.
        data = [
            [round(float(x.split(":")[0]) / 1000, 5), x.split(":")[1]]
            for x in line[2].split(",")
        ]
        # Assigns and finds the baseTime for each line, as the data is relative to the page load.
        baseTime = float(data[0][0])

        # Function that iterates over the data in the line and creates entries from each button press.
        for i in range(len(data)):  # len(data)
            if i == 0:
                result = {
                    "event": event,
                    "match": MatchNum,
                    "pos": pos,
                    "team": teamNum,
                    "matchTime": round(data[i][0] - baseTime, 5),
                    "timeLast": 0,
                    "action": data[i][1],
                }
            else:
                result = {
                    "event": event,
                    "match": MatchNum,
                    "pos": pos,
                    "team": teamNum,
                    "matchTime": round(data[i][0] - baseTime, 5),
                    "timeLast": round(data[i][0] - data[i - 1][0], 5),
                    "action": data[i][1],
                }
            teams[teamNum].rawTimeData.append(result)


def _schedules():
    if os.path.exists(file["QUALSCHEDULE"]):
        _parse_qual_matchSchedule(file["QUALSCHEDULE"])
    if os.path.exists(file["ELIMSCHEDULE"]):
        _parse_playoff_matchSchedule("elims")
    if os.path.exists(file["SEMISCHEDULE"]):
        _parse_playoff_matchSchedule("semis")


def _parse_playoff_matchSchedule(typ):
    """Builds the match schedule for the event selected."""
    pos_dict = {1: "r1", 2: "r2", 3: "r3", 4: "b1", 5: "b2", 6: "b3"}

    fread = open(file["ELIMSCHEDULE"], "r").readlines()
    alliances = {1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [], 8: []}
    i = 0
    for line in fread:
        i += 1
        line = line.strip()
        line = [x.strip() for x in line.split("-")]
        alliances[i] = line
    i = 0
    for r, b in [(1, 8), (2, 7), (3, 6), (4, 5), (1, 8), (2, 7), (3, 6), (4, 5)]:
        i += 1
        matchSchedule.append(
            [
                "qf" + str(i),
                alliances[r][0],
                alliances[r][1],
                alliances[r][2],
                "",
                "",
                alliances[b][0],
                alliances[b][1],
                alliances[b][2],
                "",
                "",
            ]
        )

    """
    QF Matches:::
    qf1 1v8
    qf2 2 v7
    qf3 3v4
    qf4 5v6
    qf5 1v8
    qf6 2 v7
    qf7 3v4
    qf8 5v6
    """


# Good should add analyitcs here, unsure...
def _parse_qual_matchSchedule(path):
    """Builds the match schedule for the event selected."""
    pos_dict = {1: "r1", 2: "r2", 3: "r3", 4: "b1", 5: "b2", 6: "b3"}

    fread = open(path, "r").readlines()
    result = []
    for line in fread:
        line = line.strip()
        line = [x.strip() for x in line.split("=")]
        event, match, pos = line[0].split("_")
        pos = pos_dict[int(pos)]
        result.append((event, match, pos, line[1]))
        if pos == "b3":
            res = [
                match,
                result[0][3],  # R1
                result[1][3],  # R2
                result[2][3],  # R3
                "",  # Red Pts
                "",  # Red Rp
                result[3][3],  # B1
                result[4][3],  # B2
                result[5][3],  # B3
                "",  # Blue Pts
                "",  # Blue Rp
            ]
            matchSchedule.append(res)
            result = []

        # Build thes team list
        teamNum = line[1]
        if teamNum not in teams.keys():
            teams[teamNum] = teamClass(teamNum)


def _pts_calc(data: dict):
    """Calculates the total points from a dict of the data. DOES NOT FACTOR FOULS"""
    auto_pts = (
        (data["taxi"] * 2) + (data["auto_low_hub"] * 2) + (data["auto_high_hub"] * 4)
    )
    tele_pts = (data["teleop_low_hub"]) + (data["teleop_high_hub"] * 2)
    if data["rung"] == 1:
        tele_pts += 4
    elif data["rung"] == 2:
        tele_pts += 6
    elif data["rung"] == 3:
        tele_pts += 10
    elif data["rung"] == 4:
        tele_pts += 15
    return auto_pts + tele_pts


def _match_predictor():

    for i in range(len(matchSchedule)):
        row = matchSchedule[i]
        r1, r2, r3 = row[1:4]
        b1, b2, b3 = row[6:9]
        try:
            Redpts = (
                teams[r1].MatchStatsAgg["pts"].Avg
                + teams[r2].MatchStatsAgg["pts"].Avg
                + teams[r3].MatchStatsAgg["pts"].Avg
            )
            BluePts = (
                teams[b1].MatchStatsAgg["pts"].Avg
                + teams[b2].MatchStatsAgg["pts"].Avg
                + teams[b3].MatchStatsAgg["pts"].Avg
            )
            RedRp = rpCalc(teams[r1], teams[r2], teams[r3])
            BlueRp = rpCalc(teams[b1], teams[b2], teams[b3])
            if Redpts > BluePts:
                RedRp += 2
            elif BluePts > Redpts:
                BlueRp += 2

            matchSchedule[i][4] = round(Redpts, 1)
            matchSchedule[i][5] = RedRp
            matchSchedule[i][9] = round(BluePts, 1)
            matchSchedule[i][10] = BlueRp
        except TypeError:
            matchSchedule[i][4] = "--"
            matchSchedule[i][5] = "--"
            matchSchedule[i][9] = "--"
            matchSchedule[i][10] = "--"


def rpCalc(t1: teamClass, t2: teamClass, t3: teamClass):
    rp = 0
    auto_cargo = (
        t1.MatchStatsAgg["auto_cargo"].Avg
        + t2.MatchStatsAgg["auto_cargo"].Avg
        + t3.MatchStatsAgg["auto_cargo"].Avg
    )
    tele_cargo = (
        t1.MatchStatsAgg["teleop_cargo"].Avg
        + t2.MatchStatsAgg["teleop_cargo"].Avg
        + t3.MatchStatsAgg["teleop_cargo"].Avg
    )
    if (tele_cargo + auto_cargo) >= 20:
        rp += 1

    rung = (
        round(t1.MatchStatsAgg["rung"].Avg, 0)
        + round(t2.MatchStatsAgg["rung"].Avg, 0)
        + round(t3.MatchStatsAgg["rung"].Avg, 0)
    )
    if rung > 5:
        rp += 1

    return rp


def teamNames():
    fhand = open(file["TEAMNAMES"], "r", encoding="utf8")
    fread = fhand.readlines()
    for line in fread:
        line = line.split(":")
        teamNum = line[0]
        teamName = line[1]
        if teamNum in teams.keys():
            teams[teamNum].teamName = teamName
    fhand.close()


def updateTeams():
    for t in teams.keys():
        teams[t].update()


class page:
    def __init__(self) -> None:
        self.returnable = ""
        self.spacing = 0

    def __str__(self):
        return self.returnable

    def create(self):
        self.__init__()
        self.heading()
        self.body_init()
        self.navBar()
        self.home()
        self.matchList()
        self.teamList()
        self.preMatchDiv()
        self.teamDiv()
        self.body_close()

        return self

    def _css(self, path="", css=""):
        if path == "":
            self.returnable += (self.spacing * "\t") + "<style>\n"
            self.spacing += 1
            for line in css:
                self.returnable += (self.spacing * "\t") + line
            self.spacing -= 1
            self.returnable += "\n" + (self.spacing * "\t") + "</style>\n"
        elif path != "":
            self.returnable += (
                (self.spacing * "\t")
                + '<link rel="stylesheet" href="'
                + path
                + '"></link>\n'
            )
        return self

    def _scripts(self, path="", script=""):
        if path == "":
            self.returnable += (self.spacing * "\t") + "<script>\n"
            self.spacing += 1
            for line in script:
                self.returnable += (self.spacing * "\t") + line
            self.spacing -= 1
            self.returnable += "\n" + (self.spacing * "\t") + "</script>\n"
        elif path != "":
            self.returnable += (
                (self.spacing * "\t") + '<script src="' + path + '"></script>\n'
            )
        return self

    def heading(self):
        self.returnable += "<!DOCTYPE html>\n<html lang='en'>\n<head>\n"
        self.returnable += "\t<title>Clever Girl</title>\n"
        # Reads in and adds the scripts and css info, so it is imbeded from those files.
        # self._scripts(script=open("../sources/strat_analytics.js", "r").readlines())
        self._scripts(path="../sources/strat_analytics.js")
        # self._css(css=open("../sources/strat_analytics.css", "r").readlines())
        self._css(path="../sources/strat_analytics.css")
        self.returnable += "</head>\n"
        return self

    def body_init(self):
        self.returnable += "<body>\n"
        self.spacing += 1
        return self

    def body_close(self):
        self.spacing -= 1
        self.returnable += "</body>\n"
        return self

    def navBar(self):
        self.returnable += (self.spacing * "\t") + "<div id='navBarDiv'>\n"
        self.spacing += 1

        self.returnable += (self.spacing * "\t") + "<table id='headerTable'>\n"
        self.spacing += 1
        self.returnable += (
            (self.spacing * "\t")
            + "<tr>"
            + "<td><p>"
            + event
            + " Updated at: "
            + str(datetime.datetime.now())
            + "</p></td>"
            + "<td><h1>1073 Joshua</h1></td>"
            + """<td><p onclick='window.location.href = "../../cgi-bin/strat.py?event="""+ event + """";'>Refresh</p></td>"""
            + "</tr>\n"
        )
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>\n"
        self.returnable += (self.spacing * "\t") + "<ul id='navBarUl'>\n"
        self.spacing += 1
        # This makes a list of navagation buttons. Must be in tuple format as: (id, DisplayName)
        pages_nav = [
            ("home", "Home"),
            ("matchList", "Match List"),
            ("teamList", "Team List"),
        ]
        # Actually does the itteration to build the above buttons
        for p in pages_nav:
            self.returnable += (
                (self.spacing * "\t")
                + """<li onclick="page_change('"""
                + p[0]
                + """')">"""
                + p[1]
                + """</li>\n"""
            )
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</ul>\n"
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"

        return self

    def home(self):
        self.returnable += (
            self.spacing * "\t"
        ) + "<div id='home' class='page' style='display:block'>\n"
        self.spacing += 1
        self.returnable += (self.spacing * "\t") + "<p>Hellow World</p>\n"

        self.returnable += (
            self.spacing * "\t"
        ) + "<img id='fieldimg' src='../img/2022_field.png'>\n"
        # self.returnable += (
        #    (self.spacing * "\t")
        #    + """<img id='fieldimg' src="data:image/jpeg;base64,"""
        #    + img_to_bytes("../img/2022_field.png")
        #    + '"'
        #    + ">\n"
        # )
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"

    def matchList(self):
        self.returnable += (
            self.spacing * "\t"
        ) + "<div id='matchList' class='page' style='display:none'>\n"
        self.spacing += 1

        self.returnable += (self.spacing * "\t") + "<table id='matchTable'>\n"
        self.spacing += 1

        # These are the match schedule headers
        self.returnable += (self.spacing * "\t") + "<tr>"
        self.spacing += 1
        heads1 = [
            "Match #",
            "Red 1",
            "Red 2",
            "Red 3",
            "Red Pts",
            "Red RPs",
            "Blue 1",
            "Blue 2",
            "Blue 3",
            "Blue Pts",
            "Blue RPs",
        ]
        for x in heads1:
            self.returnable += "<th>" + str(x).strip() + "</th>"
        self.returnable += "</tr>\n"
        self.spacing -= 1

        # The actual data that goes into the matchList, so this is the itterated stuff for all matches.
        for row in matchSchedule:

            # Checks for which alliance wins based on prediction
            if row[4] > row[9]:
                dat = (
                    ("<td>" + str(row[0]) + "</td>")
                    + ("<td>" + str(row[1]) + "</td>")
                    + ("<td>" + str(row[2]) + "</td>")
                    + ("<td>" + str(row[3]) + "</td>")
                    + ("<td style='background-color:#FD7F7F'>" + str(row[4]) + "</td>")
                    + ("<td>" + str(row[5]) + "</td>")
                    + ("<td>" + str(row[6]) + "</td>")
                    + ("<td>" + str(row[7]) + "</td>")
                    + ("<td>" + str(row[8]) + "</td>")
                    + ("<td>" + str(row[9]) + "</td>")
                    + ("<td>" + str(row[10]) + "</td>")
                )
            elif row[4] < row[9]:
                dat = (
                    (
                        """<td onclick="page_change('preMatch"""
                        + row[0]
                        + """')">"""
                        + str(row[0])
                        + "</td>"
                    )
                    + ("<td>" + str(row[1]) + "</td>")
                    + ("<td>" + str(row[2]) + "</td>")
                    + ("<td>" + str(row[3]) + "</td>")
                    + ("<td>" + str(row[4]) + "</td>")
                    + ("<td>" + str(row[5]) + "</td>")
                    + ("<td>" + str(row[6]) + "</td>")
                    + ("<td>" + str(row[7]) + "</td>")
                    + ("<td>" + str(row[8]) + "</td>")
                    + (
                        "<td  style='background-color:lightblue'>"
                        + str(row[9])
                        + "</td>"
                    )
                    + ("<td>" + str(row[10]) + "</td>")
                )
            else:
                dat = (
                    """<td onclick="page_change('preMatch"""
                    + row[0]
                    + """')">"""
                    + str(row[0])
                    + "</td>"
                )
                dat += "".join(["<td>" + str(x) + "</td>" for x in row[1:]])
            parma = ""

            # Checks if the team is playing
            if "1073" in row:
                parma = "style=font-weight:bolder;"
            self.returnable += (
                (self.spacing * "\t")
                + "<tr onclick=page_change('preMatch"
                + row[0]
                + "') "
                + parma
                + ">"
                + dat
                + "</tr>\n"
            )
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>\n"
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"

    def preMatchTeam(self, teamNum, pos, style=""):
        team: teamClass = teams[teamNum]
        self.returnable += (
            (self.spacing * "\t")
            + """<table class='preMatchTeam' onclick="overlay_on('team"""
            + teamNum
            + """')">\n"""
        )
        self.spacing += 1
        self.returnable += (
            (self.spacing * "\t") + "<tr><td colspan=3>" + pos + "</td></tr>\n"
        )
        self.returnable += (
            (self.spacing * "\t")
            + "<tr><td>Team:</td><td colspan=2>"
            + teamNum
            + "</td></tr>\n"
        )
        self.returnable += (
            (self.spacing * "\t")
            + "<tr><td>Taxi Avg:</td><td colspan=2>"
            + str(team.MatchStatsAgg["taxi"].Avg)
            + "</td></tr>\n"
        )
        self.returnable += (
            self.spacing * "\t"
        ) + "<tr><td>Cargo</td><td>High</td><td>Low</td></tr>\n"
        self.returnable += (
            (self.spacing * "\t")
            + "<tr><td>Auto Cargo:</td><td>"
            + str(team.MatchStatsAgg["auto_high_hub"].Avg)
            + "</td><td>"
            + str(team.MatchStatsAgg["auto_low_hub"].Avg)
            + "</td></tr>\n"
        )
        self.returnable += (
            (self.spacing * "\t")
            + "<tr><td>Tele Cargo:</td><td>"
            + str(team.MatchStatsAgg["teleop_high_hub"].Avg)
            + "</td><td>"
            + str(team.MatchStatsAgg["teleop_low_hub"].Avg)
            + "</td></tr>\n"
        )
        self.returnable += (
            (self.spacing * "\t")
            + "<tr><td>Rung Avg:</td><td colspan=2>"
            + str(team.MatchStatsAgg["rung"].Avg)
            + "</td></tr>\n"
        )
        rungDict = {None: "--", 0: "None", 1: "Low", 2: "Mid", 3: "High", 4: "Trav"}
        self.returnable += (
            (self.spacing * "\t")
            + "<tr><td>Rung Max:</td><td colspan=2>"
            + str(rungDict[team.MatchStatsAgg["rung"].Max])
            + "</td></tr>\n"
        )
        self.returnable += (
            (self.spacing * "\t")
            + "<tr><td>Pts Avg:</td><td colspan=2>"
            + str(team.MatchStatsAgg["pts"].Avg)
            + "</td></tr>\n"
        )

        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>\n"

    def preMatchDiv(self):
        for row in matchSchedule:
            """
            div
                table
                    tr
                        td R1
                        td Field rowspan=3
                        td B1
                    tr
                    tr
                        td R2
                        td Blank
                        td B2
                    tr
                    tr
                        td R3
                        td Blank
                        td B3
                    tr
                table
            """
            # Preview Div Builder
            self.returnable += (
                (self.spacing * "\t")
                + "<div "
                + "id='preMatch"
                + row[0]
                + "' class='page preMatchDiv' style='display:none'"
                + ">\n"
            )
            self.spacing += 1

            # Makes the preMatchInfo
            self.returnable += (self.spacing * "\t") + "<table id='preMatchInfo'>\n"
            self.spacing += 1
            self.returnable += (
                (self.spacing * "\t")
                + "<tr><td>Match:</td><td>Red Pts</td><td>Red Rp</td><td>Blue Pts</td><td>Blue Rp</td></tr>\n"
            )
            self.returnable += (self.spacing * "\t") + "<tr>"
            if row[4] > row[9]:
                self.returnable += (
                    "<td>"
                    + row[0]
                    + "</td><td style='background-color:#FD7F7F'>"
                    + str(row[4])
                    + "</td><td>"
                    + str(row[5])
                    + "</td><td>"
                    + str(row[9])
                    + "</td><td>"
                    + str(row[10])
                    + "</td></tr>\n"
                )
            elif row[4] < row[9]:
                self.returnable += (
                    "<td>"
                    + row[0]
                    + "</td><td>"
                    + str(row[4])
                    + "</td><td>"
                    + str(row[5])
                    + "</td><td style='background-color:lightblue'>"
                    + str(row[9])
                    + "</td><td>"
                    + str(row[10])
                    + "</td></tr>\n"
                )
            self.spacing -= 1
            self.returnable += (self.spacing * "\t") + "</table>\n"

            # Starts the primary display table, shape is roughly 3x3 with the center colum being the field
            self.returnable += (self.spacing * "\t") + "<table id='preMatchData'>\n"
            self.spacing += 1

            red: list = row[1:4]
            blue: list = row[6:9]
            for i in range(3):

                self.returnable += (self.spacing * "\t") + "<tr>\n"
                self.spacing += 1

                self.returnable += (self.spacing * "\t") + "<td>\n"
                self.spacing += 1

                self.preMatchTeam(red[i], "Red " + str(i + 1))

                self.spacing -= 1
                self.returnable += (self.spacing * "\t") + "</td>\n"

                if i == 0:
                    self.returnable += (
                        (self.spacing * "\t")
                        + "<td rowspan=3><img id='fieldimg' src='../img/2022_field.png'></td>\n"
                    )  # Field Image

                self.returnable += (self.spacing * "\t") + "<td>\n"
                self.spacing += 1

                self.preMatchTeam(blue[i], "Blue " + str(i + 1))

                self.spacing -= 1
                self.returnable += (self.spacing * "\t") + "</td>\n"

                self.spacing -= 1
                self.returnable += (self.spacing * "\t") + "</tr>\n"

            self.spacing -= 1
            self.returnable += (self.spacing * "\t") + "</table>\n"
            self.spacing -= 1
            self.returnable += (self.spacing * "\t") + "</div>\n"

    def teamList(self):
        self.returnable += (
            self.spacing * "\t"
        ) + "<div id='teamList' class='page' style='display:none'>\n"
        self.spacing += 1

        self.returnable += (self.spacing * "\t") + "<table>\n"
        self.spacing += 1

        self.returnable += (
            self.spacing * "\t"
        ) + "<tr><th>Team Number</th><th>Team Name</th></tr>\n"

        teamlists = [int(x) for x in teams.keys()]
        teamlists.sort()
        teamlists = [str(x) for x in teamlists]

        for t in teamlists:
            self.returnable += (
                (self.spacing * "\t")
                + "<tr onclick=overlay_on('team"
                + t
                + "')><td>"
                + t
                + "</td><td>"
                + teams[t].teamName
                + "</td></tr>\n"
            )

        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>\n"
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"

    def teamDiv(self):
        for team in teams.keys():
            # Identifies the teamClass for the selected Team
            team: teamClass = teams[team]

            # Opens the Div for the team overlay
            self.returnable += (
                (self.spacing * "\t")
                + "<div id='team"
                + team.teamNumber
                + "' class='overlay' style='display:none'>\n"
            )
            self.spacing += 1

            # This is where data should actually be, its a secondary div
            self.returnable += (
                self.spacing * "\t"
            ) + "<div class='teamDiv' style='display:block;'>\n"
            self.spacing += 1
            # Heading for the div...
            self.returnable += (
                self.spacing * "\t"
            ) + """<p id='closer' onclick="overlay_off()">Close</p>\n"""
            self.returnable += (
                (self.spacing * "\t")
                + "Team Number:"
                + team.teamNumber
                + "    Team Name:"
                + team.teamName
                + "\n"
            )

            # Lets define the layout
            """
            Raw Data:
                Table
                    tr Metrics
                    tr Matches
                table

            Auto:
                table

            """
            # Defines the list of things that are available.
            # Sets these in place : ["rawData", "auto", "tele", "endgame"]
            self.returnable += (self.spacing * "\t") + "<ul id='teamViews'>\n"
            self.spacing += 1
            self.returnable += (
                self.spacing * "\t"
            ) + "<li onclick=team_metric_change('rawData')>Raw Data</li>\n"
            self.returnable += (
                self.spacing * "\t"
            ) + "<li onclick=team_metric_change('auto')>Auto Analysis</li>\n"
            self.returnable += (
                self.spacing * "\t"
            ) + "<li onclick=team_metric_change('tele')>Tele Analysis</li>\n"
            self.returnable += (
                self.spacing * "\t"
            ) + "<li onclick=team_metric_change('endgame')>End Game</li>\n"
            self.spacing -= 1
            self.returnable += (self.spacing * "\t") + "</ul>\n"

            # Begins the rawData view
            self.TeamRawData(team)
            self.TeamAuto(team)
            self.TeamTele(team)
            self.TeamEndGame(team)

            self.spacing -= 1
            self.returnable += (self.spacing * "\t") + "</div>\n"
            self.spacing -= 1
            self.returnable += (self.spacing * "\t") + "</div>\n"

    def TeamRawData(self, team: teamClass):
        rawDataFields = [
            "match",
            "taxi",
            "human",
            "auto_low_hub",
            "auto_high_hub",
            "auto_missed",
            "auto_bounce_out",
            "teleop_low_hub",
            "teleop_high_hub",
            "teleop_missed",
            "teleop_bounce_out",
            "shoot_from_hub",
            "shoot_from_field",
            "shoot_from_outer_LP",
            "shoot_from_wallLP",
            "rung",
            "defense",
            "defended",
            "fouls",
            "techfouls",
            "rank",
            "pts",
            "auto_cargo",
            "teleop_cargo",
        ]
        self.returnable += (
            self.spacing * "\t"
        ) + "<div class='team_metric' id='rawData' style='display:block;'>\n"
        self.spacing += 1
        self.returnable += (self.spacing * "\t") + "<table>\n"
        self.spacing += 1
        self.returnable += (
            (self.spacing * "\t")
            + "<tr>"
            + "<th>match</th>"
            + "".join(["<td>" + x + "</td>" for x in rawDataFields[1:]])
            + "</tr>\n"
        )
        for row in team.rawMatchData:
            self.returnable += (
                (self.spacing * "\t")
                + "<tr>"
                + "<th>"
                + str(row["match"])
                + "</th>"
                + "".join(["<td>" + str(row[x]) + "</td>" for x in rawDataFields[1:]])
                + "</tr>\n"
            )

        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>"
        # Closing the rawData view
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"

    def TeamAuto(self, team: teamClass):
        self.returnable += (
            self.spacing * "\t"
        ) + "<div class='team_metric' id='auto' style='display:none;'>\n"
        self.spacing += 1

        self.returnable += (self.spacing * "\t") + "<table>\n"
        self.spacing += 1

        # Creates the table headers for each thing
        tableHeaders = ["metric", "Min", "Q1", "Avg", "Q3", "Max", "Range", "n", "std"]
        self.returnable += (
            (self.spacing * "\t")
            + "<tr>"
            + "".join(["<td>" + x + "</td>" for x in tableHeaders])
            + "</tr>\n"
        )
        metrics = [
            "taxi",
            "human",
            "auto_low_hub",
            "auto_high_hub",
            "auto_missed",
            "auto_cargo",
        ]
        for m in metrics:
            r = "<tr><td>" + m + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Min) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Q1) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Avg) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Q3) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Max) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Range) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].n) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].std) + "</td>"
            r += "</tr>\n"
            self.returnable += (self.spacing * "\t") + r
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>\n"

        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"

    def TeamTele(self, team: teamClass):
        self.returnable += (
            self.spacing * "\t"
        ) + "<div class='team_metric' id='tele' style='display:none;'>\n"
        self.spacing += 1

        self.returnable += (self.spacing * "\t") + "<table>\n"
        self.spacing += 1

        # Creates the table headers for each thing
        tableHeaders = ["metric", "Min", "Q1", "Avg", "Q3", "Max", "Range", "n", "std"]
        self.returnable += (
            (self.spacing * "\t")
            + "<tr>"
            + "".join(["<td>" + x + "</td>" for x in tableHeaders])
            + "</tr>\n"
        )
        metrics = [
            "teleop_low_hub",
            "teleop_high_hub",
            "teleop_missed",
            "teleop_bounce_out",
            "teleop_cargo",
            "shoot_from_hub",
            "shoot_from_field",
            "shoot_from_outer_LP",
            "shoot_from_wallLP",
            "defense",
            "defended",
            "fouls",
            "techfouls",
            "rank",
        ]
        for m in metrics:
            r = "<tr><td>" + m + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Min) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Q1) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Avg) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Q3) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Max) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].Range) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].n) + "</td>"
            r += "<td>" + str(team.MatchStatsAgg[m].std) + "</td>"
            r += "</tr>\n"
            self.returnable += (self.spacing * "\t") + r
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>\n"

        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"

    def TeamEndGame(self, team: teamClass):
        self.returnable += (
            self.spacing * "\t"
        ) + "<div class='team_metric' id='endgame' style='display:none;'>\n"
        self.spacing += 1

        self.returnable += (self.spacing * "\t") + "<table>\n"
        self.spacing += 1

        tableHeaders = ["metric", "Min", "Q1", "Avg", "Q3", "Max", "Range", "n", "std"]
        self.returnable += (
            (self.spacing * "\t")
            + "<tr>"
            + "".join(["<td>" + x + "</td>" for x in tableHeaders])
            + "</tr>\n"
        )

        r = "<tr><td>Rung</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].Min) + "</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].Q1) + "</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].Avg) + "</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].Q3) + "</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].Max) + "</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].Range) + "</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].n) + "</td>"
        r += "<td>" + str(team.MatchStatsAgg["rung"].std) + "</td>"
        r += "</tr>\n"
        self.returnable += (self.spacing * "\t") + r
        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</table>\n"

        self.spacing -= 1
        self.returnable += (self.spacing * "\t") + "</div>\n"


def redirect():
    print(
        """<!DOCTYPE html>\n<html lang='en'>\n<script>document.onload = window.location.href = "./../strat/";</script>"""
    )


def img_to_bytes(path):
    """Initall used with the thinking all images needed to be imbeded as byte code.
    It was then discovered that writing that to a file is intensive and wasteful.
    Instead we are able to link them normally and save as "webiste, complete" this will also make a folder that is saved.
    So this has been depreicated.
    """
    fpath = "/".join(
        path.split("/")[:-1] + [path.split("/")[-1].strip(".png") + ".byt"]
    )
    if os.path.exists(fpath):
        return open(fpath, "r").read()
    else:
        result = base64.b64encode(open(path, "rb").read()).decode("utf8")
        open(fpath, "w").write(result)
        return result


if __name__ == "__main__":
    print("Content-type: text/html\n\n")
    print(event)
    print(datetime.datetime.now(), "A")
    # _build_team_list()
    _schedules()
    print(datetime.datetime.now(), "B")
    _parse_match_data()
    print(datetime.datetime.now(), "C")
    _parse_time_data()
    print(datetime.datetime.now(), "D")
    updateTeams()
    print(datetime.datetime.now(), "E")
    _match_predictor()
    print(datetime.datetime.now(), "F")
    teamNames()
    print(datetime.datetime.now(), "G")

    p = page()
    p.create()
    r = str(p)
    print(datetime.datetime.now(), "H")
    open("../html/strat/index.html", "w").write(r)
    print(datetime.datetime.now(), "I")
    redirect()
    print(datetime.datetime.now(), "J")
    # print(r)
    print(datetime.datetime.now(), "K")
