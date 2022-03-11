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

Let's first start simple and just sniff some packets off the network. Open up a
terminal window and start a `tmux` session using
```shell
tmux new-session -s lab1
```
This will start a new `tmux` session which you can save and regenerate at other
times (unless you reboot your machine or you kill the session). You can view how
to use `tmux` by checking out [this cheat sheet](https://tmuxcheatsheet.com/).

Login to the attacker machine in one pane and into the victim machine on another
pane (or in a completely different terminal window). We will sniff packets on
the attacker machine and generate packets from the victim machine. 

## Sniffing on the attacker's end
On the attacker machine, first record the interface connected to the local LAN
using
```shell
$ ifconfig -a
```
and then record the name of the interface that has the IP address `10.1.1.2`,
let's assume it is `eth0` in our case. 

First, try to sniff a packet from the `python` command line using `ipython3`:
```shell
$ sudo ipython3
```
then from inside `ipython` use the following:
```python
In [1]: from scapy.all import *
WARNING: No route found for IPv6 destination :: (no default route?). This
affects only IPv6

In [2]: pkt=sniff(iface='eth0')
```

At this point, the program will hang waiting for packets to capture, leave it
running and jump into the victim machine. 

## Generating packets on the victim's end

From the victim machine, ping the attacker's machine with 1 packet using
```shell
$ ping -c1 attacker
PING attacker-lan0 (10.1.1.2) 56(84) bytes of data.
64 bytes from attacker-lan0 (10.1.1.2): icmp_seq=1 ttl=64 time=0.186 ms

--- attacker-lan0 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.186/0.186/0.186/0.000 ms
```

## Printing the sniffed packets

Now from the attacker machine, hit `Ctrl-c` to exit out of the sniffing mode,
and then type `pkt.show()` to show the packets that you can captured. In my
case, the output was
```python
In [2]: pkt=sniff(iface='eth0')
^C
In [3]: pkt.show()
0000 00:0e:0c:66:89:6a > 01:80:c2:00:00:0e (0x88cc) / Raw
0001 2c:76:8a:38:51:aa > 01:80:c2:00:00:0e (0x88cc) / Raw
0002 00:0e:0c:66:89:6a > 01:80:c2:00:00:0e (0x88cc) / Raw
0003 2c:76:8a:38:51:aa > 01:80:c2:00:00:0e (0x88cc) / Raw
0004 00:0e:0c:66:89:6a > 01:80:c2:00:00:0e (0x88cc) / Raw
0005 2c:76:8a:38:51:aa > 01:80:c2:00:00:0e (0x88cc) / Raw
0006 00:0e:0c:66:89:6a > 01:80:c2:00:00:0e (0x88cc) / Raw
0007 2c:76:8a:38:51:aa > 01:80:c2:00:00:0e (0x88cc) / Raw
0008 00:0e:0c:66:89:6a > 01:80:c2:00:00:0e (0x88cc) / Raw
0009 Ether / IP / ICMP 10.1.1.3 > 10.1.1.2 echo-request 0 / Raw
0010 Ether / IP / ICMP 10.1.1.2 > 10.1.1.3 echo-reply 0 / Raw
0011 2c:76:8a:38:51:aa > 01:80:c2:00:00:0e (0x88cc) / Raw

```
Depending on how long you keep the sniffing active, you might see more or less
packets. The only two packets that we care about are the ICMP `echo-request` and
`echo-reply` packets. 

You can then access individual packets by indexing into the `pkt` array of
packets using normal array access patterns. For example, to print the ICMP echo
request packet in my case, you can use
```python
In [4]: pkt[9].show()
###[ Ethernet ]###
  dst       = 00:0e:0c:66:89:6a
  src       = 00:04:23:ae:d0:49
  type      = IPv4
###[ IP ]###
  version   = 4
  ihl       = 5
  tos       = 0x0
  len       = 84
  id        = 39613
  flags     = DF
  frag      = 0
  ttl       = 64
  proto     = icmp
  chksum    = 0x89e5
  src       = 10.1.1.3
  dst       = 10.1.1.2
  \options \
###[ ICMP ]###
  type = echo-request
  code = 0
  chksum = 0x9715
  id = 0xdba
  seq = 0x1
###[ Raw ]###
  load = b'9\t+b\x00\x00\x00\x00"\xf1\r\x00\x00\x00\x00\x00\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f
  !"#$%&\'()*+,-./01234567'

```

You can also view more information about the packet using `ls` as follows:
```python
In [5]: ls(pkt[9])
dst        : DestMACField         = '00:0e:0c:66:89:6a' (None)
src        : SourceMACField       = '00:04:23:ae:d0:49' (None)
type       : XShortEnumField      = 2048            (36864)
--
version    : BitField             = 4               (4)
ihl        : BitField             = 5               (None)
tos        : XByteField           = 0               (0)
len        : ShortField           = 84              (None)
id         : ShortField           = 39613           (1)
flags      : FlagsField           = 2               (0)
frag       : BitField             = 0               (0)
ttl        : ByteField            = 64              (64)
proto      : ByteEnumField        = 1               (0)
chksum     : XShortField          = 35301           (None)
src        : Emph                 = '10.1.1.3'      (None)
dst        : Emph                 = '10.1.1.2'      ('127.0.0.1')
options    : PacketListField      = []              ([])
--
type       : ByteEnumField        = 8               (8)
code       : MultiEnumField       = 0               (0)
chksum     : XShortField          = 38677           (None)
id         : ConditionalField     = 3514            (0)
seq        : ConditionalField     = 1               (0)
ts_ori     : ConditionalField     = None            (30633707)
ts_rx      : ConditionalField     = None            (30633707)
ts_tx      : ConditionalField     = None            (30633708)
gw         : ConditionalField     = None            ('0.0.0.0')
ptr        : ConditionalField     = None            (0)
reserved   : ConditionalField     = None            (0)
addr_mask  : ConditionalField     = None            ('0.0.0.0')
unused     : ConditionalField     = None            (0)
--
load       : StrField             =
b'9\t+b\x00\x00\x00\x00"\xf1\r\x00\x00\x00\x00\x00\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f
!"#$%&\'()*+,-./01234567' (b'')
```

## Putting things into a script

You can also write `python` scripts that can achieve the outcome above, for
example, try the following script
```python
#!usr/bin/env python3
from scapy.all import *

def print_pkt(pkt):
    pkt.show()

pkt = sniff(iface='eth0', filter='icmp', prn=print_pkt)
```
This will start sniffing on `eth0`, but then the `filter='icmp'` parameter will
only care about ICMP packets (to reduce the amount of packets that we capture).
The parameter `prn=print_pkt` sets a callback function that gets executed
__every time__ the sniffer captures a packet. 

You can run the above script using
```shell
$ sudo python3 sniff.py
```

This will show every ICMP packet captured by the sniffer until it is terminated.
Try to ping the attacker from the victim again to verify that it is working
correctly. 


# Generating packets: Let's ping the victim

Now let's generate packets from the attacker and ping the victim. Note that if
you are using VSCode to code using `scapy`, you should also import the following
```python
from scapy.layers.inet import IP, ICMP
```
otherwise the editor's IntelliSense stuff will not work (for some weird reason). 

First let's generate an IP packet using
```python
a = IP()
```
Next, set the destination of the IP packet to be the victim's IP address
```python
a.dst = '10.1.1.3'
```
Recall that you can use `ls(a)` to view the field in a certain packet. 
Next, create an ICMP header using
```python
b = ICMP()
```
You do not need to change any of the default values in the ICMP header. 

Then, let's concatenate the two packets together. To do so, `scapy` has the
division operator overloaded, so we can do something like
```python
pkt = a / b
```
and `scapy` will encapsulate `b` inside an IP packet `a`. Finally, you can send
the packet using
```python
send(pkt)
```
But this will not wait for a response. To cause `scapy` to wait for a response
from the victim machine, using `sr1` to send a packet and then wait for a
response packet as follows:
```python
reply = sr1(pkt)
print("Received a response packet:")
reply.show()
```
This will show the response packet, if any, from the victim machine.

In my setup, running the above script generates the following output:
```shell
$ sudo python3 icmp_gen.py
WARNING: No route found for IPv6 destination :: (no default route?). This
affects only IPv6
Begin emission:
..Finished to send 1 packets.
Received 3 packets, got 1 answers, remaining 0 packets
Received pkt:
###[ IP ]###
  version   = 4
  ihl       = 5
  tos       = 0x0
  len       = 28
  id        = 30992
  flags     =
  frag      = 0
  ttl       = 64
  proto     = icmp
  chksum    = 0xebca
  src       = 10.1.1.3
  dst       = 10.1.1.2
  \options   \
###[ ICMP ]###
  type      = echo-reply
  code      = 0
  chksum    = 0xffff
  id        = 0x0
  seq       = 0x0
###[ Padding ]###
  load      = '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
```


# Traceroute

The objective of this step is to estimate the number of routers between your
machine and the google DNS server located at `8.8.8.8`. Note that __you need to
do this from your local machine, not from the DETER machines__. 

The idea is quite straightforward: just send a packet (any type) to the
destination, with its Time-To-Live (TTL) field set to 1 first. This packet
will be dropped by the first router, which will send us an ICMP error message,
telling us that the time-to-live has been exceeded. That is how we get the IP
address of the first router. We then increase our TTL field to 2, send out
another packet, and get the IP address of the second router. We will repeat
this procedure until our packet finally reaches the destination.  It should be
noted that this experiment only gets an estimated result, because in theory,
not all these packets take the same route (but in practice, they may within a
short period of time).

Running the `traceroute.py` script on my machine gives me the following results:
```shell
$ python traceroute.py
*** 192.168.1.1 ***
*** 142.254.224.97 ***
*** 74.128.8.145 ***
*** 65.29.11.6 ***
*** 66.109.6.54 ***
*** 66.109.5.136 ***
*** 24.30.200.171 ***
*** 74.125.251.147 ***
*** 142.251.231.67 ***
Destination reached: 8.8.8.8
```

# Spoofing packets from non-existing host

In the final step, you need to convince the victim that the host `10.1.1.129`
exists on the network, even though no host with this IP address exists on the
network. We will do this by spoofing both ARP packets and ICMP packets. 

You will need to first understand how the ping process works. To do so, start a
sniffer for all packets on the attacker machine, and then from the victim, ping
the non-existent host using
```shell
$ ping -c1 10.1.1.129
```
Observe the packets that you see on the attacker's end. How can you convince the
victim that the host `10.1.1.129` exists?

_Hint:_ You will need to forge packets at two different layers or protocols, one
ARP packet and one ICMP packet. 

With my script running on the attacker machine, trying to ping the non-existent
host from the victim results in

```shell
$ ping -c1 10.1.1.129
PING 10.1.1.129 (10.1.1.129) 56(84) bytes of data.
From 10.1.1.2: icmp_seq=1 Redirect Host(New nexthop: 10.1.1.129)
64 bytes from 10.1.1.129: icmp_seq=1 ttl=64 time=147 ms

--- 10.1.1.129 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 147.822/147.822/147.822/0.000 ms
```
You do not need to worry about the `Redirect Host` packet, it might show up and
it might not. You only care that the ping packet was replied to by the
non-existent host and that now the victim is convinced that the host
`10.1.1.129` exists on the local network. 

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
feedback form at the following [link](https://forms.gle/2wKnXJXLotVPKv9LA). The
form is completely anonymous.
