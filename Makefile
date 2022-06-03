local_setup:
	vagrant ssh -c "cd /var/www/html/drupal && composer install"
	vagrant ssh -c "cd /var/www/html/drupal && git submodule init"
	vagrant ssh -c "cd /var/www/html/drupal && git submodule update"
	$(MAKE) update-settings-php
	vagrant ssh -c "cd /var/www/html/drupal && git clone https://github.com/mjordan/islandora_bagger_integration.git web/sites/all/modules/islandora_bagger_integration"
	vagrant ssh -c "cd /var/www/html/drupal && drush pm:en -y islandora_bagger_integration"
	vagrant ssh -c "cd /var/www/html/drupal && drush cset -y asu_default_fields.settings disable_handle_generation 1"
	vagrant ssh -c "cd /var/www/html/drupal && drush updb -y"

update-settings-php:
	vagrant ssh -c "echo '$$'\"databases['default']['default'] = ['database' => 'drupal8', 'username' => 'root', 'password' => 'islandora', 'host' => 'localhost', 'port' => '3306', 'driver' => 'mysql', 'prefix' => '', 'collation' => 'utf8mb4_general_ci'];\" >> /var/www/html/drupal/web/sites/default/settings.php"
	vagrant ssh -c "echo '$$'\"settings['hash_salt'] = 'bc32ffdbba9cb51a7886fd3f5d8e2ff6';\" >> /var/www/html/drupal/web/sites/default/settings.php"

xhprof:
	vagrant ssh -c "sudo apt-get update && sudo apt-get install php-pear --fix-missing"
	-vagrant ssh -c "sudo pecl install xhprof"
	vagrant ssh -c "sudo chmod 777 /etc/php/7.4/cli/php.ini && echo \"extension=xhprof.so\" >> /etc/php/7.4/cli/php.ini"
	vagrant ssh -c "sudo service apache2 restart"
	vagrant ssh -c "php -i | grep xhprof"
	vagrant ssh -c "cd /var/www/html/drupal && composer require drupal/xhprof"