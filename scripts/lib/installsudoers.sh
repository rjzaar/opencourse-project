#!/bin/bash
# This will install d8fp.sh and debug so the password is not required.
# pass the file location as absolute path then the username,
# This is for security reasons. Once setup (needing password) it can't be changed without a password.

# Make sure sudo
if [ $(id -u) != 0 ]; then
  printf "**************************************\n"
  printf "* Error: You must run this with sudo or root*\n"
  printf "**************************************\n"
  print_help
  exit 1
fi
cp "$1/d8fp.sh" /usr/local/bin
cp "$1/debug" /usr/local/bin
cp "$1/sudoeuri.sh" /usr/local/bin
sudo chown root:root /usr/local/bin/d8fp.sh
sudo chown root:root /usr/local/bin/debug
sudo chown root:root /usr/local/bin/sudoeuri.sh
sudo echo "$2 ALL = (root) NOPASSWD: /usr/local/bin/d8fp.sh" > /etc/sudoers.d/pl
sudo echo "$2 ALL = (root) NOPASSWD: /usr/local/bin/debug" >> /etc/sudoers.d/pl
sudo echo "$2 ALL = (root) NOPASSWD: /usr/local/bin/sudoeuri.sh" >> /etc/sudoers.d/pl

#These commands may be security issues on certain setups. We are presuming an ubuntu setup just for pleasy.
sudo echo "$2 ALL = (root) NOPASSWD: /bin/chown" >> /etc/sudoers.d/pl
sudo echo "$2 ALL = (root) NOPASSWD: /bin/chmod" >> /etc/sudoers.d/pl
sudo echo "$2 ALL = (root) NOPASSWD: /bin/rm" >> /etc/sudoers.d/pl

sudo chmod 0440 /etc/sudoers.d/pl

