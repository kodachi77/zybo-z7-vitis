
.EXPORT_ALL_VARIABLES:

ifndef XILINX_VIVADO
$(error ERROR: 'XILINX_VIVADO' variable not set, please set correctly and rerun)
endif

ifndef XILINX_VITIS
$(error ERROR: 'XILINX_VITIS' variable not set, please set correctly and rerun)
endif

ifndef PETALINUX
$(error ERROR: 'PETALINUX' variable not set, Please install PetaLinux or use pre-built software images to build the platform. Please refer to build instructions in readme for more details.)
endif

# tools
VIVADO  = $(XILINX_VIVADO)/bin/vivado
DTC     = $(XILINX_VITIS)/bin/dtc
BOOTGEN = $(XILINX_VITIS)/bin/bootgen
XSCT    = $(XILINX_VITIS)/bin/xsct

# this contains letter 'v'
VIVADO_VERSION := $(shell $(VIVADO) -version | grep -o 'v[0-9]\+\.[0-9]\+')

ifeq ($(strip $(VIVADO_VERSION)),)
$(error Failed to extract Vivado version from $(VIVADO))
endif

# platform specific
PLATFORM 		  = zybo_z7_20
PLATFORM_TYPE 	  = zynq
CPU_ARCH 		  = a9
BOARD    		  = zynq-zybo-z7
CORE     		  = ps7_cortexa9_0

# versioning
VERSION          ?= 2022_1
VER              ?= $(VERSION)

PRE_SYNTH        ?= TRUE
PETALINUX_BUILD  ?= FALSE

# common
TOP_DIR          ?= $(shell readlink -f .)

# hw related
XSA_DIR           = $(TOP_DIR)/hw_handoff
SW_DIR            = $(TOP_DIR)/sw/build

PROJECT_NAME      = hw

XSA               = $(XSA_DIR)/$(PROJECT_NAME).xsa
HW_EMU_XSA        = $(XSA_DIR)/hw_emu/$(PROJECT_NAME).xsa
BIT_FILE          = $(XSA_DIR)/$(PROJECT_NAME).bit
README_FILE       = $(XSA_DIR)/README.txt



# sw related
BOOT_DIR          = $(SW_DIR)/platform/boot
IMAGE_DIR         = $(SW_DIR)/platform/image

DTB_FILE          = $(BOOT_DIR)/system.dtb
BOOT_IMAGE        = $(BOOT_DIR)/BOOT.BIN
SW_FILES          = $(IMAGE_DIR)/boot.scr $(BOOT_DIR)/u-boot.elf
BOOT_FILES        = u-boot.elf

SYSROOT           = $(TOP_DIR)/platform_repo/sysroot

# platform related
PLATFORM_NAME     = $(PLATFORM)_$(VERSION)
PLATFORM_SW_SRC   = $(TOP_DIR)/platform
PLATFORM_DIR      = $(TOP_DIR)/platform_repo

# flow related

PREBUILT_LINUX_PATH ?= /opt/xilinx/platform/xilinx-$(PLATFORM_TYPE)-common-$(VIVADO_VERSION)

ifneq ($(wildcard $(TOP_DIR)/xilinx-$(PLATFORM_TYPE)-common-$(VIVADO_VERSION)),)
PREBUILT_LINUX_PATH ?= $(TOP_DIR)/xilinx-$(PLATFORM_TYPE)-common-$(VIVADO_VERSION)
endif

# Getting Absolute paths
ifneq ("$(wildcard $(XSA))","")
  XSA_ABS ?= $(realpath $(XSA))
  override XSA := $(realpath $(XSA_ABS))
endif

ifneq ("$(wildcard $(HW_EMU_XSA_ABS))","")
  HW_EMU_XSA_ABS ?= $(realpath $(HW_EMU_XSA))
  override HW_EMU_XSA := $(realpath $(HW_EMU_XSA_ABS))
endif

ifneq ("$(wildcard $(PREBUILT_LINUX_PATH_ABS))","")
  PREBUILT_LINUX_PATH_ABS ?= $(realpath $(PREBUILT_LINUX_PATH))
  override PREBUILT_LINUX_PATH := $(realpath $(PREBUILT_LINUX_PATH_ABS))
endif

# common targets

check-prebuilt:
ifeq (,$(wildcard $(PREBUILT_LINUX_PATH)))
	$(info )
	$(info PREBUILT common images cannot be found at $(PREBUILT_LINUX_PATH))
	$(info If PREBUILT common images are present in another directory, Please specify the path to images as follows :)
	$(info make all PREBUILT_LINUX_PATH=/path/to/boot_files/dir)
	$(info else)
	$(info Please download PREBUILT common images from https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-platforms.html and extract them to /opt/xilinx/platform)
	$(error )
else
	$(info Found Platform Images at $(PREBUILT_LINUX_PATH))
endif

ifeq ($(PREBUILT_LINUX_PATH),)
	$(error ERROR: 'PREBUILT_LINUX_PATH' is not accesible, please set this flag to path containing common software)
endif

