#!/bin/bash

# Lấy các đối số từ tệp PHP
server="$1"
remotepath="$2"
localpath="$4"
user_id="$3"

# Thực hiện lệnh SSH đăng nhập vào máy chủ từ xa
sshpass -p 'haiyen' ssh -o StrictHostKeyChecking=no haiyen@$server 'bash -s' << EOF
    # Thực hiện lệnh SFTP để tải tệp cục bộ lên máy chủ từ xa
    sftp haiyen@$server << SFTP_COMMANDS
        put "$localpath" to "$remotepath"
        SFTP_COMMANDS
    exit
EOF

# Thực hiện các lệnh trên máy chủ từ xa
ssh haiyen@$server << SSH_COMMANDS
    cd /home/haiyen/Documents/opt/gama-platform/headless/
    # Thực hiện các lệnh GAMA headless tương ứng ở đây
    bash ./gama-headless.sh ./samples/'$user_id'_template_run.xml' . ' ./output/testFolder
    # ...
    exit
SSH_COMMANDS
