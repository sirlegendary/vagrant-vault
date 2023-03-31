#!/bin/bash
set -ex

sudo cat << EOF >> /etc/vault.d/config.hcl

api_addr = "http://$2:8200"
cluster_addr = "http://$2:8201"

seal "transit" {
  address = "http://10.0.0.2:8200"
  token = ""
  disable_renewal = "false"
  key_name = "autounseal"
  mount_path = "transit/"
  tls_skip_verify = "true"
}
EOF

sudo cat << EOF >> /home/vagrant/.bashrc
export VAULT_ADDR=http://127.0.0.1:8200
alias vlogs='journalctl -u vault'
EOF

sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault