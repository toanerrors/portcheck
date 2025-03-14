#!/bin/bash
# Script gỡ cài đặt cho Port Checker
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

# Gỡ cài đặt portcheck
uninstall_portcheck() {
    echo -e "${BLUE}[*] Đang gỡ cài đặt Port Checker...${NC}"
    
    # Xác định các đường dẫn
    BIN_FILE="/usr/local/bin/portcheck"
    CONFIG_DIR="/etc/portcheck"
    DOC_DIR="/usr/share/doc/portcheck"
    MAN_FILE="/usr/share/man/man1/portcheck.1.gz"
    
    # Xóa script chính
    if [ -f "$BIN_FILE" ]; then
        echo -e "${BLUE}[*] Đang xóa script chính...${NC}"
        rm -f "$BIN_FILE"
        echo -e "${GREEN}[✓] Đã xóa script chính${NC}"
    else
        echo -e "${YELLOW}[!] Không tìm thấy script chính tại $BIN_FILE${NC}"
    fi
    
    # Xóa trang man nếu tồn tại
    if [ -f "$MAN_FILE" ]; then
        echo -e "${BLUE}[*] Đang xóa trang man...${NC}"
        rm -f "$MAN_FILE"
        echo -e "${GREEN}[✓] Đã xóa trang man${NC}"
        
        # Cập nhật cơ sở dữ liệu man
        if command -v mandb &> /dev/null; then
            echo -e "${BLUE}[*] Đang cập nhật cơ sở dữ liệu man...${NC}"
            mandb -q
        fi
    fi
    
    # Hỏi trước khi xóa cấu hình
    local response=""
    echo -e "${YELLOW}Bạn có muốn xóa tệp cấu hình không? (y/N): ${NC}\c"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if [ -d "$CONFIG_DIR" ]; then
            echo -e "${BLUE}[*] Đang xóa thư mục cấu hình...${NC}"
            rm -rf "$CONFIG_DIR"
            echo -e "${GREEN}[✓] Đã xóa thư mục cấu hình${NC}"
        else
            echo -e "${YELLOW}[!] Không tìm thấy thư mục cấu hình tại $CONFIG_DIR${NC}"
        fi
    else
        echo -e "${BLUE}[i] Giữ nguyên thư mục cấu hình${NC}"
    fi
    
    # Xóa tài liệu
    if [ -d "$DOC_DIR" ]; then
        echo -e "${BLUE}[*] Đang xóa thư mục tài liệu...${NC}"
        rm -rf "$DOC_DIR"
        echo -e "${GREEN}[✓] Đã xóa thư mục tài liệu${NC}"
    else
        echo -e "${YELLOW}[!] Không tìm thấy thư mục tài liệu tại $DOC_DIR${NC}"
    fi
    
    echo -e "${GREEN}[✓] Gỡ cài đặt hoàn tất${NC}"
}

# Hàm main
main() {
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}       GỠ CÀI ĐẶT PORT CHECKER       ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    
    check_root
    uninstall_portcheck
    
    echo -e "\n${GREEN}[✓] Port Checker đã được gỡ cài đặt thành công!${NC}"
}

main
