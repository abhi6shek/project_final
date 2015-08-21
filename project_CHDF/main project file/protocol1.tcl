# Taking Command line paramter routing protocol such as AODV, DSR etc
set par1  [lindex $argv 0]
set par2  [lindex $argv 1]
set par3  [lindex $argv 2]
# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             121                     ;# number of mobilenodes
set val(rp)             $par1                      ;# routing protocol
set val(sender)         $par2
set val(receiver)       $par3
set val(x)              500   			   ;# X dimension of topography
set val(y)              500   			   ;# Y dimension of topography  
set val(stop)		300			   ;# time of simulation end
set val(layer)          5

if { $val(rp)=="DSR"} {
  set val(ifq)           CMUPriQueue 
} else {
  set val(ifq)          Queue/DropTail/PriQueue    ;# interface queue type
}

# creating various objects 
set ns_		  [new Simulator]
set tracefd       [open protocol1.tr w]
set namtrace      [open protocol1.nam w]    

# setting colors

$ns_ color 1 Blue
$ns_ color 2 Red

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
$ns_ use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#create-god $val(nn)
set god_  [create-god  $val(nn)]
#
#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#

# configure the nodes
        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			  -routerTrace ON \
			 -macTrace ON \
			 -movementTrace ON 
					 
	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns_ node]
	}

set x 0
set y 0

if { $par2 < "0" || $par2 > "120" } {
	puts "Sender node is unidentified."
	set x 1 
}

if { $par3 > "120" || $par3 < "0" } {
	puts "Receiver node is unidentified."
	set y 1
}



#k variable for node number
set k 0 

#variable declared for arranging node in levelwise hierarchy
set l 0.0


#loop for levelwise node arranging in hierarchy
for {set i 0} {$i < $val(layer) } { incr i } {

	#if condition for coloring the nodes levelwise and labeling them
	if {$i == "0"} {
		$ns_ at 0.0 "$node_($k) label \"BC\""
		$node_($k) set X_ 0.0
		$node_($k) set Y_ 0.0
		$node_($k) set Z_ 0.0
		
		incr k
	} else {
		if { $i == "0"} {
			set l 0 ;#in case of very first node
		} else {
			set l 1 ;#other cases
		}
	
	#loop for calculating the l value so that it will store integer
	for {set m $i} {$m > 0} { set m [expr ($m-1)] } {
		set l [expr ($l*3)]
	}	

	set d [expr ($l/2)] ;# for arranging node in left side hierarchy
	set f 1 ;# for arranging node in right side hierarchy
	
	#loop for arranging the nodes in hierarchy
	for {set j $l} {$j > 0 } { set j [expr ($j-1)] } {

		if {$i == "4"} {
			$node_($k) color red
			$ns_ at 0.0 "$node_($k) color red"
			$ns_ at 0.0 "$node_($k) label \"S\""
		}
	
		if {$i == "3"} {
			$node_($k) color blue
			$ns_ at 0.0 "$node_($k) color blue"
			$ns_ at 0.0 "$node_($k) label \"SC\""
		}
		if {$i == "2"} {
			$node_($k) color green
			$ns_ at 0.0 "$node_($k) color green"
			$ns_ at 0.0 "$node_($k) label \"PC\""
		}
		if {$i == "1"} {
			$node_($k) color cyan
			$ns_ at 0.0 "$node_($k) color cyan"
			$ns_ at 0.0 "$node_($k) label \"CC\""
		}

		if {$j > ($l/2)} {
		$node_($k) set X_ [expr -(100 * $d)]
		$node_($k) set Y_ [expr 200 * $i]
		$node_($k) set Z_ 0.0
		set d [expr ($d-1)]
		}

		#if {$j == [expr (($l/2)+1)]} {
		#$node_($k) set X_ 0.0
		#$node_($k) set Y_ [expr 200 * $i]
		#$node_($k) set Z_ 0.0
		#}

		if {$j <= ($l/2)} {
		$node_($k) set X_ [expr 100 * $f]
		#puts "[expr 100 * $j]"
		$node_($k) set Y_ [expr 200 * $i]
		$node_($k) set Z_ 0.0
		incr f

		}

		incr k
	}
	}
}


for {set i 0} {$i < $val(nn)} {incr i} {
   $ns_ initial_node_pos $node_($i) 20
}


$ns_ at 10.0 "$node_(0) setdest 50.0 10.0 6.0"
$ns_ at 15.0 "$node_(1) setdest 75.0 100.0 6.0"
$ns_ at 15.0 "$node_(0) setdest 5.0 5.0 6.0"
$ns_ at 20.0 "$node_(0) setdest 50.0 3.0 6.0" 
$ns_ at 35.0 "$node_(0) setdest 320.0 200.0 5.0" 
$ns_ at 40.0 "$node_(0) setdest 480.0 300.0 5.0"  
#$ns_ at 0.0 "$node_(0) setdest 50.0 0.0 5.0"

#array declaration and initialisation
set array(0) {0}
set array(1) {0}
set array(2) {0}
set array(3) {0}
set array(4) {0}


#key variable set for array index traversal
#set key [expr ($val(layer)-1)]

if { $x != "1" } {
#accepting sender node from user
set inp $val(sender)
set in 0
#puts " inp=$inp"

#loop for sending the packet in wireless hierarchy
for {} {$inp > 0 } {} {
set in $inp
if { [expr ($inp % 3)] == "0"} {
	set inp [expr (($inp-1)/3)]
} else {

	set inp [expr ($inp/3)]
}
#puts " inp,in after loop = $inp,$in"
puts "$in->$inp"

set udp [new Agent/UDP]
set sink [new Agent/Null]
$ns_ attach-agent $node_($in) $udp
$ns_ attach-agent $node_($inp) $sink
$ns_ connect $udp $sink
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set interval_ 0.1
$cbr set maxpkts_ 1000
$ns_ at 1.0 "$cbr start" 

after 2000
#puts "array($key)= $array($key)"

}

} 
#if { x

puts "----------"

if { $y != "1" } {
#accepting receiver node
set inp $val(receiver)
set in 0

#loop to find the successive nodes between the receiver node and the supreme node

set key 0
for {} {$inp>0} {} {
set in $inp
if { [expr ($inp % 3)] == "0"} {
	set inp [expr (($inp-1)/3)]
} else {

	set inp [expr ($inp/3)]
}

#puts " inp,in after loop = $inp,$in"

set array($key) $in
set key [expr ($key+1)]

}
set array($key) $inp
#for loop to check the values in the array
for {} { $key > 0} {} {
	set temp [expr ($key-1)]
	#puts "array($key)= $array($key)"
	puts "$array($key)->$array($temp)"
	set udp [new Agent/UDP]
	set sink [new Agent/Null]
	$ns_ attach-agent $node_($array($key)) $udp
	set key [expr ($key-1)]
	$ns_ attach-agent $node_($array($key)) $sink
	$ns_ connect $udp $sink
	set cbr [new Application/Traffic/CBR]
	$cbr attach-agent $udp
	$cbr set interval_ 0.1
	$cbr set maxpkts_ 1000
	$ns_ at 1.0 "$cbr start" 
	#puts "$array($key)"
after 2000
}

}
#if { y }
	#puts "array($key)= $array($key)"

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns_ at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"
$ns_ at 2000.01 "puts \"end simulation\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
    exec nam protocol1.nam
}

$ns_ run
