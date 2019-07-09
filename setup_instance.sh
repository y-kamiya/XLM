#!/bin/bash

LC_ALL=en_US.UTF-8

sudo apt -y update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt -y update
sudo apt install -y python3-pip
sudo apt install -y python3.7-dev
python3.7 -m pip install pip

pip3.7 install --user https://download.pytorch.org/whl/cu100/torch-1.0.1-cp37-cp37m-linux_x86_64.whl
#pip3.7 install torch==1.0.1 -f https://download.pytorch.org/whl/cu100/stable --user
pip3.7 install torchvision==0.2.2 -f https://download.pytorch.org/whl/cu100/stable --user

git clone https://github.com/NVIDIA/apex
pushd apex
pip3.7 install --user -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .
popd

./install-tools.sh
