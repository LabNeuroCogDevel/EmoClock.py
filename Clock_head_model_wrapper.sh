
export SUBJECTS_DIR=/data/Luna1/Multimodal/Clock
for s in 11258 11255 ; do

	while [`jobs | wc -l` -ge 8 ]
  	do
    		sleep 10
  	done
	
	cd $SUBJECTS_DIR
	make_mne_model.sh ${s} > $SUBJECTS_DIR/${s}/scripts/${s}_make_mne_model.log 2>&1 &	

done
