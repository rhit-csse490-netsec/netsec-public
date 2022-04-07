---
layout: post
title: Lab 2
readtime: true
date: Sat Mar 19 19:14:56 2022 
---

# Prelude: Lab 1 Feedback form

If you have not done so yet, I would really appreciate your feedback on the
first lab using [the following anonymous Google
form](https://forms.gle/CJwpjiHCJNQ4kAWK7)

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

In this step, the victim and the client are communicating via the Telnet
protocol, your job as an attacker is to intercept the communication between the
two ends and change the payload of the packets before delivering them to their
destination. In Telnet, each character is sent in an individual TCP packet. Your
goal is to replace all characters sent by the victim with the letter `Z` as
shown in the figure below.

![telnet ]({{ site.baseurl }}/figs/telnet.png)

## Setting up the Telnet connection

On the **client** machine, install the Telnet server using 
```shell
$ sudo apt install -y telnetd
```
Make sure that the `telnetd` service is up and running using
```shell
$ sudo service inetd status
```
You should see something that looks like the following:
```shell
* inetd.service - Internet superserver
   Loaded: loaded (/lib/systemd/system/inetd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2022-03-20 06:27:12 PDT; 4min 30s ago
     Docs: man:inetd(8)
 Main PID: 3802 (inetd)
    Tasks: 2 (limit: 2314)
   CGroup: /system.slice/inetd.service
           |-3802 /usr/sbin/inetd
           `-4235 in.telnetd: victim-lan0

   [...]
```

Then, create a dummy user on the client machine with username `loki` and
password `loki` as follows
```shell
$ sudo useradd loki
```
then set the password using 
```shell
$ sudo passwd loki
```
and enter the new password twice.  

Now, on the **victim** machine, try to telnet into the client machine using
```shell
$ telnet 10.1.1.4
```
and then enter the username and password for the `loki` account we just created.
You should be able to login to a shell on the client machine. Try out a
different set of commands to make sure everything is running smoothly. 

## Step 1: Launch the ARP cache poisoning attack

First, on the attacker, write a script using `scapy` that poisons that caches of
**both** the victim and the client. If the attack is successful, the victim's
ARP cache will map the client's IP address to the attacker's MAC address. At the
same time, the client's ARP cache will map the victim's IP address to the
attacker's MAC address. In order to prevent the entries from being overwritten
by the valid ones, it is best if you keep sending these attack packets
periodically (e.g., every 2 seconds). In other words, you need a loop that does
something like
```python
while(1):
  send_attack_packets()
  sleep(2)
```

If the attack is successful, packets sent between the victim and the client will
be sent instead to the attacker machine for them to modify as they please. 

## Step 2: Routing the traffic

First, disable the Linux routing on the attacker machine so that you gain full
control over the incoming packets. To do so, from the attacker's terminal
```shell
$ sudo sysctl net.ipv4.ip_forward=0
```
Note that you must redo this step every single time you reboot the machine since
it defaults to being on. 

At this step, if your attack is successful, communication between the client and
the victim will not work since all traffic is sent to the attacker and the
attacker is not forwarding the traffic. In this step, we will make the attacker
act as a router between the victim and the client. 

On the attacker machine, write another `python` script in which you sniff
packets coming from either the victim or the client machine (i.e., you need to
set an appropriate layer 2 filter to capture only relevant packets). After that,
in the packet handler function, do nothing except resend the packet on the
appropriate interface, i.e., do not change the packets yet. You can use the
following piece of code to resend a packet using `scapy`:
```python
newpkt = IP(bytes(pkt[IP]))
del(newpkt.chksum)
if TCP in newpkt:
  del(newpkt[TCP].chksum)
elif ICMP in newpkt:
  del(newpkt[ICMP].chksum)
send(newpkt, iface='<interface_name>')
```

Run your script on the attacker machine and test your code by starting a ping
session from the victim to the client. The ping should be successful even though
the ARP cache at both ends are poisoned; the attacker is acting as a router
routing traffic from the victim to the client and vice versa. Note that the ping
packet will now take significantly longer (in terms of ms) but that is okay. We
can speed this up by writing the code in C, but let's not do that now. 

## Step 3: Launching the MITM attack

Now that the attacker is intercepting and routing traffic between the victim and
the client, it is time to start modifying the packets as they come between the
victim and the client. 

Recall that the Telnet protocol sends each character in a TCP packet, therefore
we are looking for TCP packets that have a payload of one character. Modify your
script so that the attacker can change the content of the TCP packets of length
1 and make them contain the character `Z` instead of whatever character they
contain. To obtain the payload of a TCP packet, you can use the following code
snippet:
```python
if pkt[TCP].payload:
  data = pkt[TCP].payload.load
```

### A note on Telnet behavior

Typically, in Telnet, every character is sent in an individual TCP packet, yet
if you type very very fast, characters might be grouped together and sent in a
single packet. You **DO NOT** have the handle this case, we will assume that the
victim types slowly. 

On the victim's end, with Telnet, the characters you see are not the characters
you type. Instead, they are rather the same characters you send to the client
echoed back from the client. So for example, if the victim types `ls`, the
attacker will change these characters to `zz`, which the client then echo back
to the victim. Therefore, the victim's terminal will show `zz` instead of `ls`.


# MITM on Netcat

This task is similar to the previous one, except that now the victim and the
client are communicating using `netcat`. To establish a TCP connection between
the two, one the client side start a listening server on port 9090 using
```shell
$ nc -lp 9090
```
On the victim's end, connect to the client's `netcat` server using 
```shell
$ nc 10.1.1.4 9090
```
After that type a line, and one you hit the `Enter` key, the line will be sent
to the client machine and will be printed on the client's end. 

Your job in this task is to intercept the traffic between the victim and the
client, and in the payload of the TCP segments, change every occurrence of your
name to 'AAAAAA'. **Please note that in order not to break the TCP segments'
sequence number, it is important that the replaced string and the string
replacing it have the SAME length**. In other words, replace your name with the
`A` character repeated the number of characters in your name. 

For example, if on the victim's machine, I type
```shell
Hello this is Mohammad
```
On the client's end, this will show up as
```shell
Hello this is AAAAAAAA
```

# Submission Instructions

In addition to your source code, for each part in this lab, submit a
screenshot(s) showing successful implementation of the attack or utility in
question. I ask for screenshots because the nature of DETER makes it almost
impossible for me to regenerate your results unless you make them very modular,
which is not very practical for this class. 

Put your screenshots into a PDF file and then submit that to gradescope
alongside your code. 

## Video submission (Optional)

If you would rather record a video showing successful exploitation, that is
totally fine by me. Then please submit a PDF file containing a link to your
video instead of a written report. 

# Feedback

I would really appreciate your feedback on this lab. Recall that this is the
first time we offer this class and that we are trying to make it as good of an
experience for you as possible. Therefore, I will solicit your feedback on every
lab and I would highly appreciate if you can fill them out. You can find the
feedback form at the following [link](https://forms.gle/tnTYt2nY2LE4FHBe9). The
form is completely anonymous.

# Acknowledgments

This lab is based on the SEED labs by Professor Wenliang Du and modified by
Mohammad Noureddine. This work is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](https://creativecommons.org/licenses/by-nc-sa/4.0/). 

