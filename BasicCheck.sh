#!/bin/bash

#variables
path=$1
program=$2
args=${@: 3}
currentLocation=`pwd`
trash="/dev/null"
st=("FAIL" "FAIL" "FAIL")
ec=(1 1 1)

#go to path
cd $path

#search make file and get 'exit' value
make > $trash 2>&1
makeOut=$?

#write cols
echo "Compilation	Memory leaks	thread race"

#if condition:
if [ $makeOut -gt 0 ] ; then
echo "${st[0]}		${st[1]}		${st[2]}"
exit 7
fi

ec[0]=0
st[0]="PASS"

#run valgrind
# valgrind ./$program $args > $trash 2>&1
valgrind --leak-check=full --error-exitcode=1 ./$program $args > $trash 2>&1
valout=$?

if [ $valout -eq 0 ] ; then
ec[1]=0
st[1]="PASS"
fi

#run helgrind
valgrind --tool=helgrind --error-exitcode=1 ./$program $args > $trash 2>&1
helout=$?

if [ $helout -eq 0 ] ; then
ec[2]=0
st[2]="PASS"
fi


#give status and exitcode
echo "${st[0]}		${st[1]}		${st[2]}"
exitcode=$((ec[0]*4+ec[1]*2+ec[2]))
exit $exitcode 
