# vagrant-vault

Build 3 Vault Clusters. One to unseal the other two.

## Prerequisite

- vagrant installed
- packer installed

## Usage

Build the vagrant boxes using packer

```bash
cd packer
chmod +x build.sh
./build.sh
```

`This may take some time`

Now create your machines by running `vagrant up` in the root directory.

```bash
cd ..
vagrant up
```

For logs

```bash
vagrant ssh vault-server-0
journalctl -u vault
```
