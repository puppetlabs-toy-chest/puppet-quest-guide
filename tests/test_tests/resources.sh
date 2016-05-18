#!/bin/bash
HIST=~/.bash_history
quest begin resources
#Task 1
puppet resource user root
echo "puppet resource user root" >> $HIST
#Task 2
puppet describe user
echo "puppet describe user | less" >> $HIST
#Task 3
puppet apply -e "user { 'galatea': ensure => present, }"
#Task 4
puppet resource user galatea comment='Galatea of Cyprus'
