#!/bin/bash

PASSWORD='root'
domain_name=$1
db_name=$2

### SITE CONFIGURATION ###

# create site folder
sudo mkdir -p "/var/www/${domain_name}"
sudo mkdir -p "/var/www/${domain_name}/public_html"
sudo mkdir -p "/var/www/${domain_name}/log"
sudo chmod -R 755 "/var/www/$domain_name"
sudo chown -R www-data:www-data "/var/www/$domain_name"

# setup hosts file
vhost_file="/etc/apache2/sites-available/$domain_name.conf"
sudo cat << EOF > $vhost_file
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName $domain_name
        ServerAlias www.$domain_name
        LogLevel debug

        ErrorLog /var/www/$domain_name/log/error.log
        CustomLog /var/www/$domain_name/log/access.log combined
        
        DocumentRoot /var/www/$domain_name/public_html
        <Directory /var/www/$domain_name/public_html>
				AllowOverride All
                Options FollowSymLinks MultiViews
        </Directory>
</VirtualHost>
EOF

# database creation
RESULT=`mysqlshow --user=root --password=$PASSWORD $db_name| grep -v Wildcard | grep -o $db_name`
if [ "$RESULT" != "$db_name" ]; then
	echo "Creating database..."
	echo "create database $db_name;" | mysql -uroot -p$PASSWORD
	
	RESULT=`mysqlshow --user=root --password=$PASSWORD $db_name| grep -v Wildcard | grep -o $db_name`
	if [ "$RESULT" == "$db_name" ]; then
		echo "Database created succesfully!"
	fi
fi

# index file created
cd /var/www/$domain_name/public_html/
sudo echo "<h1>Hello world!</h1>" > index.html

sudo a2ensite $domain_name

# restart apache
sudo service apache2 restart
	
exit 0
