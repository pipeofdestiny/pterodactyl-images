#!/bin/ash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Make internal Docker gateway IP address available to processes.
export INTERNAL_GW=`ip route get 1 | awk '{print $3;exit}'`

# Make Lobby config path.
export LOBBY_CONFIG="/home/container/lobby.config"

# Remove previous configuration.
if [ -e "${LOBBY_CONFIG}" ]; then
    rm "${LOBBY_CONFIG}"
fi

# Create configuration from template.
cp "/lobby.config.template" "${LOBBY_CONFIG}"

edit_mysql_config() {
    if [ $# -lt 2 ]; then
        return 1
    fi
    local config="${3:-$LOBBY_CONFIG}"
    xmlstarlet edit -L -u "/settings/database/mysql/add[@key='$1']/@value" -v "$2" "$config"
    return $?
}

# Edit MySQL connection informations in configuration.
edit_mysql_config "ip" "${MYSQL_HOST:-$INTERNAL_GW}" || exit 1
edit_mysql_config "port" "${MYSQL_PORT:-3306}" || exit 1
edit_mysql_config "name" "${MYSQL_DATABASE:-s2lobby}" || exit 1
edit_mysql_config "user" "${MYSQL_USER:-s2lobby}" || exit 1
edit_mysql_config "pass" "${MYSQL_PASSWORD:-}" || exit 1

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
