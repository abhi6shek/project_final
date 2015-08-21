# Taking Command line paramter routing protocol such as AODV, DSR etc
set par1  [lindex $argv 0]
set par2  [lindex $argv 1]
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
set val(input)          $par2

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
set tracefd       [open wireless.tr w]
set namtrace      [open wireless.nam w]    

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
set k 0 
set l 0.0
for {set i 0} {$i < $val(layer) } { incr i } {


	if {$i == "0"} {
		$ns_ at 0.0 "$node_($k) label \"BC\""
		$node_($k) set X_ 0.0
		$node_($k) set Y_ 0.0#[expr 200 * $i]
		$node_($k) set Z_ 0.0
		incr k
	} else {
	if { $i == "0"} {
		set l 0
	} else {
		set l 1
	}
	
	#set l [expr pow(3, $i)]
	for {set m $i} {$m > 0} { set m [expr ($m-1)] } {
		set l [expr ($l*3)]
	}	

	puts "abhi $l"
	set d [expr ($l/2)]
	set f 1
	for {set j $l} {$j > 0 } { set j [expr ($j-1)] } {
#		puts "$j"

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
		#puts "[expr 100 * $j]"
		$node_($k) set Y_ [expr 200 * $i]
		$node_($k) set Z_ 0.0
		set d [expr ($d-1)]
		}

		if {$j == [expr (($l/2)+1)]} {
		$node_($k) set X_ 0.0
		#puts "[expr 100 * $j]"
		$node_($k) set Y_ [expr 200 * $i]
		$node_($k) set Z_ 0.0

		}


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



# random motion disable 
#for {set i 0} {$i < $val(nn)} {incr i} {
#  $node_($i) random-motion 0
#}


for {set i 0} {$i < $val(nn)} {incr i} {
   $ns_ initial_node_pos $node_($i) 20
}






set inp $val(input)
set in 0
puts " inp=$inp"
for {} {$inp > 0 } {} {
set in $inp
if { [expr ($inp % 3)] == "0"} {
	set inp [expr (($inp-1)/3)]
} else {

	set inp [expr ($inp/3)]
}
puts " inp,in after loop = $inp,$in"

set udp [new Agent/UDP]
set sink [new Agent/Null]
$ns_ attach-agent $node_($inp) $udp
$ns_ attach-agent $node_($in) $sink
$ns_ connect $udp $sink
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set interval_ 0.1
$cbr set maxpkts_ 1000
$ns_ at 1.0 "$cbr start" 

}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns_ at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"
$ns_ at 1000.01 "puts \"end simulation\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

$ns_ run
