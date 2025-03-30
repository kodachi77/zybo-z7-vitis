set overlay_name "hw"
set design_name "zybo_z7_20_base_202201"

set root_path [file normalize [file dirname [info script]]/..]

source [file join ${root_path} project_info.tcl]

set_param board.repoPaths "$::env(HOME)/.Xilinx/Vivado/2022.1/xhub/board_store/xilinx_board_store"

# open block design
open_project ${overlay_name}.xpr
open_bd_design ${overlay_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd


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
file mkdir ../hw_handoff/hw_emu
write_hw_platform -force -hw_emu -file ../hw_handoff/hw_emu/${overlay_name}.xsa

set pre_synth false

if { $argc >= 1} {
  set pre_synth [lindex $argv 0]
}
if {$pre_synth} {
  set_property platform.platform_state "pre_synth" [current_project]
  write_hw_platform -hw -force -file ../hw_handoff/${overlay_name}.xsa
} else {
  launch_runs impl_1 -to_step write_bitstream -jobs 4
  wait_on_run impl_1
  write_hw_platform -include_bit -force -file ../hw_handoff/${overlay_name}.xsa
}

validate_hw_platform ../hw_handoff/${overlay_name}.xsa

# needs GUI mode
# write_bd_layout -format pdf -orientation landscape -force ${root_path}/hw_handoff/system.pdf

#generate README.txt

set fd [open ../hw_handoff/README.txt w] 

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

