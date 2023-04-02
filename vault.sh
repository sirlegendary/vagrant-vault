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

sudo touch /opt/vault.creds
sudo touch /opt/vault-audit.log
sudo chmod 0755 /opt/vault.creds
sudo chown vagrant:vagrant /opt/vault.creds
sudo chown vault:vault /opt/vault-audit.log


sudo cat << EOF >> /home/vagrant/.bashrc
export VAULT_ADDR=http://127.0.0.1:8200
alias vlogs='journalctl -u vault'
alias vrestart="sudo systemctl daemon-reload;sudo systemctl restart vault;"
alias vinit="vault operator init -format=json > /opt/vault.creds"
alias vtoken="export VAULT_TOKEN=\`cat operator_keys | jq .root_token -r\`;"
EOF

# sudo systemctl daemon-reload
# sudo systemctl enable vault
# sudo systemctl start vault