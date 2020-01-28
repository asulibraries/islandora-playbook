# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 2.0.1"

$cpus   = ENV.fetch("ISLANDORA_VAGRANT_CPUS", "2")
$memory = ENV.fetch("ISLANDORA_VAGRANT_MEMORY", "4096")
$hostname = ENV.fetch("ISLANDORA_VAGRANT_HOSTNAME", "islandora8")
$virtualBoxDescription = ENV.fetch("ISLANDORA_VAGRANT_VIRTUALBOXDESCRIPTION", "Islandora 8")

# Available boxes are 'ubuntu/xenial64' and 'centos/7'
$vagrantBox = ENV.fetch("ISLANDORA_DISTRO", "ubuntu/bionic64")

# On Ubuntu, user is ubuntu, on all others, user is vagrant
$vagrantUser = if $vagrantBox == "ubuntu/bionic64" then "ubuntu" else "vagrant" end

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
  end

  config.vm.provision :ansible do |ansible|
    # ansible-playbook playbook.yml -i inventory/vagrant -l all -e ansible_ssh_user=$vagrantUser -e islandora_distro=ubuntu/xenial64
    ansible.compatibility_mode = "auto"
    ansible.playbook = "playbook.yml"
    ansible.galaxy_role_file = "requirements.yml"
    ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file} --roles-path=roles/external"
    ansible.limit = "all"
    ansible.inventory_path = "inventory/vagrant"
    ansible.host_vars = {
      "all" => { "ansible_ssh_user" => $vagrantUser }
    }
    ansible.extra_vars = { "islandora_distro" => $vagrantBox }
  end

end
