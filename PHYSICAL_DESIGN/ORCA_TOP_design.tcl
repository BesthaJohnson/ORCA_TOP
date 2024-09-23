#!/bin/tclsh
####################################
# ORCA PNR FLOW BY RAJINEE
###################################

set ndm_file "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/saed32_ndm/"
set ndm "[glob -directory $ndm_file *.ndm]"

set tech "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/tech/saed32nm_1p9m_mw.tf"
create_lib -technology $tech ../blocks/my_orca -ref_libs $ndm


set verilog "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_design_data/ORCA_TOP.v"
read_verilog $verilog

save_lib
remove_scenarios -all
remove_modes -all
remove_corners -all

set m_constr(func) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_m_func.tcl"
set m_constr(test)  "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_m_test.tcl"

set c_constr(ss_125c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_c_ss_125c.tcl"
set c_constr(ss_m40c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_c_ss_m40c.tcl"
set c_constr(ff_125c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_c_ff_125c.tcl"
set c_constr(ff_m40c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_c_ff_m40c.tcl"

set s_constr(func.ss_125c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_s_func.ss_125c.tcl"
set s_constr(func.ss_m40c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_s_func.ss_m40c.tcl"
set s_constr(func.ff_125c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_s_func.ff_125c.tcl"
set s_constr(func.ff_m40c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_s_func.ff_m40c.tcl"
set s_constr(test.ss_125c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_s_test.ss_125c.tcl"
set s_constr(test.ff_125c) "/home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_s_test.ff_125c.tcl"


########################################
## Mode, corner and scenario creation
########################################

foreach m [array names m_constr] {
	create_mode $m
}
get_modes
#{test func}

foreach c [array names c_constr] {
	create_corner $c
}
get_corners 
#{ss_125c ss_m40c ff_125c ff_m40c}


foreach s [array names s_constr] {
	lassign [split $s "."] m c
	create_scenario -name $s  -mode $m  -corner $c
}
get_scenarios
#{func.ff_125c func.ff_m40c func.ss_125c func.ss_m40c test.ff_125c test.ss_125c}

########################################
## Populate modes, corners and scenarios
########################################

# Common file contains port names for constraints
source /home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_constraints/ORCA_TOP_port_lists.tcl

foreach m [array names m_constr] {
	current_mode $m
	source $m_constr($m)
}

read_parasitic_tech -tlup /home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/tech/saed32nm_1p9m_Cmax.tluplus -layermap /home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/tech/saed32nm_tf_itf_tluplus.map  -name maxTLU
read_parasitic_tech -tlup /home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/tech/saed32nm_1p9m_Cmin.tluplus -layermap /home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/tech/saed32nm_tf_itf_tluplus.map -name minTLU
foreach c [array names c_constr] {
	current_corner $c
	source $c_constr($c)
}

foreach s [array names s_constr] {
	current_scenario $s
	source $s_constr($s)
}

########################################
## Configure scenarios
########################################

set_scenario_status {func.ss_125c func.ss_m40c test.ss_125c func.ff_125c} -hold false
set_scenario_status {test.ss_125c} -leakage_power false -dynamic_power false
set_scenario_status {func.ff_125c func.ff_m40c test.ff_125c} -setup false

report_qor -summary
report_clock

####################################################################################
#Clock          Period   Waveform            Attrs     Sources
#--------------------------------------------------------------------------------
#PCI_CLK          7.50   {0 3.75}                      {pclk}
#SDRAM_CLK        4.10   {0 2.05}                      {sdram_clk}
#SD_DDR_CLK    	  4.10   {0 2.05}             G, U     {sd_CK}
#SD_DDR_CLKn      4.10   {2.05 4.1}           G, U     {sd_CKn}
#SYS_2x_CLK       2.40   {0 1.2}                       {sys_2x_clk}
#SYS_CLK       	  4.80   {0 2.4               G, U      {I_CLOCKING/sys_clk_in_reg/Q}
#v_PCI_CLK        7.50   {0 3.75}                      {}
#v_SDRAM_CLK      4.10   {0 2.05}                      {}

#Generated     Master          Generated       Master          Waveform
#Clock         Source          Source          Clock           Modification
#--------------------------------------------------------------------------------
#SD_DDR_CLK    sdram_clk       sd_CK           *               div(1), combinational
#SD_DDR_CLKn   sdram_clk       sd_CKn          *               div(1), combinational, inv
#SYS_CLK       sys_2x_clk      I_CLOCKING/sys_clk_in_reg/Q
 #                                             *               div(2)
#####################################################################################


report_design

######################################################################################
#Cell Instance Type  Count         Area
#--------------------------------------
#TOTAL LEAF CELLS    52047   440170.182
#Standard cells      52007   175285.912
#Hard macro cells       40   264884.269
#Soft macro cells        0        0.000
#Always on cells         0        0.000
#Physical only           0        0.000
#Fixed cells             0        0.000
#Moveable cells      52047   440170.182
#Sequential           5427   314141.951
#Buffer/inverter      6481    14753.059
#ICG cells              23      134.950
#
#Logic Hierarchies                    : 54
#Design Masters count                 : 170
#Total Flat nets count                : 56776
#Total FloatingNets count             : 491
#Total no of Ports                    : 237
#Number of Master Clocks in design    : 11
#Number of Generated Clocks in design : 6
#Number of Path Groups in design      : 29 (17 of them Non Default)
#Number of Scan Chains in design      : 0
#List of Modes                        : test, func
#List of Corners                      : ss_125c, ss_m40c, ff_125c, ff_m40c
#List of Scenarios                    : func.ff_125c, func.ff_m40c, func.ss_125c, func.ss_m40c, test.ff_125c, test.ss_125c
#
#Core Area                            : 0.000
#Chip Area                            : 0.000
#Total Site Row Area                  : 0.000
#Number of Blockages                  : 0
#Total area of Blockages              : 0.000
#Number of Power Domains              : 1
#Number of Voltage Areas              : 1
#Number of Group Bounds               : 0
#Number of Exclusive MoveBounds       : 0
#Number of Hard or Soft MoveBounds    : 0
#Number of Multibit Registers         : 0
#Number of Multibit LS/ISO Cells      : 0
#Number of Top Level RP Groups        : 0
#Number of Tech Layers                : 71 (71 of them have unknown routing dir.)
#
#Total wire length                    : 0.00 micron
#Total number of wires                : 0
#Total number of contacts             : 0
##################################################################################


####################################################3
#		set routing direction
####################################################
set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction horizontal
set_attribute [get_layers {M2 M4 M6 M8 MRDL}] routing_direction vertical



#################################################
#		floorplan
################################################
initialize_floorplan -core_utilization 0.60 -core_offset {2 2 2 2}
#Removing existing floorplan objects
#Creating core...
#Core utilization ratio = 60.04%
#Unplacing all cells...
#Creating site array...
#Creating routing tracks...
#Initializing floorplan completed.
###############################################


##########################################
# to get boundary co-ordinates of blocks
#########################################
get_attribute [current_block] boundary
#{0.0000 0.0000} {0.0000 860.0640} {860.3680 860.0640} {860.3680 0.0000}

#########################################
#		create_pin_guides
##########################################
#create_pin_guide  -boundary { {0 360} {1 570} } -layers {M3 M5 M7 M9} -name inputports [remove_from_collection [get_ports -filter "direction == in"] { sdram_clk sys_2x_clk sd_DQ_in[*] shutdown VSS VDD} ]
#create_pin_guide  -boundary { {300 0} {560 1} } -layers {M2 M4 M6 M8} -name inputports2   [get_ports -expect_each_pattern_matches { sdram_clk sys_2x_clk sd_DQ_in[*] shutdown VSS VDD}] ]

create_pin_guide  -boundary { {859.3680 180} {860.3680 570} } -layers {M3 M5 M7 M9} -name outputports [get_ports -filter "direction == out"]
create_pin_guide  -boundary { {0 250} {1 670} } -layers {M3 M5 M7 M9} -name inputports [get_ports -filter "direction == in"]


place_pins -ports [get_ports -filter "direction == in"]
place_pins -ports [get_ports -filter "direction == out"]
#####################################################################
#			macro placemant
######################################################################
#####################################
#to place macros automatically
#
#
#set_app_options -list {plan.macro.macro_place_only {true}}
#create_placement -floorplan

###
#
############################################
#		create keep out morgin
############################################
create_keepout_margin -type hard -outer {2.9184 15.808 3.1616 0.7296} [get_selection]
[get_cell I_RISC_CORE/I_REG_FILE/REG_FILE_*]

create_keepout_margin -type hard -outer {2.6752 31.616 2.9184 0.7296} [get_selection]
[get_cell I_SDRAM_TOP/I_SDRAM_WRITE_FIFO/SD_FIFO_RAM_*]

create_keepout_margin -type hard -outer {2.432 4.3776 2.6752 0.7296} [get_selection]
I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_*

create_keepout_margin -type hard -outer {2.6752 8.2688 2.9184 0.7296} [get_selection]
I_CONTEXT_MEM/I_CONTEXT_RAM_1_*


set_fixed_objects [get_selection]

#####################################################
#			power planing
#####################################################
######################### create ports vdd vss
create_port -port_type ground -direction in VSS
create_port -port_type power -direction in VDD
################## create nets vdd vss
create_net -power VDD

create_net -ground VSS
############## connect ports to nets
connect_pg_net -net VDD [get_port VDD]
connect_pg_net -net VSS [get_port VSS]


##################### to dissable via connection during compile pg
set_app_options -name plan.pgroute.disable_via_creation -value true


######################################################
#			to create rail M1
########################################################
connect_pg_net  -net VDD [get_pins -hierarchical */VDD]
connect_pg_net  -net VSS [get_pins -hierarchical */VSS]

create_pg_std_cell_conn_pattern rail_pattern -layers M1 
set_pg_strategy M1_rails -core -pattern {{name: rail_pattern} nets: VDD VSS}

compile_pg  -strategies M1_rails
#########################################################
#	 m6 t0 m7 layers (only core region)
#######################################################
###### VDD
get_attribute [get_layers M6] pitch
get_attribute [get_layers M7] pitch

create_pg_mesh_pattern M6toM7_VDD -layers {{{vertical_layer: M6} {spacing: minimum} {pitch: 9.728} {width: 0.608000} {offset: 0.912}}                                       
                                                                              
                                           {{horizontal_layer: M7} {spacing: minimum} {pitch: 19.456} {width:1.216000} {offset: 1.824}}}

set_pg_strategy pg_mesh_VDD -core -pattern  {{name: M6toM7_VDD } {nets: VDD }} -extension {{stop: 0.03} {layers: M6}}
compile_pg -strategies pg_mesh_VDD

###### VSS
create_pg_mesh_pattern M6toM7_VSS -layers {{{vertical_layer: M6} {spacing: minimum} {pitch: 9.728} {width: 0.608000} {offset: 5.776}}                                       
                                                                              
                                        {{horizontal_layer: M7} {spacing: minimum} {pitch:19.456} {width:1.216000} {offset: 11.552}}}

set_pg_strategy pg_mesh_VSS -core -pattern  {{name: M6toM7_VSS } {nets: VSS }} -extension {{stop: 0.03} {layers: M6}}
compile_pg -strategies  pg_mesh_VSS

check_pg_drc 
check_pg_missing_vias 



######################################################################################
#				M8 MESH
#######################################################################################
get_attribute [get_layers M8] pitch
###### VDD
create_pg_mesh_pattern  M8_VDD -layers {{vertical_layer: M8 } {width: 1.216000} {pitch:  19.456} {spacing: minimum} {offset: 2.608}}
set_pg_strategy ring_pg_M8_VDD -design_boundary -pattern {{name: M8_VDD } {nets: VDD }} -extension {{stop: design_boundary} {layers: M8}}
compile_pg -strategies ring_pg_M8_VDD

###### VSS
create_pg_mesh_pattern  M8_VSS -layers {{vertical_layer: M8 } {width: 1.216000} {pitch: 19.456} {spacing: minimum} {offset: 12.336}}
set_pg_strategy ring_pg_M8_VSS -design_boundary -pattern {{name: M8_VSS } {nets: VSS }} -extension {{stop: design_boundary} {layers: M8}}
compile_pg -strategies ring_pg_M8_VSS

######################################################################################
#				M9 MESH
get_attribute [get_layers M9] pitch

create_pg_mesh_pattern  M9_VDD -layers {{horizontal_layer: M9} {width: 2.432000} {pitch: 19.456} {spacing: minimum} {offset: 3.216}}
set_pg_strategy ring_pg_M9_VDD -design_boundary -pattern {{name: M9_VDD } {nets: VDD }} -extension {{stop: design_boundary_and_generate_pin}}
compile_pg -strategies ring_pg_M9_VDD

create_pg_mesh_pattern  M9_VSS -layers {{horizontal_layer: M9} {width: 2.432000} {pitch: 19.456} {spacing: minimum} {offset: 12.944}}
set_pg_strategy ring_pg_M9_VSS -design_boundary -pattern {{name: M9_VSS } {nets: VSS }} -extension {{stop: design_boundary_and_generate_pin}}
compile_pg -strategies ring_pg_M9_VSS


################################################checks after pg mesh
check_pg_drc 
check_pg_missing_vias 
##########################################################
#               via creations 
###########################################################
########  M9 to M8
create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VDD VSS} -from_layers M9 -to_layers M8

########  M8 to M7

create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VDD VSS} -from_layers M8 -to_layers M7

########  M7 to M6

create_pg_vias -within_bbox [get_attribute [current_block] boundary] -nets {VSS VDD} -from_layers M7 -to_layers M6 -drc no_check


########  M6 to M1

set_pg_via_master_rule m6_m1 -contact_code {VIA12SQ VIA23SQ VIA34SQ VIA45SQ VIA56SQ}
create_pg_vias -within_bbox [get_attribute [get_core_area] bbox] -nets {VDD VSS} -from_layers M6 -to_layers M1 -via_masters m6_m1

#####################################################################
##*solution to resolve floating macros   RING AROUND MACRO
###############################################################
set macros [get_cell -physical_context -filter "is_hard_macro && !is_physical_only"]
create_pg_macro_conn_pattern macro_connect_pattern -pin_conn_type scattered_pin -nets {VDD VSS} -width {0.25 0.25} -layers {M5 M6}
set_pg_strategy macro_connect -pattern {{name: macro_connect_pattern} {nets: VDD VSS}} -macros "$macros"
compile_pg -strategies macro_connect


#######################################################3
#		creating tap cells
#########################################################



create_tap_cells -lib_cell saed32_hvt_std/SHFILL1_HVT -distance 30 -pattern stagger
check_legality   
legalize_placement
connect_pg_net -automatic
#######################################################3
#		creating boundary cells
#########################################################

get_lib_cells */*FILL*
set_boundary_cell_rules -left_boundary_cell saed32_hvt_std/SHFILL1_HVT -right_boundary_cell saed32_hvt_std/SHFILL1_HVT
create_boundary_cells -left_boundary_cell saed32_hvt_std/SHFILL1_HVT -right_boundary_cell saed32_hvt_std/SHFILL1_HVT



sizeof_collection [get_cells *tap*]
sizeof_collection [get_cells *boun*]

connect_pg_net -automatic 
check_pg_drc 
check_pg_missing_vias 


########################## ckecks after physical cells 
check_legality   
legalize_placement 

 
report_utilization -config config1 > ../reports/floorplan/report_utilization_before_port_buffer.txt

 report_utilization -config config1
####################to rmove shapes or remove metals##################
#--------get_shapes
#--------remove_shapes  [get_shapes PATH_31_*]
#--------connect_pg_net  -net VDD [get_pins -hierarchical */VDD]
#--------check_pg_drc
#--------connect_pg_net  -net VSS [get_pins -hierarchical */VSS]
#--------check_pg_drc
############################################ to remove vias
 #------get_vias
 #-----remove_vias [get_vias *]
 #
 ###########################################################################################
 #				placement
 ############################################################################################
 
 create_placement -effort low
create_stdcell_fillers -lib_cells [get_lib_cells */*FILL*]

check_lvs
check_pg_drc


#### Before  placement #####
#1.read sdc
#2.legalize placement
#3.add buffers on i/p ports
#4.dont use clk cells during placement
#5.dont use on high drive strength cells to reduce utilization during placement
#5.sacn def to true
#6.dont touch on buffers 
#7.make setup scenario as active
#8.prefixing for newly added cells
#9.run place_opt step by step
#10.do connect pg net command for power and ground connections for newly added buffers
#10.do timing/cONGESTION rEPORTS
 
#before placement we should do

##########################33333#################### 
#		buffwr adding at each ports
###########################3########################
#remove_from_collection [get_port *] {clk I1 I2 VDD VSS}
sizeof_collection [get_ports]
239


add_buffer -lib_cell saed32_lvt_std/NBUFFX8_LVT [remove_from_collection [all_inputs]  {sdram_clk sys_2x_clk ate_clk pclk VDD VSS}]
legalize_placement
add_buffer -lib_cell   saed32_lvt_std/NBUFFX8_LVT [all_outputs]
legalize_placement

sizeof_collection [get_cell eco_cell*]
233

set_placement_status fixed [get_cell eco_cell*] 
set_dont_touch [get_cell eco_cell*]
set_dont_touch [get_nets eco_net*]
connect_pg_net -automatic 
check_pg_drc
check_pg_missing_vias 

report_utilization -config config1 > ../reports/floorplan/report_utilization_after_port_buffer.txt
report_utilization
report_design
report_design > ../reports/floorplan/report_design_after_port_buffer.rpt


############################################################
#	 prefixing the newly added cells  during place_opt
#############################################################

set_app_options -name opt.common.user_instance_name_prefix -value "newly_added"
#opt.common.user_instance_name_prefix newly_added

set all_scenr {func.ff_125c func.ff_m40c func.ss_125c func.ss_m40c test.ff_125c test.ss_125c}
foreach scenr $all_scenr {
current_scenario $scenr
report_constraints -all_violators
}

##########################################################################################
#				READING SCAN DEF
##########################################################################################

read_def /home/tutor/PHYSICALDESIGN/PROJECTS/icc/ORCA/ORCA_TOP_design_data/ORCA_TOP.scandef

######################################################
#		DO NOT USE CK BUFFERS
#######################################################
#there are no CK BUFFS in 32 nm

############################################################### 
#do not use high drive strength cell for better utilization
################################################################
set_lib_cell_purpose -include all [get_lib_cells]
set_lib_cell_purpose -include none [get_lib_cells {*/*X32*}]


############################################ 
#	checks before plce cells
############################################


report_qor -summary > ../reports/floorplan/report_qor_summary.txt
report_qor -summary
report_design > ../reports/floorplan/report_design.txt
report_desig
report_utilization -config config1  > ../reports/floorplan/report_utilization.txt
report_utilization -config config1
check_pg_drc
check_pg_missing_vias
check_legality
check_boundary_cells
report_scenarios
report_parasitic_parameters
report_utilization
check_pg_connectivity

####################################3
#	derates
#####################3##########
set_operating_conditions -analysis_type on_chip_variation
set_app_options -name time.si_enable_analysis -value true

save_block -as before_placement
report_timing_derate

check_design -check pre_placement_stage
######################################## cell placement 
#place_opt
#              [-list_only]
#              [-from <startStage>] (<startStage> = "initial_place | initial_drc | initial_opto | final_place | final_opto")
#              [-to <endStage>] (<endStage> = "initial_place | initial_drc | initial_opto | final_place | final_opto")
#


######################### to control density ##############3

set_app_options -name place.coarse.auto_density_control -value true

set_app_options -name opt.common.max_fanout -value 5
set_app_options -name place_opt.flow.optimize_layers -value true
#When true, timing-driven coarse  placement  attempts  to  focus  timing \
       optimization  on  the most critical timing paths to find a good balancen \
       between reducing the worst slack and reducing the total negative slack.
set_app_options -name place.coarse.auto_timing_control -value true

#The flowing example enables both the macro and standard cell congestion reduction strategies.

set_app_options -list {plan.place.congestion_driven_mode both}



############ step --1 initial placement to initial drc violation fixing
place_opt -from initial_place -to  initial_place
report_utilization -config config1 > ../reports/placement/report_utilization_initial_place.txt
report_utilization -config config1
#0.4386
place_opt -from initial_drc -to  initial_drc
report_utilization -config config1 > ../reports/placement/report_utilization_initial_drc.txt
report_utilization -config config1
#0.4407



place_opt -from initial_opto -to initial_opto
report_utilization -config config1 > ../reports/placement/report_utilization_initial_opto.txt
report_utilization-config config1 
#0.4401


place_opt -from final_place -to final_place
report_utilization -config config1 > ../reports/placement/report_utilization_final_place.txt
report_utilization -config config1
#0.4401



place_opt -from final_opto -to final_opto
report_utilization -config config1 > ../reports/placement/report_utilization_final_opto.txt
report_utilization -config config1
#0.4345


report_congestion

refine_placement
legalize_placement -incremental 

check_legality


report_qor -summary > ../reports/placement/report_qor_summary.rpt
report_qor -summary
report_design > ../reports/placement/report_design.rpt
report_design
report_utilization -verbose  > ../reports/placement/report_utilization.rpt
report_utilization -verbose
report_constraints -all_violators -scenarios [all_scenarios] -significant_digits 10 > ../reports/placement/report_constraints_all_violators_scenarios.rpt
report_constraints -all_violators -scenarios [all_scenarios] -significant_digits 10

list_attributes -class cell -application
get_attribute [get_cell I_SDRAM_TOP/I_SDRAM_IF/mega_shift_1_reg[14][16]] ref_full_name




####################################################################################
# to fix max cap
#####################################################################################
set a {I_RISC_CORE/div_4/u_div/u_fa_PartRem_0_1_2/ I_RISC_CORE/div_4/u_div/u_fa_PartRem_0_1_3/ I_RISC_CORE/div_4/u_div/u_fa_PartRem_0_0_1/ I_RISC_CORE/div_4/u_div/u_fa_PartRem_0_0_2/ I_RISC_CORE/div_4/u_div/u_fa_PartRem_0_0_3/ I_RISC_CORE/div_4/u_div/u_fa_PartRem_0_0_4/}

foreach b $a {
size_cell $b -lib_cell FADDX1_HVT
}




#######################################################################################################################
########################################################################################################################
##					clock tree synthesis
########################################################################################################################
########################################################################################################################
################################
#
################################
##	before checks

check_legality
should be clean
report_congestion
acceptable -----if there is no pin density and cell density
report_qor -summary
report_clock_qor


set_scenario_status  {func* test*} -setup true -hold true
report_scenarios


## set refernces
set_lib_cell_purpose -exclude cts [get_lib_cells */*]

# use only CK buffs from D4 to D16
set cts_cells  [remove_from_collection [get_lib_cells {*/IN* */NBUFF*}] {*/*X0* */*X1* */*X2* */*X3* */*X1* */*X32* */*HVT */*RVT}]


set_lib_cell_purpose -include none [get_lib_cells $cts_cells]
#
set_lib_cell_purpose -include cts [get_lib_cells $cts_cells]


#prefixing newly added cells when clock opt
set_app_options -name opt.common.user_instance_name_prefix -value "newly_WN_CTS"
#
#
##prefixing newly added cells
#
set_app_options -name  cts.common.user_instance_name_prefix -value "cts_newly_added"
#
###################################################################################
##			        CTS SPEC	
####################################################################################

current_scenario func.ss_125c
set real_clocks [remove_from_collection [get_clocks] [get_clocks "v_* SD_DDR_CLK*"]]

set_clock_transition 0.2 $real_clocks


set_clock_uncertainty -setup 0.1 [get_clocks SYS_*]
set_clock_uncertainty -hold  0.05 [get_clocks SYS_*]
set_clock_uncertainty -setup 0.15 [get_clocks PCI_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.1 [get_clocks SDRAM_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks SDRAM_CLK]

set_clock_tree_options -target_skew 0.1 -clock [get_clocks SYS_*]
set_clock_tree_options -target_skew 0.15 -clock [get_clocks PCI_CLK]
set_clock_tree_options -target_skew 0.1 -clock [get_clocks SDRAM_CLK]

##############################################
current_scenario func.ss_m40c
set real_clocks [remove_from_collection [get_clocks] [get_clocks "v_* SD_DDR_CLK*"]]

set_clock_transition 0.2 $real_clocks


set_clock_uncertainty -setup 0.1 [get_clocks SYS_*]
set_clock_uncertainty -hold  0.05 [get_clocks SYS_*]
set_clock_uncertainty -setup 0.15 [get_clocks PCI_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.1 [get_clocks SDRAM_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks SDRAM_CLK]

set_clock_tree_options -target_skew 0.1 -clock [get_clocks SYS_*]
set_clock_tree_options -target_skew 0.15 -clock [get_clocks PCI_CLK]
set_clock_tree_options -target_skew 0.1 -clock [get_clocks SDRAM_CLK]


###############################################################
current_scenario func.ff_125c

set_clock_uncertainty -setup 0.05 [get_clocks SYS_*]
set_clock_uncertainty -hold  0.025 [get_clocks SYS_*]
set_clock_uncertainty -setup 0.05 [get_clocks PCI_CLK]
set_clock_uncertainty -hold  0.025 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.05 [get_clocks SDRAM_CLK]
set_clock_uncertainty -hold  0.025 [get_clocks SDRAM_CLK]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks SYS_*]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks PCI_CLK]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks SDRAM_CLK]


set_clock_latency 0.2 [get_clocks *SDRAM_CLK]

set real_clocks [remove_from_collection [get_clocks] [get_clocks "v_* SD_DDR_CLK*"]]

set_clock_transition 0.1 $real_clocks
###############################################################
current_scenario func.ff_m40c

set_clock_uncertainty -setup 0.05 [get_clocks SYS_*]
set_clock_uncertainty -hold  0.025 [get_clocks SYS_*]
set_clock_uncertainty -setup 0.05 [get_clocks PCI_CLK]
set_clock_uncertainty -hold  0.025 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.05 [get_clocks SDRAM_CLK]
set_clock_uncertainty -hold  0.025 [get_clocks SDRAM_CLK]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks SYS_*]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks PCI_CLK]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks SDRAM_CLK]


set_clock_latency 0.2 [get_clocks *SDRAM_CLK]

set real_clocks [remove_from_collection [get_clocks] [get_clocks "v_* SD_DDR_CLK*"]]

set_clock_transition 0.1 $real_clocks


##############################################################
current_scenario test.ss_125c

set_clock_uncertainty -setup 0.1 [get_clocks SYS_*]
set_clock_uncertainty -hold  0.05 [get_clocks SYS_*]
set_clock_uncertainty -setup 0.15 [get_clocks PCI_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.1 [get_clocks SDRAM_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks SDRAM_CLK]

set_clock_tree_options -target_skew 0.1 -clock [get_clocks SYS_*]
set_clock_tree_options -target_skew 0.15 -clock [get_clocks PCI_CLK]
set_clock_tree_options -target_skew 0.1 -clock [get_clocks SDRAM_CLK]



set real_clocks [remove_from_collection [get_clocks] [get_clocks "v_* SD_DDR_CLK*"]]

set_clock_transition 0.2 $real_clocks
set_clock_transition 0.1 $real_clocks

#########################################################

current_scenario test.ff_125c 
set_clock_uncertainty -setup 0.05 [get_clocks SYS_*]
set_clock_uncertainty -hold  0.05 [get_clocks SYS_*]
set_clock_uncertainty -setup 0.05 [get_clocks PCI_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.05 [get_clocks SDRAM_CLK]
set_clock_uncertainty -hold  0.05 [get_clocks SDRAM_CLK]
set_clock_uncertainty -setup 0.1 [get_clocks ate_clk]
set_clock_uncertainty -hold  0.05 [get_clocks ate_clk]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks SYS_*]
set_clock_tree_options -target_skew 0.05 -clock [get_clocks PCI_CLK]
set_clock_tree_options -target_skew 0.1 -clock [get_clocks SDRAM_CLK]


set_clock_latency 0.2 [get_clocks *SDRAM_CLK]

set real_clocks [remove_from_collection [get_clocks] [get_clocks "v_* SD_DDR_CLK*"]]

set_clock_transition 0.1 $real_clocks


#
#
#



set Modes {func test}
foreach aa $Modes {
current_mode $aa

current_scenario $aa
create_routing_rule root_ref_rule -multiplier_width 2 -multiplier_spacing 2 -default_reference_rule
create_routing_rule inter_ref_rule -multiplier_width 2 -multiplier_spacing 2 -default_reference_rule
create_routing_rule sink_ref_rule -multiplier_width 1 -multiplier_spacing 2 -default_reference_rule

set_clock_routing_rules -clocks [get_clocks -filter " !is_generated "] -net_type root -rules root_ref_rule -max_routing_layer M8 -min_routing_layer M6
set_clock_routing_rules -clocks [get_clocks -filter " !is_generated "] -net_type internal -rules inter_ref_rule -max_routing_layer M8 -min_routing_layer M5
set_clock_routing_rules -clocks [get_clocks -filter " !is_generated "] -net_type sink -rules sink_ref_rule -max_routing_layer M8 -min_routing_layer M4

}


report_routing_rules
report_clock_qor
report_clock_qor > ../reports/cts/report_clock_qor_befoe_clock_opt.rpt
report_qor -summary
report_qor -summary > ../reports/cts/report_qor_summary_befoe_clock_opt.rpt

report_clock_routing_rules

report_clock_timing -type interclock_skew -scenarios [get_scenarios *]
report_clock_timing -type interclock_skew -scenarios [get_scenarios *] > ../reports/cts/report_clock_timing_before_clock_opt.rpt

report_clock_settings > ../reports/cts/report_clock_settings_before_clock_opt.rpt
report_clock_settings 

check_clock_tree



#SYNTAX
#      status clock_opt
#              [-list_only]
#             [-from build_clock | route_clock | final_opto | global_route_opt]
#              [-to build_clock | route_clock | final_opto | global_route_opt]

################### build_clock ###############3
clock_opt -from build_clock -to build_clock

report_clock_qor
report_clock_qor > ../reports/cts/report_clock_qor_clock_build.rpt

report_qor -summary
report_qor -summary > ../reports/cts/report_qor_summary_clock_build.rpt

report_clock_settings
report_clock_settings > ../reports/cts/report_clock_settings_clock_build.rpt

report_clock_timing -type interclock_skew -scenarios [get_scenarios *]
report_clock_timing -type interclock_skew -scenarios [get_scenarios *] > ../reports/cts/report_clock_timing_clock_build.rpt

####################### route_clock ###########
clock_opt -from route_clock -to route_clock
report_clock_qor
report_clock_qor > ../reports/cts/report_clock_qor_clock_rout.rpt

report_qor -summary
report_qor -summary > ../reports/cts/report_qor_summary_clock_rout.rpt

report_clock_routing_rules
report_clock_settings

report_clock_timing -type interclock_skew -scenarios [get_scenarios *]
report_clock_timing -type interclock_skew -scenarios [get_scenarios *] > ../reports/cts/report_clock_timing_clock_rout.rpt

report_clock_settings
report_clock_settings > ../reports/cts/report_clock_settings_clock_rout.rpt
report_utilization -config config1

######################## final_opto #############


### to update latency of clocks ###
compute_clock_latency
current_mode func
set_latency_adjustment_options -reference_clock PCI_CLK -clocks_to_update v_PCI_CLK
 set_latency_adjustment_options -reference_clock SDRAM_CLK -clocks_to_update v_SDRAM_CLK
compute_clock_latency

current_mode test
set_latency_adjustment_options -reference_clock PCI_CLK -clocks_to_update v_PCI_CLK
 set_latency_adjustment_options -reference_clock SDRAM_CLK -clocks_to_update v_SDRAM_CLK

compute_clock_latency
#################################


clock_opt -from final_opto -to final_opto

report_clock_qor > ../reports/cts/report_clock_qor_final_opto.rpt
report_qor -summary > ../reports/cts/report_qor_summary_final_opto.rpt

report_clock_timing -type interclock_skew -scenarios [get_scenarios *] > ../reports/cts/report_clock_timing_final_opto.rpt
report_clock_settings > ../reports/cts/report_clock_settings_final_opto.rpt


report_design

set scenarios {func_ff88125 func_ff88m40 func_ss72125 func_ss72m40 func_tt825 test_ff88125 test_ff88m40}
foreach assigner $scenarios {
current_scenario $assigner
report_constraints -all_violators
}

#################################################
#		post cts
#################################################

set_lib_cell_purpose -include hold [get_lib_cells */DEL*HVT]

clock_opt -from final_opto -to final_opto
clock_opt -from route_clock -to route_clock


report_clock_qor > ../reports/cts/report_clock_qor_post_cts.rpt
report_qor -summary > ../reports/cts/report_qor_summary_post_cts.rpt

report_clock_timing -type interclock_skew -scenarios [get_scenarios *] > ../reports/cts/report_clock_timing_post_cts.rpt
report_clock_settings > ../reports/cts/report_clock_settings_post_cts.rpt

set_dont_touch_network -clock_only [get_clocks]
set_dont_touch [get_cells *cts*]

##############checks after cts

report_qor -summary
report_routing_rules
report_clock_qor 
report_timing 
report_clock_routing_rules
report_clock_settings
report_clock_timing -type interclock_skew
report_clock_timing -type skew
report_clock_timing -type latency
report_clock_timing -type transition

set scenarios [get_scenarios]
foreach assigner $scenarios {
current_scenario $assigner
report_constraints -all_violators
}
########################
#	CRPR
#####################
set_app_options   -name time.remove_clock_reconvergence_pessimism -value true
set_operating_conditions -analysis_type on_chip_variation

report_timing


################################################
#		routing
#################################################
#
check_design -checks pre_route_stage

#report_app_options *xtalk*
set_app_options -name route_opt.flow.xtalk_reduction -value true
set_app_options -name time.si_enable_analysis -value true


#set scenarios {func_ff88125 func_ff88m40 func_ss72125 func_ss72m40 func_tt825 test_ff88125 test_ff88m40}

#oreach assigner $scenarios {
#current_scenario $assigner
#set_clock_uncertainty -setup 0.8  [get_clocks clk]
#set_clock_uncertainty -hold 0.2  [get_clocks clk]
#et_clock_uncertainty -setup 0.8  [get_clocks I2]
#et_clock_uncertainty -hold 0.15  [get_clocksADD2/add_1_root_add_36_2/U1_1 I2]
#set_clock_uncertainty -setup 0.4  [get_clocks I1]
#set_clock_uncertainty -hold 0.25  [get_clocks I1]

#	}


route_global
report_qor -summary

route_track
report_qor -summary > ../reports/routing/report_qor_summary_route_track.rpt

route_detail
#The maximum number of iterations has been reached
#	By default, the maximum number of iterations is 40. You can change this limit by setting the -max_number_iterations option.
#	icc2_shell>  route_detail -max_number_iterations 20



##it cannot fix any of the remaining violations 
#     You can change the effort that the detail router uses for fixing the remaining violations before it gives up by 
#     setting the route.detail.drc_convergence_effort_level application option.
#	icc2_shell> set_app_options -name route.detail.drc_convergence_effort_level -value high
#

#You can force the detail router to complete the maximum number of iterations, regardless of the DRC convergence status, by 
#	setting the route.detail.force_max_number_iterations application option to true. 
#	icc2_shell> set_app_options -name route.detail.force_max_number_iterations -value true
#
#
#
#
#Is not timing-driven

#To enable timing-driven detail routing, set the route.detail.timing_driven application option to true. 
# icc2_shell> set_app_options -name route.detail.timing_driven -value true

report_qor -summary > ../reports/routing/report_qor_summary_route_detail.rpt
report_qor -summary
set_app_options -name time.si_enable_analysis -value true
report_timing -crosstalk_delta
#route_auto
report_qor -summary
route_opt -xtalk_reduction
report_qor -summary > ../reports/routing/report_qor_summary_route_opt.rpt
report_qor -summary
report_design  > ../reports/routing/report_design.rpt
##################################
#		PHYSICAL DRC
#################################
check_routes

################################3
#	LAYOUT VS SCHEMATIC
#################################
check_lvs



report_clock_timing -type interclock_skew > ../reports/routing/report_clock_timing_type_interclock_skew.rpt
report_clock_timing -type interclock_skew 

report_clock_timing -type skew > ../reports/routing/report_clock_timing_type_skew.rpt
report_clock_timing -type skew 

report_clock_timing -type latency > ../reports/routing/report_clock_timing_type_latency.rpt
report_clock_timing -type latency

report_clock_timing -type transition
report_congestion

report_utilization > ../reports/routing/report_utilization.rpt
report_utilization

report_qor -summary > ../reports/routing/report_qor_summary_route_opt.rpt
report_qor -summary

report_design  > ../reports/routing/report_design.rpt
report_design

report_clock_qor
report_clock_qor > ../reports/routing/report_clock_qor.rpt

report_clock_timing -type interclock_skew -scenarios [get_scenarios *]
report_clock_timing -type interclock_skew -scenarios [get_scenarios *] > ../reports/routing/report_clock_timing.rpt

report_clock_settings > ../reports/routing/report_clock_settings.rpt
report_clock_settings

set scenarios {func_ff88125 func_ff88m40 func_ss72125 func_ss72m40 func_tt825 test_ff88125 test_ff88m40}
foreach assigner $scenarios {
current_scenario $assigner
report_constraints -all_violators
}

###################################
#	
##################################

create_stdcell_fillers -lib_cells [get_lib_cell */FILL*LVT]


connect_pg_net -automatic

check_routes
check_lvs

#set_app_options -name signoff.create_metal_fill.runset -value "fill.rs"



#set_app_options -name signoff.check_drc.runset -value "drc.rs"
#signoff_check_drc

report_clock_timing -type interclock_skew > ../reports/routing/report_clock_timing_type_interclock_skew.rpt
report_clock_timing -type interclock_skew 

report_clock_timing -type skew > ../reports/routing/report_clock_timing_type_skew.rpt
report_clock_timing -type skew 

report_clock_timing -type latency > ../reports/routing/report_clock_timing_type_latency.rpt
report_clock_timing -type latency

report_clock_timing -type transition
report_congestion

report_utilization > ../reports/routing/report_utilization.rpt
report_utilization

report_qor -summary > ../reports/routing/report_qor_summary_route_opt.rpt
report_qor -summary

report_design  > ../reports/routing/report_design.rpt
report_design

report_clock_qor
report_clock_qor > ../reports/routing/report_clock_qor.rpt

report_clock_timing -type interclock_skew -scenarios [get_scenarios *]
report_clock_timing -type interclock_skew -scenarios [get_scenarios *] > ../reports/routing/report_clock_timing.rpt

report_clock_settings > ../reports/routing/report_clock_settings.rpt
report_clock_settings

set scenarios {func_ff88125 func_ff88m40 func_ss72125 func_ss72m40 func_tt825 test_ff88125 test_ff88m40}
foreach assigner $scenarios {
current_scenario $assigner
report_constraints -all_violators
}




