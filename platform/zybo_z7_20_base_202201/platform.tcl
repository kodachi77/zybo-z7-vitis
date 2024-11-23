# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/kodachi77/project/zybo-z7-vitis/platform/zybo_z7_20_base_202201/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/kodachi77/project/zybo-z7-vitis/platform/zybo_z7_20_base_202201/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {zybo_z7_20_base_202201}\
-hw {/home/kodachi77/project/zybo-z7-vitis/hw/hw_handoff/zybo_z7_20_base_202201_wrapper.xsa}\
-proc {ps7_cortexa9} -os {linux} -out {/home/kodachi77/project/zybo-z7-vitis/platform}

platform write
platform active {zybo_z7_20_base_202201}
domain config -bif {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/linux.bif}
platform write
domain config -boot {/home/kodachi77/project/zybo-z7-vitis/os/images/linux}
platform write
domain config -rootfs {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/rootfs.cpio}
platform write
domain config -image {/home/kodachi77/project/zybo-z7-vitis/os/images/linux}
platform write
domain config -sysroot {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/sdk/sysroots/cortexa9t2hf-neon-xilinx-linux-gnueabi}
platform write
platform generate
domain config -qemu-data {/home/kodachi77/project/zybo-z7-vitis/os/images/linux}
platform write
platform generate -domains 
domain config -bif {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/bootgen.bif}
platform write
platform generate -domains 
platform active {zybo_z7_20_base_202201}
domain config -qemu-args {/home/kodachi77/project/zybo-z7-vitis/platform/zybo_z7_20_base_202201/resources/zybo_z7_20_base_202201/linux_domain/qemu_args.txt}
platform write
domain config -qemu-args {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/qemu_args.txt}
platform write
domain config -bif {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/linux.bif}
platform write
platform generate -domains 
domain config -qemu-args {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/~qemu_args.txt}
platform write
domain config -qemu-args {/home/kodachi77/project/zybo-z7-vitis/os/images/linux/qemu_args.txt}
platform write
platform generate -domains 
platform clean
platform generate
platform clean
platform generate
platform clean
platform clean
