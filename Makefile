# Compiler settings
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Wno-missing-field-initializers

# Target executable
TARGET = kubsh

# Debian package settings
PACKAGE_NAME = kubsh
VERSION = 1.0.0
DEB_FILE = $(PACKAGE_NAME)_$(VERSION)_amd64.deb

# ================= Build =================

all: $(TARGET)

$(TARGET): kubsh.cpp
	$(CXX) $(CXXFLAGS) kubsh.cpp -o $(TARGET) -I/usr/include/fuse3 -lfuse3 -lpthread -lreadline

# ================= Debian Package =================

deb: $(TARGET)
	@echo "Creating .deb package..."
	rm -rf kubsh-package
	mkdir -p kubsh-package/DEBIAN
	mkdir -p kubsh-package/usr/local/bin
	cp $(TARGET) kubsh-package/usr/local/bin/kubsh
	chmod +x kubsh-package/usr/local/bin/kubsh

	# Create control file
	echo "Package: $(PACKAGE_NAME)" > kubsh-package/DEBIAN/control
	echo "Version: $(VERSION)" >> kubsh-package/DEBIAN/control
	echo "Architecture: amd64" >> kubsh-package/DEBIAN/control
	echo "Maintainer: user" >> kubsh-package/DEBIAN/control
	echo "Priority: optional" >> kubsh-package/DEBIAN/control
	echo "Section: utils" >> kubsh-package/DEBIAN/control
	echo "Description: Custom shell kubsh" >> kubsh-package/DEBIAN/control
	echo "Depends: libfuse3-3, libreadline8" >> kubsh-package/DEBIAN/control

	dpkg-deb --build kubsh-package $(DEB_FILE)
	@echo "Package created: $(DEB_FILE)"

# ================= Test in Docker =================

test: deb
	@echo "Running tests in Docker..."
	docker run -it --rm --privileged --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined \
		-v $(CURDIR)/$(DEB_FILE):/mnt/kubsh.deb \
		tyvik/kubsh_test:master \
		bash -c "apt update && apt install -y libfuse3-3 libreadline8 && dpkg -i /mnt/kubsh.deb && pytest /opt"

# ================= Clean =================

clean:
	rm -f $(TARGET) *.deb
	rm -rf kubsh-package

.PHONY: all deb test clean
