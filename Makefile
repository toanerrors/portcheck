# Makefile cho Port Checker
# Author: errors <toanerror2000@gmail.com>

PREFIX=/usr/local
CONFIG_DIR=/etc/portcheck
DOC_DIR=/usr/share/doc/portcheck
MAN_DIR=/usr/share/man/man1

.PHONY: all install uninstall clean test help man package

all: help

install:
	@echo "Đang cài đặt Port Checker..."
	@chmod +x install.sh
	@sudo ./install.sh

uninstall:
	@echo "Đang gỡ cài đặt Port Checker..."
	@chmod +x uninstall.sh
	@sudo ./uninstall.sh

clean:
	@echo "Đang dọn dẹp các file tạm..."
	@rm -f *~
	@rm -f *.bak
	@rm -f *.tmp
	@rm -f src/*~
	@rm -f src/*.bak
	@rm -f src/*.tmp

test:
	@echo "Đang kiểm tra script..."
	@shellcheck src/portcheck.sh
	@echo "Kiểm tra script thành công!"

man:
	@echo "Đang tạo thư mục build nếu chưa tồn tại..."
	@mkdir -p build
	@if [ -f docs/portcheck.1 ]; then \
		echo "Đang tạo trang man..."; \
		gzip -c docs/portcheck.1 > build/portcheck.1.gz; \
	else \
		echo "Tệp man page không tồn tại, bỏ qua..."; \
		echo "Lưu ý: Để tạo trang man, tạo tệp docs/portcheck.1 trước"; \
	fi

package-deb:
	@echo "Đang tạo package deb..."
	@mkdir -p build/deb/DEBIAN
	@mkdir -p build/deb/usr/local/bin
	@mkdir -p build/deb/etc/portcheck
	@mkdir -p build/deb/usr/share/doc/portcheck
	@mkdir -p build/deb/usr/share/man/man1
	@cp src/portcheck.sh build/deb/usr/local/bin/portcheck
	@cp config/version.conf build/deb/etc/portcheck/
	@cp README.md CHANGELOG.md build/deb/usr/share/doc/portcheck/
	@if [ -f docs/portcheck.1 ]; then \
		echo "Đang thêm trang man vào package..."; \
		if [ ! -f build/portcheck.1.gz ]; then \
			gzip -c docs/portcheck.1 > build/portcheck.1.gz; \
		fi; \
		cp build/portcheck.1.gz build/deb/usr/share/man/man1/; \
	fi
	@chmod +x build/deb/usr/local/bin/portcheck
	@echo "Package: portcheck" > build/deb/DEBIAN/control
	@echo "Version: $(shell grep VERSION config/version.conf | cut -d '"' -f 2)" >> build/deb/DEBIAN/control
	@echo "Architecture: all" >> build/deb/DEBIAN/control
	@echo "Maintainer: errors <toanerror2000@gmail.com>" >> build/deb/DEBIAN/control
	@echo "Description: Công cụ dòng lệnh để kiểm tra và quản lý các tiến trình đang sử dụng các cổng mạng" >> build/deb/DEBIAN/control
	@echo "Depends: lsof" >> build/deb/DEBIAN/control
	@echo "Section: utils" >> build/deb/DEBIAN/control
	@echo "Priority: optional" >> build/deb/DEBIAN/control
	@echo "Homepage: $(shell grep HOMEPAGE config/version.conf | cut -d '"' -f 2)" >> build/deb/DEBIAN/control
	@echo '#!/bin/sh' > build/deb/DEBIAN/prerm
	@echo 'echo "Đang chuẩn bị gỡ bỏ Port Checker..."' >> build/deb/DEBIAN/prerm
	@echo 'if [ -f /usr/share/man/man1/portcheck.1.gz ]; then rm -f /usr/share/man/man1/portcheck.1.gz; fi' >> build/deb/DEBIAN/prerm
	@echo 'exit 0' >> build/deb/DEBIAN/prerm
	@chmod +x build/deb/DEBIAN/prerm
	@dpkg-deb --build build/deb build/portcheck.deb
	@echo "Đã tạo package: build/portcheck.deb"

package: package-deb

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install    - Cài đặt Port Checker vào hệ thống"
	@echo "  uninstall  - Gỡ cài đặt Port Checker khỏi hệ thống"
	@echo "  clean      - Dọn dẹp các file tạm"
	@echo "  test       - Kiểm tra script bằng shellcheck"
	@echo "  man        - Tạo trang man"
	@echo "  package    - Tạo các gói cài đặt (hiện tại: deb)"
	@echo "  help       - Hiển thị trợ giúp này"
