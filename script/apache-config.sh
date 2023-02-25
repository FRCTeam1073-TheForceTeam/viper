#!/bin/bash

set -e

if [ -e local.conf ]
then
    source ./local.conf
else
    cp ./script/example.conf ./local.conf
    echo "Created local.conf file"
    echo "Please edit it and re-run this script"
    exit 1
fi

source ./local.conf

SERVER_NAME=${SERVER_NAMES%% *}
SERVER_ALIASES=${SERVER_NAMES#* }
DOCUMENT_ROOT=`pwd`/www
DOCUMENT_ROOT=${DOCUMENT_ROOT/#\/c\//C:\/}

TMPCONF=`mktemp /tmp/webscout-XXXXXXXXXX.conf`

APACHE_DIR=""
if [ -e /etc/apache2 ]
then
    APACHE_DIR=/etc/apache2
elif [ -e /c/xampp/apache/conf ]
then
    APACHE_DIR=/c/xampp/apache/conf
fi

if [ "z$APACHE_DIR" == "z" ]
then
    echo "Apache conf directory not found."
    exit 1
fi

APACHE_DIR_CONF=$APACHE_DIR
APACHE_DIR_CONF=${APACHE_DIR_CONF/#\/c\//C:\/}

echo '<VirtualHost *:80>' > $TMPCONF
if [ "z$SERVER_NAME" != "z" ]
then
    echo "  Servername $SERVER_NAME" >> $TMPCONF
fi
for SERVER_ALIAS in $SERVER_ALIASES
do
    echo "  ServerAlias $SERVER_ALIAS" >> $TMPCONF
done
if [ "z$HTTPS_INCLUDE" != "z" ]
then
    echo "  Redirect / https://$SERVER_NAME/" >> $TMPCONF
    echo '</VirtualHost>' >> $TMPCONF
    echo '<VirtualHost *:443>' >> $TMPCONF
    if [ "z$SERVER_NAME" != "z" ]
    then
        echo "  Servername $SERVER_NAME" >> $TMPCONF
    fi
    for SERVER_ALIAS in $SERVER_ALIASES
    do
        echo "  ServerAlias $SERVER_ALIAS" >> $TMPCONF
    done
    echo "  Include $HTTPS_INCLUDE" >> $TMPCONF
fi
echo "  DocumentRoot $DOCUMENT_ROOT" >> $TMPCONF
echo "  <Directory $DOCUMENT_ROOT/>" >> $TMPCONF
echo '    AllowOverride All' >> $TMPCONF
echo '    AuthName "webscout"' >> $TMPCONF
echo '    AuthType Digest' >> $TMPCONF
echo '    AuthDigestDomain /' >> $TMPCONF
echo '    AuthDigestProvider file' >> $TMPCONF
echo "    AuthUserFile $APACHE_DIR_CONF/webscout.auth" >> $TMPCONF
echo '    <RequireAny>' >> $TMPCONF
if [ "z$GUEST_USER" == "z" ]
then
    echo '      Require all granted' >> $TMPCONF
else
    echo '      Require valid-user' >> $TMPCONF
    if [ "$ALLOW_LOCAL" == "1" ]
    then
        echo '      Require local' >> $TMPCONF
    fi
    if [ "z$ALLOW_IPS" != "z" ]
    then
        echo "      Require ip $ALLOW_IPS" >> $TMPCONF
    fi
fi
echo '    </RequireAny>' >> $TMPCONF
echo '  </Directory>' >> $TMPCONF
if [ "z$SCOUTING_USER" != "z" ]
then
    echo "  <Directory $DOCUMENT_ROOT/scout/>" >> $TMPCONF
    echo '    <RequireAny>' >> $TMPCONF
    echo "      Require user $SCOUTING_USER" >> $TMPCONF
    if [ "z$ADMIN_USER" != "z" ]
    then
        echo "      Require user $ADMIN_USER" >> $TMPCONF
    fi
    if [ "$ALLOW_LOCAL" == "1" ]
    then
        echo '      Require local' >> $TMPCONF
    fi
    if [ "z$ALLOW_IPS" != "z" ]
    then
        echo "      Require ip $ALLOW_IPS" >> $TMPCONF
    fi
    echo '    </RequireAny>' >> $TMPCONF
    echo '  </Directory>' >> $TMPCONF
fi
if [ "z$ADMIN_USER" != "z" ]
then
    echo "  <Directory $DOCUMENT_ROOT/admin/>" >> $TMPCONF
    echo '    <RequireAny>' >> $TMPCONF
    echo "      Require user $ADMIN_USER" >> $TMPCONF
    if [ "$ALLOW_LOCAL" == "1" ]
    then
        echo '      Require local' >> $TMPCONF
    fi
    if [ "z$ALLOW_IPS" != "z" ]
    then
        echo "      Require ip $ALLOW_IPS" >> $TMPCONF
    fi
    echo '    </RequireAny>' >> $TMPCONF
    echo '  </Directory>' >> $TMPCONF
fi
echo '  </VirtualHost>' >> $TMPCONF

SUDO=""
if which sudo &> /dev/null
then
  SUDO=sudo
fi

$SUDO mkdir -p $APACHE_DIR/sites-available/
$SUDO mkdir -p $APACHE_DIR/sites-enabled/

RELOAD_NEEDED=0
$SUDO touch $APACHE_DIR/sites-available/webscout.conf
$SUDO chmod a+r $APACHE_DIR/sites-available/webscout.conf
if ! cmp $TMPCONF $APACHE_DIR/sites-available/webscout.conf >/dev/null 2>&1
then
    $SUDO cp -v $TMPCONF $APACHE_DIR/sites-available/webscout.conf
    RELOAD_NEEDED=1
fi
rm -f $TMPCONF

if [ ! -e $APACHE_DIR/sites-enabled/webscout.conf ]
then
    if which a2ensite &> /dev/null
    then
        $SUDO a2ensite webscout
    else
        $SUDO ln -s $APACHE_DIR/sites-available/webscout.conf $APACHE_DIR/sites-enabled/webscout.conf
    fi
    RELOAD_NEEDED=1
fi

if [ -e $APACHE_DIR/sites-enabled/000-default.conf ]
then
    $SUDO a2dissite 000-default
    RELOAD_NEEDED=1
fi

if which a2enmod &> /dev/null
then
    for mod in auth_digest.load headers.load rewrite.load cgid.load alias.load
    do
        if [ ! -e $APACHE_DIR/mods-enabled/$mod ]
        then
            $SUDO a2enmod $mod
            RELOAD_NEEDED=1
        fi
    done
else
    sed -i -E 's/^\#(.*((mod_auth_digest\.so)|(mod_headers\.so)|(mod_rewrite\.so)|(mod_cgi\.so)|(mod_alias\.so)))$/\1/g' $APACHE_DIR/httpd.conf
fi

if [ -e /c/xampp/apache/conf/httpd.conf ]
then
    perl -i -pe 'BEGIN { $/=undef } s/\<Directory \"C\:\/xampp\/htdocs\"\>.*?\<\/Directory\>/Include conf\/sites-available\/\*\.conf/gs' /c/xampp/apache/conf/httpd.conf
    RELOAD_NEEDED=1
fi

HTDIGEST=htdigest
if [ -e /c/xampp/apache/bin/htdigest.exe ]
then
    HTDIGEST=/c/xampp/apache/bin/htdigest.exe
fi

for USER in $GUEST_USER $SCOUTING_USER $ADMIN_USER
do
    CREATE=""
    if [ ! -e $APACHE_DIR/webscout.auth ]
    then
        CREATE="-c"
    fi
    if ! grep -Eq "^$USER:" $APACHE_DIR/webscout.auth
    then
        $SUDO $HTDIGEST $CREATE $APACHE_DIR/webscout.auth webscout $USER
        RELOAD_NEEDED=1
    fi
done

if [ "$RELOAD_NEEDED" == "1" ]
then
    if which service &> /dev/null
    then
        $SUDO service apache2 reload
        echo "Webserver configuration reloaded"
    elif [ -e /c/xampp/xampp_stop.exe ]
    then
        /c/xampp/xampp_stop.exe || true
        /c/xampp/xampp_start.exe
        echo "Webserver configuration reloaded"
    else
        echo "Could not find a command to restart web server"
        exit 1
    fi
fi

if [ -e /c/xampp/perl/bin/perl.exe ]
then
    find www/ -name *.cgi -exec sed -iE 's|^#!/usr/bin/perl|#!C:/xampp/perl/bin/perl.exe|g' {} \;
else
    find www/ -name *.cgi -exec sed -iE 's|^#!C:/xampp/perl/bin/perl.exe|#!/usr/bin/perl|g' {} \;
fi
