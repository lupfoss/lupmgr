#!/usr/bin/env bash

sudo cp rc-local.service /etc/systemd/system/rc-local.service
echo "#!/usr/bin/env bash" > rc.local.tmp
./generate_command.sh >> rc.local.tmp
sudo cp rc.local.tmp /etc/rc.local
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
sudo systemctl start rc-local.service
sudo systemctl status rc-local.service
