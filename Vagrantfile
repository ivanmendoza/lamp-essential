Vagrant.configure('2') do |config|
  config.vm.hostname = 'Labs'
  config.vm.box = "debian/jessie64"
  
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.vm.synced_folder ".", "/var/www", create:true, owner:"www-data", group:"www-data", mount_options: ["dmode=775,fmode=775"]
  
  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.customize ["modifyvm", :id, "--memory",               "512"]
  end
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host: 3380
  
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  
  config.trigger.before :destroy do
    info "Backing up database..."
    run_remote  "bash /vagrant/cleanup.sh"
  end

  config.vm.provision "shell", path:"install.sh", name: "INSTALL"
  
end