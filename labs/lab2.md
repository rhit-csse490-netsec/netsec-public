---
layout: post
title: Lab 2
readtime: true
date: Sat Mar 19 19:14:56 2022 
---

# Introduction

In this lab, we will dive deeper into the Address Resolution Protocol (ARP),
which is a communication protocol used for discovering a layer 2 address given a
layer 3 address. ARP is a very simple protocol and does not implement any
security or authentication measures, which opens it up for plenty of attacks.
The most prominent of these attacks is the ARP cache poisoning attack, where an
attacker poisons the L2 to L3 mappings of a victim with forged mappings. With
such forged mappings, the attacker can act as a man-in-the-middle and intercept
and modify packets between two victims. 

# The network topology

In this lab, we will be using the following network topology. It is composed of
three machines, an attacker, a victim, and a normal client connected to a local
LAN as show in the figure below.

![network topology]({{ site.baseurl }}/figs/topology.png)

We assume that you only have control over the attacker machine (though you can
log in to the client and victim to send ICMP packets), the client and the victim
machines are out of your reach and you must not install any additional software
on them. You have full control over the attacker machine so you can configure it
and install software as you please. 

You can use the same experiment as the one we used in lab 1, so no new setup
steps are needed. 

# ARP Cache Poisoning

The objective of this first task is to use packet spoofing to launch an ARP
cache poisoning attack on the victim machine, such that when the victim tries to
communicate with the client machine, their packets will be intercepted by the
attacker. This is referred to as a Man-In-The-Middle (MITM) attack. 

In this task, we would like to cause the victim machine to add a fake entry in
its ARP cache. This fake entry is going to map the IP address of the client
machine to the MAC address **of the attacker machine**, such that when the
victim talks to the clients, packets will make their way to the attacker machine
instead. 

## Checking the ARP cache

To check the ARP cache, on the victim's machine, you can use the `arp -an`
command, which will show something that looks like this:
```shell
$ arp -an
? (192.168.1.254) at 00:1b:21:cd:de:b1 [ether] on eth3
```
**Please do not delete** the entry for the `192.168.1.254` IP address, it is
used to statically allow all experiment machines to talk to the DETER users
machine. Without it, we would loose access to the machines. 

Now, ping the client from the victim machine using `ping -c1 10.1.1.4`. Check
the ARP cache after that, you should see a mapping for `10.1.1.4` as follows:
```shell
$ arp -an
? (10.1.1.4) at 00:11:43:d6:d5:6c [ether] on eth4
? (192.168.1.254) at 00:1b:21:cd:de:b1 [ether] on eth3
```
Note that the MAC address and the interface mappings might be different on your
end. Your task is to change the mapping for `10.1.1.4` in the victim's cache to
map to the attacker's MAC address. 

To delete an entry from the ARP cache, you can use `sudo arp -d 10.1.1.4` to
delete the entry for `10.1.1.4`. 

## Poisoning the ARP cache

There are multiple ways to poison an ARP cache, in this task, you will try three
different approaches and report on whether they work or not. 

### Attempt 1: Using an ARP request 

On the attacker's machine, forge an ARP request packet to map the client's IP
address to the attacker's MAC address. In your report, please specify whether
the attack was successful or not by showing the content of the victim's ARP
cache before and after the attack. 

### Attempt 2: Using an ARP reply

First, reset the victim's ARP cache to its original state by deleting any
entries that were created in the previous step. Most likely, this will amount to
deleting the mapping for `10.1.1.4` using `sudo arp -d 10.1.1.4`. 

On the attacker's machine, forge an ARP reply packet to map the client's IP
address to the attacker's MAC address. Is the cache poisoning attack successful
in this case?

Try the attack under the two following scenarios:
1. The victim's ARP cache does not contain a mapping for `10.1.1.4`.
2. The victim's ARP cache already contains a mapping for `10.1.1.4`, you can
   create that mapping by pinging the client from the victim's machine and then
   checking the contents of the cache using `arp -an`. 

Report on your findings in each case, when is the attack successful and when is
it failing?

### Attempt 3: Using an ARP gratuitous 

First, reset the victim's ARP cache to its original state by deleting any
entries that were created in the previous step. Most likely, this will amount to
deleting the mapping for `10.1.1.4` using `arp -d 10.1.1.4`. 

On the attacker's machine, construct an ARP gratuitous packet to map the
client's IP address to attacker's MAC address. An ARP gratuitous packet has the
following characteristics:
- The source and destination IP address are the same in the ARP header, and they
are the IP address of the spoofed host (i.e., the victim in our case). 
- The destination MAC address in the both the ARP header and the Ethernet header
are the broadcast MAC address (`ff:ff:ff:ff:ff:ff`).
- No reply is expected. 

Try the attack under the two following scenarios:
1. The victim's ARP cache does not contain a mapping for `10.1.1.4`.
2. The victim's ARP cache already contains a mapping for `10.1.1.4`, you can
   create that mapping by pinging the client from the victim's machine and then
   checking the contents of the cache using `arp -an`. 

Report on your findings in each case, when is the attack successful and when is
it failing?

# MITM on Telnet

# MITM on Netcat

