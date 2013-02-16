csf-allow-pingdom-probes
========================
Get Pingdom probe IPs and add them to the CSF (ConfigServer Firewall) allow list. Meant to be run as a daily cronjob. For example:
    32 2 * * * /root/update-pingdom-probes.sh > /dev/null 2>&1
