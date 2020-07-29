#!/bin/bash

#Install Singularity on Linux
#Singularity must be installed as root to function properly

cd /

sudo apt-get update && sudo apt-get install -y \ 
    build-essential \ 
    libssl-dev \ 
    uuid-dev \ 
    libgpgme11-dev \ 
    squashfs-tools \ 
    libseccomp-dev \ 
    wget \ 
    pkg-config \ 
    git \ 
    cryptsetup \ 
    cryptsetup-bin 

sudo wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz

sudo tar -C /usr/local -xzf go1.14.4.linux-amd64.tar.gz

rm go1.14.4.linux-amd64.tar.gz

echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc

source ~/.bashrc

sudo wget https://github.com/sylabs/singularity/releases/download/v3.6.0/singularity-3.6.0.tar.gz

sudo tar -xzf singularity-3.6.0.tar.gz

rm singularity-3.6.0.tar.gz

cd singularity

./mconfig && \ 
    make -C builddir && \ 
    sudo make -C builddir install

cd /

singularity --debug run library://sylabsed/examples/lolcow