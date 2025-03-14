# Port Checker

Port Checker là công cụ dòng lệnh giúp kiểm tra và quản lý các tiến trình đang sử dụng các cổng mạng trên hệ thống Linux/Unix. Công cụ này giúp người dùng dễ dàng xác định tiến trình nào đang chiếm một cổng mạng cụ thể và cho phép kill các tiến trình đó nếu cần.

## Tính năng chính

- Kiểm tra một hoặc nhiều cổng mạng đồng thời
- Hiển thị thông tin chi tiết về tiến trình sử dụng cổng (PID, tên tiến trình, lệnh, người dùng)
- Phát hiện nhiều tiến trình sử dụng cùng một cổng
- Tùy chọn kill tiến trình tự động hoặc với xác nhận
- Hỗ trợ kill "graceful" (SIGTERM trước, sau đó SIGKILL nếu cần)
- Giao diện dòng lệnh thân thiện với mã màu và thông báo rõ ràng
- CI/CD tích hợp qua GitHub Actions

## Trạng thái build

[![Build and Release](https://github.com/errors/portcheck/actions/workflows/build.yml/badge.svg)](https://github.com/errors/portcheck/actions/workflows/build.yml)

## Yêu cầu hệ thống

- Bash shell (phiên bản 4.0 trở lên)
- Lệnh `lsof` (cài đặt qua `apt-get install lsof` trên Debian/Ubuntu)
- Quyền sudo để kill các tiến trình hệ thống (nếu cần)

## Cài đặt

### Cài đặt tự động

```bash
git clone https://github.com/errors/portcheck.git
cd portcheck
sudo make install
```

hoặc

```bash
sudo ./install.sh
```

### Cài đặt từ gói .deb

```bash
# Tạo gói debian package
make package-deb

# Cài đặt gói
sudo dpkg -i build/portcheck.deb
```

## Sử dụng cơ bản

```bash
# Kiểm tra một cổng
portcheck 8080

# Kiểm tra nhiều cổng
portcheck 8080 3000 5432

# Chỉ liệt kê các tiến trình, không kill
portcheck -l 8080

# Kill các tiến trình mà không hỏi
portcheck -f 8080

# Kill "nhẹ nhàng" (SIGTERM trước, sau đó SIGKILL)
portcheck -g 8080
```

Chi tiết về cách sử dụng có thể xem trong trang manual:

```bash
man portcheck
```

hoặc xem tài liệu hướng dẫn chi tiết trong `/usr/share/doc/portcheck/USAGE.md`

## Gỡ cài đặt

```bash
sudo make uninstall
```

hoặc

```bash
sudo ./uninstall.sh
```

## Đóng góp

Mọi đóng góp cho dự án đều được hoan nghênh. Vui lòng đảm bảo tuân theo quy trình sau:

1. Fork repository
2. Tạo nhánh tính năng (`git checkout -b feature/amazing-feature`)
3. Commit thay đổi của bạn (`git commit -m 'Add some amazing feature'`)
4. Push lên nhánh (`git push origin feature/amazing-feature`)
5. Mở Pull Request

## Giấy phép

Dự án này được phát hành dưới giấy phép MIT - xem tệp [LICENSE](LICENSE) để biết thêm chi tiết.

## Tác giả

- **errors** - *Developer* - [GitHub](https://github.com/errors)
