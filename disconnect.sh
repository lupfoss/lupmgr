#!/usr/bin/env bash

echo "Stopping lightup-ssh-connect service..."
sudo systemctl stop lightup-ssh-connect.service
echo "Stopping lightup-dataplane-connect service..."
sudo systemctl stop lightup-dataplane-connect.service
