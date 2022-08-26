set ns [new Simulator]
source tb_compat.tcl

set server [$ns node]
set client [$ns node]

tb-set-node-os $server Ubuntu2004-STD
tb-set-node-os $client Ubuntu2004-STD

set lan0 [$ns make-lan "$server $client" 1000Mb 0ms]

$ns rtproto Static

$ns run
