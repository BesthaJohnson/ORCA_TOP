set search_path " . /home/vlsiguru/PHYSICAL_DESIGN/TRAINER2/PD/PROJECTS/RISC/ICC2/ref/CLIBs /home/vlsiguru/PHYSICAL_DESIGN/TRAINER2/PD/PROJECTS/RISC/ICC2/ref/tech /home/vlsiguru/PHYSICAL_DESIGN/TRAINER2/PD/PROJECTS/RISC/ICC2/ref/ORCA_TOP_design_data /home/vlsiguru/PHYSICAL_DESIGN/TRAINER2/PD/PROJECTS/RISC/ICC2/ref/DBs /home/vlsiguru/PHYSICAL_DESIGN/TRAINER2/PD/PROJECTS/RISC/ICC2/ref/ORCA_TOP_constraints /home/vlsiguru/PHYSICAL_DESIGN/TRAINER2/PD/PROJECTS/RISC/ICC2/ORCA_TOP/other_scripts "
# to activate all scenarios
set_scenario_status -active true [all_scenarios] ;
#set_scenario_status -active true [get_scenarios "func.ff_m40c test.ff_125c"]

#set_scenario_status -active false [get_scenarios -filter active]
#set_scenario_status -active true <>
set_app_options -name cts.compile.primary_corner -value ss_125c

set REPORTS_DIR ../rpts
set REPORT_PREFIX clock_opt
synthesize_clock_trees -propagate_only

set_app_options -name cts.common.user_instance_name_prefix -value CLOCK_
set_app_options -name opt.common.user_instance_name_prefix -value CLOCK_OPT

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}.report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}.report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}.pre_cts.report_clock_settings {report_clock_settings} ;# CTS constraints and settings
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}.pre_cts.check_clock_tree {check_clock_tree} ;# checks issues that could hurt CTS results

#synthesize_multisource_clock_taps
## Propagate clock for timer to see actual transitions on the Htree before CTS
#synthesize_clock_trees -propagate_only
## Run clock mesh simulation with clocks propagated 
#analyze_subcircuit
create_routing_rule icc2_2w2s -default_reference_rule -multiplier_width 2 -multiplier_spacing 2
set_clock_routing_rules -net_type root -rule icc2_2w2s -min_routing_layer M3 -max_routing_layer M4
set_clock_routing_rules -net_type internal -rule icc2_2w2s -min_routing_layer M3 -max_routing_layer M4
create_routing_rule icc2_leaf -default_reference_rule
set_clock_routing_rules -net_type sink -rule icc2_leaf -min_routing_layer M1 -max_routing_layer M4


set_dont_touch [get_lib_cells "*/TIEH_RVT */TIEL_RVT" ] false
set_lib_cell_purpose -include optimization [get_lib_cells  "*/TIEH_RVT */TIEL_RVT"]

set_dont_touch [get_lib_cells "*/NBUFFX2_HVT */NBUFFX4_HVT"] false
set_lib_cell_purpose -exclude hold [get_lib_cells */*]
set_lib_cell_purpose -include hold [get_lib_cells "*/NBUFFX2_HVT */NBUFFX4_HVT"]

set_dont_touch [get_lib_cells "*/NBUFFX8_LVT */NBUFFX4_LVT"] false
set_lib_cell_purpose -exclude cts [get_lib_cells */*]
set_lib_cell_purpose -include none [get_lib_cells "*/NBUFFX8_LVT */NBUFFX4_LVT"]
set_lib_cell_purpose -include cts [get_lib_cells "*/NBUFFX8_LVT */NBUFFX4_LVT"]
get_lib_cells -filter {valid_purposes==cts}

set_max_transition 0.120 -clock_path [get_clocks *]
report_timing
#Clock should not ideal

#<TCL with set_clock_balancing_points> 
#source <file name>
puts "Running clock_opt -from build_clock -to build_clock command"
clock_opt -from build_clock -to build_clock
save_block -as clock_opt_build_clock

puts "Running clock_opt -from route_clock -to route_clock command"
clock_opt -from route_clock -to route_clock
save_block -as clock_opt_clock_route

connect_pg_net
## Save block
save_block


## Enable the AOCV analysis
#set_app_options -name time.aocvm_enable_analysis -value true ;# default false
## Enable the AOCV distance analysis (optional)
## AOCV analysis will consider path distance when calculating AOCVM derate
#	set_app_options -name time.ocvm_enable_distance_analysis -value true ;# default false
## Set the configuration for the AOCV analysis (optional)
#	set_app_options -name time.aocvm_analysis_mode -value separate_launch_capture_depth ;# default separate_launch_capture_depth

## Below is an example to route the bus
#### Define the bus
##create_bundle -name {bus1}  [get_nets my_bus_net_*]
##
#### Define, set the bus constraints
##create_bus_routing_style -for {bus1} -valid_layers {M5 M6} -layer_widths {M5 0.4 M6 0.4} -layer_spacings {M5 0.4 M6 0.4} -force bus1
##
#### Route the bus
##route_custom -nets {bus1}


redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}.check_routes {check_routes -open_net false}

set REPORT_QOR_REPORT_POWER true
set INIT_DESIGN_BLOCK_NAME 		"init_design" 			
set PLACE_OPT_BLOCK_NAME 		"place_opt" 			
set CLOCK_OPT_CTS_BLOCK_NAME 		"clock_opt_cts" 		
set CLOCK_OPT_OPTO_BLOCK_NAME 		"clock_opt_opto" 		
set ROUTE_AUTO_BLOCK_NAME 		"route_auto" 			
set ROUTE_OPT_BLOCK_NAME 		"route_opt" 			
set CHIP_FINISH_BLOCK_NAME 		"chip_finish" 			
set ICV_IN_DESIGN_BLOCK_NAME 		"icv_in_design" 		
set WRITE_DATA_FROM_BLOCK_NAME 	 $ICV_IN_DESIGN_BLOCK_NAME 	
set WRITE_DATA_BLOCK_NAME 		"write_data" 			
set ECO_OPT_FROM_BLOCK_NAME 	$ROUTE_OPT_BLOCK_NAME 		
set ECO_OPT_BLOCK_NAME 			"eco_opt" 			
set FUNCTIONAL_ECO_FROM_BLOCK_NAME $ROUTE_OPT_BLOCK_NAME 		
set FUNCTIONAL_ECO_BLOCK_NAME	 "functional_eco"		
set PT_ECO_FROM_BLOCK_NAME 		$ROUTE_OPT_BLOCK_NAME 	
set PT_ECO_BLOCK_NAME 			"pt_eco" 		
set PT_ECO_INCREMENTAL_FROM_BLOCK_NAME 	$ROUTE_OPT_BLOCK_NAME 	
set PT_ECO_INCREMENTAL_1_BLOCK_NAME 	"pt_eco_incremental_1" 	
set PT_ECO_INCREMENTAL_2_BLOCK_NAME 	"pt_eco_incremental_2" 	
set REDHAWK_IN_DESIGN_PNR_FROM_BLOCK_NAME $INIT_DESIGN_BLOCK_NAME	
set USE_ABSTRACTS_FOR_BLOCKS        	[list ]
set REPORT_QOR				true 
set REPORT_QOR_SCRIPT 			"report_qor.nosplit.tcl" 
set REPORT_QOR_REPORT_POWER	 true 
set REPORT_QOR_REPORT_CONGESTION true 
source   /home/vlsiguru/PHYSICAL_DESIGN/TRAINER2/PD/PROJECTS/RISC/ICC2/ORCA_TOP/other_scripts/report_qor.nosplit.tcl


#ANA clock_opt -from final_opto -to final_opto
#ANA save_block -as clock_opt_cto
#ANA synthesize_clock_trees -postroute -routed_clock_stage detail
#ANA connect_pg_net
#ANA save_block


**************CTS2**************************
####pre sanity checks

check_design -checks pre_clock_tree_stage
report_clock
report_qor
current_mode
current_mode func

report_clocks
report_clocks -skew
report_clocks -groups

#v report_clock_qor -mode func
#v report_clock_qor -mode test

report_ports [get_ports sd_CK]

#ndr rule
source /hdd2/home/anusha/project/ICC2/lab7_cts/scripts/cts_ex_ndr.tcl
#/hdd2/home/anusha/project/ICC2/lab7_cts/scripts/ndr.tcl
current_mode
current_mode func

report_clocks
report_clocks -skew
report_clocks -groups

#v report_clock_qor -mode func
#v report_clock_qor -mode test

report_ports [get_ports sd_CK]

get_scenarios -filter active&&hold
report_scenarios
set_scenario_status test.ff_125c -hold true

set_lib_cell_purpose -exclude hold [get_lib_cells]
set_lib_cell_purpose -include hold [get_lib_cells **/NBUFFX2_HVT */NBUFFX4_HVT */NBUFFX8_HVT*]
set_lib_cell_purpose -include hold [get_lib_cells **/NBUFFX2_RVT */NBUFFX4_RVT */NBUFFX8_RVT*]
set_app_options -name opt.dft.clock_aware_scan_reorder -value true
set_app_options -name time.remove_clock_reconvergence_pessimism -value true

foreach_in_collection mode [all_modes] {
   current_mode $mode
   set_latency_adjustment_options -exclude_clocks "*"
   set_latency_adjustment_options -reference_clock PCI_CLK -clocks_to_update v_PCI_CLK
}

#v check_clock_trees

return
report_clock_qor

#v report_clock_qor -type local_skew

report_clock_qor -type area
report_clock_qor -mode func -corner ss_125c -significant_digits 3

#v report_clock_qor -type robustness -mode func -corner ff_m40c -robustness_corner ss_125c

report_clock_timing -type skew -modes func -corners ss_125c -significant_digits 3

report_qor -summary

clock_opt -from final_opto

save_block -as ctsdone

source /hdd2/home/anusha/project/ICC2/lab7_cts/scripts/margins_for_ccd.tcl
report_qor -summary

set_app_options -name clock_opt. flow.enable_ccd  -value true

clock_opt

save_block -as CTS_done
