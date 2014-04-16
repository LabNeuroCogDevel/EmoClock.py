#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
takes matlab behavior and meg recording and creates
 1) csv file to feed into R model fitting module
 2) eve MNE event file for each run
"""

from __future__ import division;
import mne;
import scipy.io; # for matlab read
import matplotlib.pyplot as plt;
import numpy as np; #, h5py;
import pandas as pd;
from itertools import groupby #, izip; # for runlenghencode like function
import argparse
import warnings



# setup arguments
parser = argparse.ArgumentParser(description='Generate CSV file from mat and fif(photodiode)')
parser.add_argument('--mat',   '-m',dest="matfile",   required=True, help='path to the subjects mat file\neg. MEG_11243_20140213_tc.mat')
parser.add_argument('--subjid','-s',dest='subjid',    required=True, help='subject id\ne.g. 12345_20001231')
parser.add_argument('--fif',   '-f',dest='fiffile',   required=True, help='path to run fif file e.g. 11243_run1_Clock_raw.fif')
parser.add_argument('--block', '-b',dest='runnum',    required=True, help='run number (1-8)',type=int)
parser.add_argument('--output','-o',dest='outputname',help='name for csv file (default: subjid_runnum.csv)')
parser.add_argument('--eve','-e',dest='evename',help='name for csv file (default: subjid_runnum.eve)')

args = parser.parse_args()
# "working"
#args = parser.parse_args('-m subjs/11262_20140312/behavior/MEG_11262_20140312_tc.mat -f subjs/11262_20140312/MEG/11262_clock_run8_raw.fif -o 11262_8.csv -s 11262_20140312 -b 8'.split())
# broken
#args = parser.parse_args('-m subjs/11255_20140318/behavior/MEG_11255_20140318_tc.mat -f subjs/11255_20140318/MEG/11255_Clock_run2_raw.fif -b 2 -s 11255_20140318'.split())

if(not args.outputname):
    args.outputname=args.subjid+'_'+str(args.runnum)+'.csv'
    
if(not args.evename):
    args.evename=args.subjid+'_'+str(args.runnum)+'.eve'

### BEHAVIORAL
# task file
mat   = scipy.io.loadmat(args.matfile,struct_as_record=True);
subj  = mat.get('subject');
order = subj['order'][0][0];

#trial = np.ndarray((order.size,12))
trial = [];
for t in order:
    trial.append( [i[0] if isinstance(i[0],basestring) else  i[0][0] for i in t[0][0]]  )

df_trial = pd.DataFrame(trial)
df_trial.columns = [ 'function','run','trial','block','null','starttime','mag','scoreinc','freq','ev','RT','emotion']

columns=['function','run','trial','block','NA','start','mag','inc','freq','ev','rsptime','emotion']
df = pd.DataFrame(trial,columns=columns)


### MEG 

# meg file
raw = mne.fiff.Raw(args.fiffile)# ,preload=True) # preload to enable editing


## get only the trials that are in this run
df_trial = df_trial[df_trial['block']==args.runnum] 
# originalTrialNums must be exctacted from list, if just =, will hold current values when we want to change 
originalTrialNums = [ x for x in df_trial['trial'] ]


# re number the trial to start at 1 (fif doesn't know there were any trials before)
starttrial=min(df_trial['trial'])
df_trial['trial'] = df_trial['trial'] - starttrial + 1
# remove 0s -- but there to avoid weird addition when sending TTL triggers
# ## takes too long
#for idx in range(0,raw[ttl,:][0].size): 
#    if ( idx>0 and abs( raw[ttl,:][0][0][idx] )-10**(-2) < 0 ):
#        raw[ttl,:][0][0][idx]=raw[ttl,:][0][0][idx-1]
#

## # [ onsite time, trigger, event id ]
## allevents = mne.find_events(raw, stim_channel='STI101',output='onset') 
## events = allevents;
## ## collapse low triggers into intended triggers
## # put the low( 1 or 0) trigger start into the trigger following
## for idx in range(0,len(events)-1): 
##     if events[idx][1]<5 and idx<len(events):
##       events[idx+1][0] = events[idx][0]
##       #events[idx+1][2]+=events[idx][2] # keep the 0 event ID
## 
## # resample to seconds
## # events=events.astype(np.float32) # need to be able to divide seconds
## # for idx in range(0,len(events)-1): 
## #    events[idx][0] = float(events[idx][0])/raw.info['sfreq']
## 
## # remove all the zeros
## events = [e for e in events if e[1]>8]



ttl = raw.ch_names.index('STI101');
pdio  = raw.ch_names.index('MISC007');
bpsh= raw.ch_names.index('STI102');
data,times = raw[ [pdio,ttl,bpsh], :]

# digitized position, length, startidx, stopidx -- start and stop are inclusuve a a a b b b b -> a,3,0,2; b,2,3,6 
def rledig(hist):
  rle = np.array( [ (i,len(list(j)) ) for i,j in groupby(hist) ] );
  idx = rle[:,1].cumsum();
  # matrix of:        histval, length,          start,stop
  rleidx = np.vstack((rle.T, (idx - rle[:,1] ).T, idx.T - 1)).T;
  rleidx= rleidx.tolist() # for faster del operation
  
  # remove jumps (len==1) and 
  #  merge identical histval sections it might have separated
  i=1;
  while i  < len(rleidx):
      j=i+1;
      while j<len(rleidx) and (rleidx[j][0] == rleidx[i][0] or rleidx[j][1] < 2):
          # update end position
          rleidx[i][3] = rleidx[j][3]
          # reset length
          rleidx[i][1] = rleidx[i][3] - rleidx[i][2] +1
          # remove this bogus entry          
          del(rleidx[j])
          #np.delete(rleidx,j,0)
          # j+=1; # b/c of delete next is current
      i+=1; 
      
  return np.array(rleidx)
  

pdioToLabel = {
 1: 'ISI', # black
 2: 'score',    # gray [204 204 204]
 3: 'face',     # white
}
ttlToLabel = {
 1: 'score', # 0 (??)
 5: 'score', # 135-235
 2: 'ISI',   # 10
 3: 'ITI',   # 15
 4: 'face',  # 24-130
 6: 'done',  #255
}

# PHOTODIODE 
# 1. face  | white
# 2. ISI   | black
# 3. score | [204 204 204]
# 4. ITI   | black
pdio_inds = np.digitize(data[0,:],np.histogram(data[0,:],bins=3)[1])


# remove anything that went too high (why did this happend?)
pdio_inds[pdio_inds>3] = 3

# PARALLEL PORT -- TTL
# 1. face  | 25-130
# 2. ISI   | 10 
# 3. score | 135 - 235 ( + 4 if correct) 
# 3. score | 135 - 235 (face+107)
# 4. ITI   | 15
# - done 255
#                                 |junk/score? |10=ISI| 15=ITI | 25-130=face | 135-239=score |
ttl_inds  = np.digitize(data[1,:],[0,           5,     12,      20,          132,           250 ])
# turn junk triggers into score
ttl_inds = [ 5 if x==1 else x for x in ttl_inds ];

# get when there is a change
ttl_rleidx = rledig(ttl_inds)
pdio_rleidx = rledig(pdio_inds)

# see actual values of photodiode at changes
#     np.reshape(pdio_rleidx[ [ [x] for x in range(0,3) ],[2,3] ],(6,1) )

# truncate photiodiode events (remove get ready)
# remove anythere where the photodiode starts before the first tigger ends
# -- pdio changes after first trigger sent
pdio_rleidx = np.array([ p for p in pdio_rleidx  if  p[2] - ttl_rleidx[0,3]  > 0 ])
# check there are the right number of trials
# [ x for x in [ [i,len(list(j))] for i,j in groupby(trial) ] if x[1]!=4 ]


# trial numbers for pdio_rleidx, trial starts with face (histogram value = 3 for photodiode)
trial = np.array([ p[0] == 3 for p in pdio_rleidx ]).cumsum()
# set 5th column to be trial number, 6th to be intertrial type
pdio_rleidx = np.c_[pdio_rleidx, trial]

# as one step, get bad data conversion
#pdio_df = pd.DataFrame(np.c_[pdio_rleidx,np.array([ pdioToLabel[x] for x in  pdio_rleidx[:,0] ])])
pdio_df = pd.DataFrame(pdio_rleidx)
pdio_df['event'] = np.array([ pdioToLabel[x] for x in  pdio_rleidx[:,0] ])
pdio_df.columns = ['pd.histval','pd.len','pd.start','pd.stop','trial','event']

# build array of (event + trialnum*10). were this overlaps, there is an ITI
# doesn't work when 2 scores in a row?? pdio_df.loc[ (pdio_df['trial']==5)] for 'subjs/11262_20140312/MEG/11262_clock_run8_raw.fif'
itiIdxs=np.r_[pdio_rleidx[:,0]+pdio_rleidx[:,4]*10, 0, 0] - np.r_[0,0,pdio_rleidx[:,0]+pdio_rleidx[:,4]*10] == 0;
pdio_df['event'][np.where(itiIdxs)[0]] = 'ITI'
# retype those pesky strings
tofloat = [ x for x in pdio_df.columns if x != 'event' ]
pdio_df[tofloat] = pdio_df[tofloat].astype(float)

# only the last trial should not have 4 pices (face,ISE,score,ITI)
if len( [t for t,g  in groupby(pdio_df['trial']) if len(list(g))!=4 ] ) > 1:
    Exception('do not have face,ISI,score,ITI for all expected trials (not last)') 


# trial number for trigger, starts at face (value of 4)
# count up trials based on number of starts
trial = np.array([ t[0] == 4 for t in ttl_rleidx ]).cumsum()
ttl_rleidx = np.c_[ttl_rleidx, trial]
ttl_df = pd.DataFrame(ttl_rleidx)
ttl_df['event'] = [ ttlToLabel[x] for x in  ttl_rleidx[:,0] ]
ttl_df.columns = ['tt.histval','tt.len','tt.start','tt.stop','trial','event']
# retype those pesky strings, for all columns that are not event
tofloat = [ x for x in ttl_df.columns if x != 'event' ]
ttl_df[tofloat] = ttl_df[tofloat].astype(float)

### if photodiode doesn't record as we hope, final trial number will be different
if( (pdio_df['trial'].tail(1) != ttl_df['trial'].tail(1)).item() ):
    warnings.warn('photodiode (n.t=' +
                     str(pdio_df['trial'].tail(1).item())+
                    ') and triggers (n.t='+
                    str(ttl_df['trial'].tail(1).item())+
                    ') do not align -- using ttl instead of pdio')
    
    ## pretend  ttl channel is the pdio channel
    #pdio_df_real = pdio_df    
    pdio_df = ttl_df.copy()
    pdio_df.columns = ['pd.histval','pd.len','pd.start','pd.stop','trial','event']
    ## plot triggers
    plt.plot(data[0,:]);
    for v in np.histogram(data[0,:],bins=3)[1]:
        plt.axhline(y=v,color='r')
    plt.savefig(args.outputname + '_badPDIO.png')
else:
    plt.plot(data[0,:]);
    for v in np.histogram(data[0,:],bins=3)[1]:
        plt.axhline(y=v,color='r')
    plt.savefig(args.outputname + '_goodPDIO.png')
    plt.close()
    plt.plot(data[2,:]);plt.plot(ttl_inds[:]);plt.plot(pdio_inds[:]);
    plt.savefig(args.outputname+'_allTrigs.pdf')
    
    
if( (ttl_df['trial'].tail(1) != df_trial['trial'].tail(1)).item()  ):
    raise Exception('trials from trigger do not match matlab file!')    
# TODO: Implement
# while trial lengths not equal
#      find where pdio face onset is > 1000 ms from ttl onset
#      add 1 to that and every subsiquent pdio trial number 


# merge the two
df = pd.merge(pdio_df,ttl_df)

## TODO: reshape df so each row is a trial (instead of every 3 as a trial)

# or do it this slow way
for e in set(pdio_df['event']):
    ename=e + '.start'
    df_trial[ename] = 0;
    for t in set(df_trial['trial']):
        startidx=pdio_df.loc[ (pdio_df['trial']==t) & (pdio_df['event']==e)]['pd.start']
        if len(startidx)!=1:
            warnings.warn(e+" on trial "+str(t)+" has "+str(len(startidx)) + " occurances",Warning)
            startidx=startidx.head(1)
        
        df_trial[ename][(df_trial['trial']==t)] = np.array(startidx) # NaN if not cast to array first (why?)
      
      




#### eve file
# TODO: set volt unique for eg. DEV scam
# from MEGClockTask/private/defineTrigger.m 
#   trigger.ITI= 10;
#    trigger.ISI= 15;
#    %face 25-130
#    % score 135 - 235 -- face+107

runTypeToVolt = {
  #face: 25 - 130 
  'CEV.fear.face'   : 29,
  'CEVR.fear.face'  : 38,
  'DEV.fear.face'   : 47,
  'IEV.fear.face'   : 56,
  'CEV.happy.face'  : 65,
  'CEVR.happy.face' : 74,
  'DEV.happy.face'  : 83,
  'IEV.happy.face'  : 92,
  'CEV.scram.face'  : 101,
  'CEVR.scram.face' : 110,
  'DEV.scram.face'  : 119,
  'IEV.scram.face'  : 128,
  #score: 135 - 235 == face+107
  'CEV.fear.score'  : 136,
  'CEVR.fear.score' : 145,
  'DEV.fear.score'  : 154,
  'IEV.fear.score'  : 163,
  'CEV.happy.score' : 172,
  'CEVR.happy.score': 181,
  'DEV.happy.score' : 190,
  'IEV.happy.score' : 199,
  'CEV.scram.score' : 208,
  'CEVR.scram.score': 217,
  'DEV.scram.score' : 226,
  'IEV.scram.score' : 235,
}
x=df_trial[['face.start','ISI.start','score.start','ITI.start']].stack()
if( not all( x[:-1] < x[1:]) ):
    Exception('indexes are not ordered correct (face<ISI<score<ITI!')    


funcEmo =  (df_trial['function'].head(1) + '.' +  df_trial['emotion'].head(1)).iget(0)
triggers = [ runTypeToVolt[ funcEmo + '.face' ], 15,  runTypeToVolt[ funcEmo + '.score' ], 10 ] 

#           index, time,      "volt":     was                                                 is
eve = np.c_[ x,    x/1000,    np.tile([ triggers[a] for a in [3, 0, 1, 2] ], len(x)/4),    np.tile(triggers, len(x)/4) ]
# add first row of zeros
eve = np.vstack(([0,0,0,0],eve))  
# make actual first transtion value from zero  
eve[1,2] = 0
# save 
np.savetxt(args.evename,eve,fmt='%d %.03f %d %d')




##### sanity checks
## difference of when Button is pushed and when RT is reported
# [ np.argmax(data[2,s:e]>=1.5)  for s,e in np.array(df_trial[['face.start','ISI.start']]) ] - np.array(df_trial['RT'])

## diff between face,isi,score, and ITI -- should be near constant
# diff(df_trial[ ['face.start','ISI.start','score.start','ITI.start'] ])
# diff(df_trial[ ['face.start','ISI.start','score.start','ITI.start'] ]).std(0)
##### save file
        
# FROM fitclock/R/fitclock.R    
#' Dataset is a .csv file consisting of the following fields 
#' 
#' \itemize{
#'   \item run. fMRI run (1:8)  
#'   \item trial. Global trial number (1:400) 
#'   \item rewFunc. Reward contingency (DEV, IEV, CEV, CEVR)
#'   \item emotion. Face emotion of central stimulus (scram, fear, happy) 
#'   \item magnitude. Magnitude of expected reward given RT  
#'   \item probability. Probability of expected reward given RT
#'   \item score. Obtained reward (probabilistic receipt of payoff)
#'   \item ev. Expected value of response given RT (magnitude*probability)
#'   \item rt. Reaction time (ms)
#'   \item clock_onset. Run onset time of clock stimulus (sec) 
#'   \item isi_onset. Run onset time of 50ms ISI (sec)
#'   \item feedback_onset. Run onset time of 850ms reward feedback (sec)
#'   \item iti_onset. Run onset time of ITI (sec)
#'   \item iti_ideal. Desired ITI duration (sec) based on fMRI design optimization.
#'   \item image. Image file displayed on screen.
#' }

## TODO:  ITIideal imagefile, score not scoreinc?
#
#  experiment order file indexes -- mat file subject.experiment
#  facenumC, ITIC, ISIC, blockC, emotionC, rewardC 

df_trial['imagefile']='NA'
df_trial['ITIideal']=0
df_trial['trial'] = originalTrialNums
df_trial['totalscore']=df_trial['scoreinc'].cumsum()
# use the button push STI102 trigger to get a more accurate RT
# -- dependant on face.start beign accurate
df_trial['pushidx'] = [ np.argmax(data[2,s:e]>=1.5) + s   for s,e in np.array(df_trial[['face.start','ISI.start']]) ]
df_trial['RT.push'] = [ np.argmax(data[2,s:e]>=1.5)  for s,e in np.array(df_trial[['face.start','ISI.start']]) ]

# TODO, run or block
df_final = df_trial[ ['block','trial', 'function', 'emotion', 'mag','freq','scoreinc','ev','RT.push',
                      'face.start','ISI.start','score.start','ITI.start','ITIideal','imagefile','pushidx'] ]
df_final.columns=['run','trial','rewFunc','emotion','magnitude','probability','score','ev','rt',
                  'clock_onset','isi_onset','feedback_onset','iti_onset','iti_ideal','image','pushidx']         
df_final.to_csv(args.outputname,index=False)

exit()






### PLOTS

# dflong = pd.wide_to_long(df,["pd.","tt."],i='trial',j='from') 
# dfmetl = pd.melt(df,id_vars=['event','trial'])
# dflong.stack()
# pd.melt(pdio_df.drop(['pd.histval','pd.len'],1),id_vars=['trial','event']).set_index('trial').stack()
# pd.wide_to_long(pdio_df.drop(['pd.histval','pd.len'],1),["pd."],i='trial',j='from').tail()
f,axarr = plt.subplots(4,1,sharex=True)
pi=0
for t in ['start','stop','len']:
   diff=df['pd.' + t] - df['tt.' + t]
   axarr[pi].hist(diff)
   ttl='pd vs tt @ ' +  t + ' $\mu$' + str(diff.mean()) + ' $\sigma$ '+  str(diff.std()) 
   axarr[pi].set_title(ttl)
   pi+=1

df_RT = pd.merge(df_trial[['trial','RT']][df_trial['block']==args.runnum].astype(int), df[['pd.len','trial']][df['event']== 'face'].astype(int),on='trial')
axarr[pi].set_title('matlab RT - photodiode face')
axarr[pi].hist( df_RT['RT'] - df_RT['pd.len'] ) 

plt.show()
#plt.scatter(times[pdio_rleidx[:,2]],pdio_rleidx[:,0],color='blue')
#plt.scatter(times[ttl_rleidx[:,2]],ttl_rleidx[:,0],color='red')
#plt.plot(times,pdio_inds,color='blue')
#plt.plot(times,ttl_inds,color='red')
#plt.set_title('triggers')



#                                    1              2        3        4            5
# move all the zeros back to what they should be
#for idx in range(1,len(ttl_inds)): 
#    if ttl_inds[idx] == 1:
#       ttl_inds[idx]=ttl_inds[idx-1]
#
#from ggplot import *;
#ggplot(pd.DataFrame(events,columns=['time','xdat','samples']),aes(x='time',y='xdat'))+geom_point()
## use samples instead of time
#plt.plot(times*raw.info['sfreq'],100+10*data[0,:],color='blue')
#plt.plot(times*raw.info['sfreq'],data[1,:],color='red')
#plt.show()



alldf = pd.merge(df,df_trial)
