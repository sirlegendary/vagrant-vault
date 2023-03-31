
source "vagrant" "vault" {
  communicator = "ssh"
  add_force    = true
  provider     = "virtualbox"

}

build {
  name = "vault"
  source "source.vagrant.vault" {
    source_path = "hashicorp/bionic64"
    output_dir  = "./box/vault"
    box_name    = "vault"
  }
  provisioner "shell" {
    inline = [
      "set -x",
      "df -H",
      "sudo apt-get update",
      "sudo apt-get install -y unzip jq"
    ]
  }
  provisioner "shell" {
    inline = [
      "curl https://releases.hashicorp.com/vault/1.13.0/vault_1.13.0_linux_amd64.zip -o /tmp/vault.zip",
      "cd /tmp && unzip /tmp/vault.zip",
      "sudo mv /tmp/vault /usr/local/bin/vault",
      "sudo chmod 0755 /usr/local/bin/vault",
      "sudo mkdir /etc/data",
      "sudo mkdir /etc/data/vault",
      "sudo mkdir /etc/vault.d",
      "sudo chmod 0755 /etc/data/vault",
      "sudo chmod 0755 /etc/vault.d",
      "sudo adduser --system --group vault || true",
      "sudo chown vault:vault /usr/local/bin/vault",
      "sudo chown vault:vault /etc/data/vault"
    ]
  }
  provisioner "file" {
    destination = "/tmp/config.hcl"
    content     = <<EOF
storage "raft" {
    path = "/etc/data/vault"
}
ui = true
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
      EOF
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/config.hcl /etc/vault.d/config.hcl",
      "sudo chmod 0755 /etc/vault.d/config.hcl",
    ]
  }
  provisioner "file" {
    destination = "/tmp/vault.service"
    content     = <<EOF
[Unit]
Description=vault

[Service]
LogsDirectory=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d
User=vault
Group=vault
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
      EOF
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/vault.service /etc/systemd/system/vault.service",
      "sudo chmod 664 /etc/systemd/system/vault.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable vault"
    ]
  }
  post-processor "shell-local" {
    inline = ["vagrant box add vault --force --name vault ./box/vault/package.box"]
  }
}