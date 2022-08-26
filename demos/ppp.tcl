set ns [new Simulator]
source tb_compat.tcl

set server [$ns node]
set client [$ns node]

tb-set-node-os $server 490_ubuntu_1804
tb-set-node-os $client 490_ubuntu_1804

set lan0 [$ns make-lan "$server $client" 1000Mb 0ms]

$ns rtproto Static

$ns run
