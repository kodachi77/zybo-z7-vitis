include platform.mk

.PHONY: all xsa linux sysroot platform clean

xsa: $(XSA)

$(XSA):
	$(MAKE) -C hw all

linux: $(SW_FILES)

$(SW_FILES): $(XSA)
	$(MAKE) -C sw all

sysroot:
	$(MAKE) -C sw/prebuilt_linux sysroot

rootfs:
	$(MAKE) -C sw/prebuilt_linux rootfs

all platform: $(XSA) $(SW_FILES) rootfs sysroot
	$(XSCT) -nodisp -sdx $(PLATFORM_SW_SRC)/generate_platform.tcl \
		platform_name "${PLATFORM_NAME}" \
		xsa_path "${XSA}" \
		emu_xsa_path "${HW_EMU_XSA}" \
		platform_out "${PLATFORM_DIR}" \
		boot_dir_path "${BOOT_DIR}" \
		img_dir_path "${IMAGE_DIR}" \
		rootfs_file "$(SW_BUILD_DIR)/platform/filesystem/rootfs.ext4" \
		sysroot_path "${SYSROOT_DIR}" \
		generate_sw false
	@echo "Platform '${PLATFORM_NAME}' build complete!"

clean:
	$(MAKE) -C hw clean
	$(MAKE) -C sw clean
	${RM} -r .Xil

mrproper:
	$(MAKE) -C hw mrproper
	$(MAKE) -C sw mrproper
	${RM} -r $(PLATFORM_DIR) .Xil
