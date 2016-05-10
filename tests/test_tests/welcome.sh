#!/bin/bash
HIST=~/.bash_history
quest begin welcome
puppet -V
echo "puppet -V" >> $HIST
quest --help
echo "quest --help" >> $HIST
quest status
echo "quest status" >> $HIST

