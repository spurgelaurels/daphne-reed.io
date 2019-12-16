---
comments: true
date: 2011-08-25 19:06:21+00:00
layout: post
slug: setting-an-ip-on-an-apc-ups
title: Setting an IP on an APC UPS
categories:
- words
tags:
- computers
- datacentre
---

It is now 14:28 in the afternoon on a particularly busy day. Our power went off last night and our UPS (APC 1400XL with AP9617 management cards) all lost battery power before the building came back on. Today, I tasked myself with configuring our UPS to properly alert me, and perform a graceful shutdown on our servers.



# **Fails.**



I plugged the Network Management card into a network switch, and watched on the DHCP server for a request from an APC MAC address (00:C0:B7:xx:xx:xx by the way). Nothing showed up at first. I thought this would be no problem if I logged in over serial, so I grabbed an RS-232 cable and plugged it into the management port on the back of the UPS.

**DO NOT EVER PLUG A NON-APC PROVIDED SERIAL CABLE INTO THE BACK OF AN APC UPS. THE UPS WILL SHUT DOWN WITHOUT ANY WARNING WHATSOEVER.**

[![](/assets/img/oldblog/it-rage.jpg)](/assets/img/oldblog/it-rage.jpg)

So our UPS went down, taking out one of our Avaya IP Office modules (which was another problem to deal in its own right). What a great feature. Thanks APC.

Once the UPS was running again, I tried in vain to reset the network card, try other cables, different ports on the switch. Finally and automagically,  I could see the DHCP offer showing up in my logs. It would sit there for about 45 seconds before disappearing to try again. This is when I found out about Option 43.



# **Option 43**


Option 43 is a DHCP option for encapsulating vendor ID information into a DHCP response. For more information, read up on RFC2132, under section 8.4. In the case of an APC device, the hex code for this option would be 010431415043 (I know it looks like decimal, but trust me; it's hex). This may work for you. Or in my case, it may not.  APC uses this option as an authentication measure.



# **PING!**


If none of the aforementioned solutions solved this problem for you, then you might have to resort to using ping.

That's right; I said PING.

First, select an IP that's unused on your network. Then create a local ARP entry with the MAC address of your device linked to that IP. Then, simply ping that IP with a packet size of 113 bytes.

`
[daphne@sixtee:~#] sudo arp -s 192.168.x.x 00:C0:B7:XX:XX:XX
[daphne@sixtee:~#] ping 192.168.x.x -s 113
`

Seriously folks, I could not make this up.
