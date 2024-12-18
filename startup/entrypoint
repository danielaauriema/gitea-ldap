#!/bin/bash
set -e

if [ $# -gt 0 ]; then
    eval "$@"
else
  if [ ! -f /data/logs/config ] && (! ./config.sh); then
    echo "*** gitea-ldap configuration error"
    tail -f /dev/null
  fi
  exec /usr/bin/entrypoint
fi
