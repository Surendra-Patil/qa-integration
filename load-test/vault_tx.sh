#!/usr/bin/bash 

ACC=$1
if [ -z $ACC ]
then
    ACC=1
fi

RPC="http://${IP}:${PORT}"
acc1=$($DAEMON keys show account$ACC --keyring-backend test | awk '{ print $2 }' | sed -n '3p')
seq1=$("${DAEMON}" q account "${acc1}" --node $RPC --output json)

seq1no=$(echo "${seq1}" | jq -r '.sequence')
bound=`expr 10000 + $seq1no`

for (( a=$seq1no; a<$bound; a++ ))
do
    sTx1=$("${DAEMON}" tx vault deposit 5 1000 --from "${acc1}" --chain-id "${CHAINID}" --keyring-backend test --gas auto --node $RPC --output json -y --sequence $a) 
    sTxHash1=$(echo "${sTx1}" | jq -r '.txhash')
    echo "** Vault Deposit TX HASH :: $sTxHash1 **"
    a=$((a+1))
    sTx3=$("${DAEMON}" tx vault draw 5 1000 --from "${acc1}" --chain-id "${CHAINID}" --keyring-backend test --gas auto --node $RPC --output json -y --sequence $a) 
    sTxHash3=$(echo "${sTx3}" | jq -r '.txhash')
    echo "** Vault draw TX HASH :: $sTxHash3 **"
    a=$((a+1))
    sTx2=$("${DAEMON}" tx vault withdraw 5 1000 --from "${acc1}" --chain-id "${CHAINID}" --keyring-backend test --gas auto --node $RPC --output json -y --sequence $a) 
    sTxHash2=$(echo "${sTx2}" | jq -r '.txhash')
    echo "** Vault Withdraw TX HASH :: $sTxHash2 **"
done
