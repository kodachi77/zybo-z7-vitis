#!/bin/sh

sudo -v

petalinux-config --get-hw-description=../hw/hw_handoff/
petalinux-config -c rootfs
petalinux-config -c kernel
petaliux-config -c u-boot

petalinux-build

petalinux-build --sdk
petalinux-package --boot --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot --boot-device sd --force
#petalinux-package --boot --bif images/linux/BOOT.bif --boot-device sd --force
petalinux-package --sysroot

sudo chown $USER:$USER images/linux/sdk/sysroots/cortexa9t2hf-neon-xilinx-linux-gnueabi/usr/bin/sudo