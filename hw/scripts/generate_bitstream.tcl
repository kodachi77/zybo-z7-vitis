# parsing options
set options [dict create {*}$argv]

set pre_synth [expr {[string tolower [dict get $options pre_synth]] in {"1" "true" "yes"}}]
set platform_name [dict get $options platform]
set platform_version [dict get $options version]
set xsa_path [dict get $options xsa_path]
set xsa_hw_emu_path [dict get $options xsa_hw_emu_path]
set bitfile_path [dict get $options bitfile_path]
set readme_path [dict get $options readme_path]

#set overlay_name "hw"
set project_name [file rootname [file tail $xsa_path]]
set design_name system

set root_path [file normalize [file dirname [info script]]/..]

source [file join ${root_path} project_info.tcl]

set_param board.repoPaths "$::env(HOME)/.Xilinx/Vivado/2022.1/xhub/board_store/xilinx_board_store"

# open block design
open_project ${project_name}.xpr
open_bd_design ${project_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd


# set platform properties
set_property platform.default_output_type "sd_card" [current_project]
set_property platform.design_intent.embedded "true" [current_project]
set_property platform.design_intent.server_managed "false" [current_project]
set_property platform.design_intent.external_host "false" [current_project]
set_property platform.design_intent.datacenter "false" [current_project]
set_property platform.extensible true [current_project]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# generate the final simulation script which will compile
launch_simulation -scripts_only
launch_simulation -step compile
launch_simulation -step elaborate

# generate emulation xsa
write_hw_platform -force -hw_emu -file ${xsa_hw_emu_path} 

if {$pre_synth} {
  set_property platform.platform_state "pre_synth" [current_project]
  write_hw_platform -hw -force -file ${xsa_path} 
 else {
  launch_runs impl_1 -to_step write_bitstream -jobs 4
  wait_on_run impl_1
  open_run impl_1
  write_bitstream -force ${bitfile_path} 
  write_hw_platform -include_bit -force -file ${xsa_path} 
}

validate_hw_platform ${xsa_path} 

# needs GUI mode
# write_bd_layout -format pdf -orientation landscape -force ${root_path}/hw_handoff/system.pdf

# generate README.txt

set fd [open ${readme_path} w] 

puts $fd "##############################################################################################"
puts $fd "# This is a brief document containing design specific details for HW platform."
puts $fd "# This file is auto-generated. DO NOT EDIT."
puts $fd "##############################################################################################"

set board_part [get_board_parts [current_board_part -quiet]]
if { $board_part != ""} {
  puts $fd "BOARD: $board_part" 
}

set design_name [get_property NAME [get_bd_designs]]
puts $fd "BLOCK DESIGN: $design_name" 
puts $fd "PRE SYNTH: ${pre_synth}"

set columns {%40s%30s%15s%50s}
puts $fd [string repeat - 150]
puts $fd [format $columns "MODULE INSTANCE NAME" "IP TYPE" "IP VERSION" "IP"]
puts $fd [string repeat - 150]
foreach ip [get_ips] {
  set catlg_ip [get_ipdefs -all [get_property IPDEF $ip]] 
  puts $fd [format $columns [get_property NAME $ip] [get_property NAME $catlg_ip] [get_property VERSION $catlg_ip] [get_property VLNV $catlg_ip]]
}
close $fd

