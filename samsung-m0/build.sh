#!/bin/bash

PARAMS="-v --assume-yes --work ../.samsung-m0 --config ./pmbootstrap_v3.cfg"

# Samsung M0 build script
# pmbootstrap $PARAMS init

# Add netowork manager credentials for wifi-12-private 
pmbootstrap chroot --rootfs -- sh -c '
mkdir -p /etc/NetworkManager/system-connections
cat > /etc/NetworkManager/system-connections/wifi.nmconnection <<EOF
[connection]
id=HomeWiFi
uuid=$(uuidgen)
type=wifi
autoconnect=true

[wifi]
mode=infrastructure
ssid=wifi-12-private

[wifi-security]
key-mgmt=wpa-psk
psk=9263777101

[ipv4]
method=auto

[ipv6]
method=auto
EOF

chmod 600 /etc/NetworkManager/system-connections/wifi.nmconnection
'

# Add autologin script for user pm
pmbootstrap chroot --rootfs -- sh -c '
cat >> /etc/start_tmux.sh << "EOF"
#!/bin/sh
# Start tmux session with 3 vertically stacked panes

SESSION="monitor"

# If the session already exists, attach to it
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach -t "$SESSION"
    exit 0
fi

# Create new session detached
tmux new-session -d -s "$SESSION" "htop"

# Split into 3 equal vertical panes
tmux split-window -v -t "$SESSION" "journalctl -f"
#tmux split-window -v -t "$SESSION" "journalctl -kf"

# Balance pane sizes evenly
tmux select-layout -t "$SESSION" even-vertical

# Attach to the session
tmux attach -t "$SESSION"
EOF

# Set ownership and permissions
#chown pm:pm /etc/start_tmux.sh
chmod +x /etc/start_tmux.sh
'

# Add autologin service for tty1
pmbootstrap chroot --rootfs -- sh -c '
cat > /etc/systemd/system/tty1-autologin.service << "EOF"
[Unit]
Description=Auto login on tty1
After=systemd-user-sessions.service getty@tty1.service
Conflicts=getty@tty1.service

[Service]
ExecStart=-/bin/su - pm -l -c "clear; echo Welcome $(whoami); /etc/start_tmux.sh"
StandardInput=tty
StandardOutput=tty
StandardError=tty
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Disable the default getty on tty1 to avoid conflict
systemctl disable getty@tty1.service || true

# Enable our autologin service
systemctl enable tty1-autologin.service
'