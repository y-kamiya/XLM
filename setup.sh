#!/bin/bash

wget https://dl.fbaipublicfiles.com/XLM/vocab_enfr
wget https://dl.fbaipublicfiles.com/XLM/codes_enfr
wget https://dl.fbaipublicfiles.com/XLM/mlm_enfr_1024.pth

git clone https://github.com/NVIDIA/apex
pushd apex
sudo chmod 777 /opt/anaconda3/lib/python3.7/site-packages
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .
popd

# ./get-data-nmt.sh --src en --tgt fr --reload_codes codes_enfr --reload_vocab vocab_enfr
./get-data-nmt.sh --src en --tgt fr
