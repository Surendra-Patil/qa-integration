#!/usr/bin/bash 

ACC=$1
if [ -z $ACC ]
then
    ACC=1
fi


RPC="http://${IP}:${PORT}"
acc1=$($DAEMON keys show account$ACC --keyring-backend test | awk '{ print $2 }' | sed -n '3p')
val1=$($DAEMON keys show account$ACC -a --bech val --keyring-backend test)  #Make sure the account used is a validator account or pass validator value in val1
#$DAEMON query staking validators    ## to fetch active validators on chain

for (( a=1; a<10000; a++ ))
do
	bTx=$("${DAEMON}" q bank balances "${acc1}" --node $RPC --output json)
	bTxres=$(echo "${bTx}" | jq -r '.balances')
	echo "** Balance :: $bTxres **"
	sTx=$("${DAEMON}" q staking validators --node $RPC --output json)
	sTxres=$(echo "${sTx}" | jq -r '.validators[].description.moniker')
	echo "** Monikers :: $sTxres **"
	dTx=$("${DAEMON}" q staking delegation "${acc1}" "${val1}" --node $RPC --output json)
	dTxres=$(echo "${dTx}" | jq -r '.delegation.shares')
	echo "** Delegations :: $dTxres **"
done
