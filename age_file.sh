#!/bin/bash
lastlog=`stat -c %Y "$1"`
now=`date +%s`
let age=$now-$lastlog
echo $age 
