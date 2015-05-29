#!/home/foranw/bin/bash-42

# what to check
# - db (recorded)
#       txt/subj_date_drop_note.txt
# - MAT  (behave matlab file from bea_res)
#       subjs/${ld}/behavior/MEG_${ld}_tc.mat
# - MEG (raw fif files)
#       FinalDataDir/$l/MEG/*[Rr]un[1-8]_raw.fif
# - FS (MR)
#       FinalDataDir/$l/mri/brain.mgz
# * bad channels
#       FinalDataDir/$l/MEG/*bad*.txt
# * csv files from matlab file 
#       subjs/${ld}/behavior/MEG_${ld}_*csv 
# * pd = is the photodiode useable
#        subjs/${ld}/behavior/*goodPDIO.png
# * eve files from matlab+photodiode (via python(
#       subjs/${ld}/behavior/MEG_${ld}_*clock_ds4.eve
# * head model
#       FinalDataDir/$l/MEG/*_chpi_sss.fif
# * max filter
#       FinalDataDir/$l/MEG/*[^n]_ds_sss_raw.fif
# * ica 
#       FinalDataDir/$l/MEG/*_dn_ds_sss_raw.fif
#
# * R model
#
# * note any annotation for the subject, not the same as db note recorded in txt/subj_date_drop_note.txt
#   subjs/${ld}/note
#   

interests=(ld db MAT CSV MEG PD EVE BC FS MF1 MF2 ICA BEM R note)
(for i in ${interests[@]}; do [ "$i" == "ld" ] && i="ld       "; echo -ne "$i\t"; done|sed 's/\t$//'; echo) | tee  completed.txt
# create a base for each row
declare -A line
declare -A baseline
for i in ${interests[@]}; do baseline[$i]=NA; done

(
  awk '($3==0){print $1 "_" $2}' txt/subj_date_drop_note.txt;
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
  grep -q $l txt/subj_date_drop_note.txt && line[db]=1

  # mat found in bea_res 
  line[MAT]=$(ls subjs/${ld}/behavior/MEG_${ld}_tc.mat | wc -l)

  # mat files succesfully extracted into csv files
  line[CSV]=$(ls subjs/${ld}/behavior/MEG_${ld}_*csv|wc -l)


  # number of clock fifs
  line[MEG]=$(ls FinalDataDir/$l/MEG/*[Rr]un[1-8]_raw.fif|wc -l)

  # did we use the photodiode
  line[PD]=$(ls subjs/${ld}/behavior/*goodPDIO.png|wc -l)

  # mat + meg photodiode can make event files
  line[EVE]=$(ls subjs/${ld}/behavior/MEG_${ld}_*clock_ds4.eve|wc -l)
  
  # do we have fs
  line[FS]=$(ls  FinalDataDir/$l/mri/brain.mgz |wc -l)

  # do we have bad channels
   line[BC]=$(ls FinalDataDir/$l/MEG/*bad*run*.txt|wc -l)
  line[MF1]=$(ls FinalDataDir/$l/MEG/*_chpi_sss.fif|wc -l)
  line[MF2]=$(ls FinalDataDir/$l/MEG/*[^n]_ds_sss_raw.fif|wc -l)
  line[ICA]=$(ls FinalDataDir/$l/MEG/*_dn_ds_sss_raw.fif|wc -l)

  line[BEM]=$(ls FinalDataDir/$l/bem/$l-head.fif|wc -l )
  line[R]=$(ls subjs/${l}_fitdata.Rdata|wc -l)

  line[note]="NA"
  nf=subjs/${ld}/note
  [ -r $nf ] && line[note]=$(cat $nf | tr '\n' ';' )


  for i in ${interests[@]}; do echo -ne "${line[$i]}\t"; done|sed 's/\t$//'; echo
done 2>txt/errorsFromCompleted.txt | tee -a txt/completed.txt
