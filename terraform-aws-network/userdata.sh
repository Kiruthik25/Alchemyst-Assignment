#!/bin/bash

sudo apt update
sudo apt install git curl unzip python3-pip python3-venv nodejs npm -y

curl -fsSL https://install.iii.dev/iii/main/install.sh | sh

echo 'export PATH="/home/ubuntu/.local/bin:$PATH"' >> /home/ubuntu/.bashrc

source /home/ubuntu/.bashrc
