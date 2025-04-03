#!/bin/bash

if [ $# -ne 1 ];then
  echo usage $0 domainame
  exit 1
fi
domain=$1

apt update
apt install -y nginx python3-pip python3.12-venv ffmpeg
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp nginx/transcriber.conf /etc/nginx/sites-enabled
sed -i "s/your.domain.com/$domain/g" /etc/nginx/sites-enabled/transcriber.conf

systemctl reload nginx
cp systemd/pytranscriber.service /etc/systemd/system/pytranscriber.service
systemctl daemon-reexec
systemctl daemon-reload
systemctl start pytranscriber
systemctl enable pytranscriber


#python app.py