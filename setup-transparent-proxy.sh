#! /bin/bash

sudo sysctl -w net.inet.ip.forwarding=1
sudo pfctl -f ./configs/pf.conf
sudo pfctl -e