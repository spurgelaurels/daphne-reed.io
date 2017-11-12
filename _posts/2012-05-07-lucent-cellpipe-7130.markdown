---
author: dave
comments: true
date: 2012-05-07 13:02:13+00:00
layout: post
slug: lucent-cellpipe-7130
title: Lucent CellPipe 7130
wordpress_id: 807
categories:
- Computers
- Hacks
---

[![](http://www.davereed.ca/wp-content/uploads/2012/04/100125_CellPipeModem_2.jpg)](http://www.davereed.ca/wp-content/uploads/2012/04/100125_CellPipeModem_2.jpg)

With the price and data gouging we've come to expect from typical Canadian Internet Service Providers, it's quite refreshing to see Tek Savvy on the scene with competitive bandwidth rates and caps.  I switched over to Tek Savvy last Autumn, opting for their 25/7MBPS with 300GB cap profile. My first comment is that this profile is blazing fast, and I have never, ever gone over my cap; I don't expect to.  

My second comment is that the modem they provide is a piece of fuck.  
Unfortunately, due to their arrangement with Bell, they have to provide the same modem used by Bell Fibe customers, the Lucent CellPipe 7130.  This modem has a few issues, most notably: 
	
* Random reboots

	
* WiFi dropping

	
* Clumsy and buggy UI

	
* Large physical desktop footprint

	
* Switch, WiFi, router, modem all-in-one (some may consider a positive)

	
* Low-end consumer feature set

	
* No custom firmwares available

	
* Insecure-by-default management utility


This list is cringe-worthy for most techies.  Fortunately, there is a workaround.  For this, you will need your Tek Savvy connection PPPoE credentials, your Cellpipe modem, a router with PPPoE client.

First you will want to reset your Cellpipe to factory defaults.  You can do this by logging in to the management UI, and finding this feature on the left side-bar.  Once this is done, you will lose your connection, and the modem will change its IP address to 192.168.0.1.  You will not need to connect to the modem after it has been reset.  Instead, you will want to set the external interface of your router to PPPoE, along with your PPPoE credentials.  For most Linksys/DLink routers, this should be relatively straight forward.  

I use a Cisco ASA 5505, running the following config:

`interface Vlan2
 nameif outside
 security-level 0
 pppoe client vpdn group pppoe
 ip address pppoe setroute

vpdn group pppoe request dialout pppoe
vpdn group pppoe localname davereed@teksavvy.com
vpdn group pppoe ppp authentication pap
vpdn username @teksavvy.com password *********
dhcpd auto_config outside`

Be aware that if you have to call Tek Savvy for support, they will ask you to be running the PPPoE client on the modem, so you will have to log in to the modem, reset your PPPoE credentials, and lose the router.  Be sure that you reset the modem again when you're done troubleshooting, or else you'll end up with two PPPoE clients fighting for the same connection.  
