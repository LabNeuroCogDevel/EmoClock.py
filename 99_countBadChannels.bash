#!/usr/bin/env bash

[ ! -d txt ] && mkdir txt

for bf in  /data/Luna1/Multimodal/Clock/*/MEG/*bad*txt; do 
  ! [[ $bf =~ /([0-9]{5})_.*([Rr]un[0-9]|[Rr]est|emptyroom) ]] && echo "bad name: $bf" >&2 &&  continue;
  echo ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} $(wc -l $bf|cut -f1 -d' ')
done  > txt/SubjRunBadChannelCount.txt
