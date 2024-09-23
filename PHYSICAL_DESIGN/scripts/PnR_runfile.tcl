set search_path {/home/pd_assignment/reqd_files_to_cp_25/ndms/ /home/tools/14nm_Libraries/SAED14nm_EDK_SRAM_v_05072020/lib/sram/ndm }


set ref_libs {saed14_hvt_ss_normal.ndm saed14_lvt_ss_normal.ndm saed14_rvt_ss_normal.ndm saed14_sram_1rw_frame_only.ndm saed14_sram_2rw_frame_only.ndm}

#set tech_file /hdd2/home/ajayaz/saed14nm_1p9m_mw.tf
set tech_file /home/tools/14nm_Libraries/tech/milkyway/saed14nm_1p9m_mw.tf
#set tech_file /hdd2/home/ajayaz/14nm/inputs/saed14nm_1p9m_mw.tf
### Import_design
create_lib -ref_libs $ref_libs -technology $tech_file /home/acs/Desktop/Johnson/Chiptop/chiptop1/outputs/works/chiptop1.ndm
derive_design_level_via_regions
read_verilog /home/tools/14nm_Libraries/references/chiptop/multi_vt/dc/output/compile.v

read_sdc /home/tools/14nm_Libraries/references/chiptop/multi_vt/dc/output/compile.sdc









##floorplan ###
initialize_floorplan -site_def unit -flip_first_row true -core_utilization 0.7 -use_site_row -core_offset {10}
#set routing layers
set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction -value horizontal
set_attribute [get_layers {M2 M4 M6 M8 MRDL}] routing_direction -value vertical

##port placement##

set_app_options -name plan.macro.macro_place_only -value true

create_placement -floorplan

set_block_pin_constraints -self -sides 4 -pin_spacing 2 -allowed_layers {M4} 
place the input port side 4
place_pins -ports [get_ports *]


#place_pins -ports [get_ports *]    ## took will automatically place all ports ( io and clock) once the ports placed do fix them###
## macro placement ## 
## do macro manually using flyline analyses and giving spacing of 8-10 ##
set_attribute [get_flat_cells -filter "is_hard_macro"] physical_status -value fixed
# Apply Keepout margin to macros (1um)
create_keepout_margin [get_flat_cells -filter "is_hard_macro"] -type hard -outer {0.2 0.2 0.2 0.2}
# Apply Blockages -- Soft blockage 

#insert boundary cells
set_boundary_cell_rules -left_boundary_cell saed14_hvt_ss_normal/SAEDHVT14_CAPB2 -right_boundary_cell saed14_hvt_ss_normal/SAEDHVT14_CAPB2 -at_va_boundary

compile_boundary_cells
check_boundary_cells

#insert tap cells
create_tap_cells -lib_cell saed14_hvt_ss_normal/SAEDHVT14_CAPB2 -distance 20 -pattern stagger



save_block -as floorplan_done





## powerplan ##
remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect
connect_pg_net

#create_pg_ring_pattern P_HM_ring -horizontal_layer M7 -horizontal_width {0.5} -vertical_layer M6 -vertical_width {0.5} -corner_bridge false
#set_pg_strategy S_HM_ring_top -macros {MemYHier/MemXb MemYHier/MemXa MemXHier/MemXb MemXHier/MemXa} -pattern {{pattern: P_HM_ring}{nets: {VSS VDD}} {offset: {0.1 0.1}}}

#Compile_pg -strategies {S_HM_ring_top }



 create_pg_mesh_pattern  MESH_PATTERN7 -layers {{vertical_layer  M6} {width :0.2} {pitch : 0.7400}  {track_alignment : track}{trim : true}} 

set_pg_strategy VDD_MESH_STRATEGY7 -core  -pattern {{pattern: MESH_PATTERN7} {nets : VDD VSS } {offset: {0.12}}} 

compile_pg -strategies {VDD_MESH_STRATEGY7}


create_pg_macro_conn_pattern scatter_pin_patternv -pin_conn_type scattered_pin -nets {VDD VSS}
set_pg_strategy -core -pattern {{pattern : scatter_pin_patternv} {nets : VDD VSS}} macro_1
compile_pg -strategies {macro_1}



create_pg_mesh_pattern  MESH_PATTERN7 -layers {{horizontal_layer  M7} {width :0.2} {pitch : 0.7400} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY7 -core  -pattern {{pattern: MESH_PATTERN7} {nets :VDD VSS} {offset: {0.12}} } 

compile_pg -strategies {VDD_MESH_STRATEGY7} 


create_pg_mesh_pattern  MESH_PATTERN8 -layers {{vertical_layer  M8} {width :0.2} {pitch : 0.7400} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY8 -core  -pattern {{pattern: MESH_PATTERN8} {nets :VDD VSS} {offset: {0.12}} } 

compile_pg -strategies {VDD_MESH_STRATEGY8} 




## Create std rail #VDD VSS



create_pg_std_cell_conn_pattern std_rail_conn1 -layers M1 

set_pg_strategy  std_rail_1 -pattern {{name : std_rail_conn1} {nets: VDD VSS}} -core

compile_pg -strategies std_rail_1

save_block -as powerplan_done



##placement##
set_app_options -name time.disable_recovery_removal_checks -value false

set_app_options -name time.disable_case_analysis -value false

set_app_options -name place.coarse.continue_on_missing_scandef -value true



read_parasitic_tech -tlup /home/tools/14nm_Libraries/tech/star_rc/max/saed14nm_1p9m_Cmax.tluplus -layermap /home/tools/14nm_Libraries/tech/star_rc/saed14nm_tf_itf_tluplus.map -name Cmax
read_parasitic_tech -tlup /home/tools/14nm_Libraries/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus -layermap /home/tools/14nm_Libraries/tech/star_rc/saed14nm_tf_itf_tluplus.map -name Cmin


source /home/acs/Desktop/Johnson/Chiptop/inputs/mcmm.tcl
read_sdc /home/tools/14nm_Libraries/references/chiptop/multi_vt/dc/output/compile.sdc


create_placement -timing_driven

legalize_placement

place_opt 


save_block -as placement_done 
## check timing check congestion ##

##clock tree synthesis##
create_routing_rule ROUTE_RULES_1 \
  -widths {M3 0.2 M4 0.2 } \
  -spacings {M3 0.42 M4 0.63 }

set_clock_routing_rules -rules ROUTE_RULES_1 -min_routing_layer M3 -max_routing_layer M4



clock_opt
save_block -as cts_done
## check hold timing and other clock reports ##

## routing ##

remove_ignored_layers -all
set_ignored_layers \
    -min_routing_layer  M2
    -max_routing_layer  M6

route_opt
save_block -as route_done
## check final timing and short opens
