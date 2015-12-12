#!/bin/bash
# Test for queue data persisting at shutdown using RELP. The
# plan is to start an instance, emit some data, do a relatively
# fast shutdown and then re-start the engine to process the 
# remaining data.
# added 2015-12-10 by alorbach
# This file is part of the rsyslog project, released  under GPLv3
# uncomment for debugging support:
echo "Testing RELP send & receive with queue persisting to disk, mode LinkedList"
. $srcdir/diag.sh init

# Startup receiver instance 
export RSYSLOG_DEBUGLOG="log"
. $srcdir/diag.sh startup sndrcv_relp_rcvr.conf 
. $srcdir/diag.sh wait-startup

# Startup sender instance 
export RSYSLOG_DEBUGLOG="log2"
echo \$WorkDirectory test-spool >> diag-common2.conf
echo \$MainMsgQueueFilename mainq >> diag-common2.conf
echo \$MainMsgQueueSaveOnShutdown on >> diag-common2.conf
echo \$MainMsgQueueType LinkedList >> diag-common2.conf
echo \$MainMsgQueueDequeueBatchSize 8 >> diag-common2.conf
# echo \$MainMsgQueueTimeoutShutdown 0 >> diag-common2.conf
. $srcdir/diag.sh startup sndrcv_relp_sender.conf 2
. $srcdir/diag.sh wait-startup 2
# Now inject the messages into instance 2. It will connect to instance 1,
# and that instance will record the data.
. $srcdir/diag.sh tcpflood -p13514 -m50000 -i1
sleep 2 # Let rsyslog send some of the events

# Shutdown sender instance to simulate lost connection
. $srcdir/diag.sh shutdown-immediate 2
. $srcdir/diag.sh wait-shutdown 2
. $srcdir/diag.sh check-mainq-spool

# Second Startup sender instance | sending should be resumed
export RSYSLOG_DEBUGLOG="log3"
. $srcdir/diag.sh startup sndrcv_relp_sender.conf 2
. $srcdir/diag.sh wait-startup 2
sleep 2 # make sure RELP is finished 

# Stop the sender now
. $srcdir/diag.sh shutdown-when-empty 2
. $srcdir/diag.sh wait-shutdown 2

# Stop the receiver as well
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown

# Do the final check
. $srcdir/diag.sh seq-check 1 50000