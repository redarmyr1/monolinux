EXE = $(BUILD)/app
BZIMAGE ?= $(BUILD)/linux/arch/x86/boot/bzImage
INITRAMFS = $(BUILD)/initramfs.cpio
INITRAMFS_FILES ?=
SCRIPTS_DIR = $(ML_ROOT)/scripts
CC = $(CROSS_COMPILE)gcc
CFLAGS += -O2
LDFLAGS += -static
SYSROOT = $(BUILD)/root
QEMU_DISKS ?=

.PHONY: all run build packages

all: build

packages:
	$(MAKE) packages-rsync
	$(MAKE) packages-build

packages-rsync:

packages-build:

packages-clean:
	rm -rf $(BUILD)/packages $(BUILD)/root

build:
	$(MAKE) linux-all
	$(MAKE) packages
	$(MAKE) $(INITRAMFS)

run: build
	qemu-system-x86_64 \
	    -kernel $(BZIMAGE) \
	    -initrd $(INITRAMFS) \
	    -nographic -append "console=ttyS0" \
	    $(QEMU_DISKS:%=-drive format=raw,file=%)

size:
	ls -lh $(BZIMAGE) $(INITRAMFS) $(EXE)

$(INITRAMFS): $(EXE)
	@echo "Creating the initramfs."
	fakeroot $(ML_ROOT)/make/create_initramfs.sh $(BUILD) "$(INITRAMFS_FILES)"

include $(ML_ROOT)/make/linux.mk
include $(ML_ROOT)/make/build.mk
