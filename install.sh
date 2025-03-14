#!/bin/bash
# Script cài đặt cho Port Checker
# Author: errors <toanerror2000@gmail.com>

# Strict mode
set -eo pipefail

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Kiểm tra quyền root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}[!] Lỗi: Script này cần được chạy với quyền root${NC}"
        echo -e "${YELLOW}    Vui lòng chạy lại với sudo: sudo $0${NC}"
        exit 1
    fi
}

# Kiểm tra và cài đặt các gói phụ thuộc
install_dependencies() {
    echo -e "${BLUE}[*] Đang kiểm tra các gói phụ thuộc...${NC}"
    
    # Kiểm tra và cài đặt lsof nếu cần
    if ! command -v lsof &> /dev/null; then
        echo -e "${YELLOW}[!] lsof không được tìm thấy, đang cài đặt...${NC}"
        
        if command -v apt-get &> /dev/null; then
            apt-get update
            apt-get install -y lsof
        elif command -v yum &> /dev/null; then
            yum install -y lsof
        elif command -v dnf &> /dev/null; then
            dnf install -y lsof
        elif command -v pacman &> /dev/null; then
            pacman -S --noconfirm lsof
        else
            echo -e "${RED}[!] Lỗi: Không thể tự động cài đặt lsof.${NC}"
            echo -e "${YELLOW}    Vui lòng cài đặt lsof thủ công trước khi tiếp tục.${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}[✓] Tất cả các gói phụ thuộc đã được cài đặt${NC}"
}

# Cài đặt portcheck
install_portcheck() {
    echo -e "${BLUE}[*] Đang cài đặt Port Checker...${NC}"
    
    # Xác định đường dẫn hiện tại và các thư mục đích
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    BIN_DIR="/usr/local/bin"
    CONFIG_DIR="/etc/portcheck"
    DOC_DIR="/usr/share/doc/portcheck"
    MAN_DIR="/usr/share/man/man1"
    
    # Tạo các thư mục nếu chúng không tồn tại
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$DOC_DIR"
    mkdir -p "$MAN_DIR"
    
    # Copy script chính vào /usr/local/bin
    echo -e "${BLUE}[*] Đang cài đặt script chính...${NC}"
    cp "$SCRIPT_DIR/src/portcheck.sh" "$BIN_DIR/portcheck"
    chmod +x "$BIN_DIR/portcheck"
    
    # Copy file cấu hình
    echo -e "${BLUE}[*] Đang cài đặt file cấu hình...${NC}"
    if [ -f "$CONFIG_DIR/version.conf" ]; then
        echo -e "${YELLOW}[!] File cấu hình đã tồn tại, đang tạo bản sao lưu...${NC}"
        cp "$CONFIG_DIR/version.conf" "$CONFIG_DIR/version.conf.bak"
    fi
    cp "$SCRIPT_DIR/config/version.conf" "$CONFIG_DIR/version.conf"
    
    # Copy trang man nếu có
    echo -e "${BLUE}[*] Đang cài đặt trang man...${NC}"
    if [ -f "$SCRIPT_DIR/docs/portcheck.1" ]; then
        gzip -c "$SCRIPT_DIR/docs/portcheck.1" > "$MAN_DIR/portcheck.1.gz"
        echo -e "${GREEN}[✓] Đã cài đặt trang man${NC}"
    elif [ -f "$SCRIPT_DIR/build/portcheck.1.gz" ]; then
        cp "$SCRIPT_DIR/build/portcheck.1.gz" "$MAN_DIR/"
        echo -e "${GREEN}[✓] Đã cài đặt trang man${NC}"
    else
        echo -e "${YELLOW}[!] Không tìm thấy trang man, bỏ qua bước này${NC}"
    fi
    
    # Copy tài liệu
    echo -e "${BLUE}[*] Đang cài đặt tài liệu...${NC}"
    if [ -d "$SCRIPT_DIR/docs" ]; then
        for doc in "$SCRIPT_DIR/docs"/*.md; do
            if [ -f "$doc" ]; then
                cp "$doc" "$DOC_DIR/"
            fi
        done
    fi
    
    if [ -f "$SCRIPT_DIR/README.md" ]; then
        cp "$SCRIPT_DIR/README.md" "$DOC_DIR/"
    fi
    
    if [ -f "$SCRIPT_DIR/CHANGELOG.md" ]; then
        cp "$SCRIPT_DIR/CHANGELOG.md" "$DOC_DIR/"
    fi
    
    # Cập nhật cơ sở dữ liệu man
    if [ -f "$MAN_DIR/portcheck.1.gz" ] && command -v mandb &> /dev/null; then
        echo -e "${BLUE}[*] Đang cập nhật cơ sở dữ liệu man...${NC}"
        mandb -q
    fi
    
    echo -e "${GREEN}[✓] Cài đặt hoàn tất${NC}"
    echo -e "${GREEN}[✓] Bạn có thể chạy 'portcheck --help' để xem hướng dẫn sử dụng${NC}"
    
    if [ -f "$MAN_DIR/portcheck.1.gz" ]; then
        echo -e "${GREEN}[✓] Hoặc 'man portcheck' để xem trang hướng dẫn đầy đủ${NC}"
    fi
}

# Hàm main
main() {
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}       CÀI ĐẶT PORT CHECKER       ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    
    check_root
    install_dependencies
    install_portcheck
    
    echo -e "\n${GREEN}[✓] Port Checker đã được cài đặt thành công!${NC}"
}

main
