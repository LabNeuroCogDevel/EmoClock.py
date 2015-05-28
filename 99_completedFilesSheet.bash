#!/home/foranw/bin/bash-42

# what to check
# - db (recorded)
# - B  (behave)
# - MEG
# - FS (MR)
# * bad channels
# * head model
# * max filter
# * ica

interests=(ld db B MEG FS BC MF1 MF2 ICA)
(for i in ${interests[@]}; do echo -ne "$i\t"; done; echo) | tee  completed.txt
# create a base for each row
declare -A line
declare -A baseline
for i in ${interests[@]}; do baseline[$i]=NA; done

(
  awk '($3==0){print $1 "_" $2}' ./subj_date_drop_note.txt;
  ls subjs/1*_*/behavior/MEG_*_tc.mat | perl -lne 'print $& if /\d{5}_\d{8}/'
) | 
 sort |
 uniq |
 while read ld; do
  l=${ld%%_*}

  line=${baseline[@]}
  line[ld]=$ld

  # in db
  line[db]=0
  grep -q $l ./subj_date_drop_note.txt && line[db]=1

  # mat found in bea_res 
  line[B]=0
  [ -r subjs/${ld}/behavior/MEG_${ld}_tc.mat ] && line[B]=1

  # number of clock fifs
  line[MEG]="$(ls FinalDataDir/$l/MEG/*run[1-8]_raw.fif|wc -l)"
  
  # do we have fs
  [ -d FinalDataDir/$l/mri/ ] && line[FS]=1

  # do we have bad channels
   line[BC]="$(ls FinalDataDir/$l/MEG/*bad*.txt|wc -l)"
  line[MF1]="$(ls FinalDataDir/$l/MEG/*_chpi_sss.fif|wc -l)"
  line[MF2]="$(ls FinalDataDir/$l/MEG/*[^n]_ds_sss_raw.fif|wc -l)"
  line[ICA]="$(ls FinalDataDir/$l/MEG/*_dn_ds_sss_raw.fif|wc -l)"


  for i in ${interests[@]}; do echo -ne "${line[$i]}\t"; done;echo
done | tee -a completed.txt
