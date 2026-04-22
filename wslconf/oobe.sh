#!/bin/bash

set -ue

DEFAULT_GROUPS='adm,cdrom,plugdev,wheel'
DEFAULT_UID='1000'

echo 'Please create a default UNIX user account. The username does not need to match your Windows username.'
echo 'For more information visit: https://aka.ms/wslusers'

if getent passwd "$DEFAULT_UID" > /dev/null ; then
  echo 'User account already exists, skipping creation'
  exit 0
fi

while true; do

  # Prompt from the username
  read -p 'Enter new UNIX username: ' username

  # Create the user
  if /usr/sbin/useradd --uid "$DEFAULT_UID" "$username"; then

    if /usr/sbin/usermod -aG "$username" $DEFAULT_GROUPS; then
      break
    else
      /usr/sbin/userdel "$username"
    fi
  fi
done

chsh -s bash "$username"

cat > /etc/sudoers.d/wsluser << EOF
%wheel ALL=(ALL:ALL) ALL
EOF