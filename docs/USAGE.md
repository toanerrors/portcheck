# Port Checker - Hướng dẫn sử dụng

## Tổng quan

Port Checker là công cụ dòng lệnh giúp kiểm tra và quản lý các tiến trình đang sử dụng các cổng mạng trên hệ thống. Công cụ này cho phép bạn nhanh chóng xác định và xử lý các tiến trình đang chiếm dụng cổng mạng cụ thể.

## Cài đặt

### Cài đặt từ source

```bash
git clone https://github.com/errors/portcheck.git
cd portcheck
sudo make install
```

Hoặc sử dụng script cài đặt:

```bash
sudo ./install.sh
```

### Cài đặt từ gói .deb (Debian/Ubuntu)

```bash
# Tạo gói .deb
make package-deb

# Cài đặt gói
sudo dpkg -i build/portcheck.deb
```

## Sử dụng cơ bản

### Kiểm tra một cổng

```bash
portcheck 8080
```

### Kiểm tra nhiều cổng

```bash
portcheck 8080 3000 5432
```

### Chỉ liệt kê các tiến trình mà không kill

```bash
portcheck -l 8080
```

### Kill tiến trình mà không hỏi

```bash
portcheck -f 8080
```

### Kill tiến trình một cách "nhẹ nhàng" (thử SIGTERM trước)

```bash
portcheck -g 8080
```

## Tùy chọn

| Tùy chọn | Mô tả |
|----------|-------|
| `-h, --help` | Hiển thị trợ giúp |
| `-f, --force` | Kill các tiến trình mà không hỏi |
| `-g, --graceful` | Thử SIGTERM trước, chờ 3 giây trước khi dùng SIGKILL |
| `-l, --list` | Chỉ liệt kê tiến trình mà không hỏi về việc kill |
| `-v, --version` | Hiển thị phiên bản và thông tin |

## Ví dụ sử dụng

### Tìm và kill tiến trình đang sử dụng cổng 8080

```bash
$ portcheck 8080

════════════════════════════════════════════════
       PORT CHECKER & PROCESS KILLER v2.4       
════════════════════════════════════════════════

[*] Đang kiểm tra cổng 8080...
[!] Cổng 8080 đang được sử dụng bởi:
    PID: 12345
    Process: nginx
    User: www-data
    Command: nginx: master process /usr/sbin/nginx
Bạn có muốn kill tiến trình này không? (y/N): y
[✓] Đã kill tiến trình 12345 thành công
[✓] Cổng 8080 đã được giải phóng

[✓] Hoàn tất kiểm tra 1 cổng
```

### Tìm và kiểm tra nhiều cổng

```bash
$ portcheck 8080 3000 5432

════════════════════════════════════════════════
       PORT CHECKER & PROCESS KILLER v2.4       
════════════════════════════════════════════════

[*] Đang kiểm tra cổng 8080...
[✓] Không có tiến trình nào đang sử dụng cổng 8080

[*] Đang kiểm tra cổng 3000...
[!] Cổng 3000 đang được sử dụng bởi:
    PID: 23456
    Process: node
    User: nodejs
    Command: node server.js
Bạn có muốn kill tiến trình này không? (y/N): n
[i] Giữ nguyên tiến trình 23456

[*] Đang kiểm tra cổng 5432...
[!] Cổng 5432 đang được sử dụng bởi:
    PID: 34567
    Process: postgres
    User: postgres
    Command: /usr/lib/postgresql/14/bin/postgres
Bạn có muốn kill tiến trình này không? (y/N): n
[i] Giữ nguyên tiến trình 34567

[✓] Hoàn tất kiểm tra 3 cổng
```

## Gỡ cài đặt

Sử dụng Makefile:

```bash
sudo make uninstall
```

Hoặc sử dụng script gỡ cài đặt:

```bash
sudo ./uninstall.sh
```

## Ghi chú

- Một số hoạt động có thể yêu cầu quyền root (sudo) để kill các tiến trình hệ thống
- Công cụ này phụ thuộc vào lệnh `lsof` để kiểm tra các cổng, đảm bảo rằng gói lsof đã được cài đặt
- Sử dụng tùy chọn `-g` khi bạn muốn cho phép các tiến trình có thời gian để dọn dẹp tài nguyên trước khi thoát
