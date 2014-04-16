#script to run maxfilter, two stage process. First do noise correction, then do trans
# this script has to be run on wallace.


for s in 10637 10662 10997 11243 11246 11252 11253 11255 11258 11262 11263; do

	for r in 1 2 3 4 5 6 7 8; do
		/neuro/bin/util/i686-pc-linux-gnu/maxfilter-2.2 \
		-f /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${r}_raw.fif \
		-o /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${r}_raw_chpi_sss.fif \
		-origin fit -autobad off \
		-bad $(sed s/MEG// /home/hwangk/Luna1/Multimodal/Clock/${s}/${s}_clock_bad_run${r}.txt) \
		-st 10 -movecomp inter -v \
		-ctc /home/hwangk/Luna1/ni_tools/maxfilter_calib/ct_sparse.fif \
		-cal /home/hwangk/Luna1/ni_tools/maxfilter_calib/sss_cal.dat \
		> /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${r}_sss.log
		
		/neuro/bin/util/i686-pc-linux-gnu/maxfilter-2.2 \
		-f /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${r}_raw_chpi_sss.fif \
		-o /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${r}_ds_sss_raw.fif \
		-origin fit -trans default -frame head -force -v -autobad off -ds 4 \
		> /home/hwangk/Luna1/Multimodal/Clock/${s}/MEG/${s}_clock_run${r}_trans.log
	
	done
done