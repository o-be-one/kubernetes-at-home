#!/usr/bin/env bash
#
# Firewall rules to setup a VPS or any Linux server to serve as entrypoint
# to workload hosted somewhere else (like home in this case).
# This is more to help than the only truth, but be sure you know what
# you are doing before changing anything after global variables.

# Define target IP (where traffic will be forwarded to)
TARGET_IP="100.75.24.97"  # Change this to your home/target server IP

# Public interface (typically eth0 for VPS)
PUB_IF="eth0"  # Change this to your public-facing interface

# Make sure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Functions must be defined before they're used
clear-rules() {
  echo "Clearing firewall rules for port forwards..."

  # Get a list of all rules numbers for our ports in reverse order
  # This ensures we delete from highest rule number to lowest
  local tcp_prerouting_rules=$(iptables -t nat -L PREROUTING --line-numbers | grep "dpt:" | tac | awk '{print $1}')
  local udp_prerouting_rules=$(iptables -t nat -L PREROUTING --line-numbers | grep "dpt:" | tac | awk '{print $1}')
  local tcp_postrouting_rules=$(iptables -t nat -L POSTROUTING --line-numbers | grep "dpt:" | tac | awk '{print $1}')
  local udp_postrouting_rules=$(iptables -t nat -L POSTROUTING --line-numbers | grep "dpt:" | tac | awk '{print $1}')
  local tcp_forward_rules=$(iptables -L FORWARD --line-numbers | grep "dpt:" | tac | awk '{print $1}')
  local udp_forward_rules=$(iptables -L FORWARD --line-numbers | grep "dpt:" | tac | awk '{print $1}')

  # Delete the rules by number (in reverse)
  for rule in $tcp_prerouting_rules; do
    iptables -t nat -D PREROUTING $rule 2>/dev/null
  done

  for rule in $udp_prerouting_rules; do
    iptables -t nat -D PREROUTING $rule 2>/dev/null
  done

  for rule in $tcp_postrouting_rules; do
    iptables -t nat -D POSTROUTING $rule 2>/dev/null
  done

  for rule in $udp_postrouting_rules; do
    iptables -t nat -D POSTROUTING $rule 2>/dev/null
  done

  for rule in $tcp_forward_rules; do
    iptables -D FORWARD $rule 2>/dev/null
  done

  for rule in $udp_forward_rules; do
    iptables -D FORWARD $rule 2>/dev/null
  done

  echo "Firewall rules cleared."

  # Restart Tailscale to restore its rules
  if command -v tailscale >/dev/null 2>&1; then
    echo "Restarting Tailscale to restore its firewall rules..."
    systemctl restart tailscaled
    echo "Tailscale restarted."
  else
    echo "Tailscale not found, skipping restart."
  fi
}

forward-port() {
  local protocol=$1
  local port=$2

  # Validate protocol
  if [[ "$protocol" != "tcp" && "$protocol" != "udp" ]]; then
    echo "Error: Protocol must be 'tcp' or 'udp'. Got '$protocol'"
    return 1
  fi

  # Validate port
  if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo "Error: Port must be a number between 1 and 65535. Got '$port'"
    return 1
  fi

  echo "Forwarding $protocol port $port from $PUB_IF to $TARGET_IP:$port"

  # Enable IP forwarding if not already enabled
  if [[ $(cat /proc/sys/net/ipv4/ip_forward) -eq 0 ]]; then
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sysctl -w net.ipv4.ip_forward=1
    echo "Enabled IP forwarding"
  fi

  # Add forwarding rules EXACTLY like in your original script
  iptables -t nat -A PREROUTING -i $PUB_IF -p $protocol --dport $port -j DNAT --to-destination $TARGET_IP:$port
  iptables -t nat -A POSTROUTING -d $TARGET_IP -p $protocol --dport $port -j MASQUERADE
  iptables -A FORWARD -p $protocol -d $TARGET_IP --dport $port -j ACCEPT

  echo "Port forwarding configured for $protocol port $port"
}

# Function to list current firewall rules
list-rules() {
  echo "========== LISTING PORT FORWARDING RULES =========="
  echo ""
  echo "--- PREROUTING (NAT) ---"
  iptables -t nat -L PREROUTING -v --line-numbers | grep -E "dpt:|DNAT"
  echo ""
  echo "--- POSTROUTING (NAT) ---"
  iptables -t nat -L POSTROUTING -v --line-numbers | grep -E "dpt:|MASQUERADE"
  echo ""
  echo "--- FORWARD ---"
  iptables -L FORWARD -v --line-numbers | grep -E "dpt:|ACCEPT"
  echo ""
  echo "========== END OF RULES =========="
}

# Save rules function
save-rules() {
  echo "Saving firewall rules..."

  # Try netfilter-persistent first (like your original script)
  if command -v netfilter-persistent > /dev/null; then
    netfilter-persistent save
    echo "Firewall rules saved using netfilter-persistent"
  elif command -v iptables-save > /dev/null; then
    # Fallback to iptables-save
    iptables-save > /etc/iptables.rules
    echo "Firewall rules saved to /etc/iptables.rules"

    # Create systemd service to restore rules on boot if it doesn't exist
    if [[ ! -f /etc/systemd/system/iptables-restore.service ]]; then
      cat > /etc/systemd/system/iptables-restore.service << EOF
[Unit]
Description=Restore iptables firewall rules
Before=network-pre.target
Before=tailscaled.service

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables.rules
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
      systemctl daemon-reload
      systemctl enable iptables-restore.service
      echo "Created and enabled iptables-restore service"
    fi
  else
    echo "Neither netfilter-persistent nor iptables-save found. Rules not saved permanently."
  fi
}

# Main case statement
case $1 in
  clear)
    clear-rules
    ;;
  list)
    list-rules
    ;;
  corekeeper)
    forward-port tcp 27015
    forward-port udp 27015
    save-rules
    ;;
  minecraft)
    forward-port tcp 25565
    forward-port udp 25565
    save-rules
    ;;
  save)
    save-rules
    ;;
  *)
    echo "Syntax: $(basename $0) [clear|list|corekeeper|minecraft|save]"
    echo ""
    echo "  clear      - Clear all port forwarding rules and restart Tailscale"
    echo "  list       - List current port forwarding rules"
    echo "  corekeeper - Forward Core Keeper ports (27015 tcp/udp)"
    echo "  minecraft  - Forward Minecraft ports (25565 tcp/udp)"
    echo "  save       - Save current rules to be restored on boot"
    ;;
esac
