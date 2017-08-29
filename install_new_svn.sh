#!/bin/bash 
set -e

NAME=$1
SVNURL=$2

PUBLICFOLDER='public_html'
WEBROOT='/var/www'
NOTEROOT='/home/arafath/Documents'

DOMAINNAME=$NAME'.local'
PROJECTDIR=$WEBROOT'/'$DOMAINNAME
PROJECTROOT=$PROJECTDIR'/public_html'
PROJECTNOTE=$NOTEROOT'/'$NAME
ERRORLOG=$WEBROOT'/'$DOMAINNAME'/error.log'
ACCESS=$WEBROOT'/'$DOMAINNAME'/access.log'

echo "Setting up a development environment for "$DOMAINNAME"..."
echo "Creating project note directory..."
mkdir -p $PROJECTNOTE

echo "Creating note predev sql file..."
cp $NOTEROOT'/myscripts/predev.sql' $PROJECTNOTE/$NAME'_predev.sql'
sed -i -- 's/databasename/'$NAME'/g' $PROJECTNOTE/$NAME'_predev.sql'

echo "Creating project root directory..."
sudo mkdir -p $PROJECTROOT

echo "Creating project log files..."
sudo touch $ERRORLOG
sudo touch $ACCESS

cd $PROJECTROOT 
echo "Getting SVN checkout..."
sudo svn co $SVNURL ./

echo "Giving permission..."
sudo chmod -R 777 $PROJECTDIR

cd $PROJECTROOT 
sudo svn patch $NOTEROOT'/kint.diff'

echo "Adding to hosts file..."
sudo sed -i "/localhost.localdomain/ s/$/ $DOMAINNAME/" /etc/hosts

echo "Adding to virtual host file..."
VIRTUALHOSTPATH='/etc/httpd/conf.d/'$NAME'.local.conf'
sudo cp /etc/httpd/conf.d/sandals.local.conf $VIRTUALHOSTPATH
sudo sed -i -- 's/sandals/'$NAME'/g' $VIRTUALHOSTPATH

echo "Restarting Apache..."
sudo apachectl restart

echo "Opening preoject in PhpStrom..."
cd $PROJECTDIR
pstorm 'public_html/'


# #echo "Updating settings factories htaccess for development..."
# #sed -i '/no_script_name/c\    no_script_name:\         false' symfony/apps/orangehrm/config/settings.yml 
# #sed -i '/session_cookie_secure/c\      session_cookie_secure:\ false' symfony/apps/orangehrm/config/factories.yml
# #sed -i '/RewriteBase/c\    #\ RewriteBase' symfony/web/.htaccess