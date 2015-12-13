#!/bin/bash

domain_name="labs.con"
password='labs1234'

mysqldump -u root -p$password $domain_name > /var/www/$domain_name-db-backup.sql

exit 0