CWD = $(shell readlink -f .)
TOP_DIR = $(CWD)/../..
include $(TOP_DIR)/platform.mk

.PHONY: all clean mrproper

clean:
	$(RM) -r .Xil

mrproper:
	@echo Running mrproper
