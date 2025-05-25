.PHONY: all linux clean

include ../platform.mk

all linux:
ifeq ("$(PETALINUX_BUILD)","TRUE")
	$(info )
	$(info You can skip PetaLinux building step by downloading common software image from https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms.html and set PREBUILT_LINUX_PATH to point to software image.)
	$(info )
#	$(MAKE) -C petalinux all
else
	$(MAKE) -C prebuilt_linux all
endif

clean:
		$(MAKE) -C prebuilt_linux clean;
#		$(MAKE) -C petalinux clean;
