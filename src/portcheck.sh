#!/bin/bash
# Port Checker and Process Killer - kiểm tra và quản lý tiến trình đang sử dụng cổng mạng
# Author: errors <toanerror2000@gmail.com>
# Role: Developer

# Strict mode (Aborting on errors)
set -eo pipefail

# Xác định đường dẫn script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_DIR="/etc/portcheck"
LOCAL_CONFIG_DIR="${SCRIPT_DIR}/../config"

# Đọc thông tin phiên bản từ file cấu hình
VERSION_FILE="${CONFIG_DIR}/version.conf"
LOCAL_VERSION_FILE="${LOCAL_CONFIG_DIR}/version.conf"
VERSION="2.4"
AUTHOR="errors"
EMAIL="toanerror2000@gmail.com"

if [ -f "$VERSION_FILE" ]; then
    source "$VERSION_FILE"
elif [ -f "$LOCAL_VERSION_FILE" ]; then
    source "$LOCAL_VERSION_FILE"
fi

# Thiết lập màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Thiết lập tùy chọn mặc định
FORCE_KILL=false
GRACEFUL_KILL=false
LIST_ONLY=false

# Hiển thị thông báo trợ giúp
show_help() {
    echo -e "Port Checker & Process Killer v${VERSION}"
    echo -e "Công cụ kiểm tra và quản lý tiến trình đang sử dụng các cổng mạng\n"
    echo -e "Cách sử dụng: ${BOLD}portcheck [TÙY CHỌN] PORT1 [PORT2 PORT3 ...]${NC}\n"
    echo -e "Tùy chọn:"
    echo -e "  ${YELLOW}-h, --help${NC}      Hiển thị trợ giúp này"
    echo -e "  ${YELLOW}-f, --force${NC}     Kill các tiến trình mà không hỏi"
    echo -e "  ${YELLOW}-g, --graceful${NC}  Thử SIGTERM trước, chờ 3 giây trước khi dùng SIGKILL"
    echo -e "  ${YELLOW}-l, --list${NC}      Chỉ liệt kê tiến trình mà không hỏi về việc kill"
    echo -e "  ${YELLOW}-v, --version${NC}   Hiển thị phiên bản và thông tin\n"
    echo -e "Ví dụ:"
    echo -e "  ${BLUE}portcheck 8080${NC}                 - Kiểm tra port 8080"
    echo -e "  ${BLUE}portcheck 8080 3000 5432${NC}       - Kiểm tra nhiều port"
    echo -e "  ${BLUE}portcheck -f 8080${NC}              - Kiểm tra và kill tiến trình sử dụng port 8080 mà không hỏi"
    echo -e "  ${BLUE}portcheck -g 8080${NC}              - Kill 'nhẹ nhàng' trước khi dùng force kill\n"
}

# Hiển thị thông tin phiên bản
show_version() {
    echo -e "Port Checker & Process Killer v${VERSION}"
    echo -e "Tác giả: ${AUTHOR} <${EMAIL}>"
    echo -e "Ngày phát hành: ${RELEASE_DATE:-Unknown}"
}

# Kiểm tra yêu cầu lsof
check_lsof() {
    if ! command -v lsof &> /dev/null; then
        echo -e "${RED}[!] Lỗi: Không tìm thấy lệnh 'lsof'. Vui lòng cài đặt lệnh này trước.${NC}"
        echo -e "    ${YELLOW}Debian/Ubuntu:${NC} sudo apt-get install lsof"
        echo -e "    ${YELLOW}CentOS/RHEL:${NC}  sudo yum install lsof"
        echo -e "    ${YELLOW}Fedora:${NC}       sudo dnf install lsof"
        echo -e "    ${YELLOW}Arch Linux:${NC}   sudo pacman -S lsof"
        exit 1
    fi
}

# Phân tích các tham số dòng lệnh
parse_args() {
    PORTS=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -f|--force)
                FORCE_KILL=true
                shift
                ;;
            -g|--graceful)
                GRACEFUL_KILL=true
                shift
                ;;
            -l|--list)
                LIST_ONLY=true
                shift
                ;;
            -*)
                echo -e "${RED}[!] Lỗi: Không nhận ra tùy chọn: $1${NC}"
                show_help
                exit 1
                ;;
            *)
                # Kiểm tra xem tham số có phải là số không
                if [[ "$1" =~ ^[0-9]+$ ]]; then
                    PORTS+=("$1")
                else
                    echo -e "${RED}[!] Lỗi: Cổng '$1' không hợp lệ. Cổng phải là một số nguyên.${NC}"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Kiểm tra xem có ít nhất một cổng được chỉ định không
    if [ ${#PORTS[@]} -eq 0 ]; then
        echo -e "${RED}[!] Lỗi: Không có cổng nào được chỉ định.${NC}"
        show_help
        exit 1
    fi
}

# Kiểm tra và hiển thị thông tin về tiến trình sử dụng một cổng
check_port() {
    local port=$1
    local pids=()
    local pname=""
    local command=""
    local user=""
    
    echo -e "\n${BLUE}[*] Đang kiểm tra cổng ${YELLOW}${port}${BLUE}...${NC}"
    
    # Kiểm tra xem cổng có được sử dụng không - bao gồm cả UDP và TCP
    if ! lsof -i ":${port}" > /dev/null 2>&1; then
        echo -e "${GREEN}[✓] Không có tiến trình nào đang sử dụng cổng ${port}${NC}"
        return 0
    fi
    
    # Lấy thông tin về tất cả các tiến trình sử dụng cổng này
    readarray -t pids < <(lsof -i ":${port}" -t 2>/dev/null | sort -u)
    
    # Nếu không tìm thấy PID, có thể là do quyền hạn không đủ hoặc lỗi khác
    if [ ${#pids[@]} -eq 0 ]; then
        echo -e "${RED}[!] Không thể xác định tiến trình đang sử dụng cổng ${port}${NC}"
        echo -e "${YELLOW}    Thử chạy lệnh này với sudo để có thêm quyền hạn${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}[!] Cổng ${port} đang được sử dụng bởi ${#pids[@]} tiến trình:${NC}"
    
    # Hiển thị thông tin từng tiến trình
    for pid in "${pids[@]}"; do
        # Lấy thêm thông tin về tiến trình
        pname=$(ps -p "$pid" -o comm= 2>/dev/null || echo "Unknown")
        command=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "Unknown")
        user=$(ps -p "$pid" -o user= 2>/dev/null || echo "Unknown")
        
        # Hiển thị thông tin về tiến trình
        echo -e "\n${BLUE}Tiến trình #${pid}:${NC}"
        echo -e "    ${BLUE}PID:${NC} ${pid}"
        echo -e "    ${BLUE}Process:${NC} ${pname}"
        echo -e "    ${BLUE}User:${NC} ${user}"
        echo -e "    ${BLUE}Command:${NC} ${command}"
        
        # Xử lý tiến trình
        handle_process "$pid" "$port"
    done
    
    return 0
}

# Xử lý tiến trình (kill hoặc không)
handle_process() {
    local pid=$1
    local port=$2
    local response=""
    
    # Nếu chỉ liệt kê, không làm gì thêm
    if [ "$LIST_ONLY" = true ]; then
        return 0
    fi
    
    # Nếu là force kill, kill ngay lập tức
    if [ "$FORCE_KILL" = true ]; then
        echo -e "${YELLOW}[!] Đang kill tiến trình ${pid} theo yêu cầu...${NC}"
        kill_process "$pid" "$port"
        return 0
    fi
    
    # Hỏi người dùng có muốn kill tiến trình không
    echo -e "${YELLOW}Bạn có muốn kill tiến trình này không? (y/N): ${NC}\c"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        kill_process "$pid" "$port"
    else
        echo -e "${BLUE}[i] Giữ nguyên tiến trình ${pid}${NC}"
    fi
}

# Kill một tiến trình
kill_process() {
    local pid=$1
    local port=$2
    
    # Kiểm tra xem tiến trình có tồn tại không trước khi kill
    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo -e "${YELLOW}[!] Tiến trình ${pid} không còn tồn tại${NC}"
        return 0
    fi
    
    # Nếu là graceful kill, thử SIGTERM trước
    if [ "$GRACEFUL_KILL" = true ]; then
        echo -e "${YELLOW}[!] Đang thử kill tiến trình ${pid} một cách nhẹ nhàng (SIGTERM)...${NC}"
        kill -15 "$pid" 2>/dev/null || true
        
        # Chờ 3 giây và kiểm tra xem tiến trình còn tồn tại không
        echo -e "${BLUE}[*] Đợi 3 giây để tiến trình kết thúc...${NC}"
        sleep 3
        
        # Kiểm tra xem tiến trình còn tồn tại không
        if ps -p "$pid" > /dev/null 2>&1; then
            echo -e "${YELLOW}[!] Tiến trình ${pid} vẫn còn tồn tại, đang sử dụng SIGKILL...${NC}"
            kill -9 "$pid" 2>/dev/null || {
                echo -e "${RED}[!] Không thể kill tiến trình ${pid}. Có thể cần quyền root.${NC}"
                return 1
            }
        else
            echo -e "${GREEN}[✓] Đã kill tiến trình ${pid} thành công (SIGTERM)${NC}"
            return 0
        fi
    else
        # Kill ngay lập tức với SIGKILL
        kill -9 "$pid" 2>/dev/null || {
            echo -e "${RED}[!] Không thể kill tiến trình ${pid}. Có thể cần quyền root.${NC}"
            return 1
        }
    fi
    
    # Kiểm tra lại xem tiến trình đã bị kill chưa
    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo -e "${GREEN}[✓] Đã kill tiến trình ${pid} thành công${NC}"
        
        # Kiểm tra xem cổng đã được giải phóng chưa
        if ! lsof -i ":${port}" > /dev/null 2>&1; then
            echo -e "${GREEN}[✓] Cổng ${port} đã được giải phóng${NC}"
        else
            echo -e "${YELLOW}[!] Cổng ${port} vẫn đang được sử dụng bởi tiến trình khác${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}[!] Không thể kill tiến trình ${pid}. Tiến trình vẫn còn tồn tại.${NC}"
        return 1
    fi
}

# Hàm main
main() {
    # Kiểm tra lsof
    check_lsof
    
    # Phân tích tham số dòng lệnh
    parse_args "$@"
    
    # Hiển thị banner
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}       PORT CHECKER & PROCESS KILLER v${VERSION}       ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    
    # Kiểm tra từng cổng
    for port in "${PORTS[@]}"; do
        check_port "$port"
    done
    
    echo -e "\n${GREEN}[✓] Hoàn tất kiểm tra ${#PORTS[@]} cổng${NC}"
}

# Chạy hàm main với tất cả tham số dòng lệnh
main "$@"
