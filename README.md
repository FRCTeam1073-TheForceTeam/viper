# Viper - FRC/FTC Scouting

This is a scouting app designed and used by FRC 1073, The Force Team from Hollis and Brookline, New Hampshire.
It is designed to collect data about each of the robots as they compete in the tournament.
The data, such as the number of each type of point scored by each bot, is then used to inform alliance selection decisions.
It runs on as a web app on a server that can be taken to events and powered by a battery while watching matches.

## Website

The demo and public data can be found on the official Viper website: [ViperScout.com](https://viperscout.com/). Documentation, downloads, and installation instructions can be found on [GitHub](https://github.com/FRCTeam1073-TheForceTeam/viper).

## Usage

1. The lead scouter enters the match schedule for practice matches and qualification matches. Schedules can also be imported from the API or thebluealliance.com.\
   [<img src=doc/event-table.png width=200>](doc/event-table.png)
1. Team members can go interview other teams and collect pit scouting data.\
   [<img src=doc/pit-scout.png width=200>](doc/pit-scout.png) [<img src=doc/bot-photos.png width=200>](doc/bot-photos.png)
1. Six team members connect wired devices (Android tablets, Android phones, or laptops) and load the scouting page. Once the app is loaded, devices can be disconnected for watching and scouting matches. Data is stored in persistent storage on the client devices as it is collected. As scouting data is needed, devices plug back into the server and upload their data.\
   [<img src=doc/scouting-pre.png width=200>](doc/scouting-auto.png) [<img src=doc/scouting-auto.png width=200>](doc/scouting-auto.png) [<img src=doc/scouting-tele.png width=200>](doc/scouting-tele.png) [<img src=doc/scouting-end.png width=200>](doc/scouting-end.png)
1. An additional scouter can be used to collect subjective data.\
   [<img src=doc/scouting-subjective.png width=200>](doc/scouting-subjective.png)
1. Scouting data can be used to plan for playing an upcoming match. It can give you insight into the strengths of the teams playing with you and the strengths and weaknesses of the teams playing against you. There is a specific page in the app that supports this use case with a fields whiteboard and stats for the teams playing.\
   [<img src=doc/planner.png width=200>](doc/planner.png)
1. Stats and rankings are available about all teams for alliance selection.\
   [<img src=doc/stats.png width=200>](doc/stats.png)
1. The match predictor forecasts likely scores for upcoming matches.\
   [<img src=doc/predictor.png width=200>](doc/predictor.png)
1. Once alliances are selected, team numbers for the alliances can be entered for further scouting during playoffs and finals.\
   [<img src=doc/playoffs.png width=200>](doc/playoffs.png) [<img src=doc/bracket.png width=200>](doc/bracket.png)
1. This software stores data in CSV files which can be imported into Excel or Tableau for further analysis.\
   [<img src=doc/csv.png width=200>](doc/csv.png)

## Demo

 - [Half hour video](https://drive.google.com/file/d/18dF44_FT35HEZ7824Iv5jhn8GvhnvuFO/view)
 - [Interactive demo](https://demo.viperscout.com/)

## Other documentation

 - [Recommended hardware](doc/hardware.md)
 - [Installing on Linux (Like a Raspberry Pi)](doc/linux-install.md)
 - [Installing on Windows with XAMPP](doc/windows-install.md)
 - [Windows, Mac, or Linux development environment with Docker](doc/docker-install.md)
 - For users:
   - [About](www/about.md)
   - [Printable instructions](www/printable-instructions.md)
   - [Event data entry instructions](www/event-table-instructions.md)
   - [Event page instructions](www/event-instructions.md)
   - [Bot photo scouting instructions](www/bot-photos-instructions.md)
   - [Scouting instructions — select a bot](www/scouting-select-bot-instructions.md)
   - [Scouting instructions — select a match](www/scouting-select-match-instructions.md)
   - Scouting instructions — record data
      - [2022](www/2022/scouting-instructions.md)
      - [2023](www/2023/scouting-instructions.md)
      - [2024](www/2024/scouting-instructions.md)
   - [Match planner instructions](www/planner-instructions.md)
   - [Data import/export instructions](www/import-export-instructions.md)
