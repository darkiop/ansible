#!/bin/bash
# This script checks if the Pi-hole service is running and if the web interface is reachable

# Define the IP and port of the Pi-hole instance
PIHOLE_IP="127.0.0.1"
PIHOLE_PORT="80"

# Check if the Pi-hole service is running
if ! systemctl is-active --quiet pihole-FTL; then
    echo "Pi-hole service is not active."
    exit 1
fi

# Optionally, check if the Pi-hole web interface is reachable
if ! curl -s --max-time 2 http://${PIHOLE_IP}:${PIHOLE_PORT}/admin > /dev/null; then
    echo "Pi-hole web interface is not reachable."
    exit 1
fi

# If all checks pass
exit 0
