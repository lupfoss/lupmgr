# Redhat
# Run using: source setup_rhel.sh
# Will need to logout and log back in to enable snapd to work


sudo yum check-update
sudo yum install git 

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf upgrade

sudo yum install snapd
sudo systemctl enable --now snapd.socket

exit
