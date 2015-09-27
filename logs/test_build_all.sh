#!/bin/bash
BASE=$(dirname $0)
for p in $(cat $BASE/projects); do echo -ne "\e[0mTesting $p"; L=$BASE/proj_$p.log; make APP=$p all clean &>$L && echo -e "\e[34m Ok\e[0m" || echo -e "\033[31m Fail\e[0m See $L"; done
