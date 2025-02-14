#!/bin/bash
sudo apt install openssh-server
sudo systemctl enable ssh --now
sudo systemctl start ssh