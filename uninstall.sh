#!/usr/bin/env bash

./disconnect.sh

echo "Uninstalling lightup-ssh-connect..."
sudo rm -rf lightup-ssh-connect.service.pid
sudo rm -rf lightup-ssh-connect.service.log
sudo systemctl disable lightup-ssh-connect

echo "Uninstalling lightup-dataplane-connect..."
sudo rm -rf lightup-dataplane-connect.service.log
sudo rm -rf lightup-dataplane-connect.service.pid
sudo systemctl disable lightup-dataplane-connect

sudo rm -rf /opt/lightup/*

echo "Lightup uninstalled"
