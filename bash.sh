#!/bin/bash

#===============================================================================================
#   脚本: Ubuntu 初始化一键脚本
#   描述: 用于快速完成新安装Ubuntu系统后的软件安装与环境配置。
#   作者: bai0012
#   更新日期: 2025-08-02
#===============================================================================================

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}错误：此脚本需要以root权限运行。${NC}"
    echo -e "${YELLOW}请尝试使用 'sudo bash ${0}' 来运行此脚本。${NC}"
    exit 1
fi

# 暂停并等待用户按回车继续
function pause() {
    read -rp "任务完成。请按 [Enter] 键返回主菜单..."
}

# 1. 一键换源
function change_apt_source() {
    echo -e "\n${GREEN}==> [1] 开始执行：一键更换系统软件源...${NC}"
    echo -e "${YELLOW}将使用 'linuxmirrors.cn' 的脚本进行操作。${NC}"
    bash <(curl -sSL https://linuxmirrors.cn/main.sh)
    echo -e "\n${GREEN}==> 换源脚本执行完毕。建议立即执行一次系统更新。${NC}"
    pause
}

# 2. 系统更新与清理
function update_system() {
    echo -e "\n${GREEN}==> [2] 开始执行：全面更新系统并清理...${NC}"
    apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y
    echo -e "\n${GREEN}==> 系统更新与清理完成。${NC}"
    pause
}

# 3. 安装常用工具
function install_common_tools() {
    echo -e "\n${GREEN}==> [3] 开始执行：安装常用工具 (curl, neofetch, unzip, git...)${NC}"
    apt-get update && apt-get upgrade -y
    apt-get install curl neofetch unzip git nano net-tools tasksel screen nethogs -y
    apt-get autoremove -y
    echo -e "\n${GREEN}==> 常用工具安装完成。${NC}"
    pause
}

# 4. 安装 Docker
function install_docker() {
    echo -e "\n${GREEN}==> [4] 开始执行：安装 Docker Engine 和 Docker Compose...${NC}"
    # 卸载旧版本
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done

    echo -e "${YELLOW}正在安装依赖并设置 Docker GPG 密钥...${NC}"
    apt-get update
    apt-get install ca-certificates curl -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo -e "${YELLOW}正在将 Docker 软件源添加到 Apt sources...${NC}"
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    echo -e "${YELLOW}正在更新软件包列表并安装 Docker...${NC}"
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    
    echo -e "\n${GREEN}==> Docker 安装完成。正在检查运行状态...${NC}"
    systemctl status docker --no-pager
    docker --version
    pause
}

# 5. 安装 XRDP
function install_xrdp() {
    echo -e "\n${GREEN}==> [5] 开始执行：安装 XRDP 远程桌面服务...${NC}"
    apt-get update
    apt-get install xrdp -y
    # Ubuntu 22.04及以上版本，xrdp用户需要加入 'ssl-cert' 组
    adduser xrdp ssl-cert
    systemctl restart xrdp
    echo -e "\n${GREEN}==> XRDP 安装并启动成功。${NC}"
    systemctl status xrdp --no-pager
    pause
}

# 6. 安装 1Panel
function install_1panel() {
    echo -e "\n${GREEN}==> [6] 开始执行：安装 1Panel...${NC}"
    curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh
    echo -e "\n${GREEN}==> 1Panel 安装脚本执行完毕。${NC}"
    pause
}

# 7. 安装 X-ui
function install_xui() {
    echo -e "\n${GREEN}==> [7] 开始执行：安装 X-ui...${NC}"
    bash <(curl -Ls https://raw.githubusercontent.com/MHSanaei/3x-ui/refs/tags/v2.6.0/install.sh)
    echo -e "\n${GREEN}==> X-ui 安装脚本执行完毕。${NC}"
    pause
}

# 8. 安装 V2rayA
function install_v2raya() {
    echo -e "\n${GREEN}==> [8] 开始执行：安装 V2rayA...${NC}"
    wget -qO - https://apt.v2raya.org/key/public-key.asc | tee /etc/apt/keyrings/v2raya.asc
    echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | tee /etc/apt/sources.list.d/v2raya.list
    apt-get update && apt-get install v2raya xray -y
    systemctl start v2raya.service && systemctl enable v2raya.service
    echo -e "\n${GREEN}==> V2rayA 安装并启动成功。${NC}"
    systemctl status v2raya.service --no-pager
    pause
}

# 9. 安装并加入 ZeroTier
function install_zerotier() {
    echo -e "\n${GREEN}==> [9] 开始执行：安装 ZeroTier...${NC}"
    curl -s https://install.zerotier.com | bash
    echo -e "\n${GREEN}==> ZeroTier 安装完成。${NC}"
    read -rp "请输入您要加入的 ZeroTier 网络 ID [默认: 5756c68f8fb92cfd]: " network_id
    network_id=${network_id:-"5756c68f8fb92cfd"}
    zerotier-cli join "${network_id}"
    echo -e "\n${GREEN}==> ZeroTier 配置完成。${NC}"
    pause
}

# 10. 安装 Fail2ban
function install_fail2ban() {
    echo -e "\n${GREEN}==> [10] 开始执行：安装 Fail2ban...${NC}"
    apt-get update && apt-get install fail2ban -y
    systemctl restart fail2ban.service
    echo -e "\n${GREEN}==> Fail2ban 安装并启动成功。${NC}"
    systemctl status fail2ban.service --no-pager
    pause
}

# 11. 安装中文语言支持
function install_chinese_support() {
    echo -e "\n${GREEN}==> [11] 开始执行：安装中文语言包和字体...${NC}"
    apt-get install locales -y
    echo -e "\n${YELLOW}接下来会进入图形化配置界面，请进行如下操作：${NC}"
    echo -e "1. 使用方向键找到并选中 ${GREEN}en_US.UTF-8 UTF-8${NC} 和 ${GREEN}zh_CN.UTF-8 UTF-8${NC} (按空格键选中)"
    echo -e "2. 按 Tab 键切换到 <Ok>，然后按 Enter 确认。"
    echo -e "3. 在下一个界面中，选择 ${GREEN}zh_CN.UTF-8${NC} 作为默认语言环境，然后按 Enter 确认。"
    read -rp "理解后请按 [Enter] 键开始配置..."
    dpkg-reconfigure locales
    echo -e "\n${YELLOW}正在安装中文字体...${NC}"
    apt-get install ttf-wqy-microhei ttf-wqy-zenhei xfonts-intl-chinese -y
    echo -e "\n${GREEN}==> 中文语言支持安装完成。建议重启系统以使所有设置生效。${NC}"
    pause
}

# 12. 安装 AdGuard Home
function install_adguard_home() {
    echo -e "\n${GREEN}==> [12] 开始执行：安装 AdGuard Home...${NC}"
    curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
    echo -e "\n${GREEN}==> AdGuard Home 安装脚本执行完毕。${NC}"
    pause
}

# 13. 配置 AdGuard Home 使用53端口
function configure_adguard_port53() {
    echo -e "\n${GREEN}==> [13] 开始执行：配置 systemd-resolved 以释放53端口...${NC}"
    CONF_FILE="/etc/systemd/resolved.conf.d/adguardhome.conf"
    mkdir -p "$(dirname "${CONF_FILE}")"
    cat <<EOF > "${CONF_FILE}"
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
EOF
    if [ -L /etc/resolv.conf ] && [ "$(readlink -f /etc/resolv.conf)" = "/run/systemd/resolve/stub-resolv.conf" ]; then
        mv /etc/resolv.conf /etc/resolv.conf.backup
        ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    fi
    systemctl reload-or-restart systemd-resolved
    echo -e "\n${GREEN}==> 端口53配置完成！现在 AdGuard Home 应该可以使用53端口了。${NC}"
    pause
}

# 14. BBR/锐速等内核优化脚本
function bbr_kernel_script() {
    echo -e "\n${GREEN}==> [14] 开始执行：BBR/锐速等内核优化脚本...${NC}"
    echo -e "${YELLOW}该脚本会更改系统内核，请谨慎操作！${NC}"
    bash <(curl -Lso- https://git.io/kernel.sh)
    echo -e "\n${GREEN}==> 内核优化脚本执行完毕。${NC}"
    pause
}

# 15. 另一个一键脚本
function oneclick_script() {
    echo -e "\n${GREEN}==> [15] 开始执行：另一个一键脚本 (oneclick)...${NC}"
    bash <(curl -Lso- https://git.io/oneclick)
    echo -e "\n${GREEN}==> oneclick 脚本执行完毕。${NC}"
    pause
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo -e "${YELLOW}================================================================${NC}"
        echo -e "${GREEN}             Ubuntu 初始化一键脚本 (v2.0)              ${NC}"
        echo -e "${YELLOW}================================================================${NC}"
        echo -e " ${GREEN}1.${NC}  一键更换系统软件源 (推荐优先执行)"
        echo -e " ${GREEN}2.${NC}  系统更新与清理 (apt update && upgrade)"
        echo -e " ${GREEN}3.${NC}  安装常用工具 (curl, neofetch, git, etc.)"
        echo -e " ${GREEN}4.${NC}  安装 Docker 和 Docker-Compose"
        echo -e " ${GREEN}5.${NC}  安装 XRDP (远程桌面)"
        echo -e "${YELLOW}------------------------- 面板与代理 -------------------------${NC}"
        echo -e " ${GREEN}6.${NC}  安装 1Panel (服务器运维管理面板)"
        echo -e " ${GREEN}7.${NC}  安装 X-ui (v2.6.0) (多功能代理面板)"
        echo -e " ${GREEN}8.${NC}  安装 V2rayA (V2Ray 客户端)"
        echo -e "${YELLOW}------------------------- 系统与网络 -------------------------${NC}"
        echo -e " ${GREEN}9.${NC}  安装 ZeroTier (虚拟局域网)"
        echo -e " ${GREEN}10.${NC} 安装 Fail2ban (防暴力破解)"
        echo -e " ${GREEN}11.${NC} 安装中文语言支持及字体"
        echo -e " ${GREEN}12.${NC} 安装 AdGuard Home (广告拦截)"
        echo -e " ${GREEN}13.${NC} 配置 AdGuard Home 使用53端口"
        echo -e "${YELLOW}---------------------- 其他一键脚本(谨慎) --------------------${NC}"
        echo -e " ${GREEN}14.${NC} BBR/锐速等内核优化脚本"
        echo -e " ${GREEN}15.${NC} 另一个一键脚本 (oneclick)"
        echo -e "${YELLOW}================================================================${NC}"
        echo -e " ${RED}0.${NC}  退出脚本"
        echo -e "${YELLOW}================================================================${NC}"
        
        read -rp "请输入您的选择 [0-15]: " choice

        case $choice in
            1) change_apt_source ;;
            2) update_system ;;
            3) install_common_tools ;;
            4) install_docker ;;
            5) install_xrdp ;;
            6) install_1panel ;;
            7) install_xui ;;
            8) install_v2raya ;;
            9) install_zerotier ;;
            10) install_fail2ban ;;
            11) install_chinese_support ;;
            12) install_adguard_home ;;
            13) configure_adguard_port53 ;;
            14) bbr_kernel_script ;;
            15) oneclick_script ;;
            0)
                echo -e "\n${GREEN}感谢使用，脚本已退出。${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}无效的输入，请输入 0 到 15 之间的数字。${NC}"
                sleep 2
                ;;
        esac
    done
}

# 脚本入口
main_menu
