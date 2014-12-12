#!/bin/sh

# This is based on the dxr vagrant_provision.sh script.

set -e
set -x

apt-get update

# configure locales
apt-get install -y language-pack-en

# basics
apt-get install -y curl git

# node
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs

# python
apt-get install -y libapache2-mod-wsgi python-pip
pip install virtualenv virtualenvwrapper python-hglib nose

# get dxr
git clone --recursive https://github.com/mozilla/dxr /opt/dxr
cd /opt/dxr

# build libtrilite
apt-get install -y libsqlite3-dev mercurial pkg-config
make trilite
ln -sf /opt/dxr/trilite/libtrilite.so /usr/local/lib/libtrilite.so
ldconfig

# build html templates
make templates

# install dxr
./peep.py install -r requirements.txt
python setup.py install

# get apache
apt-get install -y apache2-dev apache2

a2enmod rewrite
a2enmod proxy
a2enmod wsgi

# indexed code goes in /var/www/dxr
mkdir -p /var/www/dxr

# create apache config for dxr
cat > /etc/apache2/sites-available/dxr.conf <<THEEND
ServerName code.sfolab.ibm.com

<VirtualHost *:80>
  SetEnv DXR_FOLDER /var/www/dxr

  Alias /static/ /opt/dxr/dxr/static/
  <Directory /opt/dxr/dxr/static>
    Require all granted
  </Directory>

  WSGIScriptAlias / /usr/local/lib/python2.7/dist-packages/dxr-0.1-py2.7.egg/dxr/wsgi.py
  <Files wsgi.py>
    Require all granted
  </Files>
</VirtualHost>
THEEND

chmod 0644 /etc/apache2/sites-available/dxr.conf

a2dissite 000-default
a2ensite dxr

service apache2 restart
