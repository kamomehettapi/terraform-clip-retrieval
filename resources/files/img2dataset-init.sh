#!/bin/bash

# python -m pip install typing-extensions
# python -m pip install img2dataset

wget https://secure.nic.cz/files/knot-resolver/knot-resolver-release.deb
sudo dpkg -i knot-resolver-release.deb
sudo apt-get update
sudo apt-get install -y knot-resolver
sudo sh -c 'echo `hostname -I` `hostname` >> /etc/hosts'
sudo sh -c 'echo nameserver 127.0.0.1 > /etc/resolv.conf'
sudo systemctl stop systemd-resolved

sudo systemctl start kresd@1.service
sudo systemctl start kresd@2.service
sudo systemctl start kresd@3.service
sudo systemctl start kresd@4.service
