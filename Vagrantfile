Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.provision "shell", path: "install.sh"
end
