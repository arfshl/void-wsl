OUT_ZIP=void-glibc.zip
LNCR_EXE=void-glibc.exe

DLR=curl
DLR_FLAGS=-L
LNCR_ZIP_EXE=Void.exe

all: $(OUT_ZIP)

zip: $(OUT_ZIP)
$(OUT_ZIP): $(ARCH)

x64_glibc:
	cd src_x64_glibc && $(MAKE) ARCH=x64_glibc
	mv src_x64_glibc/$(OUT_ZIP) ./

arm64_glibc:
	cd src_arm64_glibc && $(MAKE) ARCH=arm64_glibc
	mv src_arm64_glibc/$(OUT_ZIP) ./

x64_musl:
	cd src_x64_musl && $(MAKE) ARCH=x64_musl
	mv src_x64_musl/$(OUT_ZIP) ./

arm64_musl:
	cd src_arm64_musl && $(MAKE) ARCH=arm64_musl
	mv src_arm64_musl/$(OUT_ZIP) ./

clean:
	cd src_x64_glibc && make clean
	cd src_arm64_glibc && make clean
	cd src_x64_musl && make clean
	cd src_arm64_musl && make clean