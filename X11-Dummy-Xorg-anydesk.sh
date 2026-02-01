#!/bin/bash
# 🚀🚀🚀 SUPER AWESOME ANYDESK HEADLESS INSTALLER 🚀🚀🚀
# Script to automate AnyDesk installation and configuration on a headless Ubuntu server
# With added pizzazz and properly configured display for maximum reliability!

# Color definitions for epic terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RAINBOW='\033[38;5;'
BOLD='\033[1m'
RESET='\033[0m'

# Set up ASCII art function for extra flair
function show_banner() {
    echo -e "${CYAN}"
    echo -e "    _    _   ___   __ ____  _____ ____  _  __"
    echo -e "   / \  | \ | \ \ / /|  _ \| ____/ ___|| |/ /"
    echo -e "  / _ \ |  \| |\ V / | | | |  _| \___ \| ' / "
    echo -e " / ___ \| |\  | | |  | |_| | |___ ___) | . \ "
    echo -e "/_/   \_\_| \_| |_|  |____/|_____|____/|_|\_\\"
    echo -e "${YELLOW}       🔥 HEADLESS EDITION v3.0 🔥${RESET}"
    echo -e "${PURPLE}=================================================${RESET}"
}

# Another banner for the finale
function show_final_banner() {
    echo -e "${GREEN}"
    echo -e " ____  _   _  ____ ____ _____ ____ ____  _ "
    echo -e "/ ___|| | | |/ ___/ ___| ____/ ___/ ___|| |"
    echo -e "\___ \| | | | |  | |   |  _| \___ \___ \| |"
    echo -e " ___) | |_| | |__| |___| |___ ___) |__) |_|"
    echo -e "|____/ \___/ \____\____|_____|____/____/(_)"
    echo -e "${RESET}"
}

# Set up logging with style
LOG_FILE="/var/log/anydesk_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Display the epic banner
show_banner
echo -e "${YELLOW}Starting the AWESOME AnyDesk headless installation script!${RESET}"
echo -e "${PURPLE}=================================================${RESET}"
echo

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}${BOLD}😱 HALT! This script must be run as root (sudo mode).${RESET}"
        exit 1
    fi
}

# Function to log messages with colorful flair
log() {
    local color=${2:-$GREEN}
    echo -e "${color}[🚀 INFO]${RESET} $1"
}

# Function to show warnings
warn() {
    echo -e "${YELLOW}[⚠️ WARNING]${RESET} $1"
}

# Function to handle errors with dramatic effect
error() {
    echo -e "${RED}[💥 ERROR]${RESET} $1" >&2
    if [ "$2" = "fatal" ]; then
        echo -e "${RED}${BOLD}💀 FATAL ERROR! Mission aborted. System meltdown imminent...${RESET}"
        exit 1
    fi
}

# Function for success messages
success() {
    echo -e "${GREEN}[✅ SUCCESS]${RESET} $1"
}

# Function to show progress
show_progress() {
    local title="$1"
    echo -ne "${BLUE}[⏳ PROGRESS]${RESET} $title... "
    for i in {1..30}; do
        echo -ne "${CYAN}▓${RESET}"
        sleep 0.03
    done
    echo -e " ${GREEN}Complete!${RESET}"
}

# Function to check if AnyDesk is running
check_anydesk_running() {
    if pgrep -x "anydesk" > /dev/null; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

# Rainbow text function for special announcements
rainbow_text() {
    local text="$1"
    local start_color=16
    
    for (( i=0; i<${#text}; i++ )); do
        local char="${text:$i:1}"
        local color=$(( (start_color + i*6) % 216 + 16 ))
        echo -ne "${RAINBOW}${color}m${char}${RESET}"
    done
    echo
}

# Function to uninstall AnyDesk completely
uninstall_anydesk() {
    log "🧹 Uninstalling existing AnyDesk installation - Clearing the slate!" "${RED}"
    
    # Stop and disable the AnyDesk service if it exists
    if systemctl list-unit-files | grep -q anydesk; then
        show_progress "Stopping AnyDesk services"
        systemctl stop anydesk.service 2>/dev/null
        systemctl disable anydesk.service 2>/dev/null
        systemctl stop anydesk-headless.service 2>/dev/null
        systemctl disable anydesk-headless.service 2>/dev/null
        success "AnyDesk services stopped and disabled!"
    fi
    
    # Remove the AnyDesk package
    show_progress "Removing AnyDesk package"
    apt-get remove --purge -y anydesk 2>/dev/null
    apt-get autoremove -y 2>/dev/null
    
    # Clean up any remaining configuration files
    show_progress "Cleaning up configuration files"
    rm -rf /etc/anydesk 2>/dev/null
    rm -rf /etc/systemd/system/anydesk*.service 2>/dev/null
    rm -rf /usr/local/bin/start-anydesk-headless.sh 2>/dev/null
    rm -rf ~/.anydesk 2>/dev/null
    
    # Clean up X11 configuration if it exists
    if [ -f /etc/X11/xorg.conf ] && grep -q "dummy" /etc/X11/xorg.conf; then
        mv /etc/X11/xorg.conf /etc/X11/xorg.conf.bak 2>/dev/null
        log "Backed up existing xorg.conf to xorg.conf.bak" "${YELLOW}"
    fi
    
    # Remove any lingering processes
    killall -9 Xorg 2>/dev/null
    killall -9 anydesk 2>/dev/null
    
    # Reload systemd
    systemctl daemon-reload
    
    success "Previous AnyDesk installation has been completely purged! Ready for a fresh start! 🌟"
}

# Check if running as root
check_root

# Step 0: Uninstall AnyDesk if it's already installed
if command -v anydesk &> /dev/null || [ -d /etc/anydesk ] || [ -f /etc/apt/sources.list.d/anydesk-stable.list ]; then
    log "🔍 Existing AnyDesk installation detected!" "${YELLOW}"
    uninstall_anydesk
else
    log "🔍 No existing AnyDesk installation found - Starting fresh!" "${CYAN}"
fi

# Step 1: Install prerequisites with pizzazz
log "🧰 Installing prerequisites - The foundation of our AnyDesk fortress!" "${CYAN}"
show_progress "Updating package lists"
apt update || { error "Failed to update package lists" "fatal"; }

show_progress "Installing required packages"
apt install -y wget gnupg apt-transport-https expect xserver-xorg-video-dummy x11-xserver-utils xfonts-base xfonts-75dpi xfonts-100dpi dbus-x11 libglib2.0-0 libxrandr2 libxtst6 curl lightdm xinit || { error "Failed to install prerequisites" "fatal"; }
success "All prerequisites installed! Ready for the next phase of our mission!"

# Step 2: Add AnyDesk repository
log "🔑 Adding AnyDesk GPG key - Unlocking the gateway to remote connection glory!" "${CYAN}"
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add - || { error "Failed to add AnyDesk GPG key" "fatal"; }

log "📦 Adding AnyDesk repository - Preparing the launch pad!" "${CYAN}"
echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list || { error "Failed to add AnyDesk repository" "fatal"; }

# Step 3: Install AnyDesk
log "🔄 Updating package list - Synchronizing with the cosmos!" "${CYAN}"
apt update || { error "Failed to update package list"; }

log "📥 Installing AnyDesk - The moment we've been waiting for!" "${CYAN}"
show_progress "Downloading and installing AnyDesk"
apt install -y anydesk || { error "Failed to install AnyDesk" "fatal"; }
success "AnyDesk installed successfully! 🎉"

# Step 4: Configure Xorg with dummy display - IMPROVED CONFIGURATION
log "🖥️ Setting up dummy display driver - Creating a virtual window to the world!" "${PURPLE}"
show_progress "Creating the most robust Xorg configuration"

# This is a much more comprehensive configuration specifically for AnyDesk headless use
cat > /etc/X11/xorg.conf << 'EOF'
Section "ServerLayout"
    Identifier "Layout0"
    Screen 0 "Screen0" 0 0
    InputDevice "Keyboard0" "CoreKeyboard"
    InputDevice "Mouse0" "CorePointer"
    Option "AutoAddDevices" "true"
    Option "AutoAddGPU" "false"
EndSection

Section "Files"
    ModulePath "/usr/lib/xorg/modules"
    FontPath "/usr/share/fonts/X11/misc"
    FontPath "/usr/share/fonts/X11/Type1"
    FontPath "/usr/share/fonts/X11/100dpi"
    FontPath "/usr/share/fonts/X11/75dpi"
EndSection

Section "Module"
    Load "glx"
EndSection

Section "InputDevice"
    Identifier "Keyboard0"
    Driver "kbd"
    Option "XkbLayout" "us"
    Option "XkbModel" "pc105"
EndSection

Section "InputDevice"
    Identifier "Mouse0"
    Driver "mouse"
    Option "Protocol" "auto"
    Option "Device" "/dev/input/mice"
    Option "ZAxisMapping" "4 5 6 7"
EndSection

Section "Monitor"
    Identifier "Monitor0"
    HorizSync 28.0-80.0
    VertRefresh 48.0-75.0
    Option "DPMS" "true"
    Modeline "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -HSync +Vsync
EndSection

Section "Device"
    Identifier "Card0"
    Driver "dummy"
    VideoRam 256000
    Option "IgnoreEDID" "true"
    Option "NoDDC" "true"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "Card0"
    Monitor "Monitor0"
    DefaultDepth 24
    Option "AllowEmptyInitialConfiguration" "true"
    SubSection "Display"
        Viewport 0 0
        Depth 24
        Virtual 1920 1080
        Modes "1920x1080_60.00" "1280x1024" "1024x768"
    EndSubSection
EndSection
EOF

success "Super-robust dummy display configuration installed! Your server now thinks it has a fancy 1080p monitor! 🎮"

# Step 5: Create autologin user configuration for LightDM
log "🔐 Configuring automatic login for AnyDesk - Making sure we have a full session!" "${BLUE}"

# Get current username if running with sudo
if [ -n "$SUDO_USER" ]; then
    CURRENT_USER="$SUDO_USER"
else
    CURRENT_USER="$(whoami)"
    if [ "$CURRENT_USER" = "root" ]; then
        # If we're root but not via sudo, prompt for a username
        read -p "Enter the username for automatic login: " CURRENT_USER
    fi
fi

# Configure LightDM for autologin
mkdir -p /etc/lightdm/lightdm.conf.d/
cat > /etc/lightdm/lightdm.conf.d/50-myconfig.conf << EOF
[SeatDefaults]
autologin-user=$CURRENT_USER
autologin-user-timeout=0
user-session=ubuntu
greeter-session=unity-greeter
xserver-command=X -core
EOF

# Ensure LightDM uses Xorg not Wayland
if [ -f /etc/gdm3/custom.conf ]; then
    log "📝 Configuring GDM3 to use Xorg instead of Wayland" "${CYAN}"
    sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
fi

# Step 6: Create systemd service for AnyDesk
log "⚙️ Creating systemd service for AnyDesk - Building the eternal guardian!" "${CYAN}"
cat > /etc/systemd/system/anydesk-service.service << 'EOF'
[Unit]
Description=AnyDesk Service
After=network-online.target lightdm.service
Wants=network-online.target
Requires=lightdm.service

[Service]
Type=simple
ExecStart=/usr/bin/anydesk --service
Restart=always
RestartSec=10
User=root
Environment=DISPLAY=:0

[Install]
WantedBy=multi-user.target
EOF

# Step 7: Enable and start the services
log "🚦 Enabling and starting LightDM - Powering up the visual matrix!" "${CYAN}"
systemctl daemon-reload
systemctl enable lightdm.service || { error "Failed to enable LightDM service"; }

log "🚦 Enabling and starting AnyDesk service - Igniting the engines!" "${CYAN}"
systemctl enable anydesk-service.service || { error "Failed to enable AnyDesk service"; }

# Step 8: Setting up unattended access password
log "🔐 Setting up unattended access - Granting the keys to your kingdom!" "${PURPLE}"
echo -e "${YELLOW}Enter a secure password for unattended access (min 8 characters):${RESET}"
read -s PASSWORD
echo

if [ ${#PASSWORD} -lt 8 ]; then
    error "Password must be at least 8 characters long" "fatal"
fi

# Create password file for future use with expect script
cat > /tmp/anydesk_password.txt << EOF
$PASSWORD
$PASSWORD
EOF

# Step 9: Open firewall ports (if UFW is enabled)
if command -v ufw &> /dev/null && ufw status | grep -q "active"; then
    log "🔥 Configuring firewall for AnyDesk - Opening the gates for remote access!" "${CYAN}"
    ufw allow 7070/tcp comment "AnyDesk" || error "Failed to allow TCP port 7070"
    ufw allow 7070/udp comment "AnyDesk" || error "Failed to allow UDP port 7070"
    success "Firewall rules added for AnyDesk! The gates are open!"
else
    log "No UFW firewall detected, skipping configuration" "${YELLOW}"
fi

# Step 10: Final preparation steps and notify about reboot
log "🧪 Preparing for system reboot - Almost there!" "${BLUE}"

# Create a startup script to set the password after reboot
cat > /usr/local/bin/anydesk-setup-password.sh << EOF
#!/bin/bash
# Wait for AnyDesk to start properly
sleep 30

# Set the AnyDesk password
export DISPLAY=:0
cat /tmp/anydesk_password.txt | anydesk --set-password

# Clean up the password file
rm -f /tmp/anydesk_password.txt

# Get the AnyDesk ID for logging
ANYDESK_ID=\$(anydesk --get-id)
echo "\$(date): AnyDesk configured with ID \$ANYDESK_ID" >> /var/log/anydesk_setup.log
EOF

chmod +x /usr/local/bin/anydesk-setup-password.sh

# Create a systemd service to run the password setup on boot
cat > /etc/systemd/system/anydesk-setup-password.service << 'EOF'
[Unit]
Description=AnyDesk Password Setup
After=anydesk-service.service lightdm.service
Requires=anydesk-service.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/anydesk-setup-password.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the password setup service
systemctl enable anydesk-setup-password.service

# Final instructions with pizzazz
echo
echo -e "${PURPLE}=================================================${RESET}"
show_final_banner
echo -e "${PURPLE}=================================================${RESET}"
echo
log "🎉 Configuration complete! A system reboot is REQUIRED!" "${GREEN}"
echo
echo -e "${YELLOW}=========== IMPORTANT POST-INSTALL STEPS ===========${RESET}"
echo -e "${CYAN}1. Your system needs to be rebooted to activate the changes${RESET}"
echo -e "${CYAN}2. After reboot, AnyDesk will start automatically${RESET}"
echo -e "${CYAN}3. Your password will be applied automatically after boot${RESET}"
echo -e "${CYAN}4. Check status with: systemctl status anydesk-service${RESET}"
echo -e "${YELLOW}=================================================${RESET}"
echo
log "📊 To get your AnyDesk ID after reboot: ${WHITE}anydesk --get-id${RESET}" "${BLUE}"
log "📝 AnyDesk logs are in: ${WHITE}~/.anydesk/anydesk.trace${RESET}" "${BLUE}"
log "❓ For more help, visit: ${WHITE}https://support.anydesk.com${RESET}" "${BLUE}"
echo
rainbow_text "✨ Thanks for using the SUPER AWESOME ANYDESK HEADLESS INSTALLER! ✨"
echo -e "${RED}${BOLD}SYSTEM REBOOT REQUIRED!${RESET} Type 'sudo reboot' to finish installation!"
echo -e "${GREEN}Happy remote accessing! 👋${RESET}"
