#!/bin/bash
# This file is part of the rsyslog project, released under ASL 2.0
echo ===============================================================================
echo \[es-basic.sh\]: basic test for elasticsearch functionality
. $srcdir/diag.sh init
. $srcdir/diag.sh es-init
. $srcdir/diag.sh startup es-loop-test.conf
. $srcdir/diag.sh injectmsg  0 100
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown 
. $srcdir/diag.sh es-getdata 100
. $srcdir/diag.sh seq-check  0 99
. $srcdir/diag.sh exit
