#!/usr/bin/env bash

./disconnect.sh

echo "Uninstalling lightup-ssh-connect..."
sudo rm -rf lightup-ssh-connect.service.pid
sudo rm -rf lightup-ssh-connect.service.log
sudo systemctl disable lightup-ssh-connect
sudo rm -rf /etc/systemd/system/lightup-ssh-connect.service

echo "Uninstalling lightup-dataplane-connect..."
sudo rm -rf lightup-dataplane-connect.service.log
sudo rm -rf lightup-dataplane-connect.service.pid
sudo systemctl disable lightup-dataplane-connect
sudo rm -rf /etc/systemd/system/lightup-dataplane-connect.service

sudo rm -rf /opt/lightup/*
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "Lightup uninstalled"
