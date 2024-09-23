# Routing  
####################################  
route_auto  
 
check_routes  
 
report_qor -summary  
set_app_options -name time.si_enable_analysis -value true  
set_app_options -name time.enable_ccs_rcv_cap -value true  
# Will only work with CCS libraries:  
set_app_options -name time.delay_calc_waveform_analysis_mode -value full_design  
# set_app_options -name time.awp_compatibility_mode -value false   ;# false by default  
report_qor -summary  
set_app_options -name time.enable_si_timing_windows -value true  
report_qor -summary  
report_qor -summary -pba_mode path  
 
route_opt  
report_qor -summary  
## To disable soft-rule-based timing optimization during ECO routing, uncomment the following.  
#  This is to limit spreading which can touch multiple routes and impact convergence.  
set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false  
set_app_options -name route_opt.flow.enable_ccd -value false  
    
route_opt  
report_qor -summary -pba_mode path  
save_block -as route_Done


#************ROUTE 2******************
#open_lib ./outputs/work/ORCA_TOP.nlib
#copy_block -from_block clock_opt_ccd.design -to_block route
#current_block route
#
##procs.tcl
#source ./scripts/procs.tcl
#
##### making clock network untouched
##set_dont_touch_network [all_clocks]
#
##NDR's
##clock rules
#set_clock_routing_rules -net_type sink -rules iccrm_clock_double_spacing -min_routing_layer M4 -max_routing_layer M5
##power rules
#
##### modifying application options
########	Deciding the metal layers
#set_ignored_layers -min_routing_layer M2 -max_routing_layer M5
######## Modifing the top an bottom layer attributed
#set_app_options -list { \
	#route.common.global_max_layer_mode soft \
	#route.common.global_min_layer_mode allow_pin_connection \
#}
#
######## Enabling the signal integrity related
#set_app_options -list { \
	#time.si_enable_analysis true \
	#time.enable_si_timing_windows true \
	#time.enable_ccs_rcv_cap true \
#}
#
######## Performing route related options change
#set_app_options -list { \
	#route.global.timing_driven true \
	#route.track.timing_driven true \
	#route.detail.timing_driven true \
	#route.global.crosstalk_driven true \
	#route.track.crosstalk_driven true \
	#route_opt.flow.xtalk_reduction true \
#}
#
##### performing routing
## global routing
## 	route_global
#
## track assignment
## 	route_track
#
## detail routing
## 	route_detail
#set_app_options -list { \
	#opt.common.user_instance_name_prefix route_detail \
	#cts.common.user_instance_name_prefix route_detail \
#}
#route_auto \
	#-save_after_global_route true  \
	#-save_after_track_assignment true \
	#-save_after_detail_route true \
	#-max_detail_route_iterations 20 
	#-save_cell_prefix route_auto
#
#cts route_detail
#
#set_app_options -list { \
	#opt.common.user_instance_name_prefix route_opt \
	#cts.common.user_instance_name_prefix route_opt \
#}
#
#route_opt
#cts route_opt
#
#save_block
#
##sanity checks
#	
#check_routes
#check_lvs
