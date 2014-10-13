-----------------------------------------------------------------------
      			MoSShE  v14.9.19
 	   2003-2014 by Volker Tanger <volker.tanger@wyae.de>
-----------------------------------------------------------------------

MoSShE (MOnitoring in Simple SHell Environment) is a simple,
lightweight (both in size and system requirements) server monitoring
package designed for secure and in-depth monitoring of single or
multiple typical/critical internet systems. 

As most of the servers/services I want to monitor are remote systems,
traditional NMS (relying on close-looped and/or unencrypted sessions) are
either big, complicated to install for safe remote monitoring, ressource
intense (when doing remote checks), lack a status history or a combination
thereof.

Thus I wrote this small, easily configured system. It originally was
intended for monitoring of single a handful of typical internet
systems. With the more recent system and grouping features monitoring
of serious numbers of systems is easily possible.

MoSShE supports email alerts and SLA monitoring out of the box - and
whatever you can script. 

The system is programmed in plain (Bourne) SH, and to be compatible
with BASH and Busybox so it can easily be deployed on embedded systems.

Monitoring is designed to be distributed over multiple systems,
usually running locally. As no parameters are accepted from outside,
checks cannot be tampered or misused from outside. 

The system is designed to allow decentralized checks and evaluation as
well as classical agent-based checks with centralized data
accumulation. 

Agent data is transferred via HTTP (pull-mode) or FTP, SSH, SCP, ...
in push-mode, so available web servers can be co-used for agent data
transfer. Additionally each agent creates simple (static) HTML pages
with full and condensed status reports on each system, allowing simple
local checks.


Requirements for MoSSHe:
	* Unix Shell (BASH, soon Bourne-SH, Busybox)
	* standard Unix text tools (fgrep, cut, head, mail, time, date, ...)
	* "netcat" networking tool
	
for single checks only if performed:
	* "pstree" for tree view of process list
	* "dig" for DNS check
	* "free" memory display for memory check
	* "lpq" BSD(compatible) printing for printing check
	* "lynx" web browser for HTTP check or server/client architectures
	* "curl" or "wget" web downloader for server/client architectures
	* "mailq" if running the mail queue check
	* "mbmon" or "lm-sensors" motherboard check for temp/fan check
	* "smbclient" for samba check
	* [future] "snmp" networking tools (especiall "snmpget") for SNMP check
	* /proc/mdstat for Linux MD0 SoftRAID checks
	* "smartctl" (smartmontools) for HD health checks
	* "tw_cli" from 3ware (now: LSI) for Raid3ware checks
	* "mysqladm" for MySQL checks
	
for web interface:
	* webserver - which can server static files (= nearly any)
	* the "dygraphs" JavaScript library. Included in the archive
	  within the /plotdata/ directory

for PUSH configuration: 
	* ftp server with incoming directory 
	* SCP server with incoming directory 
	* fileserver (SMB) with incoming directory


Hardware requirements:
	A difficult question. As the checks are run and evaluated
	locally on each system it is nearly impossible to "overload"
	the server as is with other monitoring systems. 

	The system is a shell script, so no big size components here,
	either. For a webserver (nearly) any HTTPD is fine. No
	database needed - everything is plain text. 



KNOWN ISSUES:
	- currently (13.5.14 and newer) only works in BASH, but not in 
	  BOURNE shell / Busybox, needs compatibility cleanup


Updates will be available at   http://www.wyae.de/software/mosshe/
Please check there for updates prior to submitting patches!

There is a user/developer mailing list available. To subscribe send a
mail with "subscribe mosshe" as subject to minimalist@wyae.de

For bug reports and suggestions or if you just want to talk to me
please contact me at volker.tanger@wyae.de


-----------------------------------------------------------------------
Monitoring server Setup
-----------------------------------------------------------------------

Get and unzip the archive - usually in /usr/local/lib/mosshe.

copy the whole plotdata/ directory to WWWDIR (see below)


Edit the MOSSHE file and set the environment

	MYNAME	HOSTname of this server
	
	MYDOM	DOMAINname of this server
	
	MYGROUP	GROUPname of this server
	
	WWWDIR	where the HTML reports and status file are saved to
	
	DATADIR	location of MOSSHE scripts (/usr/local/lib/mosshe)

	TEMPDIR	for temporary files (default: /tmp)


In the MOSSHE shell script file you now can configure the checks to be
run - usually you can set warning and alert trigger levels


#=========================================================
# Local Shows
#=========================================================

ServerInfo 		prints the output of the command into an
			information section onto the server-specific
			HTML page (i.e. the srv_MYNAME page) which is
			directly linked from the overviews.

#=========================================================
# Local Checks
#=========================================================

DaysUpCheck		notify of recent reboot

DebianUpdatesAvailable	status whether updates are available (debian) 
			needs hourly cron job - included in the TAR
UbuntuUpdatesAvailable	number of package updates available (ubuntu)
UbuntuReleaseUpgrade	is a release upgrade available? (ubuntu)
UbuntuRebootRequired	is a reboot required according to system? (ubuntu)

HDCheck 		minimum free space on a filesystem in MB
HDCheckGB 		minimum free space on a filesystem in GB
HDparmState 		no alert, only records active/standby state of discs

LoadCheck		maximum load of a system
LoadHektoCheck		maximum load of a system (= uptime * 100)
MemCheck		minimum free RAM

ProcessCheck		maximum processes running
ZombieCheck		maximum zombie processes
ShellCheck		maximum shells for root / other users

NetworkErrorsCheck	percentage of errors on interface
NetworkTrafficCheck	maximum kbit/s network throughput
NetworkBandwidth	maximum GByte/month bandwidth usage 
			(momentary use projected to month values)

FileCheck		check file existing (check PIDs or named pipes)
ProcCheck		check for process existing

FileTooOld 		check whether file was modified not too long ago
			(e.g. for checking whether a backup has run)
FileTooBig		check for files growing too much - esp. useful
			for logfiles (no logrotate/gallopping problems) 
FileLines		check whether a file exceeded a number of lines

MailqCheck		maximum number of mails in queue
PrintCheck		maximum number of print jobs in queue

MBMonCheck		Motherboard-checks: maximum temperature, fan speeds (mbmon)
HardwareSensor		Hardware-Check: sensor warn alert
HardwareSensorBetween	Hardware-Check: sensor min max

SmartMonHealth		health status of hard discs
Raid3ware		OK status of 3ware RAID controllers
RaidCheck		checks md0 RAID  (WARN=syncing, ALERT=fail)

LogEntryCheck		maximum number of message matches in logfiles
			(used to check for bruteforcing, see examples in MOSSHE)

CheckFileChanges	compare current file to known-good copy
CheckConfigChanges	compare config (command) to known-good copy


#=========================================================
# Network Checks
#=========================================================

PingPartner		maximum ping loss and avg. roundtrip
PingTime 		max roundtrip time regardless loss
PingLoss		max % Loss regardless roundtrip

TCPing			generic TCP connect ping

SAMBA			checks for Microsoft file server (SMB/CIFS/Samba)

HTTPheader		http server return code
HTTPheadermatch		checks for named return code (usually 302-Moved)
HTTPcontentmatch	 check for web site content

FTPcheck		checks for FTP service

SSHcheck		checks for SSH service

POP3check		checks for POP3 service
IMAPcheck		checks for IMAP service
SMTPcheck		checks for SMTP mail service

RBLcheckIP		checks whether an IP address is listed on RBL
RBLcheckFQDN		checks whether a named system is listed on RBL

DNSquery		checks whether a DNS response is given
DNSmatch		checks a DNS response against expected value


#=========================================================
# MySQL Checks
#=========================================================

MySQLThreads		number of Threads running
MySQLQueries		number of Queries/second


#=========================================================
# VIRTUALization Checks
#=========================================================

CheckVserverDown	verifies if Linux VSERVER is shut down
CheckVserverUp		verifies if Linux VSERVER is up and running
VserverLoad		measures individual Linux VSERVER uptime * 100

VZbeancounter		checks usage (percent) of OpenVZ/Virtuzzo beancounters
 

#=========================================================
# Import agent data *from* other servers
#=========================================================

Typical setup is to monitor multiple scattered servers from behind
(DSL) a router/firewall.

With this function you can establish one or multiple central servers
by including the data from other MoSShE agents into the local one.
Just be careful not to do circular inclusions or your logfile size
might explode!

ImportAgent	URL to the index.csv file, which can include
		username and password as in
		http://user:passwd@remote.server.test/mosshe/index.csv

ImportAgentCurl - see above, but using curl instead of lynx

ImportAgentWget - see above, but using wget instead of lynx

ImportServerInfo  import the server info txt file for a server



#=========================================================
# Centralize data *to* other servers
#=========================================================

Typical setup is to monitor multiple customer servers without opening
a TCP listener on them to reduce possible attack surface on those
systems. Instead have them send the information files to your own,
dedicated incoming monitoring system using battle-proven file transfer
system servers and methods:  ftp-incoming, ssh/scp.

Or to monitor systems within a LAN without having to run additional
network services (except maybe the network file system mounter).

You can combine centralizing functions sequentially. You can set up a
"internet monitoring" server in a DMZ, receiving monitoring data from
customers servers via FTP and SCP - and pulling other infos off other
hosting systems via ImportAgent. Using separate (password-protected)
customer incoming monitoring directories, you even can offer split
monitoring: you pull all your customers from the incoming server - and
each customer can pull the already accumulated monitoring for their
systems from that machine, too.

You can mix and combine ad lib - just make damn sure not to create
loops, otherwise your logs will explode.

You need to setup a secured incoming server - I suggest ftp (incoming
directory mechanism) or SCP with password-free certificates  (but make
sure to disable shell access). On LANs you maybe alreday have a common 
NAS (network drive) mounted you can directly use a dedicated
monitoring drop-off directory. 

Examples of drop-off script snippets to include into the MOSSHE script: 

### via file system mount
cp $WWDIR/index.csv /mnt/nfsmount/mosshe/zeus.example.com.csv		

### via password-free ssh key
scp $WWDIR/index.csv mosshe@central.example.com:zeus.example.com.csv	

### via ftp-upload
ftp-upload --host central.example.com --user USER --password PASSWD \
	--passive --no-ls --dir /incoming \
	--as zeus.example.com.csv $WWDIR/index.csv



On the importing/monitoring server the ReapPassiveChecks script checks
for the existence of the check file and its age. If the file is too
old (given in minutes), something with the (passively) monitored
system is probably wrong and an alert is raised. 

# MYGROUP="Externals"
#### reap from       servername,   max.age , file location
# ReapPassiveChecks  zeus.example.com  10  /home/ftp/zeus.example.com.csv 
# ReapPassiveChecks  hera.example.com  10  /home/ssh/hera.example.com.csv




#=========================================================
# Alerting, Logging
#=========================================================


LogTo			write full log to given filename
LogToDaily		as above, but with date appended 
LogToWeekly		as above, but with calendar week appended
LogToMonthly		as above, but with month appended 

SyslogOnChange 		log status changes to syslog 

AlertMailAlways		send alert whenever a service IS down
AlertMailOnChange	send alert mail only if something changed
			(whenever a service GOES up or down)
AlertMailOnChangeFor	as above, but with pattern matching e.g.
			server or group name 
			e.g. for alerting different admins  

SLA_Eval		builds log extract for downtime documentation 

CreateDataFiles		create data files with N maximum data sets 
			for each host and check (see $WWWDIR/datalog/)

PlotDataFiles		create data files with N maximum data sets
			(no longer uses GNUplot)

PlotAvgDataFiles	create data files with values averaged over X 
			points with N maximum data sets
			ONLY RUN AFTER PlotDataFiles
			(no longer uses GNUplot)


-----------------------------------------------------------------------
Usage
-----------------------------------------------------------------------

Adapt the "mosshe" script. 

Place the CRON.D_MOSSHE file into /etc/cron.d 
or adapt it accordingly so mosshe is called periodically.

Via the web interface you can view the overall status - full and
abbreviated status. But you cannot modify anything - which makes it
quite safe for even non-admin multiuser use...  
;-)



Quick setup:
------------
* make sure you have NMAP installed
* change to the TOOLS directory.
* run  ./create_mosshe.sh MYNETWORKFILE ipaddress/mask
* adapt MYNETWORKFILE (especially setting the right mail addresses and 
  paths!) and rename it to ../mosshe
* copy CRON.D_MOSSHE to /etc/cron.d/mosshe and reload CRON

For example running
	./create_mosshe.sh ../mosshe 192.168.0.0/16
will scan your local network (in this example: 192.168.0.0/16) and 
create a basic monitoring from the services found.


-----------------------------------------------------------------------
Known/common Problems and Maintenance
-----------------------------------------------------------------------

During the first run (usually including every reboot of the system)
MoSShE will complain on nonexisting previous files it tries to compare 
its status and values to. This is normal and expected. 

Only if you consistently see errors popping up in the CRON logs/mails
that do not clearly relate to actual system errors (e.g. network
outages) there something needs fixing.



-----------------------------------------------------------------------
Customizing Checks & Writing your own
-----------------------------------------------------------------------

Writing your own:

A check must terminate within a given (short) timeframe regardless
circumstances - so make sure there are timeouts builtin or configured.
If not, your complete MoSSHe might hang when this check stops.

Scripts (better: shell functions) must write a status line to
	$TEMPDIR/tmp.$$.collected.tmp

A check *must* give back the results in ONE LINE PER STATUS ONLY in
the format: 
date;time;groupname;systemname;status;numeric;long


DATE	in ISO format: yyyy-mm-dd   
	with yyyy = 4digit year, mm=2digit month, dd=2digit day
	
TIME	HH:MM:SS - 24hour time, all 2digit
	this is the time local to MoSSHe server for all PING and service
	checks, but local time of the server checked when using imported
	checks

GROUPNAME
	Domain name or some group name for the system as configured in mosshe

SYSTEMNAME
	Host name or IP address of the system as configured in mosshe

CHECK	(short) name of the check. 

STATUS	any status of: OK, INFO, WARN, ALERT, UNDEF

NUMERIC	the numeric value of the test, e.g. LOAD number, free megabytes, etc.
	It must be a valid FLOAT or INT number to be displayed nicely.

LONG	A longer text with details to the status. Should be short enough to
	fit into one line of the web display for nicer display, though.


Here an example of the output of a number of checks - the first 6 checks
after PING are all from a single LOCALCHECK script, btw.

	2004-07-23;23:55:32;LanSrv;kali;ping;OK;1;host up
	2004-07-23;23:55:32;LanSrv;kali;/dev/hda1;OK;4054;Disk free
	2004-07-23;23:55:32;LanSrv;kali;/dev/hda2;OK;1395;Disk free
	2004-07-23;23:55:32;LanSrv;kali;/dev/hdb3;OK;2817;Disk free
	2004-07-23;23:55:32;LanSrv;kali;load;OK;0.80;Load: 0.80
	2004-07-23;23:55:32;LanSrv;kali;processes;OK;76;Total processes: 76
	2004-07-23;23:55:32;LanSrv;kali;zombies;OK;0;Zombie processes: 0 = ok
	2004-07-23;23:55:34;LanSrv;hermes;ping;OK;1;host up


Please keep in mind that MoSSHe is designed to be lean, small, efficient.
Thus having to install a JSP/EJB server only to install one singular check
usually is not considered overly adequate. 

Small, simple, secure - that's the way we should go.


If you have a nice (free) check that could be of use to other people, please
send it to me so I can include it into the distribution.


-----------------------------------------------------------------------
Shortcut: Distributable under  GPL
-----------------------------------------------------------------------
Copyright (C) 2003- Volker Tanger

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
USA. or on their website http://www.gnu.org/copyleft/gpl.html

-----------------------------------------------------------------------

