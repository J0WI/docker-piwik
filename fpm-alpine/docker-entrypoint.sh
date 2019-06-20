#!/bin/sh
set -e

if expr "$1" : "apache2" 1>/dev/null || [ "$1" = "php-fpm" ]; then
#	if [ "$(id -u)" = '0' ]; then
#		case "$1" in
#			apache2*)
#				user="${APACHE_RUN_USER:-www-data}"
#				group="${APACHE_RUN_GROUP:-www-data}"
#
#				# strip off any '#' symbol ('#1000' is valid syntax for Apache)
#				pound='#'
#				user="${user#$pound}"
#				group="${group#$pound}"
#				;;
#			*) # php-fpm
#				user='www-data'
#				group='www-data'
#				;;
#		esac
#	else
#		user="$(id -u)"
#		group="$(id -g)"
#	fi

	if [ ! -e piwik.php ]; then
		#tar cf - --one-file-system -C /usr/src/piwik --owner "$user" --group "$group" . | tar xf -
		tar cf - --one-file-system -C /usr/src/piwik . | tar xf -
		chown -R www-data:www-data .
	fi

	if [ ! -e config/config.ini.php ]; then
		if [ -n "${MYSQL_DATABASE+x}" ] && [ -n "${MYSQL_USER+x}" ] && [ -n "${MYSQL_PASSWORD+x}" ] && [ -n "${MYSQL_HOST+x}" ]; then
			php /var/www/html/console config:set --section="database" --key="host" --value="$MYSQL_HOST"
			php /var/www/html/console config:set --section="database" --key="username" --value="$MYSQL_USER"
			php /var/www/html/console config:set --section="database" --key="password" --value="$MYSQL_PASSWORD"
			php /var/www/html/console config:set --section="database" --key="dbname" --value="$MYSQL_DATABASE"
			php /var/www/html/console config:set --section="general" --key="installation_in_progress" --value="1"
		fi
	fi
fi

exec "$@"
