CWD = $(shell readlink -f .)
TOP_DIR = $(CWD)/../..
include $(TOP_DIR)/platform.mk

SYSTEM_USER_DTSI = $(CWD)/user_dts/system-user.dtsi
SYSTEM_CONF_DTS  = $(CWD)/user_dts/system-conf.dtsi

IMG_ROOTFS_FILES = $(IMAGE_DIR)/uImage $(SW_BUILD_DIR)/platform/filesystem/rootfs.ext4
PREBUILT_ROOTFS_FILES = $(PREBUILT_LINUX_PATH)/uImage $(PREBUILT_LINUX_PATH)/rootfs.ext4
PREBUILT_SDK = $(PREBUILT_LINUX_PATH)/sdk.sh

.PHONY: all sw_comp dtb bootimage rootfs sysroot clean mrproper

all: check-prebuilt $(SW_FILES) $(BOOT_IMAGE) $(IMG_ROOTFS_FILES)

$(XSA):
	$(MAKE) -C $(TOP_DIR) xsa

dtb: $(DTB_FILE)

$(DTB_FILE): $(XSA)
	$(info "Generating SW Artifacts...")
	@if [ ! -d $(BOOT_DIR) ]; then mkdir -p $(BOOT_DIR); fi
	mkdir -p $(SW_BUILD_DIR)/tmp
	$(info "DTB generation started using XSCT")
	$(XSCT) -eval "setws $(SW_BUILD_DIR)/tmp; createdts -hw $(XSA) -git-url https://github.com/kodachi77/device-tree-xlnx -git-branch xlnx_rel_$(VIVADO_VERSION) -board $(BOARD) -platform $(PLATFORM) -zocl -out $(SW_BUILD_DIR)/tmp"
	$(eval BSP_PATH = $(SW_BUILD_DIR)/tmp/$(PLATFORM)/$(CORE)/device_tree_domain/bsp/)
	cp -rf $(SYSTEM_CONF_DTS) $(BSP_PATH)
	cp -rf $(SYSTEM_USER_DTSI) $(BSP_PATH)
	@if [ -f $(SYSTEM_USER_DTSI) ]; then echo "#include \"system-user.dtsi\"" >> $(BSP_PATH)/system-top.dts; fi
	cd $(BSP_PATH) && cpp -Iinclude -E -P -undef -D__DTS__ -x assembler-with-cpp ./system-top.dts | $(DTC) -I dts -O dtb -o $(DTB_FILE) - && cd -
	$(RM) -r $(SW_BUILD_DIR)/tmp


sw_comp: $(SW_FILES)

$(SW_FILES): $(DTB_FILE)
	mkdir -p $(IMAGE_DIR)
	mkdir -p $(SYSROOT)
	cp -f $(PREBUILT_LINUX_PATH)/boot.scr ${IMAGE_DIR}/boot.scr
	$(foreach BOOT_FILE,$(BOOT_FILES),cp -f $(PREBUILT_LINUX_PATH)/$(BOOT_FILE) $(BOOT_DIR) ;)
	
	# Generate fsbl file
	$(XSCT) -nodisp -sdx $(PLATFORM_SW_SRC)/generate_platform.tcl \
		platform_name "${PLATFORM_NAME}" \
		xsa_path "${XSA}" \
		emu_xsa_path "${HW_EMU_XSA}" \
		platform_out "${PLATFORM_DIR}" \
		boot_dir_path "${BOOT_DIR}" \
		img_dir_path "${IMAGE_DIR}" \
		rootfs_file "$(SW_BUILD_DIR)/platform/filesystem/rootfs.ext4" \
		sysroot_path "${SYSROOT_DIR}" \
		generate_sw true
	$(eval BOOT_ARTIFACTS = ${PLATFORM_DIR}/${PLATFORM_NAME}/export/${PLATFORM_NAME}/sw/${PLATFORM_NAME}/boot)
	# we want to fail if there are no boot artifacts
	cp -rf ${BOOT_ARTIFACTS}/*.elf ${BOOT_DIR} 

$(BIT_FILE): $(XSA)
	mkdir -p $(SW_BUILD_DIR)
	cp -f $(XSA) $(SW_BUILD_DIR)/system.xsa
	# do not fail if file doesn't exist
	cp -f $(BIT_FILE) $(SW_BUILD_DIR)/hw.bit 2> /dev/null || :

bootimage: $(BOOT_IMAGE)

$(BOOT_IMAGE): $(BIT_FILE) $(SW_FILES)
	$(info "BOOT image for platforms")
ifeq ($(PRE_SYNTH),TRUE)
	$(BOOTGEN) -arch $(PLATFORM_TYPE) -image $(CWD)/bootgen-pre-synth.bif -o $(BOOT_IMAGE) -w
else
	$(BOOTGEN) -arch $(PLATFORM_TYPE) -image $(CWD)/bootgen.bif -o $(BOOT_IMAGE) -w
endif	

rootfs: $(IMG_ROOTFS_FILES)

$(IMG_ROOTFS_FILES): $(PREBUILT_ROOTFS_FILES)
	mkdir -p $(IMAGE_DIR)
	cp -f $(PREBUILT_LINUX_PATH)/uImage $(IMAGE_DIR)/uImage
	mkdir -p $(SW_BUILD_DIR)/platform/filesystem
	cp -f $(PREBUILT_LINUX_PATH)/rootfs.ext4 $(SW_BUILD_DIR)/platform/filesystem/rootfs.ext4

sysroot:
	mkdir -p $(SYSROOT)
	@if [ ! -d $(SYSROOT_DIR)/usr/include ]; then $(PREBUILT_SDK) -y -d $(SYSROOT); fi

clean:
	${RM} -r $(SW_BUILD_DIR)

mrproper: clean
	$(info "Running mrproper")