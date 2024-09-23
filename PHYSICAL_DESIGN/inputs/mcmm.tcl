##########################################################################################
# Tool: IC Compiler II
# Script: mcmm_ORCA_TOP.tcl
##########################################################################################
lappend search_path {/home/abdulaleem/Desktop/sai/ORCA_TOP/inputs/ /home/abdulaleem/Desktop/sai/ORCA_TOP/inputs/sdc_constrains/ /home/vlsiguru/PHYSICAL_DESIGN/TRAINER1/ICC2/ORCA_TOP/ref/tech/}
set TECH_LIB [which saed32_1p9m_tech.ndm]
set_ref_libs -add $TECH_LIB


remove_scenarios -all
remove_modes -all
remove_corners -all

# mode files has clock information 
set m_constr(func) "../../inputs/sdc_constrains/ORCA_TOP_m_func.tcl"
set m_constr(test) "../../inputs/sdc_constrains/ORCA_TOP_m_test.tcl"

# PVT info is present in constraints files 
set c_constr(ss_125c) "../../inputs/sdc_constrains/ORCA_TOP_c_ss_125c.tcl"
set c_constr(ss_m40c) "../../inputs/sdc_constrains/ORCA_TOP_c_ss_m40c.tcl"
set c_constr(ff_125c) "../../inputs/sdc_constrains/ORCA_TOP_c_ff_125c.tcl"
set c_constr(ff_m40c) "../../inputs/sdc_constrains/ORCA_TOP_c_ff_m40c.tcl"


# Scenario files is assigned to variables
set s_constr(func.ss_125c) "../../inputs/sdc_constrains/ORCA_TOP_s_func.ss_125c.tcl"
set s_constr(func.ss_m40c) "../../inputs/sdc_constrains/ORCA_TOP_s_func.ss_m40c.tcl"
set s_constr(func.ff_125c) "../../inputs/sdc_constrains/ORCA_TOP_s_func.ff_125c.tcl"
set s_constr(func.ff_m40c) "../../inputs/sdc_constrains/ORCA_TOP_s_func.ff_m40c.tcl"
set s_constr(test.ss_125c) "../../inputs/sdc_constrains/ORCA_TOP_s_test.ss_125c.tcl"
set s_constr(test.ff_125c) "../../inputs/sdc_constrains/ORCA_TOP_s_test.ff_125c.tcl"

########################################
## Mode, corner and scenario creation
########################################
foreach m [array names m_constr] {
	create_mode $m
}

foreach c [array names c_constr] {
	create_corner $c
}

foreach s [array names s_constr] {
	lassign [split $s "."] m c
	create_scenario -name $s  -mode $m  -corner $c
}

########################################
## Populate modes, corners and scenarios
########################################

# Common file contains port names for constraints
source ../../inputs/sdc_constrains/ORCA_TOP_port_lists.tcl

foreach m [array names m_constr] {
	current_mode $m
	source $m_constr($m)
}

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
# set_scenario_status {func.ss_125c func.ss_m40c test.ss_125c } -hold false
set_scenario_status {func.ss_125c test.ss_125c } -hold false
set_scenario_status {func.ff_125c func.ff_m40c test.ff_125c} -setup false
set_scenario_status {*} -leakage_power false -dynamic_power false
set_scenario_status func.ss_125c -leakage_power true -dynamic_power true


puts "RM-info : Completed script [info script]\n"


