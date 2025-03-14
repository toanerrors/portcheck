# Port Checker GitHub Actions

Thư mục này chứa các tệp cấu hình cho GitHub Actions, giúp tự động hóa việc kiểm tra, xây dựng và phát hành Port Checker.

## Workflows

### Build and Release

Workflow `build.yml` thực hiện các công việc sau:

1. **Lint**: Kiểm tra chất lượng mã nguồn sử dụng ShellCheck
2. **Build**: Xây dựng gói Debian (.deb) và tarball
3. **Release**: Tự động tạo GitHub Release khi có tag mới

## Cách sử dụng

### Phát hành phiên bản mới

Để phát hành một phiên bản mới của Port Checker:

1. Cập nhật phiên bản trong `config/version.conf`
2. Cập nhật `CHANGELOG.md` với các thay đổi mới
3. Tạo tag và push lên GitHub:

```bash
git tag -a v2.4.0 -m "Release v2.4.0"
git push origin v2.4.0
```

GitHub Actions sẽ tự động tạo release với các tệp:
- Gói Debian (.deb)
- Tarball (.tar.gz)

### Kiểm tra Pull Requests

Khi có Pull Request mới, GitHub Actions sẽ tự động kiểm tra và xây dựng dự án để đảm bảo mã nguồn không có lỗi trước khi merge.
