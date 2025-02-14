#!/bin/bash
bash ufw_enable.sh
bash ssh_install.sh
bash ssh_safe_create_config.sh
bash ssh_add_keys.sh
bash mosh_install.sh
bash ufw_allow.sh