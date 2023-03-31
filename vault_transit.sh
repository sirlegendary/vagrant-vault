#!/bin/bash
set -ex

sudo cat << EOF >> /etc/vault.d/config.hcl
api_addr = "http://$2:8200"
cluster_addr = "http://$2:8201"
EOF

sudo cat << EOF >> /home/vagrant/.bashrc
export VAULT_ADDR=http://127.0.0.1:8200
alias vlogs='journalctl -u vault'
EOF

sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

sudo cat << EOF > /home/vagrant/autounseal.hcl
path "transit/encrypt/autounseal" {
   capabilities = [ "update" ]
}

path "transit/decrypt/autounseal" {
   capabilities = [ "update" ]
}
EOF

sudo cat << EOF > /home/vagrant/setup.sh
#!/bin/bash
set -ex

vault operator init -format=json > operator_keys;
vault operator unseal \`cat operator_keys | jq .unseal_keys_b64[0] -r\`;
vault operator unseal \`cat operator_keys | jq .unseal_keys_b64[2] -r\`;
vault operator unseal \`cat operator_keys | jq .unseal_keys_b64[4] -r\`;
export VAULT_TOKEN=\`cat operator_keys | jq .root_token -r\`;
# sudo touch /var/log/vault-audit.log;
# vault audit enable file file_path=/var/log/vault_audit.log;
vault secrets enable transit;
vault write -f transit/keys/autounseal
vault policy write autounseal autounseal.hcl
vault token create -policy="autounseal" -format=json > wrapping_token
EOF

chmod +x /home/vagrant/setup.sh




