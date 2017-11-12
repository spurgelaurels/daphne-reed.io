---
author: dave
comments: true
date: 2013-07-09 02:41:30+00:00
layout: post
slug: dhcpd-fail-arch
title: DHCPD Fail - Arch
wordpress_id: 855
categories:
- Computers
- Hacks
- Linux
- Networking
tags:
- arch
- dhcp
- linux
---

After deciding it was time to return to Linux on my workstation at home, and after an irritating battle with Ubuntu that I will detail in another post, I've ended up with Arch Linux installed to my platters again.

I didn't expect Arch Linux to install itself to my system, however, I also didn't expect such a treat in configuring something as simple as DHCP. In short, it seemed that the dhcpcd service was timing out while waiting for another dependent service to start.  This resulted in a completely booted system without an address from DHCP.   Checking on the service status revealed the following error message:

    
    <code>sudo systemctl status dhcpcd@enp6s50.service
    dhcpcd@enp6s50.service - dhcpcd on enp6s50
    	  Loaded: loaded (/usr/lib/systemd/system/dhcpcd@.service; enabled)
    	  Active: failed (Result: exit-code) since Wed, 2013-02-28 22:03:01 EST; 3min 32s ago
    	 Process: 368 ExecStart=/sbin/dhcpcd -A -q -w %I (code=exited, status=1/FAILURE)
    	  CGroup: name=systemd:/system/dhcpcd@.service/enp6s50
    </code>


Recently, it seems that the Arch community has migrated to [systemd](http://en.wikipedia.org/wiki/Systemd) as their init handling daemon.  Services that are controlled by systemd are configured using a service file, for example, the dhcpcd.service file

    
    /usr/lib/systemd/system/dhcpcd@.service


In this file, dependency chains are listed, as well as configuration options for the service daemons. It seems that an upstream service is taking too long to load, and dhcpcd doesn't have a chance to grab an IP  before the conch is taken away.  We have a few options to fix this.  First would be to rechain the entire dependency tree surrounding the dhcpcd service.  This would take a while, and would possibly be completely wiped out the next time you upgrade your system.  Not my favourite practice.  Another would be to make sure that dhcpcd has enough time to grab an IP.

Open up /usr/lib/systemd/system/dhcpcd@.service in your favourite editor.  Under the [ExecStart] directive, we will want to add a timeout value (_-t 120_) high enough to allow enough wiggle room to let dhcpcd grab an IP.  120 seconds is way more than enough time.   Keep in mind that this won't force dhcpcd to /wait/ 120 seconds; it will exit as soon as it gets an IP address.

    
    <code>ExecStart=/sbin/dhcpcd -A -q -w %I <strong>-t 120</strong></code>


I've seen many other methods that attempted to resolve this issue, such as explicitly loading your network card module, scripting a manual start of dhcpcd near the end of the boot loading, or using dhclient instead.  I found the above method to work like a charm, and if an update wipes it out, it's a simple fix to add it back in there again.

Now I patiently await the upstream fix.
