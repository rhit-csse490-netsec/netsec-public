---
layout: post
title: Lab 3
readtime: true
date: Sun Mar 27 19:17:23 2022 
---

# Prelude: Lab 2 Feedback form

If you have not done so yet, I would really appreciate your feedback on the
second lab using [the following anonymous Google
form](https://forms.gle/tnTYt2nY2LE4FHBe9).

# Prelude: Work in pairs

For this assignment, please work in pairs so as to avoid the stress on the DETER
resources. Each experiment will need 6 machines, and with 15 students, we might
end up needing 80 machines, which is not very practical. So I would really
appreciate it if you could work in pairs. 

# Introduction

In this lab, we will transition from Layer 2 attacks to Layer 3 attacks and
defenses. We will add one more tool to our arsenal and explore ways in which we
can poison the **routing table** at a victim's so that all traffic destined to a
target server will pass through our malicious router. The Internet Control
Messages Protocol (ICMP) is a layer 3 protocol that provides two
functionalities: (1) control messages and (2) error messages. 

At one point in time, ICMP was used to provide hints to hosts as to where to
route their traffic, especially if something changes in the network and a new,
better router, becomes available. As attackers, we will exploit this fact to
send malicious ICMP redirect messages and trick the victim into sending us all
of its traffic. 

# The network topology

In this lab, we will be using the following network topology. It is composed of
six machines, two of which are controlled by Loki, the trickster god. The rest
are under Asgard's control and are out of your reach. 

![network topology]({{ site.baseurl }}/figs/lab3topo.png)

We assume that you only have control over the attacker machines (though you can
log in to the client and victim to send ICMP packets), the client and the victim
machines are out of your reach and you must not install any additional software
on them. You have full control over the attacker machine so you can configure it
and install software as you please. 

## Creating a new experiment

For this lab, we will create a new experiment, this time call it `<userid>-lab3`
and under the `Your NS file` entry, enter the following under the `On Server`
path:
```
/proj/csse490/labs/lab3b.tcl
```

Hit `Submit` and then swap your experiment in, it should take about 10 minutes
for this one to finish the swap in. If it takes you longer to swap in, please
reach out to your instructor to take a look. 

# ICMP Redirect Attack

## Prelude: Run this on the victim

ICMP Redirect attacks have been in existence for a long time, and the mitigation
in most cases is to simply ignore redirect packets on each and every host. And
that is the default behavior of modern operating systems. 

However, in this case, we will assume that when configuring the Asgard servers,
Baldr (before being brutally murdered by a mistletoe) forgot to set the correct
updates, and thus inadvertently ran this command on the victim machine:
```shell
$ sudo sysctl net.ipv4.conf.all.accept_redirects=1
```
**Note that you must do this step every time you reboot the victim machine or
your swap the experiment in**. 

## The attack

First, let's take a look at the routing table at the victim using
```shell
$ ip route
default via 192.168.1.254 dev eth4 proto dhcp src 192.168.1.197 metric 1024
10.0.0.0/8 via 10.1.2.5 dev eth2
10.1.2.0/24 dev eth2 proto kernel scope link src 10.1.2.3
192.168.0.0/22 dev eth4 proto kernel scope link src 192.168.1.197
192.168.1.254 dev eth4 proto dhcp scope link src 192.168.1.197 metric 1024
```
Let's ignore the `192.XXX` entries as those as reserved for the DETER
communications and let's focus on the two entries for `10.0.0.0/8` and
`10.1.2.0/24`. 
* The entry at `10.1.2.0/24` specifies that for the victim to reach hosts on the
  same `10.1.2.0/24` subnetwork, it can directly use the `eth2` interface and it
  has IP `10.1.2.3`. 
* On the other hand, to reach anything on the `10.0.0.0/8` subnetwork (note the
  overlap between the two entries and thus the longest prefix matching in
  practice), the victim must use the node at `10.1.2.5` (i.e., the router) as a
  default gateway to reach other subnets. 

**Your goal** is to poison the routing table's cache and cause the victim to
send its traffic destined for `10.0.0.0/8` to the attacker router (i.e., the
`arouter` machine) instead of the default gateway which is `10.1.2.5`. 

Now from the attacker machine, forge an ICMP redirect packet that is destined
for the victim and change the victim's default gateway to become the attacker
router machine located at IP address `10.1.2.4`.  

Note that an ICMP redirect packet has the following characteristics:
1. It should be originating from the default gateway, i.e., from `10.1.2.5`.
2. You need to figure out what the ICMP type and code should be. You can find
   the specifications of the ICMP header
   [here](https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml)
   or anywhere online. 
3. An ICMP redirect message has `gw` field as the field of the new IP address to
   which the host must redirect to. 
4. The ICMP redirect packet **must** contain another packet (in normal cases,
   the packet that caused the redirect) as its payload. You need to also craft
   this packet. 
5. You do not have to worry about the layer 2 behavior of the packet, so you can
   just use scapy's `send` function (instead of `sendp`). 

## Verifying the attack works

Forge the packet from the attacker machine and examine the behavior of the
routing table at the victim using
```shell
$ sudo ip route get 10.1.1.2
```
You should see something that looks like
```shell
10.1.1.2 via 10.1.2.4 dev eth2 src 10.1.2.3 uid 0
    cache <redirected> expires 232sec
```
You can now see that at the victim, traffic destined to `10.1.1.2` is now routed
through `10.1.2.4` instead. Notice that the entry expires after a certain amount
of time, so you must keep sending those redirect messages to the victim,
otherwise you might loose the forwarding behavior after the entry expires. You
can use a similar approach to that we used in lab 2. 

To clear the cache on the victim's end, you can use
```shell
$ sudo ip route flush cache
```

## Troubleshooting

The attacker router has not yet been properly configured to be malicious, you
must find out how to change its configuration settings in order to make it act
maliciously.

First, try to ping `10.1.1.2` from the victim after you launch the attack and
examine what happens:
```shell
$ ping -c2 10.1.1.2
PING 10.1.1.2 (10.1.1.2) 56(84) bytes of data.
From 10.1.2.4: icmp_seq=1 Redirect Host(New nexthop: 10.1.2.5)
64 bytes from 10.1.1.2: icmp_seq=1 ttl=63 time=0.322 ms
From 10.1.2.4: icmp_seq=2 Redirect Host(New nexthop: 10.1.2.5)
64 bytes from 10.1.1.2: icmp_seq=2 ttl=63 time=0.346 ms

--- 10.1.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 0.322/0.334/0.346/0.012 ms
```
Answer the following question in your report:
> Q: What can you notice? What is the attacker router doing by default?

Note that `traceroute` can be a great help here in case you are debugging your
code. 

## Configuring the attacker router

In this lab, it is your job to find out how to configure the attacker router so
that you can successfully **disable** communication between the victim and the
destination (i.e., `10.1.1.2`) after the attack is launched. In other words, you
need to configure the attacker router to do two things:
1. Drop packets that are not destined to it (_hint_: we already did that in lab
   2). 
2. Stop sending ICMP redirect messages. **You need to figure this one out on
   your own.** 

For me, this just turned out to be a small, 4-lines, bash script that I called
`configure_router.sh`, I make it an executable using
```shell
chmod +x configure_router.sh
```
and then run it using
```shell
./configure_router.sh
```

If your attack is successful, the victim will no longer be able to communicate
with the destination machine (`10.1.1.2`) as follows:
```shell
$ ping -c2 10.1.1.2
PING 10.1.1.2 (10.1.1.2) 56(84) bytes of data.

--- 10.1.1.2 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1001ms
```

## Exploration

Try the following ICMP redirect attacks and answer the following questions in
your report.

> Q: Can you use ICMP redirect attacks to redirect to a remote machine, i.e.,
  one that is not on the same subnet?

> Q: Can you use ICMP redirect attacks to redirect to a non-existing host? In
  other words, try to redirect to a host on the same subnet but does not exist. 


# MITM Attack

Repeat the MITM attack from the previous lab (lab 2) but instead of using the
ARP cache poisoning attack, use the ICMP redirect attack. Explain your findings
in your report. You need to show that you are able to MITM on **either**
services (netcat or telnet) and not both, unless you really want to. 

# Acknowledgments

This lab is based on the SEED labs by Professor Wengliang Du and modified by
Mohammad Noureddine. This work is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](https://creativecommons.org/licenses/by-nc-sa/4.0/). 

