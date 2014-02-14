# -*- coding: utf-8 -*-
"""
Created on Fri Feb 14 10:07:25 2014

@author: foranw
"""

import mne;
import matplotlib.pyplot as plt;
import numpy as np, h5py;

# meg file
raw = mne.fiff.Raw('11243_run1_Clock_raw.fif')

# task file
f = h5py.File("MEG_11243_20140213_tc.mat",'r') 
#data = f.get('data/variable1') 
#data = np.array(data) 


pd  = raw.ch_names.index('MISC007');
ttl = raw.ch_names.index('STI101');

data,times = raw[ [pd,ttl], :]

plt.plot(times,100+10*data[0,:])
plt.plot(times,data[1,:])
plt.show()
#plt.ion()



