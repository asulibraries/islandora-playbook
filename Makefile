local_setup:
	vagrant plugin install vagrant-vbguest
	touch .asurepo_vault_pass
	@echo -n "Please ensure the file .asurepo_vault_pass has the password in it and press 'y': [y/N] " && read ans && [ $${ans:-N} = y ]
	vagrant ssh -c "cd /var/www/html/drupal && composer install"
	vagrant ssh -c "cd /var/www/html/drupal && git submodule init"
	vagrant ssh -c "cd /var/www/html/drupal && git submodule update"
	echo "increasing php memory limit so we can do the config install later"
	vagrant ssh -c "sudo chmod 777 /etc/php/7.4/cli/php.ini && sudo chmod 777 /etc/php/7.4/cli && sed -i 's/memory_limit = 256M/memory_limit = 512M/' /etc/php/7.4/cli/php.ini"
	vagrant ssh -c "sudo service apache2 restart"
	echo "setting up a fake 'hdl' module because we can't find the real one"
	-vagrant ssh -c "cd /var/www/html/drupal && mkdir web/modules/custom/hdl && printf 'name: Nothing to see here\ncore: 8.x\ntype: module' > web/modules/custom/hdl/hdl.info.yml && printf '<?php' > web/modules/custom/hdl/hdl.module"
	echo "fix some other missing modules"
	vagrant ssh -c "cd /var/www/html/drupal && composer require 'drupal/contextual_range_filter:^1.0'"
	-vagrant ssh -c "cd /var/www/html/drupal && git clone https://github.com/mjordan/islandora_riprap.git web/modules/custom/islandora_riprap"
	-vagrant ssh -c "cd /var/www/html/drupal && git clone https://github.com/mjordan/persistent_identifiers.git web/modules/custom/persistent_identifiers"
	-vagrant ssh -c "cd /var/www/html/drupal && git clone https://github.com/mjordan/islandora_bagger_integration.git web/modules/custom/islandora_bagger_integration"
	vagrant ssh -c "cd /var/www/html/drupal && drush pm:en -y islandora_riprap islandora_bagger_integration layout_builder contextual_range_filter"
	vagrant ssh -c "cd /var/www/html/drupal && drupal config:import --directory /var/www/html/drupal/config/sync"
	vagrant ssh -c "cd /var/www/html/drupal && drush config:import --partial --source /var/www/html/drupal/config/dev -y"
	vagrant ssh -c "cd /var/www/html/drupal && drush pm:un -y asu_deposit_methods && drush pm:en -y asu_deposit_methods"
	$(MAKE) update-settings-php
	vagrant ssh -c "cd /var/www/html/drupal && drush cset -y asu_default_fields.settings disable_handle_generation 1"
	vagrant ssh -c "cd /var/www/html/drupal && drush cset -y islandora.settings fedora_url http://127.0.0.1:8080/fcrepo/rest"
	vagrant ssh -c "cd /var/www/html/drupal && drush updb -y"
	# fedora_url: 'http://127.0.0.1:8080/fcrepo/rest'

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
