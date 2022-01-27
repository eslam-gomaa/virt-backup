# -*- mode: ruby -*-
# vi: set ft=ruby :

## Variables ##
memory      = 2048

##################  ##################  ##################

## Create the VMs ##

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  # config.ssh.username = "vagrant"
  # config.ssh.password = "vagrant"

  config.vm.define "ubuntu_18_04" do |ubuntu_18_04|
    ubuntu_18_04.vm.hostname = "ubuntu-18-04" 
    ubuntu_18_04.vm.box = "generic/ubuntu1804"
    # ubuntu_18_04.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    ubuntu_18_04.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    ubuntu_18_04.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_ubuntu.sh"
    ubuntu_18_04.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_ubuntu.sh"
    ubuntu_18_04.vm.provision "Install Ruby", type: "shell", path: "scripts/install_virt-backup.sh"
    ubuntu_18_04.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    ubuntu_18_04.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "ubuntu_18_04"
      libvirt.nested = true
    end
  end

  config.vm.define "ubuntu_16_04" do |ubuntu_16_04|
    ubuntu_16_04.vm.hostname = "ubuntu-16-04" 
    ubuntu_16_04.vm.box = "generic/ubuntu1804"
    # ubuntu_16_04.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    ubuntu_16_04.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    ubuntu_16_04.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_ubuntu.sh"
    ubuntu_16_04.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_ubuntu.sh"
    ubuntu_16_04.vm.provision "Install Ruby", type: "shell", path: "scripts/install_virt-backup.sh"
    ubuntu_16_04.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    ubuntu_16_04.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "ubuntu_16_04"
      libvirt.nested = true
    end
  end

  config.vm.define "ubuntu_20_04" do |ubuntu_20_04|
    ubuntu_20_04.vm.hostname = "ubuntu-20-04" 
    ubuntu_20_04.vm.box = "generic/ubuntu1804"
    # ubuntu_20_04.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    ubuntu_20_04.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    ubuntu_20_04.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_ubuntu.sh"
    ubuntu_20_04.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_ubuntu.sh"
    ubuntu_20_04.vm.provision "Install Ruby", type: "shell", path: "scripts/install_virt-backup.sh"
    ubuntu_20_04.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    ubuntu_20_04.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "ubuntu_20_04"
      libvirt.nested = true
    end
  end



end
