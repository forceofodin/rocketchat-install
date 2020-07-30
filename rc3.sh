#!/bin/bash
ip=192.168.1.180
#create the rocketchat sys service
if [[ -f /etc/systemd/system/rocketchat.service ]]; then
	sudo echo ">>>>rocketchat.service file already exists!"
	sudo echo ">>>>Skipping config of the rocketchat sys service!"
else
	sudo touch /etc/systemd/system/rocketchat.service
	sudo echo "[Unit]" >> /etc/systemd/system/rocketchat.service
	sudo echo "Description=Rocket.Chat server" >> /etc/systemd/system/rocketchat.service
	sudo echo "After=network.target nss-lookup.target mongod.target" >> /etc/systemd/system/rocketchat.service
	sudo echo "[Service]" >> /etc/systemd/system/rocketchat.service
	sudo echo "StandardOutput=syslog" >> /etc/systemd/system/rocketchat.service
	sudo echo "StandardError=syslog" >> /etc/systemd/system/rocketchat.service
	sudo echo "SyslogIdentifier=rocketchat" >> /etc/systemd/system/rocketchat.service
	sudo echo "User=rocket" >> /etc/systemd/system/rocketchat.service
	sudo echo "Environment=MONGO_URL=mongodb://localhost:27017/rocketchat MONGO_OPLOG_URL=mongodb://localhost:27017/local?replSet=rs01 ROOT_URL=http://$ip PORT=3000" >> /etc/systemd/system/rocketchat.service
	sudo echo "ExecStart=/usr/local/bin/node /opt/rocket/Rocket.Chat/main.js" >> /etc/systemd/system/rocketchat.service
	sudo echo "[Install]" >> /etc/systemd/system/rocketchat.service
	sudo echo "WantedBy=multi-user.target" >> /etc/systemd/system/rocketchat.service
fi
#reload, enable, start rocketchat
sudo systemctl daemon-reload
sudo systemctl enable rocketchat
sudo systemctl start rocketchat
