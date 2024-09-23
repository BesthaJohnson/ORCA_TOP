#### Pre placement checks
check_design -checks pre_placement_stage
check_design -checks physical_constraints
check_legality

#### providing the timing information
source ./inputs/sdc_constraints/mcmm_ORCA_TOP.tcl

#### providing the scan-chain information
remove_scan_def
read_def inputs/ORCA_TOP_design_data/ORCA_TOP.scandef
report_scan_chains


##fix hard macros###

set_attribute [get_cells -hierarchical -filter "is_hard_macro"] physical_status fixed


#### Modifying the attributes of the TIE cells
set_attribute [get_lib_cells */*TIE*] dont_touch false
set_attribute [get_lib_cells */*TIE*] dont_use false

#### Modifying the application options
set_app_options -list {place.legalize.enable_advanced_legalizer true \
		       place.legalize.legalizer_search_and_repair true \
		       opt.common.max_fanout 30 \
}

#creating the configuration for the utilization calculation to be used in the procs.tcl
create_utilization_configuration place -include all -force

#group_path
report_path_group
report_global_timing -seperate_all_groups
group_path -name IN2REG -from [all_inputs ] -to [all_registers] 
group_path -name REG2REG -from [all_registers] -to [all_registers] 
group_path -name REG2OUT -from [all_registers] -to [all_outputs]
group_path -name IN2OUT -from [all_inputs ] -to [all_outputs] 


#### running the placement commands
#	Coarse Placement
create_placement

#	Legalize_placement
legalize_placement

#	Detail Placement
set_app_option -name opt.common.user_instance_name_prefix -value "initial_drc"
place_opt -from initial_drc -to initial_drc
placement_sanity initial_drc
count_area initial_drc
save_block -as initial_drc_john1

set_app_option -name opt.common.user_instance_name_prefix -value "initial_opto"
place_opt -from initial_opto -to initial_opto
placement_sanity initial_opto
count_area initial_opto
save_block -as initial_opto_john2

set_app_option -name opt.common.user_instance_name_prefix -value "final_place"
place_opt -from final_place -to final_place
placement_sanity final_place
count_area final_place
save_block -as final_place_john3

set_app_option -name opt.common.user_instance_name_prefix -value "final_opto"
place_opt -from final_opto -to final_opto
placement_sanity final_opto
count_area final_opto
save_block -as final_place_opt_john4

#Un-comment the following lines if you dont want the script to be working in batch mode

#close_blocks -force
#close_lib
#
