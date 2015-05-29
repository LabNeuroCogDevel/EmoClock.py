#!/usr/bin/env bash

#
# get all subjects in the database who are in MM (MEGEmo) and did the clock task
#
sql mysql://lncd@arnold.wpic.upmc.edu/lncddb3 '
select
  pe.value as lunaid, 
  date_format(v.visitdate,"%Y%m%d") as vd,
  sum(dropReason!=0) as dropped,
  replace(group_concat(note,";;"),"\n",";") as note
 from visitsTasks as vt 
 join peopleEnroll pe on vt.peopleid=pe.peopleid and enrollType like "lunaID"
 join notes n on (( n.visitid is null and n.peopleid=vt.peopleid) or n.visitid = vt.visitid) 
 join visits v on v.visitid=vt.visitid
 join visitsStudies vs on v.visitid=vs.visitid
 where vt.TaskName like "EmoClockMEG" and subsection like "completed"
 group by vt.visitid 
 order by dropped,lunaid,vd
' | tee txt/subj_date_drop_note.txt
