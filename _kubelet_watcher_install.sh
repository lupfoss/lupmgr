#!/bin/bash
#
# shortcut script to install kubelet-watcher on hybrid-ha-rc
# 
# (only for reference, to be removed before merging branch)

set -x

nodes=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/stack.pem ubuntu@connect.hybrid-ha-rc.lightup.ai \
  "kubectl get nodes -o name | sed 's/node\///'")

scp -o StrictHostKeyChecking=no -i ~/.ssh/stack.pem ./kubelet-watcher* ubuntu@connect.hybrid-ha-rc.lightup.ai:/tmp/
echo; echo "copied kubelet-watcher scripts to connect server"; echo

for node in $nodes; do
echo; echo "copying kubelet-watcher scripts to $node"; echo
ssh -i ~/.ssh/stack.pem ubuntu@connect.hybrid-ha-rc.lightup.ai \
  "scp -o StrictHostKeyChecking=no -i lightup-to-hybrid-ha-rc /tmp/kubelet-watcher* $node:~/"
done


for node in $nodes; do
echo; echo "installing kubelet-watcher on $node"; echo
ssh -o StrictHostKeyChecking=no -i ~/.ssh/stack.pem ubuntu@connect.hybrid-ha-rc.lightup.ai \
  "ssh -o StrictHostKeyChecking=no -i lightup-to-hybrid-ha-rc $node \
    \"chmod +x ~/kubelet-watcher-install.sh \""

ssh -o StrictHostKeyChecking=no -i ~/.ssh/stack.pem ubuntu@connect.hybrid-ha-rc.lightup.ai \
  "ssh -o StrictHostKeyChecking=no -i lightup-to-hybrid-ha-rc $node \
    \"~/kubelet-watcher-install.sh \""

echo
done

#----

echo; echo "all done"
