#open the floorplan with import dsesign details 
open_lib ./outputs/work/ORCA_TOP.nlib
copy_block -from_block ORCA_TOP_imported -to_block ORCA_TOP_FLOORPLAN
current_block FLOORPLAN



 ###################################
 #setting the direction of the metal layers
 set_attribute [get_alyers " M1 M3 M5 M7 M9"] routing_direction horizontal
 set_attribute [get_alyers " M2 M4 M6 M8 MRDL PO"] routing_direction vertical
 

##### creating core and die area ###
initialize_floorplan -control_type die -core_utilization 0.80 -flip_first_row false -use_site_row -keep_all -core_offset {5} -keep_placement {all macro block io physical_only}
#Removing existing floorplan objects
#Creating core...
#Core utilization ratio = 80.07%
#Unplacing all cells...
#Creating site rows...
#Creating routing tracks...
#Initializing floorplan completed.
get_attribute[get_core_area] area

#### set the ports 
#gui_show_man_page set_port_attribute
#set the port input port side 1
 set_block_pin_constraints -self -sides 1 -pin_spacing 2 -allowed_layers {M5} -corner_keepout_distance 100
#place the input port side 1
place_pins -ports [remove_from_collection [all_inputs] [get_ports *clk*]

#set the port output port side 3
set_block_pin_constraints -self -sides 3 -pin_spacing 2 -allowed_layers {M5} -corner_keepout_distance 100
#place the output ports side 3
place_pins -ports [all_outputs] 

#set the port clock port side 2
 set_block_pin_constraints -self -sides 2 -pin_spacing 2 -allowed_layers {M4} -corner_keepout_distance 100
#place the clock ports
place_pins -ports [get_ports *clk*] 
#fixed the ports 
set_attribute [get_ports] physical_status fixed

############################################
# set the colours for  family of macros
set_colour -cycle_colour

#separate the family of macros
#place the macros nearer the core boundary
#same family of macros should sit together
#orientation 0 or 180
#set the pins of the macros should face the core boundary
#space between the macro to macro using align and distribute
#
#
###fixd the mcros###
set_attribute [get_flat_cells -filter "is_hard_macro"] physical_status fixed


#####################################################################
#create the keepout margin 
 create_keepout_margin [get_flat_cells -filter "is_hard_macro"] -outer {2 2 2 2} -type hard_macro


#create the placement blockage #####
create_placement_blockage -boundary {{}} -type hard
#list the plaxement blockages 
get_attribute [get_placement_blockages] 

######## lock the placement blockages ######

###########################################################################
###########creating voltage area for multi voltage design
reset_upf
load_upf ./inputs/ORCA_TOP.upf
commit_upf

create_voltage_area -power_domains PD_RISC_CORE -region {{374.8160 10.0000} {742.2160 264.1600}} -guard_band {{5.016 5.016}}

#################################################################################3
#
#### 
##### list the voltage areas ############
get_voltage_area


######################################################33333
###copy block 
copy_block -from_block ORCA_TOP_FLOORPLAN -to_block ORCA_TOP_POWER_PLAN
################################
#
#set the pre place cells
set_pre_place_cells "saed32_hvt|saed32_hvt_std/DCAP_HVT"
###create the tap cells 
create_tap_cells -lib_cell $pre_place_cells -distance 30 -pattern stagger

#### create boundary cells 
#set the preplace cells
set pre_place_cells "saed32_hvt|saed32_hvt_std/DCAP_HVT"
#set the boundary cells
icc2_shell> set_boundary_cell_rules -left_boundary_cell $pre_place_cells -right_boundary_cell $pre_place_cells
#### to show the boundary cells
compile_boundary_cells


###### to remove boundary cells 
proc remove_boundary_cell {} {
remove_cells [get_flat_cells *boundary* -all]
}
remove_boundary_cell

#################### to remove tap cells ####
proc remove_tap_cell {} {
remove_cells [get_flat_cells *tapfiller* -all]
}
remove_tap_cell


################################
#count the tap cells
change_selection [get_flat_cells -hierarchical *tapfiller* -all]
icc2_shell> sizeof_collection [get_selection ] 

######################################
save_block -as pre_power_plan.design

###################################

save_block
close_block
close-lib
