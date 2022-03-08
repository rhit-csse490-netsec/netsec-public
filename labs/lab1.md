---
layout: post
title: Lab 1
readtime: true
date: Tue Mar  1 17:17:40 2022 
---

# Introduction

In this lab, we will start by getting our hands dirty with network programming
using the `scapy` package. Sniffing and spoofing packets are the essential tools
available to a security attacker and defender. Therefore, our journey of
learning the ins and outs of network security starts with sniffing and spoofing
network packets. 

## Learning Objectives

The goal of this lab is to introduce you to the concepts of packet sniffing and
packet spoofing. After completion of this lab, you should be able to write code
to capture packets off the wire using `python` and the `scapy` package. 
You should also be able to create both real and counterfeit packets and send
them to their destination. 

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

# Starting the DETER experiment

Log in to your DETERLab account, in the top menu, expand the `Experimentation`
tab and then click on `Begin an experiment`. Give your experiment a __unique__
name. I suggest you use the following format `<user_id>-lab1` and replace
`<user_id>` with your Rose ID. Make sure that there are no spaces in the name
and there are no special characters. 

Enter a description in the `Description` category. I recommend that you enter
your name and your partner's name if you are working in a group, that would be
very helpful for me in debugging things around. 

In the `Your NS file:` row, write down
```
 /proj/csse490/labs/lab1.tcl
```
in the `On Server` text box. 

Leave everything else as defaults and then click on `Submit`. You should be
moved to another page where you will see some logs being shown. Once the
experiment has been created, then you will receive an automated email from
DETER, and things should be ready for you. 

## Swapping the experiment in

After the experiment has been created, it will show up in the home page for your
DETER account (you can always click on `My DeterLab` menu item to go the home
page). Click on the experiment `EID` (second column in the table) and then you
will be taken to the experiment page.

From the experiment page, click on `Swap Experiment In` in the left-hand side
menu in yellow. You will be taken to a page that shows logs coming up. Sit back
and wait for the experiment to be swapped in, this can take a while (a few
minutes) so grab a cup of coffee in the meantime. 

Once the experiment has been swapped in, you are ready to go to access the
experiment machines. You will receive an email from DETER saying that the
experiment has been successfully swapped in. 

Once you are done with your experiment, you can choose the `Swap Experiment Out`
menu item form the left-hand side menu to swap the experiment out and release
the machines that you were using. __Please be mindful of other DETER users and
swap your experiment out when you are done using it__. The experiment will be
automatically swapped out after 4 hours of inactivity in case you forget. 

## Reaching the attacker machine

To reach the attacker machine (and any other machine on the experiment), first
`ssh` into the main DETER users machine using 
```shell
ssh deter
```
and then from that machine, use
```shell
ssh attacker.noureddi-lab1.csse490
```
and replace `noureddi-lab1` with your experiment name. In the same way, you can
reach the other machines using
```shell
ssh client.noureddi-lab1.csse490
```
and
```shell
ssh victim.noureddi-lab1.csse490
```


# Sniffing packets

# Generating packets: Let's ping google.com

# Traceroute

# Spoofing packets
