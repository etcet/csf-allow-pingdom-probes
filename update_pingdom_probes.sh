#!/bin/bash
# Update the pingdom firewall rules based on their feed

# rotate pingdom ip list (keep 8 days)
LIST=$(ls -r /root/pingdom_ips*);
for i in $LIST; do
	# get index of file
	INDEX=$(ls $i | cut -d"." -f 2)

	# if there's no index, rename to pingdom_ips.0
	if [ $INDEX = "/root/pingdom_ips" ]; then
		NEW=$INDEX.0
		mv $i $NEW
	# remove files with index > 6 (keep 8 files)
	elif [ $INDEX -gt 6 ]; then
		rm $i
	# increment index for all other files
	else
		BASE=$(ls $i | cut -d"." -f 1)
		NEW=$BASE.$(($INDEX+1))
		mv $i $NEW
	fi
done

# get pingdom ips from their rss feed
wget https://www.pingdom.com/rss/probe_servers.xml -O /root/probe_servers.xml -o /dev/null
cat /root/probe_servers.xml | grep IP | sed -e 's/.*IP: //g' | sed -e 's/; Host.*//g' | grep -v IP > /root/pingdom_ips

# if old lists do not exist, just allow all ips
if [ ! -f /root/pingdom_ips.0 ]; then
	cat /root/pingdom_ips | xargs -n 1 csf -a
else
	# if there any differences between previous and current list, replace ips in allow list
	if ! diff -q /root/pingdom_ips /root/pingdom_ips.0 > /dev/null; then
		cat /root/pingdom_ips.0 | xargs -n 1 csf -ar
		cat /root/pingdom_ips | xargs -n 1 csf -a
	fi
fi
