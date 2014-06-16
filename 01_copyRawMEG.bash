#!/usr/bin/env bash

# copy fif files from Raw to final processing directory 
# needs behavor files to already be pulled (so it knows who to look for)

rawdir=/data/Luna1/Multimodal/MEG_Raw/
finaldir=/data/Luna1/Multimodal/Clock/

for s in subjs/1*_*/; do
 subj_date=$(basename $s)
 subj=$(basename $s |sed s/_.*//;)
 finalSubjDir=$finaldir/${subj}/MEG/

 # before we create folders for subject MEG 
 # make sure they have MEG data
 rawSubjDir=$rawdir/$subj_date 
 [ ! -d $rawSubjDir ] && echo "no MEG data for $subj_date!" && continue

 # make the directory if we need
 [  -d $finalSubjDir ] ||  mkdir -p $finalSubjDir
 # copy all the files that match our needs
 # 11253_Clock_Run1_Raw.fif
 find "$rawSubjDir" -regextype posix-extended -iregex ".*/${subj}.*_[Cc]lock_([Rr]est|[Ee]mptyroom|[Rr]un[1-8])_[Rr]aw.fif" | while read f; do
   newname="$finalSubjDir/$(basename "$f" | perl -ne 's/_\d{8}//; print lc($_)')"
   [ -r $newname ] && continue
   echo $newname
   cp $f $newname
 done

done

exit

###########################
# from rename.sh in $rawSubjDir
# KH by hand rawdir (/data/Luna1/Multimodal/MEG_Raw/)

for s in 11250 10638; do
	mkdir /home/hwangk/Luna1/Multimodal/Clock/${s}/
	mkdir /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/
	cd /home/hwangk/Luna1/Multimodal/MEG_Raw/${s}_2014*/1*
	#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_calib_raw.fif
	#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_calib.fif
	cp ${s}_Clock_Rest_Raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_rest_raw.fif
	cp ${s}_Clock_Emptyroom_Raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_emptyroom_raw.fif	
	for run in 1 2 3 4 5 6 7 8; do
		#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_anti_run${run}_raw.fif
		#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_anti_run${run}.fif
		cp ${s}_Clock_Run${run}_Raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${run}_raw.fif
	done
done


for s in 11281 10772 11287; do
	mkdir /home/hwangk/Luna1/Multimodal/Clock/${s}/
	mkdir /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/
	cd /home/hwangk/Luna1/Multimodal/MEG_Raw/${s}_2014*/1*
	#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_calib_raw.fif
	#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_calib.fif
	cp ${s}_Clock_rest_raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_rest_raw.fif
	cp ${s}_Clock_emptyroom_raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_emptyroom_raw.fif	
	for run in 1 2 3 4 5 6 7 8; do
		#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_anti_run${run}_raw.fif
		#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_anti_run${run}.fif
		cp ${s}_Clock_run${run}_raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${run}_raw.fif
	done
done

for s in 11278 11279 11277; do
	mkdir /home/hwangk/Luna1/Multimodal/Clock/${s}/
	mkdir /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/
	cd /home/hwangk/Luna1/Multimodal/MEG_Raw/${s}_2014*/1*
	#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_calib_raw.fif
	#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_calib.fif
	cp ${s}_clock_rest_raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_rest_raw.fif
	cp ${s}_clock_emptyroom_raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_emptyroom_raw.fif	
	for run in 1 2 3 4 5 6 7 8; do
		#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_anti_run${run}_raw.fif
		#rm /Volumes/T800/Multimodal/ANTI/${s}/MEG/${s}_anti_run${run}.fif
		cp ${s}_clock_run${run}_raw.fif /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${run}_raw.fif
	done
done
