# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "archlinux/archlinux"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.customize ["modifyvm", :id, "--audio", "none"]
  end

  config.vm.define "lb-0" do |c|
    c.vm.hostname = "lb-0"
    c.vm.network "private_network", ip: "192.168.199.40"

    c.vm.provision "shell", path: "scripts/base-setup.sh"
    c.vm.provision "shell", path: "scripts/lb-setup.sh"
  end

  (0..2).each do |n|
    config.vm.define "server-#{n}" do |c|
      c.vm.hostname = "serverNode-#{n}"
      c.vm.network "private_network", ip: "192.168.199.1#{n}"

      c.vm.provision "shell", path: "scripts/base-setup.sh"
      c.vm.provision "shell", path: "scripts/server-setup.sh"
    end
  end

  (0..2).each do |n|
    config.vm.define "agent-#{n}" do |c|
      c.vm.hostname = "agentNode-#{n}"
      c.vm.network "private_network", ip: "192.168.199.2#{n}"

      c.vm.provision "shell", path: "scripts/base-setup.sh"
      c.vm.provision "shell", path: "scripts/agent-setup.sh"
    end
  end
end
