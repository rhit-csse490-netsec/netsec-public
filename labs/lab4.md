---
layout: post
title: Lab 4
readtime: true
date: Sun May  1 05:44:57 2022 
---

# Introduction

In this lab, we will finally make the transition from the Network Layer to the
Transport Layer and focus on the Transport Control Protocol (TCP). We will start
off with TCP session hijacking attacks, and then use such an attack to start a
reverse shell on the victim's machine. 

In the second part of this lab, we will recreate parts of the Kevin Mitnick
attack that we described in class. This will be a bit more involved that a
normal TCP session hijacking attack since it will involve forging a connection
that we will then hijack to run malicious commands and obtain access a victim
server. 


# The network topology

In this lab, we will be using the following network topology. It is composed of
three machines:
1. A victim machine that is our target in this lab.
2. A client machine that is trusted by the victim.
3. An attacker machine that sits in between the client and the victim. 

![network topology]({{ site.baseurl }}/figs/lab4topo.png)

We assume that you only have control over the attacker machine, yet with the
following restriction: __You are only allowed to sniff packets and forge packets
on the attacker machine__. In other words, you are not allowed to violate the
integrity of the packets that are on the way from the client to the victim and
vice versa.

## Creating a new experiment

For this lab, we will create a new experiment, this time call it `<userid>-lab4`
and under the `Your NS file` entry, enter the following under the `On Server`
path:
```
/proj/csse490/labs/lab4.tcl
```

Hit `Submit` and then swap your experiment in, it should take about 10 minutes
for this one to finish the swap in. If it takes you longer than that, please
reach to your instructor to take a look. 

# TCP Session Hijacking

## Objective

The objective of the TCP session hijacking attack is to hijack an existing TCP
session between two victims (the client and the victim in our case) by injecting
malicious contents into this session. If this connection happen to be a `telnet`
session, an attacker can inject malicious commands into this session, causing
the `telnet` server to execute these command inadvertently. 

Your goal in this task is to hijack an existing `telnet` session so that you can
cause the server (called victim in our case) to execute a malicious command from
you. For simplicity, we assume that you'd like to create a file under `/tmp`
called `pwnd`. In other words, your goal is to run the following command on the
`telnet` server
```shell
touch /tmp/pwnd
```

## Important Assumption 

We assume that the attacker machine can sniff all packet between the client and
the server, but cannot violate the integrity of those packets. You must forge
packets and hijack the TCP session rather than modifying the already existing
packets from the client to the victim. 

## The Attack

The attacker machine is configured to act as a router between the client the
victim. You will start by setting up a sniffing program on the attacker machine
so that the attacker can sniff all the packets going from the client to the
victim (which is the `telnet` server).

To get started, on the victim machine, run the following commands:
```shell
sudo apt install telnetd
sudo useradd -m loki
sudo passwd loki
```
and choose a password for the `loki` user.    

Verify that the client can connect to the victim machine via `telnet` using
```shell
telnet victim
```
and login using the username `loki` and the password you just set in the
previous step. Once the connect is established, leave the connection running and
switch to the attacker machine. 

### On the Attacker Machine

I have provided you with a starter code that allows you to pass the interfaces
to sniff and send on as command line parameters. You can find the starter code
below:
```python
#!/usr/bin/python3
from scapy.all import *
import logging
import argparse

# The interface between the client and the attacker
client_iface = 'UNKNOWN'
# The interface between the attacker and the victim
victim_iface = 'UNKNOWN'

def hijack(pkt):
    """
    Sniff an already established TCP session between the client and the victim
    and hijack that session to run malicious commands on the victim server.

    :param: pkt The packet we are sniffing
    """
    # TODO: Add your sniffing and spoofing code here


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    parser = argparse.ArgumentParser()

    # add the client iface argument
    parser.add_argument("--client-iface", type=str, required=True,
                        help='The interface between the client and the attacker machine')
    # add the victim iface argument
    parser.add_argument("--victim-iface", type=str, required=True,
                        help='The inteface between the victim and the attacker machine')

    # grab the arguments
    args = parser.parse_args()
    client_iface = args.client_iface
    victim_iface = args.victim_iface
    logging.info("Running TCP Session Hijacking Attack from {} to {}".format(
        client_iface, victim_iface))

    # set up the filter to catch the packets from the victim to the client 
    # TODO: Your code starts here
    client_filter = ''
    sniff(iface='', filter=client_filter, prn=hijack)
```

Here's the help message from trying to run this script:
```shell
$ python3 tcp_hijack.py --help
usage: tcp_session_hijack.py [-h] --client-iface CLIENT_IFACE --victim-iface VICTIM_IFACE

optional arguments:
  -h, --help            show this help message and exit
  --client-iface CLIENT_IFACE
                        The interface between the client and the attacker machine
  --victim-iface VICTIM_IFACE
                        The inteface between the victim and the attacker machine
```

Modify the code above to hijack an already established `telnet` session between
the client and the victim machines. Your code should run the following command
on the victim server
```shell
touch /tmp/pwnd
```

Once you run the attack, check that the file has been created on the victim
server and make sure that its timestamp corresponds to the time that you have
ran the attack.

> _Hint_: You will need to compute the new sequence number and the new ACK
number for the packet that you forge. 

> _Hint_: You will need to calculate the length of the TCP packet. You will need
to use a combination of fields from the IP header and the TCP header.
Specifically, you will find the fields: `ip.len`, `ip.ihl`, and `tcp.dataofs`.

##  Submission

In your lab report, include screenshots that show the successful creation of the
file `/tmp/pwnd` on the victim server using the TCP hijacking technique from the
attacker's machine. 

# Creating a Reverse Shell

In class, we talked in depth about creating a reverse shell on the attacker
machine that is logged into the victim server. Modify the attack above to launch
a reverse shell on the victim server that is accessible from the attacker
machine. 

_Hint_: You only need to change one line of code and run a single command to do
so. 

## Submission

In addition to your code, include in your report screenshots that show the
successful creation of the reverse shell that is authenticated to run on the
victim server from the attacker's machine. 


# The Mitnick Attack

- Coming in Lab 4b.


# Acknowledgments

This lab is based on the SEED labs by Professor Wenliang (Kevin) Du and modified
by Mohammad Noureddine. This work is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](https://creativecommons.org/licenses/by-nc-sa/4.0/). 


