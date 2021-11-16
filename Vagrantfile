# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 2.0.1"

$cpus   = ENV.fetch("ISLANDORA_VAGRANT_CPUS", "2")
$memory = ENV.fetch("ISLANDORA_VAGRANT_MEMORY", "4096")
$hostname = ENV.fetch("ISLANDORA_VAGRANT_HOSTNAME", "islandora8")
$virtualBoxDescription = ENV.fetch("ISLANDORA_VAGRANT_VIRTUALBOXDESCRIPTION", "Islandora 8")

# Available boxes are 'islandora/8', ubuntu/bionic64' and 'centos/7'
# Use 'ubuntu/bionic64' or 'centos/7' to build a dev environment from scratch.
# Use 'islandora/8' if you just want to download a ready to run VM.
$vagrantBox = ENV.fetch("ISLANDORA_DISTRO", "elizoller/asurepo")

# vagrant is the main user
$vagrantUser = "vagrant"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.name = "Islandora CLAW Ansible ASU"
  end

  config.vm.hostname = $hostname

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = $vagrantBox

  # Configure home directory
  home_dir = "/home/" + $vagrantUser

  # Configure sync directory
  config.vm.synced_folder ".", home_dir + "/islandora"
  # config.vm.synced_folder "./claw-app/web/sites/default/files", home_dir + "/islandora/claw-app/web/sites/default/files", owner: "www-data", group: "www-data", mode: 0777, disabled: false
  # config.vm.synced_folder "./islandora", "/var/www/html/drupal/web/modules/contrib/islandora", disabled: true
  config.vm.synced_folder "./islandora-repo/web/themes/custom/asulib_barrio", "/var/www/html/drupal/web/themes/custom/asulib_barrio"
  config.vm.synced_folder "./islandora-repo/web/modules/custom", "/var/www/html/drupal/web/modules/custom", owner: "vagrant", group: "vagrant", mode: 0755
  config.vm.boot_timeout = 99999999

  config.vm.network :forwarded_port, guest: 8000, host: 8000 # Apache
  config.vm.network :forwarded_port, guest: 8080, host: 8080 # Tomcat
  config.vm.network :forwarded_port, guest: 3306, host: 3306 # MySQL
  config.vm.network :forwarded_port, guest: 5432, host: 15432 # PostgreSQL
  config.vm.network :forwarded_port, guest: 8983, host: 18983 # Solr
  config.vm.network :forwarded_port, guest: 8161, host: 18161 # Activemq
  config.vm.network :forwarded_port, guest: 8081, host: 18081 # API-X

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", $memory]
    vb.customize ["modifyvm", :id, "--cpus", $cpus]
    vb.customize ["modifyvm", :id, "--description", $virtualBoxDescription]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]
  end

  if $vagrantBox != "islandora/8" and $vagrantBox != "elizoller/asurepo" then
    config.vm.provision :ansible do |ansible|
      ansible.compatibility_mode = "auto"
      ansible.playbook = "playbook.yml"
      ansible.galaxy_role_file = "requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file}"
      ansible.limit = "all"
      ansible.inventory_path = "inventory/vagrant"
      ansible.host_vars = {
        "all" => { "ansible_ssh_user" => $vagrantUser }
      }
      ansible.extra_vars = { "islandora_distro" => $vagrantBox }
    end
  end

end
