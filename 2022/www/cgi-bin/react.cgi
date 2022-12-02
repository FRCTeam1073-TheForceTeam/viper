#!/usr/bin/perl

use strict;
use warnings;

#
# read in game state
#
my %params;
if (exists $ENV{'QUERY_STRING'}) {
    my @args = split /\&/, $ENV{'QUERY_STRING'};
    foreach my $arg (@args) {
	my @bits = split /=/, $arg;
	next unless (@bits == 2);
	$params{$bits[0]} = $bits[1];
    }
}

if (exists $ENV{'CONTENT_LENGTH'}) {
    my $content = $ENV{'CONTENT_LENGTH'};
    if ($content > 0) {
	my $data = <STDIN>;
	my @args = split /\&/, $data;
	foreach my $arg (@args) {
	    my @bits = split /=/, $arg;
	    next unless (@bits == 2);
	    $params{$bits[0]} = $bits[1];
	}
    }
}

my $game = "";
my $team = "";

$game = $params{'game'} if (defined $params{'game'});
$team = $params{'team'} if (defined $params{'team'});

if ("$game" eq "" || "$team" eq "") {
    print "Content-type: text/html

<html lang=\"en\"><head>
    <meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\">
    <meta charset=\"utf-8\">
  </head>
  <body>
  <H2>Error, missing venue, match, robot position, and/or team</H2>
  </body></html>\n";
    exit(0);
}

my @gbits  = split /_/, $game;
my $event  = $gbits[0];
my $match  = $gbits[1];
my $posnum = $gbits[2];

my $RED  = "bgcolor=\"#ff6666\"";
my $BLUE = "bgcolor=\"#99ccff\"";

my $color = $RED;
$color = $BLUE if ($posnum > 3);

#print "<!DOCTYPE html>\n";
print "Content-type: text/html

<html lang=\"en\"><head>
    <meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\">
    <meta charset=\"utf-8\">
  </head>
  <body>

    <script>
      var autoLoCount;
      var autoHiCount;
      var autoBounce;
      var autoMissed;
      var taxi;
      var human;
      var teleLoCount;
      var teleHiCount;
      var teleBounce;
      var teleMissed;
      var shootWLP;
      var shootOLP;
      var shootHub;
      var shootField;
      var rung;
      var defense;
      var defended;
      var fouls;
      var techfouls;
      var robot;

      autoLoCount = 0;
      autoHiCount = 0;
      autoBounce = 0;
      autoMissed = 0;
      taxi = 0;
      start = 0;
      human = 0;
      teleLoCount = 0;
      teleHiCount = 0;
      teleBounce = 0;
      teleMissed = 0;
      shootWLP = 0;
      shootOLP = 0;
      shootHub = 0;
      shootField = 0;
      rung = 0;
      defense = 0;
      defended = 0;
      fouls = 0;
      techfouls = 0;
      robot = 0;\n";

print "
      function getTime(event) {
          if (event.target.id != \"\") {
              let store = document.getElementById(\"timing\");
              store.value = store.value + ',' + event.timeStamp + ':' + event.target.id;
          }
       }
       document.body.addEventListener(\"click\", getTime);\n";

print "
       function toggle (id) {
          var str;
          str = \"&nbsp;No\";
          if (id == \"start\") {
              if (start == 0) {
                  document.getElementById(id).innerHTML = \"Match Started\";
                  document.getElementById('startButton').style = \"background-color:#eeeeee\";
                  start = 1;
              }
          }
          if (id == \"taxi\") {
              if (taxi == 0) {
                  taxi = 1;
                  str = \"Yes\";
              } else {
                  taxi = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT id='taxiClick' SIZE=+2>\" + str + \"</FONT>\";
              document.forms[0].taxi.value = taxi;
          }
          if (id == \"human\") {
              if (human == 0) {
                  human = 1;
                  str = \"Yes\";
              } else {
                  human = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT id='humanClick' SIZE=+2>\" + str + \"</FONT>\";
              document.forms[0].human.value = human;
          }
          if (id == \"wlp\") {
              if (shootWLP == 0) {
                  shootWLP = 1;
                  str = \"Yes\";
              } else {
                  shootWLP = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + str + \"</FONT>\";
              document.forms[0].shootWLP.value = shootWLP;
          }
          if (id == \"olp\") {
              if (shootOLP == 0) {
                  shootOLP = 1;
                  str = \"Yes\";
              } else {
                  shootOLP = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + str + \"</FONT>\";
              document.forms[0].shootOLP.value = shootOLP;
          }
          if (id == \"hub\") {
              if (shootHub == 0) {
                  shootHub = 1;
                  str = \"Yes\";
              } else {
                  shootHub = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + str + \"</FONT>\";
              document.forms[0].shootHub.value = shootHub;
          }
          if (id == \"field\") {
              if (shootField == 0) {
                  shootField = 1;
                  str = \"Yes\";
              } else {
                  shootField = 0;
              }

              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + str + \"</FONT>\";
              document.forms[0].shootField.value = shootField;
          }
          if (id == \"lorung\" || id == \"midrung\" || id == \"hirung\" || id == \"trav\") {
              loStr   = \"&nbsp;No\";
              midStr  = \"&nbsp;No\";
              hiStr   = \"&nbsp;No\";
              travStr = \"&nbsp;No\";\n";
print "
              if (id == \"lorung\") {
                  if (rung != 1) {
                      rung = 1;
                      loStr   = \"Yes\";
                      midStr  = \"&nbsp;No\";
                      hiStr   = \"&nbsp;No\";
                      travStr = \"&nbsp;No\";
                  } else {
                      rung = 0;
                  }
              }
              if (id == \"midrung\") {
                  if (rung != 2) {
                      rung = 2;
                      loStr   = \"&nbsp;No\";
                      midStr  = \"Yes\";
                      hiStr   = \"&nbsp;No\";
                      travStr = \"&nbsp;No\";
                  } else {
                      rung = 0;
                  }
              }
              if (id == \"hirung\") {
                  if (rung != 3) {
                      rung = 3;
                      loStr   = \"&nbsp;No\";
                      midStr  = \"&nbsp;No\";
                      hiStr   = \"Yes\";
                      travStr = \"&nbsp;No\";
                  } else {
                      rung = 0;
                  }
              }
              if (id == \"trav\") {
                  if (rung != 4) {
                      rung = 4;
                      loStr   = \"&nbsp;No\"
                      midStr  = \"&nbsp;No\";
                      hiStr   = \"&nbsp;No\";
                      travStr = \"Yes\";
                  } else {
                      rung = 0;
                  }
              }
              document.getElementById('lorung').innerHTML = \"<FONT id='lorungClick' SIZE=+2>\" + loStr + \"</FONT>\";
              document.getElementById('midrung').innerHTML = \"<FONT id='midrungClick' SIZE=+2>\" + midStr + \"</FONT>\";
              document.getElementById('hirung').innerHTML = \"<FONT id='hirungClick' SIZE=+2>\" + hiStr + \"</FONT>\";
              document.getElementById('trav').innerHTML = \"<FONT id='travClick' SIZE=+2>\" + travStr + \"</FONT>\";
              document.forms[0].rung.value = rung;
          }
      }\n";

print "
      function qtoggle (id) {
          loStr  = \"&nbsp;No\";
          midStr = \"&nbsp;No\";
          hiStr  = \"&nbsp;No\";
          if (id == 'dlo' || id == 'dmid' || id == 'dhi') {
              if (id == 'dlo') {
                  if (defense != 1) {
                      defense = 1;
                      loStr  = \"Yes\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      defense = 0;
                  }
              }
              if (id == 'dmid') {
                  if (defense != 2) {
                      defense = 2;
                      loStr  = \"&nbsp;No\";
                      midStr = \"Yes\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      defense = 0;
                  }
              }
              if (id == 'dhi') {
                  if (defense != 3) {
                      defense = 3;
                      loStr  = \"&nbsp;No\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"Yes\";
                  } else {
                      defense = 0;
                  }
              }
              document.getElementById('dlo').innerHTML = \"<FONT SIZE=+2>\" + loStr + \"</FONT>\";
              document.getElementById('dmid').innerHTML = \"<FONT SIZE=+2>\" + midStr + \"</FONT>\";
              document.getElementById('dhi').innerHTML = \"<FONT SIZE=+2>\" + hiStr + \"</FONT>\";
              document.forms[0].defense.value = defense;
              return;
          }\n";
print "
          if (id == 'olo' || id == 'omid' || id == 'ohi') {
              if (id == 'olo') {
                  if (defended != 1) {
                      defended = 1;
                      loStr  = \"Yes\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      defended = 0;
                  }
              }
              if (id == 'omid') {
                  if (defended != 2) {
                      defended = 2;
                      loStr  = \"&nbsp;No\";
                      midStr = \"Yes\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      defended = 0;
                  }
              }
              if (id == 'ohi') {
                  if (defended != 3) {
                      defended = 3;
                      loStr  = \"&nbsp;No\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"Yes\";
                  } else {
                      defended = 0;
                  }
              }
              document.getElementById('olo').innerHTML = \"<FONT SIZE=+2>\" + loStr + \"</FONT>\";
              document.getElementById('omid').innerHTML = \"<FONT SIZE=+2>\" + midStr + \"</FONT>\";
              document.getElementById('ohi').innerHTML = \"<FONT SIZE=+2>\" + hiStr + \"</FONT>\";
              document.forms[0].defended.value = defended;
              return;
          }\n";
print "
          if (id == 'flo' || id == 'fmid' || id == 'fhi') {
              if (id == 'flo') {
                  if (fouls != 1) {
                      fouls = 1;
                      loStr  = \"Yes\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      fouls = 0;
                  }
              }
              if (id == 'fmid') {
                  if (fouls != 2) {
                      fouls = 2;
                      loStr  = \"&nbsp;No\";
                      midStr = \"Yes\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      fouls = 0;
                  }
              }
              if (id == 'fhi') {
                  if (fouls != 3) {
                      fouls = 3;
                      loStr  = \"&nbsp;No\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"Yes\";
                  } else {
                      fouls = 0;
                  }
              }
              document.getElementById('flo').innerHTML = \"<FONT SIZE=+2>\" + loStr + \"</FONT>\";
              document.getElementById('fmid').innerHTML = \"<FONT SIZE=+2>\" + midStr + \"</FONT>\";
              document.getElementById('fhi').innerHTML = \"<FONT SIZE=+2>\" + hiStr + \"</FONT>\";
              document.forms[0].fouls.value = fouls;
              return;
          }\n";
print "
          if (id == 'tlo' || id == 'tmid' || id == 'thi') {
              if (id == 'tlo') {
                  if (techfouls != 1) {
                      techfouls = 1;
                      loStr  = \"Yes\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      techfouls = 0;
                  }
              }
              if (id == 'tmid') {
                  if (techfouls != 2) {
                      techfouls = 2;
                      loStr  = \"&nbsp;No\";
                      midStr = \"Yes\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      techfouls = 0;
                  }
              }
              if (id == 'thi') {
                  if (techfouls != 3) {
                      techfouls = 3;
                      loStr  = \"&nbsp;No\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"Yes\";
                  } else {
                      techfouls = 0;
                  }
              }
              document.getElementById('tlo').innerHTML = \"<FONT SIZE=+2>\" + loStr + \"</FONT>\";
              document.getElementById('tmid').innerHTML = \"<FONT SIZE=+2>\" + midStr + \"</FONT>\";
              document.getElementById('thi').innerHTML = \"<FONT SIZE=+2>\" + hiStr + \"</FONT>\";
              document.forms[0].techfouls.value = techfouls;
              return;
          }\n";
print "
          if (id == 'rlo' || id == 'rmid' || id == 'rhi') {
              if (id == 'rlo') {
                  if (robot != 1) {
                      robot = 1;
                      loStr  = \"Yes\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      robot = 0;
                  }
              }
              if (id == 'rmid') {
                  if (robot != 2) {
                      robot = 2;
                      loStr  = \"&nbsp;No\";
                      midStr = \"Yes\";
                      hiStr  = \"&nbsp;No\";
                  } else {
                      robot = 0;
                  }
              }
              if (id == 'rhi') {
                  if (robot != 3) {
                      robot = 3;
                      loStr  = \"&nbsp;No\";
                      midStr = \"&nbsp;No\";
                      hiStr  = \"Yes\";
                  } else {
                      robot = 0;
                  }
              }
              document.getElementById('rlo').innerHTML = \"<FONT SIZE=+2>\" + loStr + \"</FONT>\";
              document.getElementById('rmid').innerHTML = \"<FONT SIZE=+2>\" + midStr + \"</FONT>\";
              document.getElementById('rhi').innerHTML = \"<FONT SIZE=+2>\" + hiStr + \"</FONT>\";
              document.forms[0].robot.value = robot;
              return;
          }
      }\n";
print "
      function countUp (id) {
          if (id == \"alo\") {
              autoLoCount++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoLoCount + \"</FONT>\";
              document.forms[0].autoLoCount.value = autoLoCount;
          }
          if (id == \"ahi\") {
              autoHiCount++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoHiCount + \"</FONT>\";
              document.forms[0].autoHiCount.value = autoHiCount;
          }
          if (id == \"abo\") {
              autoBounce++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoBounce + \"</FONT>\";
              document.forms[0].autoBounce.value = autoBounce;
          }
          if (id == \"ami\") {
              autoMissed++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoMissed + \"</FONT>\";
              document.forms[0].autoMissed.value = autoMissed;
          }
          if (id == \"lo\") {
              teleLoCount++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleLoCount + \"</FONT>\";
              document.forms[0].teleLoCount.value = teleLoCount;
          }
          if (id == \"hi\") {
              teleHiCount++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleHiCount + \"</FONT>\";
              document.forms[0].teleHiCount.value = teleHiCount;
          }
          if (id == \"bo\") {
              teleBounce++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleBounce + \"</FONT>\";
              document.forms[0].teleBounce.value = teleBounce;
          }
          if (id == \"mi\") {
              teleMissed++;
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleMissed + \"</FONT>\";
              document.forms[0].teleMissed.value = teleMissed;
          }
      }\n";
print "
      function countDown (id) {
          if (id == \"alo\") {
              autoLoCount--;
              if (autoLoCount < 0) {
                  autoLoCount = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoLoCount + \"</FONT>\";
              document.forms[0].autoLoCount.value = autoLoCount;
          }
          if (id == \"ahi\") {
              autoHiCount--;
              if (autoHiCount < 0) {
                  autoHiCount = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoHiCount + \"</FONT>\";
              document.forms[0].autoHiCount.value = autoHiCount;
          }
          if (id == \"abo\") {
              autoBounce--;
              if (autoBounce < 0) {
                  autoBounce = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoBounce + \"</FONT>\";
              document.forms[0].autoBounce.value = autoBounce;
          }
          if (id == \"ami\") {
              autoMissed--;
              if (autoMissed < 0) {
                  autoMissed = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + autoMissed + \"</FONT>\";
              document.forms[0].autoMissed.value = autoMissed;
          }
          if (id == \"lo\") {
              teleLoCount--;
              if (teleLoCount < 0) {
                  teleLoCount = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleLoCount + \"</FONT>\";
              document.forms[0].teleLoCount.value = teleLoCount;
          }
          if (id == \"hi\") {
              teleHiCount--;
              if (teleHiCount < 0) {
                  teleHiCount = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleHiCount + \"</FONT>\";
              document.forms[0].teleHiCount.value = teleHiCount;
          }
          if (id == \"bo\") {
              teleBounce--;
              if (teleBounce < 0) {
                  teleBounce = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleBounce + \"</FONT>\";
              document.forms[0].teleBounce.value = teleBounce;
          }
          if (id == \"mi\") {
              teleMissed--;
              if (teleMissed < 0) {
                  teleMissed = 0;
              }
              document.getElementById(id).innerHTML = \"<FONT SIZE=+2>\" + teleMissed + \"</FONT>\";
              document.forms[0].teleMissed.value = teleMissed;
          }
      }
    </script>\n";

sub printCounter {
    my ($key, $desc) = (@_);
print "
            <table cellpadding=0 cellspacing=0 border=0>
              <tr>
                <td colspan=2>
                  <button onclick=\"countUp('${key}')\">
                    <img id='${key}Up' src=\"/scoutpics/count_up2.png\">
                  </button>
                </td>
              </tr><tr>
                <td align=\"center\"><FONT SIZE=+2>${desc}</FONT></td>
                <td><p id=\"${key}\"><FONT SIZE=+2>0</FONT></p></td>
              </tr><tr>
                <td colspan=2 align=\"center\">
                  <button onclick=\"countDown('${key}')\">
                    <img id='${key}Down' src=\"/scoutpics/count_down2.png\">
                  </button>
                </td>
              </tr>
            </table>\n";
}


print "
    <center>    
      <table cellpadding=0 cellspacing=0 $color border=1>
        <tr>
          <td colspan=4>
            <table cellpadding=0 cellspacing=0 $color width=\"100%\" border=1>
              <tr>
                <th align=\"center\"><FONT SIZE=+2>Venue: $event</FONT></th>
                <th align=\"center\"><FONT SIZE=+2>Team : $team</FONT></th>
                <th align=\"center\"><FONT SIZE=+2>Match : $match</FONT></th>
              </tr>
           </table>
          </td>";
print "
      </tr><tr>
        <th colspan=4 align=\"center\"><FONT SIZE=+4>$team Autonomous</FONT></th>
";
print "
      </tr><tr>
          <td colspan=4>
            <table cellspacing=0 cellpadding=0 width=\"100%\" border=1>
              <tr>
                <td align=\"center\" bgcolor=\"#ffffff\">
                  <table cellpadding=0 cellspacing=0 border=0>
                    <tr>
                      <td><FONT SIZE=+2>Did the robot&nbsp;<br>earn Taxi Points?&nbsp;</FONT></td>
                      <td>
                        <button onclick=\"toggle('taxi')\"><p id=\"taxi\"><FONT id='taxiClick' SIZE=+2>&nbsp;No</FONT></p></button>
                      </td>
                    </tr>
                  </table>
                </td>
                <td align=\"center\" bgcolor=\"#ffffff\">
                  <button onclick=\"toggle('start')\" id=\"startButton\" style=\"background-color:red\">
                    <FONT id=\"start\" SIZE=+2>Click Here when<br>Match Starts</FONT>
                  </button></td>
                <td align=\"center\" bgcolor=\"#ffffff\">
                  <table cellpadding=0 cellspacing=0 border=0>
                    <tr>
                      <td><FONT SIZE=+2>Did the $team Human&nbsp;<br>Player Score?&nbsp;</FONT></td>
                      <td>
                        <button onclick=\"toggle('human')\"><p id=\"human\"><FONT id='humanClick' SIZE=+2>&nbsp;No</FONT></p></button>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>";
print "
        </tr><tr>
          <td>\n";
printCounter('alo', "Lower Hub");
print "          </td><td>\n";
printCounter('abo', "Bounced Out");
print "          </td><td>\n";
printCounter('ami', "Missed Hub");
print "          </td><td>\n";
printCounter('ahi', "Upper Hub");
print "          </td>
        </tr>
      </table>
      <p>&nbsp;</p>
      <table cellpadding=0 cellspacing=0 border=1>
        <tr>
          <th colspan=4 align=\"center\"><FONT SIZE=+4>$team TeleOp</FONT></th>
        </tr><tr>
          <td>\n";
printCounter('lo', "Lower Hub");
print "          </td>\n";
print "          <td>\n";
printCounter('bo', "Bounced Out");
print "          </td>\n";
print "          <td>\n";
printCounter('mi', "Missed Hub");
print "          </td>\n";
print "          <td>\n";
printCounter('hi', "Upper Hub");
print "          </td>
        </tr>
      </table>";
print "
      <table cellpadding=0 cellspacing=0 border=1>
        <tr>
          <td>
            <p><FONT SIZE=+2>&nbsp;Where did the<br>Robot Shoot From?&nbsp;</FONT></p>
          </td>
          <td>
            <table cellpadding=0 cellspacing=0 border=1>
              <tr><td align=center>
                  <FONT SIZE=+2>&nbsp;Against&nbsp;<br>&nbsp;Hub:&nbsp;</FONT>
                </td><td>
                  <button onclick=\"toggle('hub')\"><p id=\"hub\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
              </td></tr>
            </table>
          </td>
          <td>
            <table cellpadding=0 cellspacing=0 border=1>
              <tr><td align=center>
                  <FONT SIZE=+2>&nbsp;Spots&nbsp;<BR>&nbsp;in Field:&nbsp;</FONT>
                </td><td>
                  <button onclick=\"toggle('field')\"><p id=\"field\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
              </td></tr>
            </table>
          </td>
          <td>
            <table cellpadding=0 cellspacing=0 border=1>
              <tr>
                <td colspan=4 align=\"center\">
                  <FONT SIZE=+2>Against Launch Pad</FONT>
                </td>
              </tr><tr>
                <td>
                  <p><FONT SIZE=+2>&nbsp;&nbsp;&nbsp;Outer:&nbsp;&nbsp;</FONT></p>
                </td><td>
                  <button onclick=\"toggle('olp')\"><p id=\"olp\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
                </td>
                <td>
                  <p><FONT SIZE=+2>&nbsp;&nbsp;&nbsp;Wall:&nbsp;&nbsp;</FONT></p>
                </td><td>
                  <button onclick=\"toggle('wlp')\"><p id=\"wlp\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>";
print "
      <p>&nbsp;</p>
      <table cellpadding=0 cellspacing=0 $color border=1>
        <tr>
          <th colspan=5 align=\"center\"><FONT SIZE=+4>End Game</FONT></th>
        </tr><tr>
          <td>
            <p><FONT SIZE=+2>&nbsp;Where did the<BR>Robot Hang From?&nbsp;&nbsp;</FONT></p>
          </td>
          <td>
            <table cellpadding=0 cellspacing=0 border=1>
              <tr><td>
                  <p><FONT SIZE=+2>&nbsp;Low:&nbsp;</FONT></p>
                </td><td>
                  <button onclick=\"toggle('lorung')\"><p id=\"lorung\">
                    <FONT id='lorungClick' SIZE=+2>&nbsp;No</FONT>
                  <p></button>
              </td></tr>
            </table>
          </td>
          <td>
            <table cellpadding=0 cellspacing=0 border=1>
              <tr><td>
                  <p><FONT SIZE=+2>&nbsp;Middle:&nbsp;</FONT></p>
                </td><td>
                  <button onclick=\"toggle('midrung')\"><p id=\"midrung\"><FONT id='midrungClick' SIZE=+2>&nbsp;No</FONT></p></button>
              </td></tr>
            </table>
          </td>
          <td>
            <table cellpadding=0 cellspacing=0 border=1>
              <tr><td>
                  <p><FONT SIZE=+2>&nbsp;High:&nbsp;</FONT></p>
                </td><td>
                  <button onclick=\"toggle('hirung')\"><p id=\"hirung\"><FONT id='hirungClick' SIZE=+2>&nbsp;No</FONT></p></button>
              </td></tr>
            </table>
          </td>
          <td>
            <table cellpadding=0 cellspacing=0 border=1>
              <tr><td>
                  <p><FONT SIZE=+2>&nbsp;Traversal:&nbsp;</FONT></p>
                </td><td>
                  <button onclick=\"toggle('trav')\"><p id=\"trav\"><FONT id='travClick' SIZE=+2>&nbsp;No</FONT></p></button>
              </td></tr>
            </table>
          </td>
        </tr>
      </table>";
print "
      <p>&nbsp;</p>
      <table cellpadding=0 cellspacing=0 border=1>
        <tr>
          <th colspan=3 align=\"center\"><FONT SIZE=+4>Post-Match Robot Review</FONT></th>
        </tr><tr>
          <th colspan=3 $color><hr></th>
        </tr><tr>
          <th colspan=3 align=\"center\"><FONT SIZE=+2>Did $team play defense?</FONT></th>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Good Defense</FONT>
          </th><td>
            <button onclick=\"qtoggle('dhi')\"><p id=\"dhi\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2><B>Not many</B> game pieces scored<br> by opponent during defense</FONT>
          </td>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Average Defense</FONT>
          </th><td>
            <button onclick=\"qtoggle('dmid')\"><p id=\"dmid\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>Opponent was still able<BR> to score <B>some</B> game pieces</FONT>
          </td>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Below Average Defense</FONT>
          </th><td>
            <button onclick=\"qtoggle('dlo')\"><p id=\"dlo\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>Opponent was still able to<BR>&nbsp;&nbsp;score game pieces <B>without delay</B>&nbsp;&nbsp;</FONT>
          </td>
        </tr><tr>
          <th colspan=3 $color><hr></th>
        </tr><tr>
          <th colspan=3 align=\"center\"><FONT SIZE=+2>Was $team defended?</FONT></th>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Good Against Defense</FONT>
          </th><td>
            <button onclick=\"qtoggle('ohi')\"><p id=\"ohi\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>Defended but still scored game<BR>&nbsp;pieces with <B>little to no delay</B>&nbsp;</FONT>
          </td>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Average Against Defense</FONT>
          </th><td>
            <button onclick=\"qtoggle('omid')\"><p id=\"omid\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>Defended but still able to score<BR> <B>some</B> game pieces with delay</FONT>
          </td>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Affected by Defense</FONT>
          </th><td>
            <button onclick=\"qtoggle('olo')\"><p id=\"olo\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>Good defense <B>really affected</B><BR> robot performance</FONT>
          </td>
        </tr><tr>
          <th colspan=3 $color><hr></th>
        </tr><tr>
          <th colspan=3 align=\"center\"><FONT SIZE=+2>Did $team receive any fouls?</FONT></th>
        </tr><tr>
          <td colspan=3>
            <table cellpadding=0 cellspacing=0 width=\"100%\" border=1>
              <tr>
                <td>
                  <button onclick=\"qtoggle('flo')\"><p id=\"flo\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
                </td><th>
                  <FONT SIZE=+2>1 foul</FONT>
                </th><th>
                  <FONT SIZE=+2>1 tech foul</FONT>
                </th><td>
                  <button onclick=\"qtoggle('tlo')\"><p id=\"tlo\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
               </td>
              </tr><tr>
                <td>
                  <button onclick=\"qtoggle('fmid')\"><p id=\"fmid\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
                </td><th>
                  <FONT SIZE=+2>2 fouls</FONT>
                </th><th>
                  <FONT SIZE=+2>2 tech fouls</FONT>
                </th><td>
                  <button onclick=\"qtoggle('tmid')\"><p id=\"tmid\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
                </td>
              </tr><tr>
                <td>
                  <button onclick=\"qtoggle('fhi')\"><p id=\"fhi\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
                </td><th>
                  <FONT SIZE=+2>3 or more fouls</FONT>
                </th><th>
                  <FONT SIZE=+2>3 or more tech fouls</FONT>
                </th><td>
                  <button onclick=\"qtoggle('thi')\"><p id=\"thi\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
                </td>
              </tr>
            </table>";
print "
          </td>
        </tr><tr>
          <th colspan=3 $color><hr></th>
        </tr><tr>
          <th colspan=3 align=\"center\"><FONT SIZE=+2>Is this a good robot?</FONT></th>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Very good robot</FONT>
          </th><td>
            <button onclick=\"qtoggle('rhi')\"><p id=\"rhi\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>Could be an alliance captain</FONT>
          </td>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Decent robot</FONT>
          </th><td>
            <button onclick=\"qtoggle('rmid')\"><p id=\"rmid\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>A productive and useful robot</FONT>
          </td>
        </tr><tr>
          <th>
            <FONT SIZE=+2>Struggled to be effective</FONT>
          </th><td>
            <button onclick=\"qtoggle('rlo')\"><p id=\"rlo\"><FONT SIZE=+2>&nbsp;No</FONT></p></button>
          </td><td align=center>
            <FONT SIZE=+2>Maybe good at one thing,<BR> but bad at others</FONT>
          </td>
        </tr><tr>
          <th colspan=3 $color><hr></th>
        </tr><tr>
          <th colspan=3 align=\"center\">
            <p><FONT SIZE=+2>Scouter Name:</FONT><input type=\"text\" name=\"scouter\" form=\"wrapup\"></p>
            <p><FONT SIZE=+2>Comments:</FONT><textarea name=\"comments\" form=\"wrapup\" cols=\"60\" rows=\"5\"></textarea></p>
          </th>
        </tr>
      </table>\n";
print "
      <form action=\"/cgi-bin/react2.cgi\" id=\"wrapup\" enctype=\"text/plain\">
        <input type=\"hidden\" name=\"game\" value=\"$game\">
        <input type=\"hidden\" name=\"team\" value=\"$team\">
        <input type=\"hidden\" name=\"autoLoCount\" id=\"alo\" value=\"0\">
        <input type=\"hidden\" name=\"autoHiCount\" id=\"ahi\" value=\"0\">
        <input type=\"hidden\" name=\"autoBounce\" id=\"abo\" value=\"0\">
        <input type=\"hidden\" name=\"autoMissed\" id=\"ami\" value=\"0\">
        <input type=\"hidden\" name=\"teleLoCount\" id=\"lo\" value=\"0\">
        <input type=\"hidden\" name=\"teleHiCount\" id=\"hi\" value=\"0\">
        <input type=\"hidden\" name=\"teleMissed\" id=\"mi\" value=\"0\">
        <input type=\"hidden\" name=\"teleBounce\" id=\"bo\" value=\"0\">
        <input type=\"hidden\" name=\"taxi\" id=\"taxi\" value=\"0\">
        <input type=\"hidden\" name=\"human\" id=\"human\" value=\"0\">
        <input type=\"hidden\" name=\"shootHub\" id=\"hub\" value=\"0\">
        <input type=\"hidden\" name=\"shootField\" id=\"field\" value=\"0\">
        <input type=\"hidden\" name=\"shootOLP\" id=\"olp\" value=\"0\">
        <input type=\"hidden\" name=\"shootWLP\" id=\"wlp\" value=\"0\">
        <input type=\"hidden\" name=\"rung\" id=\"rung\" value=\"0\">
        <input type=\"hidden\" name=\"defense\" id=\"defense\" value=\"0\">
        <input type=\"hidden\" name=\"defended\" id=\"defended\" value=\"0\">
        <input type=\"hidden\" name=\"fouls\" id=\"fouls\" value=\"0\">
        <input type=\"hidden\" name=\"techfouls\" id=\"techfouls\" value=\"0\">
        <input type=\"hidden\" name=\"robot\" id=\"robot\" value=\"0\">
        <input type=\"hidden\" name=\"timing\" id=\"timing\" value=\"$game,$team\">
        <input type=\"image\" src=\"/scoutpics/save_button.png\" width=\"100\" height=\"50\">
      </form>
    </center>
</body></html>\n";
