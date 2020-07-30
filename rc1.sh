
sudo apt -y update
sudo apt -y upgrade

#create rocket user and home dir
sudo useradd -m -U -r -d /opt/rocket rocket

sudo usermod -a -G rocket www-data
sudo chmod 750 /opt/rocket

#install node.js
sudo apt install -y nodejs npm build-essential curl software-properties-common graphicsmagick vim wget

sudo npm install -g inherits n
sudo n 12.16.1

#install mongo
#=====================
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
sudo add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse'

sudo apt -y update
sudo apt -y install mongodb-org

sudo systemctl start mongod
sudo systemctl enable mongod

sudo echo -e "replication:\n replSetName: \"rs01\"" | tee -a /etc/mongod.conf
sudo systemctl restart mongod
sudo mongo --eval "rs.initiate()"
