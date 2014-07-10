# This file does 3 thigns
#  sets up datapaths based on the hostname
#  creates the saveModel function (only saves if rdata file does not exist)
#  creates the writeEveFromModel function to save rpe ev and reward

# where to save the model depends on what host we are on
datapaths  <- list(
             'wallace.wpic.upmc.edu'="/data/Luna1/EmoClockMEG/FinalDataDir",
              'arnold.wpic.upmc.edu'="/Volumes/T800/Multimodal/Clock"
             )
nodename <-  Sys.info()[['nodename']]
datapath <- datapaths[nodename ];

# save a file with the fitted model
# also write out EV Rpi and Reward "eve" column vectors
# returns file name of the saved rdata file
saveModel <- function(s) {
  require(plyr)

  #setup file name
  file=paste("subjs/",s,"_fitdata.Rdata",sep="")
  
  #only run fitting if output not saved already
  if (!file.exists(file))
  {
    
    require(fitclock)
    subjdata <- adply(Sys.glob(paste(datapath,s,"MEG/*csv",sep="/")),1,.fun=function(x){read.csv(x,header=T)})
    #setup subject
    subData <- clockdata_subject(subject_ID=as.character(s), dataset=subjdata)
    subDiffData <- clockdata_subject(subject_ID=as.character(s), dataset=subjdata)
    
    #setup model to fit RT
    RT_model <- clock_model(fit_RT_diffs=FALSE)
    RT_model$add_params(
      meanRT(max_value=4000),
      autocorrPrevRT(),
      goForGold(),
      go(),
      noGo(),
      meanSlowFast(),
      exploreBeta()
    )
    
    #setup model to fit RT differences
    expDiff_model <- clock_model(fit_RT_diffs=TRUE)
    expDiff_model$add_params(
      meanRT(max_value=4000),
      autocorrPrevRT(),
      goForGold(),
      go(),
      noGo(),
      meanSlowFast(),
      exploreBeta()
    )
    
    #tell model which dataset to use
    RT_model$set_data(subData)
    expDiff_model$set_data(subDiffData)
    
    incrFit <- RT_model$incremental_fit(njobs=6)
    
    #fit full model, using 5 random starts and choosing the best fit
    fitRT <- RT_model$fit(random_starts=5)
    fitDiffRT <- expDiff_model$fit(random_starts=5)
    
    #save data
    save(file=file,fitRT,fitDiffRT,incrFit,s)
  }
  return(file)
}

writeEveFromModel = function(rdata) {
  load(rdata)
  nametemplate <- sub('MEG_','',sub('_tc_[1-8].csv','',Sys.glob(paste(datapath,s,"MEG/*csv",sep="/"))[1]))
  for(x in c('rpe','Reward','ev')){
   for(tr in 1:dim(fitRT[[x]])[1] ) {
    write.table(fitRT[[x]][tr,],file=paste0(nametemplate,"_",tr,"_",x,".eve"),col.names=F,row.names=F )
   }
  }
}
