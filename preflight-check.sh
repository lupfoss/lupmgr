#!/usr/bin/env bash

echo 'Running Lightup preflight checks...'

echo 'Checking user...'
if [ `whoami` = root ]; then
    echo "ERROR: Please do not run this script as root or using sudo\n"
    exit 1
else
    echo "  User '`whoami`' will be used for the installation"
fi

# Run replicated preflight checks
# Start the standard install but exit after the host checks are run
# TODO: Ideally this would use the release type that is being installed but 'head'
# should be fine just for preflight checks
echo 'Running Replicated preflight checks...'
curl -sSL https://k8s.kurl.sh/lightup-head | sed 's/    install_host_dependencies/    exit 0/' | sudo bash
EXIT=$?
if [ $EXIT -eq 0 ]; then
  echo Lightup preflight checks succeeded!
else
  echo ERROR: Lightup preflight checks failed
  exit $EXIT
fi
