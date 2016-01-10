#!/bin/bash

domain_name="labs.con"
PASSWORD='root'
db_name="labs_db"

### SERVER CONFIG AND PACKAGE INSTALLATION ###

# config mysql password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server-5.5/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server-5.5/root_password_again password $PASSWORD"


# update / upgrade
sudo aptitude update
sudo aptitude -y upgrade

# install apache 2.5 and php
sudo aptitude install -q -y -f mysql-server mysql-client apache2 php5-fpm libapache2-mod-php5

echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=$PASSWORD
echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=$PASSWORD
sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" "/etc/mysql/my.cnf"

# Install commonly used php packages
sudo aptitude install -q -y -f php5-mysql php5-curl php5-gd php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache php5-xdebug

# install git
sudo aptitude -y install git

# install Composer
if [ ! -f "/usr/local/bin/composer" ]; then 
sudo curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
fi

# Install WP Command Line
if [ ! -f "/usr/local/bin/wp" ]; then 
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv -f wp-cli.phar /usr/local/bin/wp
fi

# some apache configs
sudo a2enmod rewrite

sudo usermod -a -G www-data vagrant
sudo chmod -R 775 /var/www

### SITE CONFIGURATION ###

# create site folder
sudo mkdir "/var/www/${domain_name}"
sudo mkdir "/var/www/${domain_name}/public_html"
sudo mkdir "/var/www/${domain_name}/log"
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
				<Limit GET POST OPTIONS>
				Require all granted
				</Limit>
				<LimitExcept GET POST OPTIONS>
				Require all denied
				</LimitExcept>
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
