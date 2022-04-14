#!/usr/bin/bash 

FROM=$1
if [ -z $FROM ]
then
    FROM=1
fi

TO=$2
if [ -z $TO ]
then
    TO=2
fi

RPC="http://${IP}:${PORT}"
acc1=$($DAEMON keys show account$FROM --keyring-backend test | awk '{ print $2 }' | sed -n '3p')
acc2=$($DAEMON keys show account$TO --keyring-backend test | awk '{ print $2 }' | sed -n '3p')
seq1=$("${DAEMON}" q account "${acc1}" --node $RPC --output json)

seq1no=$(echo "${seq1}" | jq -r '.sequence')
bound=`expr 10000 + $seq1no`



for (( a=$seq1no; a<$bound; a++ ))
do
    sTx=$("${DAEMON}" tx bank send "${acc1}" "${acc2}" 1000000"${DENOM}" --chain-id "${CHAINID}" --keyring-backend test --node $RPC --output json -y --sequence $a) 
    sTxHash=$(echo "${sTx}" | jq -r '.txhash')
    echo "** TX HASH :: $sTxHash **"
done
