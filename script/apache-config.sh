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

TMPCONF=`mktemp /tmp/webscout-XXXXXXXXXX.conf`

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
echo '    AuthUserFile /etc/apache2/webscout.auth' >> $TMPCONF
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

RELOAD_NEEDED=0
sudo touch /etc/apache2/sites-available/webscout.conf 
sudo chmod a+r /etc/apache2/sites-available/webscout.conf 
if ! cmp $TMPCONF /etc/apache2/sites-available/webscout.conf >/dev/null 2>&1
then
    sudo cp -v $TMPCONF /etc/apache2/sites-available/webscout.conf
    RELOAD_NEEDED=1
fi
rm -f $TMPCONF

if [ ! -e /etc/apache2/sites-enabled/webscout.conf ]
then
    sudo a2ensite webscout
    RELOAD_NEEDED=1
fi

if [ -e /etc/apache2/sites-enabled/000-default.conf ]
then
    sudo a2dissite 000-default
    RELOAD_NEEDED=1
fi

for mod in auth_digest.load headers.load rewrite.load cgid.load alias.load
do
    if [ ! -e /etc/apache2/mods-enabled/$mod ]
    then
        sudo a2enmod $mod
        RELOAD_NEEDED=1
    fi
done

for USER in $GUEST_USER $SCOUTING_USER $ADMIN_USER
do
    CREATE=""
    if [ ! -e /etc/apache2/webscout.auth ]
    then
        CREATE="-c"
    fi
    if ! grep -Eq "^$USER:" /etc/apache2/webscout.auth
    then
        sudo  htdigest $CREATE /etc/apache2/webscout.auth webscout $USER
        RELOAD_NEEDED=1
    fi
done

if [ "$RELOAD_NEEDED" == "1" ]
then
    sudo service apache2 reload
    echo "Webserver configuration reloaded"
fi
