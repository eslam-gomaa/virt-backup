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
    ubuntu_18_04.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
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
    ubuntu_16_04.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
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
    ubuntu_20_04.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
    ubuntu_20_04.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    ubuntu_20_04.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "ubuntu_20_04"
      libvirt.nested = true
    end
  end

  config.vm.define "centos_7" do |centos_7|
    centos_7.vm.hostname = "centos-7" 
    centos_7.vm.box = "generic/centos7"
    # centos_7.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    centos_7.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    centos_7.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_centos7.sh"
    centos_7.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_centos7.sh"
    centos_7.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
    centos_7.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    centos_7.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "centos_7"
      libvirt.nested = true
    end
  end

  config.vm.define "centos_8" do |centos_8|
    centos_8.vm.hostname = "centos-8" 
    centos_8.vm.box = "generic/centos8"
    # centos_8.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    centos_8.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    centos_8.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_centos8.sh"
    centos_8.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_centos8.sh"
    centos_8.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
    centos_8.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    centos_8.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "centos_8"
      libvirt.nested = true
    end
  end

  config.vm.define "fedora34" do |fedora34|
    fedora34.vm.hostname = "fedora34" 
    fedora34.vm.box = "generic/fedora34"
    # fedora34.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    fedora34.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    fedora34.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_fedora34.sh"
    fedora34.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_centos7.sh"
    fedora34.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
    fedora34.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    fedora34.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "fedora34"
      libvirt.nested = true
    end
  end

  config.vm.define "debian10" do |debian10|
    debian10.vm.hostname = "debian-10" 
    debian10.vm.box = "generic/debian10"
    # debian10.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    debian10.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    debian10.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_ubuntu.sh"
    debian10.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_ubuntu.sh"
    debian10.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
    debian10.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    debian10.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "debian10"
      libvirt.nested = true
    end
  end

  config.vm.define "debian11" do |debian11|
    debian11.vm.hostname = "debian-11" 
    debian11.vm.box = "generic/debian11"
    # debian11.vm.network :public_network, :dev => "virbr0", :mode => "bridge", :type => "bridge", :ip => "192.168.122.40"
    debian11.vm.provision "enable nested virtualization", type: "shell", path: "scripts/enable_nested_virtualization.sh"
    debian11.vm.provision "Install KVM", type: "shell", path: "scripts/install_kvm_ubuntu.sh"
    debian11.vm.provision "Install Ruby", type: "shell", path: "scripts/install_ruby_ubuntu.sh"
    debian11.vm.provision "Install virt-backup", type: "shell", path: "scripts/install_virt-backup.sh"
    debian11.vm.provision "Run Tests", type: "shell", path: "scripts/test.sh"
    debian11.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = "#{memory}"
      libvirt.title  = "debian11"
      libvirt.nested = true
    end
  end

end
