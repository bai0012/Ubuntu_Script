#!/bin/bash

#===============================================================================================
#   脚本: Ubuntu/Debian 初始化一键脚本
#   作者: bai0012
#   更新日期: 2025-10-02
#===============================================================================================

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root. Please use 'sudo bash'.${NC}"
    echo -e "${RED}错误：此脚本需要以root权限运行。请使用 'sudo bash'。${NC}"
    exit 1
fi

# 语言选择
select_language() {
    echo -e "${YELLOW}Please select a language / 请选择语言:${NC}"
    echo -e "${GREEN}1. English${NC}"
    echo -e "${GREEN}2. 中文 (Chinese)${NC}"
    read -rp "Enter your choice [1-2]: " lang_choice

    case $lang_choice in
        1)
            LANG="en"
            ;;
        2)
            LANG="zh"
            ;;
        *)
            echo -e "${RED}Invalid input, defaulting to English.${NC}"
            LANG="en"
            ;;
    esac
}

# 调用语言选择函数
select_language

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    OS_ID="unknown"
fi


# 定义文本变量
# --- English ---
if [ "$LANG" = "en" ]; then
    PAUSE_MSG="Task completed. Press [Enter] to return to the main menu..."
    # Menu Titles
    MENU_TITLE="Ubuntu/Debian Quick Setup Script (v4.3)"
    MENU_SECTION_SYSTEM="--------- System & SSH ---------"
    MENU_SECTION_PANEL="-------- Panel & Proxy ---------"
    MENU_SECTION_NETWORK="------- Network & Security -------"
    MENU_SECTION_OTHERS="------- Other Scripts (Use with caution) -------"
    # Menu Options
    MENU_OPT_1="Change APT mirror to a Chinese source"
    MENU_OPT_2="Update and clean system"
    MENU_OPT_3="Install common tools & Enable auto-updates"
    MENU_TIPS_3_1="Installing unattended-upgrades..."
    MENU_TIPS_3_2="Enabling automatic security updates..."
    MENU_TIPS_3_3="Unattended-upgrades enabled."
    MENU_OPT_4="Install Docker and Docker-Compose"
    MENU_TIPS_4_1="Detected OS:"
    MENU_TIPS_4_2="Starting Docker installation..."
    MENU_TIPS_4_3="Unsupported OS. This script only supports automatic Docker installation on Ubuntu and Debian."
    MENU_TIPS_4_4="Could not determine OS distribution."
    MENU_OPT_5="Install XRDP (Remote Desktop)"
    MENU_OPT_6="Install SSH server & configure public key (github.com/bai0012)"
    MENU_TIPS_6="Installing SSH Server..."
    MENU_TIPS_6_2="Configuring SSH public key..."
    MENU_TIPS_6_3="SSH public key has been installed to"
    MENU_OPT_7="Change SSH port to 8847 (Sync with Fail2ban)"
    MENU_TIPS_7="Changing SSH port to"
    MENU_TIPS_7_2="SSH port has been changed. Restarting SSH service..."
    MENU_TIPS_7_3="Fail2ban detected, syncing port..."
    MENU_TIPS_7_4="Fail2ban port has been changed. Restarting Fail2ban service..."
    MENU_OPT_8="Change timezone to Asia/Shanghai"
    MENU_TIPS_8="Changing timezone to Asia/Shanghai..."
    MENU_TIPS_8_2="Timezone updated. Current time:"
    MENU_OPT_9="Enable Ubuntu Pro"
    MENU_TIPS_9_1="Please enter your Ubuntu Pro token"
    MENU_TIPS_9_2="Default token (please replace)"
    MENU_TIPS_9_3="Attaching Ubuntu Pro subscription..."
    MENU_TIPS_9_4="Ubuntu Pro status:"
    MENU_TIPS_9_5="This feature is only available on Ubuntu."
    MENU_OPT_10="Install 1Panel"
    MENU_OPT_11="Install X-ui"
    MENU_OPT_12="Install V2rayA"
    MENU_OPT_13="Install ZeroTier"
    MENU_TIPS_13="Please enter the ZeroTier Network ID to join"
    MENU_TIPS_13_2="Default"
    MENU_OPT_14="Install Fail2ban"
    MENU_OPT_15="Install Chinese language support"
    MENU_OPT_16="Install AdGuard Home"
    MENU_OPT_17="Configure AdGuard Home to use port 53"
    MENU_TIPS_17_1="systemd-resolved service is not active. Skipping configuration."
    MENU_OPT_18="kernel.sh"
    MENU_OPT_19="oneclick.sh"
    MENU_OPT_0="Exit Script"
    # General Messages
    INVALID_INPUT="Invalid input, please enter a number between"
fi

# --- 中文 ---
if [ "$LANG" = "zh" ]; then
    PAUSE_MSG="任务完成。请按 [Enter] 键返回主菜单..."
    # Menu Titles
    MENU_TITLE="Ubuntu/Debian 初始化一键脚本 (v4.3)"
    MENU_SECTION_SYSTEM="-------------------------- 系统与SSH -------------------------"
    MENU_SECTION_PANEL="------------------------- 面板与代理 -------------------------"
    MENU_SECTION_NETWORK="------------------------- 网络与安全 -------------------------"
    MENU_SECTION_OTHERS="---------------------- 其他一键脚本(谨慎) --------------------"
    # Menu Options
    MENU_OPT_1="一键更换系统软件源"
    MENU_OPT_2="系统更新与清理"
    MENU_OPT_3="安装常用工具并启用自动更新"
    MENU_TIPS_3_1="正在安装 unattended-upgrades..."
    MENU_TIPS_3_2="正在启用自动安全更新..."
    MENU_TIPS_3_3="unattended-upgrades 已启用。"
    MENU_OPT_4="安装 Docker 和 Docker-Compose"
    MENU_TIPS_4_1="检测到操作系统为:"
    MENU_TIPS_4_2="开始安装 Docker..."
    MENU_TIPS_4_3="不支持的操作系统。此脚本仅支持在 Ubuntu 和 Debian 上自动安装 Docker。"
    MENU_TIPS_4_4="无法确定操作系统发行版。"
    MENU_OPT_5="安装 XRDP (远程桌面)"
    MENU_OPT_6="安装SSH服务并配置公钥 (github.com/bai0012)"
    MENU_TIPS_6="正在安装 OpenSSH 服务器..."
    MENU_TIPS_6_2="正在配置SSH公钥..."
    MENU_TIPS_6_3="SSH公钥已安装到"
    MENU_OPT_7="修改SSH端口为 8847 (联动Fail2ban)"
    MENU_TIPS_7="正在修改SSH端口为"
    MENU_TIPS_7_2="SSH端口已修改。正在重启SSH服务..."
    MENU_TIPS_7_3="检测到Fail2ban，正在同步修改监听端口..."
    MENU_TIPS_7_4="Fail2ban端口已修改。正在重启Fail2ban服务..."
    MENU_OPT_8="修改时区为 Asia/Shanghai"
    MENU_TIPS_8="正在修改时区为 Asia/Shanghai..."
    MENU_TIPS_8_2="时区已更新。当前时间:"
    MENU_OPT_9="启用 Ubuntu Pro"
    MENU_TIPS_9_1="请输入您的 Ubuntu Pro Token"
    MENU_TIPS_9_2="默认Token(请替换)"
    MENU_TIPS_9_3="正在附加 Ubuntu Pro 订阅..."
    MENU_TIPS_9_4="Ubuntu Pro 状态:"
    MENU_TIPS_9_5="此功能仅在 Ubuntu 系统上可用。"
    MENU_OPT_10="安装 1Panel"
    MENU_OPT_11="安装 X-ui"
    MENU_OPT_12="安装 V2rayA"
    MENU_OPT_13="安装 ZeroTier"
    MENU_TIPS_13="请输入您要加入的 ZeroTier 网络 ID"
    MENU_TIPS_13_2="默认"
    MENU_OPT_14="安装 Fail2ban"
    MENU_OPT_15="安装中文语言支持"
    MENU_OPT_16="安装 AdGuard Home"
    MENU_OPT_17="配置 AdGuard Home 使用53端口"
    MENU_TIPS_17_1="systemd-resolved 服务未运行，跳过配置。"
    MENU_OPT_18="kernel.sh"
    MENU_OPT_19="oneclick.sh"
    MENU_OPT_0="退出脚本"
    # General Messages
    INVALID_INPUT="无效的输入，请输入 0 到 19 之间的数字。"
fi


# 暂停并等待用户按回车继续
function pause() {
    read -rp "${PAUSE_MSG}"
}

# 功能函数区
function change_apt_source() {
    bash <(curl -sSL https://linuxmirrors.cn/main.sh)
    pause
}

function update_system() {
    apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y
    pause
}

function install_common_tools() {
    apt-get update
    apt-get install curl neofetch unzip git nano net-tools tasksel screen nethogs -y

    # 安装并启用 unattended-upgrades
    echo -e "${YELLOW}${MENU_TIPS_3_1}${NC}"
    apt-get install -y unattended-upgrades
    
    echo -e "${YELLOW}${MENU_TIPS_3_2}${NC}"
    # 以非交互方式创建配置文件以启用自动更新
    cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
    # 启用自动清理未使用的依赖项
    sed -i 's|//Unattended-Upgrade::Remove-Unused-Dependencies "false";|Unattended-Upgrade::Remove-Unused-Dependencies "true";|' /etc/apt/apt.conf.d/50unattended-upgrades
    echo -e "${GREEN}${MENU_TIPS_3_3}${NC}"
    pause
}

function install_docker() {
    if [ "$OS_ID" = "unknown" ]; then
        echo -e "${RED}${MENU_TIPS_4_4}${NC}"
        pause
        return 1
    fi

    local docker_dist=""
    if [ "$OS_ID" = "ubuntu" ]; then
        docker_dist="ubuntu"
        echo -e "${GREEN}${MENU_TIPS_4_1} Ubuntu. ${MENU_TIPS_4_2}${NC}"
    elif [ "$OS_ID" = "debian" ]; then
        docker_dist="debian"
        echo -e "${GREEN}${MENU_TIPS_4_1} Debian. ${MENU_TIPS_4_2}${NC}"
    else
        echo -e "${RED}${MENU_TIPS_4_3}${NC}"
        pause
        return 1
    fi
    
    # 安装 Docker
    apt-get update && apt-get install ca-certificates curl -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/${docker_dist}/gpg" -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    
    # 注意: ${UBUNTU_CODENAME:-$VERSION_CODENAME} 这个表达式能同时兼容Ubuntu和Debian
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${docker_dist} $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl status docker --no-pager
    pause
}

function install_xrdp() {
    apt-get update && apt-get install xrdp -y
    adduser xrdp ssl-cert
    systemctl restart xrdp
    systemctl status xrdp --no-pager
    pause
}

function setup_ssh_key() {
    if ! dpkg -l | grep -q "openssh-server"; then
        echo -e "${YELLOW}${MENU_TIPS_6}${NC}"
        apt-get update && apt-get install openssh-server -y
    fi
    local ssh_dir="/root/.ssh"
    local auth_keys_file="${ssh_dir}/authorized_keys"
    echo -e "${YELLOW}${MENU_TIPS_6_2}${NC}"
    mkdir -p "${ssh_dir}" && chmod 700 "${ssh_dir}"
    touch "${auth_keys_file}" && chmod 600 "${auth_keys_file}"
    curl -sSL http://github.com/bai0012.keys >> "${auth_keys_file}"
    sort -u "${auth_keys_file}" -o "${auth_keys_file}"
    echo -e "${GREEN}${MENU_TIPS_6_3} ${auth_keys_file}${NC}"
    pause
}

function change_ssh_port() {
    local new_port=8847
    local ssh_config="/etc/ssh/sshd_config"
    echo -e "${YELLOW}${MENU_TIPS_7} ${new_port}...${NC}"
    cp "${ssh_config}" "${ssh_config}.bak"
    sed -i "s/^#*Port [0-9]*/Port ${new_port}/" "${ssh_config}"
    echo -e "${GREEN}${MENU_TIPS_7_2}${NC}"
    systemctl restart sshd
    local jail_local="/etc/fail2ban/jail.local"
    if [ -f "${jail_local}" ]; then
        echo -e "${YELLOW}${MENU_TIPS_7_3}${NC}"
        if grep -q "\[sshd\]" "${jail_local}"; then
            sed -i "/\[sshd\]/,/\[/ s/^port\s*=.*/port = ${new_port}/" "${jail_local}"
        else
            echo -e "\n[sshd]\nenabled = true\nport = ${new_port}" >> "${jail_local}"
        fi
        echo -e "${GREEN}${MENU_TIPS_7_4}${NC}"
        systemctl restart fail2ban
    fi
    pause
}

function set_timezone_shanghai() {
    echo -e "${YELLOW}${MENU_TIPS_8}${NC}"
    timedatectl set-timezone Asia/Shanghai
    echo -e "${GREEN}${MENU_TIPS_8_2} $(date)${NC}"
    pause
}

function enable_ubuntu_pro() {
    # 检查是否为 Ubuntu 系统
    if [ "$OS_ID" != "ubuntu" ]; then
        echo -e "${RED}${MENU_TIPS_9_5}${NC}"
        pause
        return
    fi

    # 检查 ubuntu-advantage-tools 是否已安装
    if ! dpkg -l | grep -q "ubuntu-advantage-tools"; then
        echo "Installing ubuntu-advantage-tools..."
        apt-get update
        apt-get install ubuntu-advantage-tools -y
    fi

    local default_token="xxxxxxxx"
    read -rp "${MENU_TIPS_9_1} [${MENU_TIPS_9_2}: ${default_token}]: " pro_token
    pro_token=${pro_token:-"${default_token}"}
    
    echo -e "${YELLOW}${MENU_TIPS_9_3}${NC}"
    pro attach "${pro_token}"
    
    echo -e "${GREEN}${MENU_TIPS_9_4}${NC}"
    pro status
    pause
}


function install_1panel() {
    curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh
    pause
}

function install_xui() {
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    pause
}

function install_v2raya() {
    wget -qO - https://apt.v2raya.org/key/public-key.asc | tee /etc/apt/keyrings/v2raya.asc
    echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | tee /etc/apt/sources.list.d/v2raya.list
    apt-get update && apt-get install v2raya xray -y
    systemctl start v2raya.service && systemctl enable v2raya.service
    pause
}

function install_zerotier() {
    curl -s https://install.zerotier.com | bash
    read -rp "${MENU_TIPS_13} [${MENU_TIPS_13_2}: 5756c68f8fb92cfd]: " network_id
    network_id=${network_id:-"5756c68f8fb92cfd"}
    zerotier-cli join "${network_id}"
    pause
}

function install_fail2ban() {
    apt-get update && apt-get install fail2ban -y
    if [ ! -f /etc/fail2ban/jail.local ]; then
        cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    fi
    systemctl restart fail2ban
    pause
}

function install_chinese_support() {
    apt-get install locales -y
    dpkg-reconfigure locales
    apt-get install ttf-wqy-microhei ttf-wqy-zenhei xfonts-intl-chinese -y
    pause
}

function install_adguard_home() {
    curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
    pause
}

function configure_adguard_port53() {
    # 检查 systemd-resolved 服务是否在运行
    if ! systemctl is-active --quiet systemd-resolved; then
        echo -e "${YELLOW}${MENU_TIPS_17_1}${NC}"
        pause
        return
    fi

    CONF_FILE="/etc/systemd/resolved.conf.d/adguardhome.conf"
    mkdir -p "$(dirname "${CONF_FILE}")"
    echo -e "[Resolve]\nDNS=127.0.0.1\nDNSStubListener=no" > "${CONF_FILE}"
    if [ -L /etc/resolv.conf ]; then
        ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    fi
    systemctl reload-or-restart systemd-resolved
    pause
}

function bbr_kernel_script() {
    bash <(curl -Lso- https://git.io/kernel.sh)
    pause
}

function oneclick_script() {
    bash <(curl -Lso- https://git.io/oneclick)
    pause
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo -e "${YELLOW}================================================================${NC}"
        echo -e "${GREEN}                  ${MENU_TITLE}                  ${NC}"
        echo -e "${YELLOW}================================================================${NC}"
        echo -e " ${GREEN}1.${NC}  ${MENU_OPT_1}"
        echo -e " ${GREEN}2.${NC}  ${MENU_OPT_2}"
        echo -e " ${GREEN}3.${NC}  ${MENU_OPT_3}"
        echo -e " ${GREEN}4.${NC}  ${MENU_OPT_4}"
        echo -e " ${GREEN}5.${NC}  ${MENU_OPT_5}"
        echo -e "${YELLOW}${MENU_SECTION_SYSTEM}${NC}"
        echo -e " ${GREEN}6.${NC}  ${MENU_OPT_6}"
        echo -e " ${GREEN}7.${NC}  ${MENU_OPT_7}"
        echo -e " ${GREEN}8.${NC}  ${MENU_OPT_8}"
        echo -e " ${GREEN}9.${NC}  ${MENU_OPT_9}"
        echo -e "${YELLOW}${MENU_SECTION_PANEL}${NC}"
        echo -e " ${GREEN}10.${NC} ${MENU_OPT_10}"
        echo -e " ${GREEN}11.${NC} ${MENU_OPT_11}"
        echo -e " ${GREEN}12.${NC} ${MENU_OPT_12}"
        echo -e "${YELLOW}${MENU_SECTION_NETWORK}${NC}"
        echo -e " ${GREEN}13.${NC} ${MENU_OPT_13}"
        echo -e " ${GREEN}14.${NC} ${MENU_OPT_14}"
        echo -e " ${GREEN}15.${NC} ${MENU_OPT_15}"
        echo -e " ${GREEN}16.${NC} ${MENU_OPT_16}"
        echo -e " ${GREEN}17.${NC} ${MENU_OPT_17}"
        echo -e "${YELLOW}${MENU_SECTION_OTHERS}${NC}"
        echo -e " ${GREEN}18.${NC} ${MENU_OPT_18}"
        echo -e " ${GREEN}19.${NC} ${MENU_OPT_19}"
        echo -e "${YELLOW}================================================================${NC}"
        echo -e " ${RED}0.${NC}  ${MENU_OPT_0}"
        echo -e "${YELLOW}================================================================${NC}"
        
        read -rp "Your choice [0-19]: " choice

        case $choice in
            1) change_apt_source ;;
            2) update_system ;;
            3) install_common_tools ;;
            4) install_docker ;;
            5) install_xrdp ;;
            6) setup_ssh_key ;;
            7) change_ssh_port ;;
            8) set_timezone_shanghai ;;
            9) enable_ubuntu_pro ;;
            10) install_1panel ;;
            11) install_xui ;;
            12) install_v2raya ;;
            13) install_zerotier ;;
            14) install_fail2ban ;;
            15) install_chinese_support ;;
            16) install_adguard_home ;;
            17) configure_adguard_port53 ;;
            18) bbr_kernel_script ;;
            19) oneclick_script ;;
            0)
                exit 0
                ;;
            *)
                echo -e "\n${RED}${INVALID_INPUT} 0-19.${NC}"
                sleep 1
                ;;
        esac
    done
}

# 脚本入口
main_menu

