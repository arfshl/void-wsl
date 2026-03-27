all: $(OUT_ZIP)

zip: $(OUT_ZIP)

x64_glibc:
	cd src_x64_glibc && $(MAKE)
	mv src_x64_glibc/$(OUT_ZIP) ./

arm64_glibc:
	cd src_arm64_glibc && $(MAKE)
	mv src_arm64_glibc/$(OUT_ZIP) ./

x64_musl:
	cd src_x64_musl && $(MAKE)
	mv src_x64_musl/$(OUT_ZIP) ./

arm64_musl:
	cd src_arm64_musl && $(MAKE)
	mv src_arm64_musl/$(OUT_ZIP) ./

clean:
	cd src_x64_glibc && make clean
	cd src_arm64_glibc && make clean
	cd src_x64_musl && make clean
	cd src_arm64_musl && make clean