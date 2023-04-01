# -*- mode: ruby -*-
# vi: set ft=ruby :

VAULT_TRANSIT = 1
VAULT_SERVER_NUMER = 2
Vagrant.configure(2) do |config|
  # Increase memory for Virtualbox
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
  (0..VAULT_TRANSIT-1).each do |i|
    config.vm.define "vault_transit-#{i}" do |vault|
      vault.vm.box = "vault"
      vault.vm.hostname = "vault-transit-#{i}"
      vault.vm.provision "shell" do |shell|
        shell.path = "vault_transit.sh"
        shell.args = [i, "10.0.0.#{i + 2}", VAULT_TRANSIT]
        shell.privileged = true
      end
      # Create a network that will allow the servers to communicate with each other
      vault.vm.network "private_network", ip: "10.0.0.#{i + 2}", virtualbox__intnet: "vault"
    end
  end
  (0..VAULT_SERVER_NUMER-1).each do |i|
    config.vm.define "vault_server-#{i}" do |vault|
      vault.vm.box = "vault"
      vault.vm.hostname = "vault-cluster-#{i}"
      vault.vm.provision "shell" do |shell|
        shell.path = "vault.sh"
        shell.args = [i, "10.0.0.#{i + 3}", VAULT_SERVER_NUMER]
        shell.privileged = true
      end
      # Expose the vault api and ui to the host
      vault.vm.network "forwarded_port", guest: 8200, host: "8200", auto_correct: true, host_ip: "127.0.0.1"
      vault.vm.network "private_network", ip: "10.0.0.#{i + 3}", virtualbox__intnet: "vault"
    end
  end
end
