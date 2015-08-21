# Taking Commnad line paramter routing protocol such as AODV, DSR etc
set par1  [lindex $argv 0]

# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             13                      ;# number of mobilenodes
set val(rp)             $par1                      ;# routing protocol
set val(x)              500   			   ;# X dimension of topography
set val(y)              500   			   ;# Y dimension of topography  
set val(stop)		300			   ;# time of simulation end
set val(layer)          3

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
set l 0
for {set i 0} {$i < $val(layer) } { incr i } {
		if {$i == "3"} {
			$node_($k) color red
			$ns_ at 0.0 "$node_($k) color red"
			$ns_ at 0.0 "$node_($k) label \"S\""
		}
		if {$i == "2"} {
			$node_($k) color blue
			$ns_ at 0.0 "$node_($k) color blue"
			$ns_ at 0.0 "$node_($k) label \"SC\""
		}
		if {$i == "1"} {
			$node_($k) color green
			$ns_ at 0.0 "$node_($k) color green"
			$ns_ at 0.0 "$node_($k) label \"PC\""
		}
	$node_($k) set X_ 0.0
	$node_($k) set Y_ [expr 100 * $i]
	$node_($k) set Z_ 0.0

	incr k

	set l [expr pow(3, $i)]
	puts "$l"

	for {set j 1} {$j <= ($l/ 2) } { incr j } {
		if {$i == "3"} {
			$node_($k) color red
			$ns_ at 0.0 "$node_($k) color red"
			$ns_ at 0.0 "$node_($k) label \"S\""
		}
		if {$i == "2"} {
			$node_($k) color blue
			$ns_ at 0.0 "$node_($k) color blue"
			$ns_ at 0.0 "$node_($k) label \"SC\""
		}
		if {$i == "1"} {
			$node_($k) color green
			$ns_ at 0.0 "$node_($k) color green"
			$ns_ at 0.0 "$node_($k) label \"PC\""
		}
		$node_($k) set X_ [expr 100 * $j]
		puts "[expr 100 * $j]"
		$node_($k) set Y_ [expr 100 * $i]
		$node_($k) set Z_ 0.0

		incr k
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

		$node_($k) set X_ [expr 100 * -$j]
		$node_($k) set Y_ [expr 100 * $i]
		$node_($k) set Z_ 0.0
	
		incr k
	}
}



# lables to Nodes
#$ns_ at 0.0 "$node_(0) label \"C1\""
#$ns_ at 0.0 "$node_(1) label \"C2\""
#$ns_ at 0.0 "$node_(2) label \"C3\""
#$ns_ at 0.0 "$node_(3) label \"CC1\""
#$ns_ at 0.0 "$node_(4) label \"CC2\""
#$ns_ at 0.0 "$node_(5) label \"CC3\""
#$ns_ at 0.0 "$node_(6) label \"CCC1\""
#$ns_ at 0.0 "$node_(7) label \"CCC2\""
#$ns_ at 0.0 "$node_(8) label \"CCC3\""
#$ns_ at 0.0 "$node_(9) label \"CCCC\""





for {set i 0} {$i < $val(nn)} {incr i} {
   $ns_ initial_node_pos $node_($i) 20
}

# Generation of movements

#$ns_ at 100.0 "$node_(0) setdest 250.0 250.0 3.0"
#$ns_ at 150.0 "$node_(1) setdest 45.0 285.0 5.0"
#$ns_ at 150.0 "$node_(0) setdest 480.0 300.0 5.0"
#$ns_ at 160.0 "$node_(0) setdest 250.0 300.0 5.0" 
#$ns_ at 180.0 "$node_(0) setdest 320.0 200.0 5.0" 
#$ns_ at 280.0 "$node_(0) setdest 480.0 300.0 5.0"  

# node 0 transfers UDP packets to node 4

set k 0 
set j 0
set l 0

for {set i 0} {$i < 500 } { set i [expr ($i+50)] } {
puts "$i"
set tcp [new Agent/TCP]
$ns_ attach-agent $node_(3) $tcp
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(8) $sink
$ns_ connect $tcp $sink
$tcp set fid_ 1
$tcp set window_ 8000
$tcp set packetSize_ 552
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
$ns_ at $i "$ftp start"
set k [expr ($i+20)] 
$ns_ at $k "$ftp stop"

set tcp1 [new Agent/TCP]
$ns_ attach-agent $node_(3) $tcp1
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(10) $sink
$ns_ connect $tcp1 $sink
$tcp1 set fid_ 1
$tcp1 set window_ 8000
$tcp1 set packetSize_ 552
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
set l [expr ($i+20)]
$ns_ at $l "$ftp1 start"
set j [expr ($i+50)]
$ns_ at  $j "$ftp1 stop"
}


# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns_ at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"
$ns_ at 300.01 "puts \"end simulation\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

$ns_ run
