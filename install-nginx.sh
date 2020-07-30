#!/bin/bash
sudo apt update
sudo apt install nginx

sleep 30

sudo systemctl status nginx

sudo ufw enable
sudo ufw allow 'Nginx Full'
sudo ufw status

