set overlay_name "hw"
set design_name "zybo_z7_20_base_202201"

set root_path [file normalize [file dirname [info script]]/..]

source [file join ${root_path} project_info.tcl]

# open block design
open_project ${overlay_name}.xpr
open_bd_design ${overlay_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd
# write_bd_layout -format pdf -orientation landscape -force ${root_path}/hw_handoff/system.pdf

# set platform properties
set_property platform.default_output_type "sd_card" [current_project]
set_property platform.design_intent.embedded "true" [current_project]
set_property platform.design_intent.server_managed "false" [current_project]
set_property platform.design_intent.external_host "false" [current_project]
set_property platform.design_intent.datacenter "false" [current_project]

# call implement
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# generate xsa
set_property platform.extensible true [current_project]
# set_property platform.uses_pr 0 [current_project]
# set_property board_part digilentinc.com:zybo-z7-20:part0:1.1 [current_project]
write_hw_platform -fixed -include_bit -force -file ../${overlay_name}.xsa
validate_hw_platform ../hw_handoff/${overlay_name}.xsa
