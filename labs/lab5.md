---
layout: post
title: Lab 4
readtime: true
date: Mon May 16 10:41:35 2022 
---

# Introduction 

Providing private communication over an untrusted, public network is the job of
a Virtual Private Network (VPN). Computers inside a VPN can communicate
securely, just like if they were on a real private network that is physically
isolated from the outside, even though their traffic may go through a public
network, or the Internet. 

There are two main components in a VPN: tunneling and encryption. In this lab,
we will strictly focus on the tunneling part. We will build a small VPN built on
top of the transport layer by writing a VPN client and VPN server and
establishing an IP tunnel in between them. 

This lab covers the following topics:
- Virtual Private Network (VPN)
- TUN/TAP Interfaces
- IP Tunneling

# Network Topology

# Step 0: Verify the topology

To verify that the topology is set up correctly, we must make sure that the two
private network cannot communicate with each other, but they can communicate
with the VPN server. To do so, on the `useru` machine, do the following:
```shell
useru:$ ping -c1 server
```
The ping should be successful and you should see something that looks like the
following:
```shell
PING server-lan0 (10.1.2.3) 56(84) bytes of data.
64 bytes from server-lan0 (10.1.2.3): icmp_seq=1 ttl=64 time=0.344 ms

--- server-lan0 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.344/0.344/0.344/0.000 ms
```

Next, try to traceroute the server and verify that it is only one hop away:
```shell
useru:$ traceroute server
traceroute to server (10.1.2.3), 30 hops max, 60 byte packets
 1  server-lan0 (10.1.2.3)  0.142 ms  0.110 ms  0.127 ms
```

Next, verify the other hosts are not reachable from `useru` as follows:
```shell
useru:$ ping -c1 userv
PING userv-lab1 (10.1.1.2) 56(84) bytes of data.
From router.isi.deterlab.net (192.168.1.254) icmp_seq=1 Destination Host
Unreachable

--- userv-lab1 ping statistics ---
1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms
```
**If the above ping packet is successfully returned, then your network setup is
incorrect and you need to contact your instructor for debugging**. 

Repeat the above steps from the `userv` machine as follows:
```shell
userv:$ ping -c1 server
PING server-lab1 (10.1.1.4) 56(84) bytes of data.
64 bytes from server-lab1 (10.1.1.4): icmp_seq=1 ttl=64 time=0.362 ms

--- server-lab1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.362/0.362/0.362/0.000 ms
```

```shell
userv:$ traceroute server
traceroute to server (10.1.1.4), 30 hops max, 60 byte packets
 1  server-lab1 (10.1.1.4)  0.203 ms  0.183 ms  0.155 ms
```

```shell
userv:$ ping -c1 useru
PING useru-lan0 (10.1.2.2) 56(84) bytes of data.
From router.isi.deterlab.net (192.168.1.254) icmp_seq=1 Destination Host
Unreachable

--- useru-lan0 ping statistics ---
1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms
```

# Step 1: Create and configure a TUN interface

The VPN tunnel that we are going to build is based on the TUN/TAP technologies.
TUN and TAP are virtual network kernel drivers; they implement network devices
that are supported entirely in software. TAP (as in network tap) simulates an
Ethernet device and it operates with layer-2 packets such as Ethernet frames;
TUN (as in network TUNnel) simulates a network layer device and it operates with
layer-3 packets such as IP packets. With TUN/TAP, we can create virtual network
interfaces.

A user-space program is usually attached to the TUN/TAP virtual network
interface. Packets sent by an operating system via a TUN/TAP network interface
are delivered to the user-space program. On the other hand, packets sent by the
program via a TUN/TAP network interface are injected into the operating system
network stack. To the operating system, it appears that the packets come from an
external source through the virtual network interface.

When a program is attached to a TUN/TAP interface, IP packets sent by the kernel
to this interface will be piped into the program. On the other hand, IP packets
written to the interface by the program will be piped into the kernel, as if
they came from the outside through this virtual network interface. The program
can use the standard `read()` and `write()` system calls to receive packets from
or send packets to the virtual interface.

Use the code below to create a TUN interface on `useru`:
```python
#!/usr/bin/env python

import fcntl
import struct
import os
import time
import logging

from scapy.all import *

# Globals, do not change these values
TUNSETIFF = 0x400454ca
IFF_TUN   = 0x0001
IFF_TAP   = 0x0002
IFF_NO_PI = 0x1000

if __name__ == '__main__':
    # configure logging
    logging.basicConfig(level=logging.INFO)

    # This code is nothing but a wrapper around C code
    tun = os.open("/dev/net/tun", os.O_RDWR)
    ifr = struct.pack('16sH', b'tun%d', IFF_TUN | IFF_NO_PI)
    ifname_bytes = fcntl.ioctl(tun, TUNSETIFF, ifr)

    # Grab the name of the interface
    ifname = ifname_bytes.decode('UTF-8')[:16].strip("\x00")
    logging.info("Interface name: {}".format(ifname))

    # Do nothing
    while True:
        time.sleep(10)
```

## Verify that the interface is created

To run the above script, you can use the following commands:
```shell
user:$ sudo python3 tun.py
```
and you should leave the program running. 

In another terminal on `useru`, check out the available interfaces using
```shell
useru:$ ip -c address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0e:0c:68:a7:11 brd ff:ff:ff:ff:ff:ff
    inet 10.1.2.2/24 brd 10.1.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20e:cff:fe68:a711/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:04:23:ae:cc:16 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:04:23:ae:cc:17 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:11:43:d5:f5:72 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.96/22 brd 192.168.3.255 scope global eth3
       valid_lft forever preferred_lft forever
    inet6 fe80::211:43ff:fed5:f572/64 scope link
       valid_lft forever preferred_lft forever
6: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:11:43:d5:f5:73 brd ff:ff:ff:ff:ff:ff
8: tun0: <POINTOPOINT,MULTICAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 500
    link/none
```

Specifically, the last line is the one of interest to us:
```shell
8: tun0: <POINTOPOINT,MULTICAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 500
    link/none
```
We have created a TUN interface called `tun0` that is in the DOWN state
currently. 

## Set up the interface

As you can see in the output above, the `tun0` interface is DOWN. We need to
bring it up, let's do the following
```shell
useru:$ sudo ip addr add 10.1.3.1/24 dev tun0
```
At this point, you can bring the interface up using
```shell
useru:$ sudo ip link set dev tun0 up
```
The interface now should be up and should have an IP address. You can check it
out using
```shell
useru:$ ip -c address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0e:0c:68:a7:11 brd ff:ff:ff:ff:ff:ff
    inet 10.1.2.2/24 brd 10.1.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20e:cff:fe68:a711/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:04:23:ae:cc:16 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:04:23:ae:cc:17 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:11:43:d5:f5:72 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.96/22 brd 192.168.3.255 scope global eth3
       valid_lft forever preferred_lft forever
    inet6 fe80::211:43ff:fed5:f572/64 scope link
       valid_lft forever preferred_lft forever
6: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 00:11:43:d5:f5:73 brd ff:ff:ff:ff:ff:ff
8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none
    inet 10.1.3.1/24 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::1e27:e6f1:e996:3dd1/64 scope link stable-privacy
       valid_lft forever preferred_lft forever

```

To help you create and bring up the interfaces in one shot from your python
script, add the following to the `tun.py` script
```python
os.system("ip addr add 10.1.3.1/24 dev {}".format(ifname))
os.system("ip link set dev {} up".format(ifname))
```

## Read from the interface

Now, let's read stuff out of the TUN interface. Whatever comes out of the
interface represents an IP packet as a bunch of bytes. We can then use `scapy`
to read the bytes as an IP packet and use the fancy stuff in `scapy`. 

Replace the `while` loop in the `tun.py` script with the following:
```shell
while True:
    # Get a packet from the interface
    packet = os.read(tun, 2048)
    if packet:
        ip = IP(packet)
        logging.info(ip.summary())
```

Update your `tun.py` script and run it, then bring up another terminal on
`useru` and try the following experiments:
```shell
useru:$ ping -c1 10.1.3.4
```

> Report on your observations. What do you see at the `tun.py` output? 

Then try to reach the other private network
```shell
useru:$ ping -c1 userv
```

> Report on your observations. Can you see any packets? Is the ping successful?

## Write to the interface

Now let's write to the interface and see what happens. Since this is a virtual
network interface at layer 3, whatever is written to the interface by the
application will appear in the kernel as an IP packet. 

We will modify our script such that whenever it receives a packet, it will
construct a new packet based on the received one, except that it will change its
source IP address to `1.2.3.4` and its destination address is the source address
of the received packet. It should look something like this
```python
newip = IP(src='1.2.3.4', dst=ip.src)
newpkt = newip/ip.payload
# write the packet to the tun interface
os.write(tun, bytes(newpkt))
```

### Successful ping

Now let's make the TUN interface reply to ICMP echo requests. Modify your
`tun.py` script such that:
- It receives packets from the interface
- If the received packet is an ICMP echo request packet:
  - Construct a corresponding echo reply and send it back through the TUN
    interface to the source of the packet. 
  - In other words, the `ping 10.1.3.4` should be successful. 

> Name your script `tun_ping.py` and submit it along with a screenshot showing a
successful ping. 


# Step 2: Send packets to the VPN server through the tunnel

Now, it's time to set up a dummy server that will listen to UDP packets coming
from the TUN interface. For every received packet on the TUN interface, we will
create another UDP packet, and make the received packet **the payload of the UDP
packet**. In other words, the TUN interface sends the received packet to the UDP
server inside of another UDP packet. This is known as IP tunneling. Even though
we chose UDP for this task, you can equally do the same using TCP. 

## The server script

On the server machine, create script called `tun_udp_server.py` that will act as
a UDP server that will listen for incoming UDP packets. It listens on port 9090
and simply prints out whatever it receives. The server assumes that every UDP
packet contains another IP packets inside of it, so the server will be looking
for packets inside of packets. Here's a good starting code for you that
implements a standard UDP server using socket programming in python

```python
#!/usr/bin/env python

from scapy.all import *
import logging

# Globals
# 0.0.0.0 means bind to all interfaces
IP_ADDR = '0.0.0.0'
PORT = 9090

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    logging.info("Start UDP server on port {}".format(PORT))

    # create a socket to host the connections
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((IP_ADDR, PORT))

    # main server loop
    while True:
        data, (ip, port) = sock.recvfrom(2048)
        logging.info("{}:{} --> {}:{}".format(ip, port, IP_ADDR, PORT))
        pkt = IP(data)
        logging.info("    Inside: {} ---> {}".format(pkt.src, pkt.dst))
```

To start the server, use
```shell
server:$ python3 tun_udp_server.py
```

## Writing the client script

On the `useru` end, create a new script called `tun_client.py` that builds upon
the `tun.py` script but does the following:
- Creates a TUN interface and brings it up
- Reads packets from the TUN interface as IP packets
- Encapsulates the IP packets inside of UDP packets
- Sends the UDP packets to the VPN server at the address `server:9090`. 

To help you achieve the above, I have provided you with a small starter code for
the VPN tunnel main loop that looks like the following:
```python
####### OTHER CODE ABOVE
####### ...
####### 

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# main TUN loop
while True:
    # Grab a packet from the TUN interface
    packet = os.read(tun, 2048)

    # send the packet to the server
    if packet:
        # TODO: Do stuff with the packet

        # Send the packet to the server
        # TODO: Replace SERVER_IP and SERVER_PORT with the correct IP address and
        # port number
        sock.sendto(packet, (SERVER_IP, SERVER_PORT))
```

## Testing

Run the `tun_udp_server.py` script on the `server` machine and the
`tun_client.py` on the `useru` machine. Then try to ping a host that is on the
10.1.3.0/24 network as follows:
```shell
useru:$ ping -c5 10.1.3.5
```
> What do you notice at the server end (you should see something, nothing
  happens is not a valid answer)? Why? Submit a screenshot and explanation of
  the output at the `server` and the `useru` machines.

### Reaching the private network

Our goal from this exercise is not to reach the 10.1.3.0/24 network, rather it
is to reach the private network that contains the `userv` and `userw` hosts
(which is the 10.1.1.0/24 network). 

First, from the `useru` machine, try
```shell
useru:$ ping -c1 userv
```
then you should still not be able to get that ping though.
> Does the UDP server see your ping packet? Why?

To resolve this issue, we need to add a route in the `useru`'s routing table
that will take traffic destined to the 10.1.1.0/24 network and send them to the
TUN interface. To do so, you can use the following command
```shell
useru:$ sudo ip route add <network> dev <interface> via <router ip>
```
Your job in this task is to figure out what the parameters `<network>`,
`<interface>`, and `<router ip>` are. After you do this, the ping should get to
the UDP server but you should expect any response. 

If your implementation is correct, then you shouldn't see the destination host
unreachable message anymore. Rather, the ping command should just hang in there
waiting for a response that never comes back until it times out. 

> Show a screenshot of the ping packet reaching the VPN server for full credit. 


# Step 3: Create the VPN server

Now is the time to set up our VPN server to receive traffic from the VPN client
and send it over to the correct interval destination on the private network.
Create a file `tun_server.py` that is based on your `tun_udp_server.py` but
modified to achieve the following:
1. Create a TUN interface and configure it correctly, this is fairly identical
   to what you did for the VPN client.
2. Get data **from the socket interface (i.e., the UDP server)** and cast it as
   an IP packet using `scapy`. 
3. Write the packet to the TUN interface for routing to the destination. 

## Testing

To test your code, first you need to configure the server as a router using
```shell
server:$ sudo sysctl -w net.ipv4.ip_forward=1
```

Now on the `userv`, set up a `tcpdump` instance to monitor traffic coming in on
the 10.1.1.0/24 interface as follows:
```shell
userv:$ sudo tcpdump -i <ethX> ip
```
Replace `<ethX>` with the name of the interface that is connected to the
10.1.1.0/24 network. 

Finally, from the `useru` terminal, try to ping `userv`, as follows
```shell
useru:$ ping -c1 userv
```
At this point, the ping packet will show up at the `userv` (so you should see an
updated packet on the `tcpdump` terminal), but the response from `userv` is not
delivered to `useru` yet because we haven't configured the tunnel in the reverse
direction. 

> Show a screenshot showing the ping packet being delivered to `userv`. 

# Step 4: Bidirectional tunneling

At this point, one direction of your tunnel is complete, i.e., we can send
packets from `useru` to `userv` via the tunnel. We can see from the previous
step that `userv` is able to receive the ping packets from `useru`, sends the
packets back, but they do not get delivered back to `useru`. This is because our
tunnel is only one-directional; we need to set up its other direction, so
returning traffic can be tunneled back from `userv` to `useru`.

To achieve that, our TUN client and server scripts need to read data from two
interfaces, the TUN interface and the socket interface. But how can we achieve
that? All of our read functions so far take a single interface as a parameter.

In the operating system, all interfaces are represented by file descriptors, so
we need to monitor those file descriptors for changes and obtain the incoming
data. One way to do this is to keep polling both interfaces sequentially, and
see whether any of them has any data. This is very inefficient and wasteful on
resources. Another way is to block (i.e., sleep) until data arrives on
**either** interface. This way we do not waste CPU time and the CPU can go
execute other things while we're waiting for packets to arrive. 

Blocking on a single interface is easy, you've been doing it all along. However,
Linux provides us with a way to block on more than interface using the `select`
system call. To use `select`, we need to put all the file descriptors that we
want to monitor into a set and pass that set as an argument to `select`. The
system call will then unblock when data is available on at least one of the
interfaces in the set. Once the server unblocks, it can iterate over the file
descriptors and find which one of them received the data. 

Below is a sample code that shows you how you can use the `select` system call
from python to block on multiple interfaces. In the code below, we assume that
you have already created a TUN interface called `tun` and a socket interface
called `sock`. 

```python
# TODO: Add code to create sock and tun

while True:
    # this will block until at least one interface is ready
    ready, _, _ = select.select([sock, tun], [], [])

    # ready contains the interfaces that have data in them
    for fd in read:
        if fd is sock:
            data, (ip, port) = sock.recvfrom(2048)
            pkt = IP(data)
            logging.info("From socket <==: {} --> {}".format(pkt.src, pkt.dst))
            # TODO: Add code here to process the data from the socket
        
        if fd is tun:
            packet = os.read(tun, 2048)
            pkt = IP(packet)
            logging.info("From tun ==>: {} --> {}".format(pkt.src, pkt.dst))
            # TODO: Add code here to process the data from the tunnel iface
```

**NOTE that you need to update both your client AND server code to listen on
both interfaces so that you can enable two-directional communication**. 

**Hint: You might need to make routing changes at `userv` and `userw`.**

### Testing

Once you update your code, you should be to reach `userv` and `userw` from
`useru` even though they are technically not on the same subnet. To show
successful completion of this task, you should show a screenshot showing the
following:
- `tun_client.py` running on `useru`
- `tun_server.py` running on `server`
- A successful ping from `useru` to `userv` and vice versa. 

# Submission

Submit your report and all your code to gradescope as usual. 

# Acknowledgments

This lab is based on the SEED labs by Professor Wenliang (Kevin) Du and modified
by Mohammad Noureddine. This work is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](https://creativecommons.org/licenses/by-nc-sa/4.0/). 

