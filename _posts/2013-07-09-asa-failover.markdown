---
comments: true
date: 2013-07-09 02:42:10+00:00
layout: post
slug: asa-failover
title: ASA Failover
tags:
- firewall
- network
---

Setting up a failover between Cisco ASA units proved to be far simpler than I anticipated, and a very useful technique if you value the availability and potential load-balancing it has to offer.   In the example below, I will demonstrate an Active/Standby configuration, which does not allow for load-balanced operation.  For load balancing, you will need to run in Active/Active configuration and you will need to configure them in context mode.

[![Topology](/assets/img/oldblog/asa-210x300.png)](/assets/img/oldblog/asa.png) 


Our topology will include 2 ASA 5520 units, ASA4 and ASA5.  After you've configured your basic ASA operation, we'll want to configure our interfaces. The difference between a failover setup and a normal setup is the standby address.  The IP used for a standby address will end up being the address of the secondary unit while it's in standby mode.  If the secondary unit goes active, it will then assume the first address.  So, the configuration is set on ASA4 is as follows:

    
    interface Ethernet0/0
     nameif OUTSIDE
     security-level 0
     ip address 10.0.0.1 255.255.255.0 standby 10.0.0.2
    
    interface Ethernet0/1
     nameif INSIDE
     security-level 100
     ip address 172.16.0.1 255.255.255.0 standby 172.16.0.2




Once set, enable the interfaces and test that they're operational.  Next, we're going to configure the failover itself, and then configure interface ethernet0/3 as our dedicated failover link.

First, shut down ethernet0/3 on ASA4.

    
    conf t
    int e0/3
    shut




Next, configure ASA4 for the following failover directives:

    
    failover
    failover lan unit primary
    failover lan interface FAIL Ethernet0/3
    failover interface ip FAIL 192.168.1.1 255.255.255.0 standby 192.168.1.2


This will set ASA4 as the primary unit, creating an interface named FAIL and attaching it to physical interface Ethernet0/3 on 192.168.1.1.  We can leave ethernet0/3 shutdown for now.

Next, we want to configure ASA5 with the same interface configuration, only in reverse:

    
    interface Ethernet0/0
     nameif OUTSIDE
     security-level 0
     ip address 10.0.0.2 255.255.255.0 standby 10.0.0.1
    
    interface Ethernet0/1
     nameif INSIDE
     security-level 100
     ip address 172.16.0.2 255.255.255.0 standby 172.16.0.1




Then we configure the secondary failover:

    
    failover
    failover lan unit secondary
    failover lan interface FAIL Ethernet0/3
    failover interface ip FAIL 192.168.1.1 255.255.255.0 standby 192.168.1.2




Then finally, we can enable e0/3 on both ASA4 and ASA5 with

    
    conf t 
    int e0/3
    no shut




At this point, you should see some console logging data showing synchronization between the ASA units, as they negotiate configuration data and enable the sync link on e0/3.  Once complete, you will find the following output from running a 'show failover' on each host:

    
    <strong>ASA4</strong># show failover
    Failover On
    Failover unit <strong>Primary</strong>
    Failover LAN Interface: FAIL Ethernet0/3 (up)
    Unit Poll frequency 1 seconds, holdtime 15 seconds
    Interface Poll frequency 5 seconds, holdtime 25 seconds
    Interface Policy 1
    Monitored Interfaces 2 of 250 maximum
    Version: Ours 8.0(2), Mate 8.0(2)
    Last Failover at: 00:00:06 UTC Nov 30 1999
            This host: Primary - Active
                    Active time: 3135 (sec)
                    slot 0: empty
                      Interface <strong>OUTSIDE (10.0.0.1)</strong>: Normal
                      Interface <strong>INSIDE (172.16.0.1)</strong>: Normal
                    slot 1: empty
            Other host: Secondary - Standby Ready
                    Active time: 0 (sec)
                    slot 0: empty
                      Interface <strong>OUTSIDE (10.0.0.2)</strong>: Normal
                      Interface <strong>INSIDE (172.16.0.2)</strong>: Normal
                    slot 1: empty




    
    <strong>ASA4</strong># show failover
    Failover On
    Failover unit <strong>Secondary</strong>
    Failover LAN Interface: FAIL Ethernet0/3 (up)
    Unit Poll frequency 1 seconds, holdtime 15 seconds
    Interface Poll frequency 5 seconds, holdtime 25 seconds
    Interface Policy 1
    Monitored Interfaces 2 of 250 maximum
    Version: Ours 8.0(2), Mate 8.0(2)
    Last Failover at: 00:00:01 UTC Nov 30 1999
            This host: Secondary - Standby Ready
                    Active time: 0 (sec)
                    slot 0: empty
                      Interface<strong> OUTSIDE (10.0.0.2)</strong>: Normal
                      Interface <strong>INSIDE (172.16.0.2)</strong>: Normal
                    slot 1: empty
            Other host: Primary - Active
                    Active time: 3138 (sec)
                    slot 0: empty
                      Interface <strong>OUTSIDE (10.0.0.1)</strong>: Normal
                      Interface <strong>INSIDE (172.16.0.1)</strong>: Normal
                    slot 1: empty




I've emboldened a few key points in the failover output.



	
  1. You'll notice that the hostname is the same on both ASA units.  This is because they're essentially a single logical entity now, with one unit acting as the primary, and syncing data to the secondary.

	
  2. You'll also notice that the primary host has the x.x.x.1 addresses for its interfaces, while the secondary has the x.x.x.2 addresses.  Watch what happens next...


To test our failover, log into ASA4, and type "no failover active", which will tell the active failover host to drop to standby mode.  **DO NOT** type "no failover", as this will turn off failover altogether, and this would be bad on a production box.   You'll see in the output of "show failover" that the IP addresses of the INSIDE and OUTSIDE interfaces have swapped between the Primary and Secondary hosts.

**ASA4**

    
    This host: Primary - Standby Ready
                    Active time: 3552 (sec)
                    slot 0: empty
                      Interface OUTSIDE (10.0.0.2): Normal (Waiting)
                      Interface INSIDE (172.16.0.2): Normal (Waiting)
                    slot 1: empty
            Other host: Secondary - Active
                    Active time: 25 (sec)
                    slot 0: empty
                      Interface OUTSIDE (10.0.0.1): Normal (Waiting)
                      Interface INSIDE (172.16.0.1): Normal (Waiting)
                    slot 1: empty


**ASA5**

    
    This host: Primary - Standby Ready
                    Active time: 3552 (sec)
                    slot 0: empty
                      Interface OUTSIDE (10.0.0.2): Normal (Waiting)
                      Interface INSIDE (172.16.0.2): Normal (Waiting)
                    slot 1: empty
            Other host: Secondary - Active
                    Active time: 25 (sec)
                    slot 0: empty
                      Interface OUTSIDE (10.0.0.1): Normal (Waiting)
                      Interface INSIDE (172.16.0.1): Normal (Waiting)
                    slot 1: empty




To summarize, we have created a configuration with two modes, active and standby.  Then we've created a link between our two devices, over which they synchronize their configuration and communicate their states.  In the event that the Primary device fails, the Secondary device already has both a working replicated configuration, but also a copy of open connection states in memory.  This allows for a clean cutover with no packet loss.


