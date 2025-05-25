include platform.mk

.PHONY: all xsa linux sysroot platform clean

xsa: $(XSA)

$(XSA):
	@echo $(XSA)
	$(MAKE) -C hw all

linux: $(SW_FILES)

$(SW_FILES): $(XSA)
	$(MAKE) -C sw all

sysroot:
	$(MAKE) -C sw/petalinux sysroot

all platform: $(XSA) $(SW_FILES)
	$(XSCT) -nodisp -sdx $(PLATFORM_SW_SRC)/generate_platform.tcl platform_name "${PLATFORM_NAME}" \
		xsa_path "${XSA}" emu_xsa_path "${HW_EMU_XSA}" platform_out "${PLATFORM_DIR}" \
		boot_dir_path "${BOOT_DIR}" img_dir_path "${IMAGE_DIR}" generate_sw false
	
	@if [ -d $(SW_DIR)/platform/filesystem ]; then cp -rf ${SW_DIR}/platform/filesystem $(PLATFORM_DIR)/${PLATFORM_NAME}/export/${PLATFORM_NAME}/sw/${PLATFORM_NAME}/xrt/; fi
	@echo 'Platform build complete'

clean:
	$(MAKE) -C hw clean
	$(MAKE) -C sw clean
	${RM} -r .Xil

mrproper:
	$(MAKE) -C hw mrproper
	$(MAKE) -C sw mrproper
	${RM} -r $(PLATFORM_DIR)
