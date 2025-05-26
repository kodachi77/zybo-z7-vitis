# parsing options
set options [dict create {*}$argv]

set xsa_path [dict get $options xsa_path]
set platform_name [dict get $options platform_name]
set emu_xsa_path [dict get $options emu_xsa_path]
set platform_out [dict get $options platform_out]
set boot_dir_path [dict get $options boot_dir_path]
set img_dir_path [dict get $options img_dir_path]
set rootfs_file [dict get $options rootfs_file]
set sysroot_path [dict get $options sysroot_path]
set generate_sw [dict get $options generate_sw]

set image_path [file dirname $rootfs_file]

set plat_arg [list]
if {$xsa_path ne "" && [file exists $xsa_path] } {
  lappend plat_arg -hw
  lappend plat_arg $xsa_path
}

if {$emu_xsa_path ne "" && [file exists $emu_xsa_path] } {
  lappend plat_arg -hw_emu
  lappend plat_arg $emu_xsa_path
}

if {$generate_sw} {
  # Generate sw components(eg: fsbl, pmufw)
  platform -name $platform_name {*}$plat_arg -out $platform_out
  domain -name xrt -proc ps7_cortexa9 -os linux -sd-dir $img_dir_path
  platform generate
  exit
}

platform -name $platform_name -desc "A basic static platform targeting the Zybo Z7-20 evaluation board, which includes 1GB DDR3, GEM, USB, SDIO interface and UART of the Processing System. It reserves most of the PL resources for user to add acceleration kernels" {*}$plat_arg -out $platform_out

domain -name xrt -proc ps7_cortexa9 -os linux -sd-dir $img_dir_path
domain config -boot $boot_dir_path
domain config -generate-bif
domain -runtime opencl
domain -qemu-data $boot_dir_path

set image_file [file join $img_dir_path uImage]

if {[file isfile $image_file]} {
  domain config -image $img_dir_path
} else {
    puts "WARNING: $image_file not found. Skipping -image domain"
}


set usr_include_path [file join $sysroot_path usr include]

if {[file isfile $rootfs_file]} {
  domain config -rootfs $rootfs_file
} else {
    puts "WARNING: $rootfs_file not found. Skipping -rootfs domain"
}


if {[file isdirectory $usr_include_path]} {
    domain config -sysroot $sysroot_path
} else {
    puts "WARNING: /usr/include not found in $sysroot_path. Skipping -sysroot domain"
}

platform generate
exit
