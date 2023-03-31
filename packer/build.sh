function build(){
    packer build -force -only $1.vagrant.vault .; vagrant box add $1 --force --name base ./box/$1/package.box
}

#build base
build vault
