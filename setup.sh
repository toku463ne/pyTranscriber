#!/bin/bash

if [ $# -ne 1 ];then
  echo usage $0 domainame
  exit 1
fi
domain=$1

sudo apt update
sudo apt install -y nginx python3-pip python3-venv ffmpeg
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

sudo mkdir -p ${HOME}/.creds
sudo touch ${HOME}/.creds/pytranscriber.env
sudo chmod 700 ${HOME}/.creds/pytranscriber.env

sudo cp nginx/transcriber.conf /etc/nginx/sites-enabled
sudo sed -i "s/your.domain.com/$domain/g" /etc/nginx/sites-enabled/transcriber.conf

sudo systemctl reload nginx
sudo cp systemd/pytranscriber.service /etc/systemd/system/pytranscriber.service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl start pytranscriber
sudo systemctl enable pytranscriber


#python app.py