#!/bin/bash
set -e

if [ ! -f "./bash-test.sh" ]; then
  curl -s "https://raw.githubusercontent.com/danielaauriema/bash-tools/master/lib/bash-test.sh" > "/opt/test/bash-test.sh"
fi

. /opt/lib/bash-wait.sh
. /opt/test/bash-test.sh

bash_test_header "gitea-ldap :: wait for connection"
bash_wait_for_uri "http://localhost:3000" 60

bash_test_header "gitea-ldap :: check admin login"
curl -X 'GET' 'http://localhost:3000/api/v1/user' -H 'accept: application/json' -u 'gitea:password'

bash_test_header "gitea-ldap :: check ldap login"
curl -X 'GET' 'http://localhost:3000/api/v1/user' -H 'accept: application/json' -u 'ldap:password'

bash_test_header "All tests has finished successfully!!"