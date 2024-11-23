#!/bin/sh

# petalinux-config --get-hw-description=../hw/hw_handoff/
# petalinux-config -c rootfs
# petalinux-config -c kernel

petalinux-build

petalinux-package --boot --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --uboot --force
petalinux-build --sdk
petalinux-package --sysroot

#sudo cp "/home/kodachi77/project/zybo-z7-vitis/os/images/linux/sdk/sysroots/cortexa9t2hf-neon-xilinx-linux-gnueabi/usr/bin/sudo" "/home/kodachi77/project/zybo-z7-vitis/platform/zybo_z7_20_base_202201/export/zybo_z7_20_base_202201/sw/zybo_z7_20_base_202201/linux_domain/sysroot/cortexa9t2hf-neon-xilinx-linux-gnueabi/usr/bin/sudo"
