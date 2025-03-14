# Changelog

Tất cả các thay đổi đáng chú ý của dự án Port Checker sẽ được ghi lại trong file này.

## [2.4] - 2025-03-13 (Upcoming)

### Thêm mới
- Hỗ trợ kiểm tra nhiều tiến trình trên cùng một cổng
- Thêm tùy chọn kiểm tra cả kết nối UDP và TCP
- Thêm GitHub Actions để tự động build và tạo release

### Cải thiện
- Tối ưu đường dẫn file cấu hình để hỗ trợ cả cài đặt toàn cục và cục bộ
- Cải thiện khả năng phát hiện tiến trình đang sử dụng cổng
- Kiểm tra tình trạng giải phóng cổng sau khi kill tiến trình
- Tự động tạo trang man nếu không tồn tại

### Sửa lỗi
- Sửa lỗi không tìm thấy file cấu hình khi chạy từ thư mục khác
- Sửa lỗi chương trình bị lỗi khi không đủ quyền để kill tiến trình

## [2.3] - 2023-10-25

### Thêm mới
- Thêm tùy chọn tắt tiến trình một cách nhẹ nhàng (graceful kill)
- Thêm hỗ trợ Makefile cho việc cài đặt và gỡ bỏ

### Cải thiện
- Cải thiện thông báo lỗi và màu sắc trong output
- Chỉnh sửa cấu trúc dự án theo tiêu chuẩn

### Sửa lỗi
- Sửa lỗi crash khi không có quyền lsof

## [2.2] - 2023-07-10

### Thêm mới
- Thêm tùy chọn force kill (-f, --force)
- Thêm tùy chọn chỉ liệt kê không kill (-l, --list)

### Cải thiện
- Cải thiện hiệu suất khi kiểm tra nhiều cổng
- Thêm thông tin chi tiết về tiến trình đang chạy

## [2.1] - 2023-04-03

### Thêm mới
- Hỗ trợ kiểm tra nhiều cổng cùng lúc

### Sửa lỗi
- Sửa lỗi khi kill tiến trình có PID dài

## [2.0] - 2023-01-15

### Thêm mới
- Thiết kế lại giao diện với màu sắc
- Thêm hệ thống trợ giúp
- Thêm tùy chọn hiển thị phiên bản

### Cải thiện
- Cải thiện xử lý tham số dòng lệnh
- Tái cấu trúc mã nguồn

## [1.0] - 2022-09-20

### Thêm mới
- Phiên bản đầu tiên với chức năng cơ bản
- Kiểm tra một cổng, hiển thị và kill tiến trình
