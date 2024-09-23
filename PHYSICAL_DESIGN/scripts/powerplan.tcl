remove_pg_patterns -all

remove_pg_strategies -all

remove_routes -stripe

##### The  connect_pg_net  command  creates  the power and ground network for your design by connecting the power, ground, and tie-off  pins  to  the  power and ground nets in your design.

 connect_pg_net
#################create rings #############


#################### create pg ring i.e default RING ######
create_pg_ring_pattern RING_PATTERND -horizontal_layer  M9  -horizontal_width 0.5  -vertical_layer M8 -vertical_width 0.5 -track_alignment track

set_pg_strategy ORCA_RING_STRATEGYD -voltage_areas DEFAULT_VA -pattern {{pattern:  RING_PATTERND}  {nets: VDD VSS} {offset: {0.896 1.048}}}
 
compile_pg -strategies {ORCA_RING_STRATEGYD} 

################# creating pg ring RISC RING #########
#
create_pg_ring_pattern RING_PATTERN -horizontal_layer  M9  -horizontal_width 0.5  -vertical_layer M8 -vertical_width 0.5 -track_alignment track


set_pg_strategy RISC_RING_STRATEGY -voltage_areas PD_RISC_CORE -pattern {{pattern: RING_PATTERN}  {nets: VDDH VSS} {offset: {0.16 0.16}}} 

compile_pg -strategies    {RISC_RING_STRATEGY}





################################create m7 layer################3
 create_pg_mesh_pattern  MESH_PATTERN7 -layers {{horizontal_layer  M7} {width :0.8} {pitch : 7.296} {horizontal :vertical} {track_alignment : track}{trim : true}} 

set_pg_strategy VDD_MESH_STRATEGY7 -core  -pattern {{pattern: MESH_PATTERN7} {nets :VSS} {offset: {3.648}}} 

compile_pg -strategies {VDD_MESH_STRATEGY7}


 create_pg_mesh_pattern  MESH_PATTERN7D -layers {{horizontal_layer  M7} {width :0.8} {pitch : 7.296} {track_alignment : track} {trim : true}}

 set_pg_strategy VDD_MESH_STRATEGY7D -voltage_areas DEFAULT_VA  -pattern {{pattern: MESH_PATTERN7D} {nets :VDD} {offset: {1.216}}} 

compile_pg -strategies {VDD_MESH_STRATEGY7D}


create_pg_mesh_pattern  MESH_PATTERN7DV -layers {{horizontal_layer  M7} {width :0.8} {pitch : 7.296} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY7DV -voltage_areas PD_RISC_CORE  -pattern {{pattern: MESH_PATTERN7DV} {nets :VDDH} {offset: {1.216}}} 

compile_pg -strategies {VDD_MESH_STRATEGY7DV}





########################################################
#create macro pin connectiom


create_pg_macro_conn_pattern scatter_pin_patternv -pin_conn_type scattered_pin -nets {VDDH VSS}
set_pg_strategy -voltage_areas PD_RISC_CORE -pattern {{pattern : scatter_pin_patternv} {nets : VDDH VSS}} macro_1
compile_pg -strategies {macro_1}

#######################for orca top######################
create_pg_macro_conn_pattern scatter_pin_pattern -pin_conn_type scattered_pin -nets {VDD VSS}
set_pg_strategy -voltage_areas DEFAULT_VA -pattern {{pattern : scatter_pin_pattern} {nets : VDD VSS}} macro_2
compile_pg -strategies {macro_2}





##################### creating pg mesh pattern for orca top ###

############creating M8 layer############ 
create_pg_mesh_pattern  MESH_PATTERN8 -layers {{vertical_layer  M8} {width :1.12} {pitch : 4.864} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY8 -voltage_areas DEFAULT_VA  -pattern {{pattern: MESH_PATTERN8} {nets :VDD VSS} {offset: {2.428}} } 

compile_pg -strategies {VDD_MESH_STRATEGY8} 


create_pg_mesh_pattern  MESH_PATTERN8v -layers {{vertical_layer  M8} {width :1.12} {pitch : 4.864} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY8v -voltage_areas PD_RISC_CORE  -pattern {{pattern: MESH_PATTERN8v} {nets :VDDH VSS} {offset: {2.428}} } 

compile_pg -strategies {VDD_MESH_STRATEGY8v} 




####creating M9 layer
 create_pg_mesh_pattern  MESH_PATTERN9 -layers {{horizontal_layer  M9} {width :2.12} {pitch : 8.816} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY9 -voltage_areas DEFAULT_VA  -pattern {{pattern: MESH_PATTERN9} {nets :VDD VSS} {offset: {3.952}} } 

compile_pg -strategies {VDD_MESH_STRATEGY9}


 create_pg_mesh_pattern  MESH_PATTERN9v -layers {{horizontal_layer  M9} {width :2.12} {pitch : 8.816} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY9v -voltage_areas PD_RISC_CORE  -pattern {{pattern: MESH_PATTERN9v} {nets :VDDH VSS} {offset: {3.952}} } 

compile_pg -strategies {VDD_MESH_STRATEGY9v}



######################################################################################################
#create m4 layer#######3

  create_pg_mesh_pattern  MESH_PATTERN4v -layers {{vertical_layer  M4} {width :0.4} {spacing : 0.608} {pitch : 4.56} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY4v -voltage_areas PD_RISC_CORE  -pattern {{pattern: MESH_PATTERN4v} {nets :VDDH VSS} {offset: {3.952}} } 

compile_pg -strategies {VDD_MESH_STRATEGY4v}


 create_pg_mesh_pattern  MESH_PATTERN4 -layers {{vertical_layer  M4} {width :0.4} {spacing : 0.608} {pitch : 4.56} {track_alignment : track} {trim : true}}

set_pg_strategy VDD_MESH_STRATEGY4 -voltage_areas DEFAULT_VA  -pattern {{pattern: MESH_PATTERN4} {nets :VDD VSS} {offset: {3.952}} } 

compile_pg -strategies {VDD_MESH_STRATEGY4}

#########################################create m1 rails#######################

create_pg_std_cell_conn_pattern M1railv -layer M1
set_pg_strategy M1starv -voltage_areas PD_RISC_CORE -pattern {{name : M1railv} {nets : VDDH VSS}}
compile_pg -strategies {M1starv}


create_pg_std_cell_conn_pattern M1rail -layer M1
set_pg_strategy M1star -voltage_areas PD_RISC_CORE -pattern {{name : M1rail} {nets : VDDH VSS}}
compile_pg -strategies {M1star}


 


#remove_shapes [get_shapes -filter "shape_use == stripe && layer.name == M8"]


#remove_pg_strategies -all
#remove_pg_patterns -all
#remove_shapes [get_shapes -filter "shape_use == stripe && layer.name == M8"]

#remove_vias [get_vias -filter "cut_layer_names == VIA7"]
#remove_vias [get_vias -filter "cut_layer_names == VIA6"]
#remove_vias [get_vias -filter "cut_layer_names == VIA5"]

#remove_vias [get_vias  -filter "shape_use == macro_pin_connect && layer.name == M6"]

#remove_vias [get_vias  -filter "shape_use == macro_pin_connect"]

#
