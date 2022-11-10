#!/bin/bash

ETH0_MAC=`cat /sys/class/net/eth0/address | sed 's/://g'`
MAC_PREFIX=`echo ${ETH0_MAC} | cut -c 1-6`
MAC_POST=`echo ${ETH0_MAC} | cut -c 7-`
GATEWAY_ID="${MAC_PREFIX}fffe${MAC_POST}"
echo ${GATEWAY_ID}

region_onchain=`cat /opt/panther-x2/data/region_onchain`
if [ -z $region_onchain ]; then
    REGION=`/usr/bin/region_uptd`
else
    REGION=$region_onchain
fi
echo $REGION

cd /usr/bin && ./sx1302_test_loragw_reg
if [ "$?" != "0" ]; then
    # Run SX1308 lora pkt fwd
    sed "s/AABBCCFFFEDDEEFF/${GATEWAY_ID}/g" /etc/global_conf.json.sx1257.$REGION.template > /etc/global_conf.json
    /usr/bin/reset_lgw.sh start
    cd /usr/bin/ && ./sx1308_lora_pkt_fwd
else
    # Run SX1302 lora pkt fwd
    sed "s/AABBCCFFFEDDEEFF/${GATEWAY_ID}/g" /etc/global_conf.json.sx1250.$REGION.template > /etc/global_conf.json
    cd /usr/bin/ && ./sx1302_lora_pkt_fwd -c /etc/global_conf.json
fi
