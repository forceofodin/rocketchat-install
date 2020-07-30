#!/bin/bash
site=clippedresistors.site
#create the rocketchat sys service
rc_service=/etc/systemd/system/rocketchat.service

cat > $rc_service << EOF
[Unit]
Description=Rocket.Chat server
After=network.target nss-lookup.target mongod.target
[Service]
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=rocket
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat MONGO_OPLOG_URL=mongodb://localhost:27017/local?replSet=rs01 ROOT_URL=http://$site PORT=3000
ExecStart=/usr/local/bin/node /opt/rocket/Rocket.Chat/main.js
[Install]
WantedBy=multi-user.target
EOF

#reload, enable, start rocketchat
sudo systemctl daemon-reload
sudo systemctl restart rocketchat
sudo systemctl status rocketchat
