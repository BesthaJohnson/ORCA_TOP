set a [get_attribute [get_cells [get_selection]] area]
set area 0
foreach i $a {
set area [expr $area + $i]

}
puts $area
