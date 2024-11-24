#!/bin/sh

#petalinux-config --get-hw-description=../hw/hw_handoff/
#petalinux-config -c rootfs
#petalinux-config -c kernel

#petalinux-build

#petalinux-build --sdk
#petalinux-package --boot --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --uboot --force
petalinux-package --sysroot

