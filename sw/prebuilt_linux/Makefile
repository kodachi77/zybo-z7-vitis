CWD = $(shell readlink -f .)
TOP_DIR = $(CWD)/../..
include $(TOP_DIR)/platform.mk

SYSTEM_USER_DTSI = $(CWD)/user_dts/system-user.dtsi
SYSTEM_CONF_DTS  =  $(CWD)/user_dts/system-conf.dtsi

IMG_ROOTFS_FILES = $(IMAGE_DIR)/uImage $(SW_DIR)/platform/filesystem/rootfs.ext4

.PHONY: all sw_comp dtb bootimage clean

$(XSA):
	$(MAKE) -C $(TOP_DIR) xsa

dtb: $(DTB_FILE)

$(DTB_FILE): $(XSA)
	$(info "Generating SW Artifacts...")
	@if [ ! -d $(BOOT_DIR) ]; then mkdir -p $(BOOT_DIR); fi
	mkdir -p $(SW_DIR)/tmp
	$(info "DTB generation started using XSCT")
	$(XSCT) -eval "setws $(SW_DIR)/tmp; createdts -hw $(XSA) -git-url https://github.com/kodachi77/device-tree-xlnx -git-branch xlnx_rel_$(VIVADO_VERSION) -board $(BOARD) -platform $(PLATFORM) -zocl -out $(SW_DIR)/tmp"
	$(eval BSP_PATH = $(SW_DIR)/tmp/$(PLATFORM)/$(CORE)/device_tree_domain/bsp/)
	cp -rf $(SYSTEM_CONF_DTS) $(BSP_PATH)
	cp -rf $(SYSTEM_USER_DTSI) $(BSP_PATH)
	@if [ -f $(SYSTEM_USER_DTSI) ]; then echo "#include \"system-user.dtsi\"" >> $(BSP_PATH)/system-top.dts; fi
	cat $(BSP_PATH)/system-top.dts
	cd $(BSP_PATH) && \
	cpp -Iinclude -E -P -undef -D__DTS__ -x assembler-with-cpp ./system-top.dts | $(DTC) -I dts -O dtb -o $(DTB_FILE) - && cd -
	#rm -rf $(SW_DIR)/tmp


sw_comp: $(SW_FILES)

$(SW_FILES): $(DTB_FILE)
	mkdir -p $(IMAGE_DIR)
	cp -f $(PREBUILT_LINUX_PATH)/boot.scr ${IMAGE_DIR}/boot.scr
	$(foreach BOOT_FILE,$(BOOT_FILES),cp -f $(PREBUILT_LINUX_PATH)/$(BOOT_FILE) $(BOOT_DIR) ;)
	
	# Generate fsbl file
	$(XSCT) -nodisp -sdx $(PLATFORM_SW_SRC)/generate_platform.tcl platform_name "${PLATFORM_NAME}" \
		xsa_path "${XSA}" emu_xsa_path "${HW_EMU_XSA}" platform_out "${PLATFORM_DIR}" \
		boot_dir_path "${BOOT_DIR}" img_dir_path "${IMAGE_DIR}" generate_sw true
	$(eval BOOT_ARTIFACTS = ${PLATFORM_DIR}/${PLATFORM_NAME}/export/${PLATFORM_NAME}/sw/${PLATFORM_NAME}/boot)
	cp -rf ${BOOT_ARTIFACTS}/*.elf ${BOOT_DIR} 
	# 2>/dev/null || :
	#${RM} -r ${PLATFORM_DIR}



all: check-prebuilt $(SW_FILES)

#image_rootfs: $(IMG_ROOTFS_FILES)
#bitfile: $(BIT_FILE)

clean:
	${RM} -r $(SW_DIR)

#platform: $(XSA) $(SW_FILES)
#	$(XSCT) -nodisp -sdx $(PLATFORM_SW_SRC)/generate_platform.tcl platform_name "${PLATFORM_NAME}" \
#		xsa_path "${XSA}" emu_xsa_path "${HW_EMU_XSA}" platform_out "${PLATFORM_DIR}" \
#		boot_dir_path "${BOOT_DIR}" img_dir_path "${IMAGE_DIR}" generate_sw false
#	@if [ -d $(SW_DIR)/platform/filesystem ]; then cp -rf ${SW_DIR}/platform/filesystem $(PLATFORM_DIR)/${PLATFORM_NAME}/export/${PLATFORM_NAME}/sw/${PLATFORM_NAME}/xrt/; fi
#	@echo 'Platform build complete'

$(BIT_FILE): $(XSA)
	mkdir -p $(SW_DIR)
	cp -f $(XSA) $(SW_DIR)/system.xsa
	cp -f $(BIT_FILE) $(SW_DIR)/hw.bit
	#@echo "openhw $(SW_DIR)/system.xsa" > $(SW_DIR)/extract
	#@echo "set bitstream_file [get_property BITSTREAM_FILE [current_hw_design]]" >> $(SW_DIR)/extract
	#@echo "file copy -force $$bitstream_file \"$(BIT_FILE)\"" >> $(SW_DIR)/extract
	#$(XSCT) $(SW_DIR)/extract

bootimage: $(BOOT_IMAGE)

$(BOOT_IMAGE): $(BIT_FILE) $(SW_FILES)
	$(info "BOOT image for platforms")
	$(BOOTGEN) -arch $(PLATFORM_TYPE) -image $(CWD)/bootgen.bif -o $(BOOT_IMAGE) -w;

#$(IMG_ROOTFS_FILES): $(SYSTEM_XSA) $(PETA_FILES)
#	cp -f $(PREBUILT_LINUX_PATH)/uImage $(IMAGE_DIR)/uImage
#	mkdir -p $(SW_DIR)/platform/filesystem
#	cp -f $(PREBUILT_LINUX_PATH)/rootfs.ext4 $(SW_DIR)/platform/filesystem/rootfs.ext4

mrproper:
	@echo Running mrproper