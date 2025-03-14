# Port Checker

Port Checker là công cụ dòng lệnh giúp kiểm tra và quản lý các tiến trình đang sử dụng các cổng mạng trên hệ thống Linux/Unix. Công cụ này giúp người dùng dễ dàng xác định tiến trình nào đang chiếm một cổng mạng cụ thể và cho phép kill các tiến trình đó nếu cần.

[![Build and Release](https://github.com/toanerrors/portcheck/actions/workflows/build.yml/badge.svg)](https://github.com/toanerrors/portcheck/actions/workflows/build.yml)

## Mục lục

- [Tính năng chính](#tính-năng-chính)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cài đặt](#cài-đặt)
  - [Cài đặt từ source](#cài-đặt-từ-source)
  - [Cài đặt từ gói .deb](#cài-đặt-từ-gói-deb)
  - [Cài đặt từ tarball](#cài-đặt-từ-tarball)
- [Sử dụng](#sử-dụng)
  - [Cú pháp cơ bản](#cú-pháp-cơ-bản)
  - [Các tùy chọn](#các-tùy-chọn)
  - [Ví dụ sử dụng](#ví-dụ-sử-dụng)
- [Cấu hình](#cấu-hình)
- [Tài liệu](#tài-liệu)
- [Gỡ cài đặt](#gỡ-cài-đặt)
- [Xử lý sự cố](#xử-lý-sự-cố)
- [Đóng góp](#đóng-góp)
- [Giấy phép](#giấy-phép)
- [Tác giả](#tác-giả)
- [Changelog](#changelog)

## Tính năng chính

- Kiểm tra một hoặc nhiều cổng mạng đồng thời
- Hiển thị thông tin chi tiết về tiến trình sử dụng cổng (PID, tên tiến trình, lệnh, người dùng)
- Phát hiện nhiều tiến trình sử dụng cùng một cổng
- Tùy chọn kill tiến trình tự động hoặc với xác nhận
- Hỗ trợ kill "graceful" (SIGTERM trước, sau đó SIGKILL nếu cần)
- Kiểm tra tự động tình trạng cổng sau khi kill tiến trình
- Hỗ trợ cả kết nối TCP và UDP
- Giao diện dòng lệnh thân thiện với mã màu và thông báo rõ ràng
- Tích hợp CI/CD qua GitHub Actions cho việc kiểm tra và phát hành tự động
- Trang man đầy đủ và tài liệu chi tiết

## Yêu cầu hệ thống

- Bash shell (phiên bản 4.0 trở lên)
- Lệnh `lsof` (để kiểm tra cổng mạng)
- Quyền sudo để kill các tiến trình hệ thống (nếu cần)

Các lệnh cài đặt gói phụ thuộc:

| Hệ điều hành | Lệnh cài đặt |
|--------------|--------------|
| Debian/Ubuntu | `sudo apt-get install lsof` |
| CentOS/RHEL | `sudo yum install lsof` |
| Fedora | `sudo dnf install lsof` |
| Arch Linux | `sudo pacman -S lsof` |

## Cài đặt

### Cài đặt từ source

#### Phương pháp 1: Sử dụng make

```bash
# Clone repository
git clone https://github.com/toanerrors/portcheck.git

# Di chuyển vào thư mục
cd portcheck

# Cài đặt
sudo make install
```

#### Phương pháp 2: Sử dụng script cài đặt

```bash
# Clone repository
git clone https://github.com/toanerrors/portcheck.git

# Di chuyển vào thư mục
cd portcheck

# Phân quyền và chạy script cài đặt
chmod +x install.sh
sudo ./install.sh
```

### Cài đặt từ gói .deb

Nếu bạn đang sử dụng hệ thống dựa trên Debian (như Ubuntu):

```bash
# Tải về gói .deb từ trang releases
wget https://github.com/toanerrors/portcheck/releases/download/v2.4/portcheck.deb

# Cài đặt gói
sudo dpkg -i portcheck.deb

# Cài đặt các gói phụ thuộc nếu cần
sudo apt-get install -f
```

### Cài đặt từ tarball

```bash
# Tải về tarball từ trang releases
wget https://github.com/toanerrors/portcheck/releases/download/v2.4/portcheck-2.4.tar.gz

# Giải nén
tar -xzf portcheck-2.4.tar.gz

# Di chuyển vào thư mục
cd portcheck-2.4

# Cài đặt
sudo make install
```

## Sử dụng

### Cú pháp cơ bản

```
portcheck [TÙY CHỌN] PORT1 [PORT2 PORT3 ...]
```

### Các tùy chọn

| Tùy chọn | Mô tả |
|----------|-------|
| `-h, --help` | Hiển thị trợ giúp và thoát |
| `-v, --version` | Hiển thị phiên bản và thông tin |
| `-f, --force` | Kill các tiến trình mà không hỏi |
| `-g, --graceful` | Thử SIGTERM trước, chờ 3 giây trước khi dùng SIGKILL |
| `-l, --list` | Chỉ liệt kê tiến trình mà không hỏi về việc kill |

### Ví dụ sử dụng

#### Kiểm tra một cổng

```bash
portcheck 8080
```

Kết quả:
```
════════════════════════════════════════════════
       PORT CHECKER & PROCESS KILLER v2.4       
════════════════════════════════════════════════

[*] Đang kiểm tra cổng 8080...
[!] Cổng 8080 đang được sử dụng bởi 1 tiến trình:

Tiến trình #1234:
    PID: 1234
    Process: node
    User: toanerrors
    Command: node server.js
Bạn có muốn kill tiến trình này không? (y/N): 
```

#### Kiểm tra nhiều cổng

```bash
portcheck 8080 3000 5432
```

#### Chỉ liệt kê các tiến trình, không kill

```bash
portcheck -l 8080
```

#### Kill các tiến trình mà không hỏi

```bash
portcheck -f 8080
```

#### Kill "nhẹ nhàng" (SIGTERM trước, sau đó SIGKILL)

```bash
portcheck -g 8080
```

## Cấu hình

Port Checker sử dụng file cấu hình `/etc/portcheck/version.conf` để lưu trữ các thiết lập chung. File này được tự động tạo trong quá trình cài đặt.

Nếu bạn muốn chỉnh sửa cấu hình:

```bash
sudo nano /etc/portcheck/version.conf
```

## Tài liệu

Tài liệu đầy đủ có sẵn qua trang man:

```bash
man portcheck
```

Các tài liệu bổ sung có thể được tìm thấy trong thư mục `/usr/share/doc/portcheck/`:

- `README.md`: Tài liệu tổng quan
- `USAGE.md`: Hướng dẫn sử dụng chi tiết
- `CHANGELOG.md`: Lịch sử các phiên bản và thay đổi

## Gỡ cài đặt

### Sử dụng make

```bash
sudo make uninstall
```

### Sử dụng script gỡ cài đặt

```bash
sudo ./uninstall.sh
```

### Gỡ bỏ gói .deb

```bash
sudo dpkg -r portcheck
```

## Xử lý sự cố

### Lỗi "lsof command not found"

Cài đặt lệnh lsof:

```bash
# Debian/Ubuntu
sudo apt-get install lsof

# CentOS/RHEL
sudo yum install lsof

# Fedora
sudo dnf install lsof

# Arch Linux
sudo pacman -S lsof
```

### Lỗi "Không thể kill tiến trình"

Đảm bảo bạn đang chạy lệnh với quyền sudo:

```bash
sudo portcheck 8080
```

### Lỗi "Không thể xác định tiến trình đang sử dụng cổng"

Đảm bảo bạn đang chạy lệnh với quyền sudo để có thể xem tất cả các tiến trình:

```bash
sudo portcheck 8080
```

## Đóng góp

Mọi đóng góp cho dự án đều được hoan nghênh. Vui lòng đảm bảo tuân theo quy trình sau:

1. Fork repository
2. Tạo nhánh tính năng (`git checkout -b feature/amazing-feature`)
3. Commit thay đổi của bạn (`git commit -m 'Add some amazing feature'`)
4. Push lên nhánh (`git push origin feature/amazing-feature`)
5. Mở Pull Request

### Quy tắc đóng góp

- Đảm bảo mã nguồn tuân theo shellcheck
- Viết test cho các tính năng mới
- Cập nhật tài liệu khi cần thiết
- Tuân thủ quy ước đặt tên và định dạng mã nguồn

## Giấy phép

Dự án này được phát hành dưới giấy phép MIT - xem tệp [LICENSE](LICENSE) để biết thêm chi tiết.

## Tác giả

- **errors** - *Developer* - [GitHub](https://github.com/errors)

## Changelog

Xem [CHANGELOG.md](CHANGELOG.md) để biết chi tiết về các thay đổi trong từng phiên bản.

### Phiên bản mới nhất: 2.4 (Sắp ra mắt)

- Hỗ trợ kiểm tra nhiều tiến trình trên cùng một cổng
- Thêm tùy chọn kiểm tra cả kết nối UDP và TCP
- Tối ưu đường dẫn file cấu hình
- Kiểm tra tình trạng giải phóng cổng sau khi kill
