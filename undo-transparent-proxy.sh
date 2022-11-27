#! /bin/bash

sudo sysctl -w net.inet.ip.forwarding=0
sudo pfctl -d