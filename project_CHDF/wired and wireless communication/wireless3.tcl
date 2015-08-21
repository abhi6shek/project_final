set opt(chan)   Channel/WirelessChannel        ;# channel type
set opt(prop)   Propagation/TwoRayGround       ;# radio-propagation model
set opt(netif)  Phy/WirelessPhy                ;# network interface type
set opt(mac)    Mac/802_11                     ;# MAC type
set opt(ifq)    Queue/DropTail/PriQueue        ;# interface queue type
set opt(ll)     LL                             ;# link layer type
set opt(ant)    Antenna/OmniAntenna            ;# antenna model
set opt(ifqlen)         50                     ;# max packet in ifq
set opt(nn)             1                      ;# number of mobilenodes
set opt(adhocRouting)   DSDV                   ;# routing protocol

set opt(cp)     ""                             ;# cp file not used
set opt(sc)     ""                             ;# node movement file. 

set opt(x)      200                            ;# x coordinate of topology
set opt(y)      200                            ;# y coordinate of topology
set opt(seed)   0.0                            ;# random seed
set opt(stop)   250                            ;# time to stop simulation

set opt(ftp1-start)      100.0

set num_wired_nodes      2
#set num_bs_nodes       2  ; this is not really used here.

# ======================================================================

# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical

AddrParams set domain_num_ 3           ;# number of domains
lappend cluster_num 2 1 1              ;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 2 1            ;# number of nodes in each cluster 
AddrParams set nodes_num_ $eilastlevel ;# of each domain

set tracefd  [open wireless3-out.tr w]
set namtrace [open wireless3-out.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
#   2 for HA and FA
create-god [expr $opt(nn) + 2]

#create wired nodes
set temp {0.0.0 0.1.0}           ;# hierarchical addresses 
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]] 
}

# Configure for ForeignAgent and HomeAgent nodes
$ns_ node-config -mobileIP ON \
                 -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 

# Create HA and FA
set HA [$ns_ node 1.0.0]
set FA [$ns_ node 2.0.0]
$HA random-motion 0
$FA random-motion 0

# Position (fixed) for base-station nodes (HA & FA).
$HA set X_ 20.000000000000
$HA set Y_ 30.000000000000
$HA set Z_ 0.000000000000

$FA set X_ 150.000000000000
$FA set Y_ 100.000000000000
$FA set Z_ 0.000000000000

# create a mobilenode that would be moving between HA and FA.
# note address of MH indicates its in the same domain as HA.
$ns_ node-config -wiredRouting OFF

set MH [$ns_ node 1.0.1]
set node_(0) $MH
set HAaddress [AddrParams addr2id [$HA node-addr]]
[$MH set regagent_] set home_agent_ $HAaddress

# movement of the MH
$MH set Z_ 0.000000000000
$MH set Y_ 2.000000000000
$MH set X_ 2.000000000000

# MH starts to move towards FA
$ns_ at 100.000000000000 "$MH setdest 110.000000000000 110.000000000000 20.000000000000"
# goes back to HA
$ns_ at 200.000000000000 "$MH setdest 2.000000000000 2.000000000000 20.000000000000"

# create links between wired and BaseStation nodes
$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $HA 5Mb 2ms DropTail
$ns_ duplex-link $W(1) $FA 5Mb 2ms DropTail

$ns_ duplex-link-op $W(0) $W(1) orient down
$ns_ duplex-link-op $W(1) $HA orient left-down
$ns_ duplex-link-op $W(1) $FA orient right-down

# setup TCP connections between a wired node and the MobileHost

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $W(0) $tcp1
$ns_ attach-agent $MH $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at $opt(ftp1-start) "$ftp1 start"


set udp [new Agent/UDP]
set sink [new Agent/Null]
$ns_ attach-agent $MH $udp
$ns_ attach-agent $FA $sink
$ns_ connect $udp $sink
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set interval_ 0.1
$cbr set maxpkts_ 1000
$ns_ at 130.0 "$cbr start" 

# source connection-pattern and node-movement scripts
if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	puts "Loading connection pattern..."
	source $opt(cp)
}
if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
	puts "Load complete..."
}

# Define initial node position in nam

for {set i 0} {$i < $opt(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your
    # scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 20
}     


# Tell all nodes when the simulation ends
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}


$ns_ at $opt(stop).0 "$HA reset";
$ns_ at $opt(stop).0 "$FA reset";

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd namtrace
    close $tracefd
    close $namtrace
    exec nam wireless3-out.nam
}

# some useful headers for tracefile
puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp \
	$opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."
$ns_ run
