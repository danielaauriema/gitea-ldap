#!/bin/bash
set -e

_log(){
  echo "*** gitea-config :: $1"
}
_log "starting..."

. /opt/lib/bash-wait.sh

_log "custom config..."
/etc/s6/gitea/setup

_log "waiting for DB connection: ${GITEA__database__HOST}"
bash_wait_for_connection "${GITEA__database__HOST}" 60

_log "migrating database..."
su git -c "gitea migrate --config /data/gitea/conf/app.ini"

_log "adding gitea admin user..."
su git -c \
  "gitea admin user create \
  --username \"${GITEA__ADMIN_USERNAME}\" \
  --password \"${GITEA__ADMIN_PASSWORD}\" \
  --email \"${GITEA__ADMIN_EMAIL}\" \
  --admin -c /data/gitea/conf/app.ini"

_log "adding LDAP connection..."
su git -c \
  "gitea admin auth add-ldap \
    --name ldap \
    --security-protocol ${LDAP__PROTOCOL} \
    --host ${LDAP__HOST} \
    --port ${LDAP__PORT} \
    --user-search-base ${LDAP__SEARCH_BASE} \
    --user-filter '(&(objectClass=posixAccount)(uid=%s))' \
    --admin-filter '(memberof=cn=admin,ou=groups,${LDAP__BASE_DN})' \
    --email-attribute mail \
    --bind-dn ${LDAP__BIND_DN} \
    --bind-password ${LDAP__BIND_PASSWORD} \
    --skip-tls-verify"

_log "config finished successfully!"
mkdir -p /data/logs
touch /data/logs/config

