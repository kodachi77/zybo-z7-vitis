#!/bin/sh

sudo -v

pl_name="zybo_z7_20_base_202201"
arch_name="cortexa9t2hf-neon-xilinx-linux-gnueabi"

sudo cp "../os/images/linux/sdk/sysroots/${arch_name}/usr/bin/sudo" "${pl_name}/export/${pl_name}/sw/${pl_name}/linux_domain/sysroot/${arch_name}/usr/bin/sudo"
