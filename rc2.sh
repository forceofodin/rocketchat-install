#!/bin/bash
#download rocketchat and install with npm
cd /opt/rocket
curl -L https://releases.rocket.chat/latest/download -o rocket.chat.tgz
tar zxf rocket.chat.tgz
mv bundle Rocket.Chat
cd Rocket.Chat/programs/server
npm install
#set enviro variables
ip=192.168.1.180
export ROOT_URL=$ip:3000
export MONGO_URL=mongodb://localhost:27017/rocketchat
export MONGO_OPLOG_URL=mongodb://localhost:27017/local?replSet=rs01
export PORT=3000
#check node to be working proper
cd /opt/rocket/Rocket.Chat
sleep 60
node main.js
