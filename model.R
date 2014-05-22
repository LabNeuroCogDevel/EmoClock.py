# install if not installed
if (!require(fitclock)) { 
  install.packages(c("devtools",'doMC','survival','Hmisc','colorspace','ggplot2'));
  library(devtools)

  install_github("fitclock", "LabNeuroCogDevel", args="--byte-compile");
  require(fitclock)
}

library(ggplot2)
library(plyr)

#list of subjects to fit
Subj <- c(10637, 10997, 11243, 11246, 11255, 11258, 11262, 11263)

#loop through subjects and fit
for (s in Subj) 
	{
  #setup file name
  file=paste("subjs/",s,"_fitdata.Rdata",sep="")
  
  #only run fitting if output not saved already
  if (!file.exists(file))
    {
  
	  subjdata <- adply(Sys.glob(paste("/Volumes/T800/Multimodal/Clock",s,"MEG/*csv",sep="/")),1,.fun=function(x){read.csv(x,header=T)})
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

	  #fit full model, using 5 random starts and choosing the best fit
	  fitRT <- RT_model$fit(random_starts=5)
	  fitDiffRT <- expDiff_model$fit(random_starts=5)
	
	  #save data
	  save(file=file,fitRT,fitDiffRT,s)
    }
  
  #code for plotting
  
  #construct dataframe from fit object
  load(file)
  
  RTFitDf <- data.frame(
    run=rep(1:nrow(fitRT$RTobs), each=ncol(fitRT$RTobs)),
    trialN=1:ncol(fitRT$RTobs),
    emo_condition=rep(fitRT$run_condition, each=ncol(fitRT$RTobs)),
    rew_function=rep(fitRT$rew_function, each=ncol(fitRT$RTobs)),
    magnitude=c(as.vector(t(fitRT$Reward)),as.vector(t(fitRT$rpe))),
    mag_type=rep(c("Reward", "PE"), each=length(fitRT$RTobs)),
    rt=c(as.vector(t(fitRT$RTraw)), as.vector(t(fitRT$RTpred))),
    rt_type=rep(c("observed", "predicted"), each=length(fitRT$RTobs))
  )
  
  DiffRTFitDf <- data.frame(
    run=rep(1:nrow(fitDiffRT$RTobs), each=ncol(fitDiffRT$RTobs)),
    trialN=1:ncol(fitRT$RTobs),
    emo_condition=rep(fitDiffRT$run_condition, each=ncol(fitDiffRT$RTobs)),
    rew_function=rep(fitDiffRT$rew_function, each=ncol(fitDiffRT$RTobs)),
    RT=c(as.vector(t(fitDiffRT$RTobs)),as.vector(t(laply(fitDiffRT$pred_contrib[1:8],"[","p_epsilonBeta",1:ncol(fitRT$RTobs))))),
    rt_type=rep(c("RT Diff", "Exploration"), each=length(fitRT$RTobs))
  )
  
  #pdf("file.pdf", width=8, height=11)
  RewardPE_Fig <- ggplot(RTFitDf, aes(trialN,magnitude,colour=mag_type))
  RewardPE_Fig <- RewardPE_Fig+layer(geom="line") + facet_grid(rew_function ~ emo_condition)
  print(RewardPE_Fig)
  
  RTobsVRTpred_Fig <- ggplot(RTFitDf, aes(trialN,rt,colour=rt_type))
  RTobsVRTpred_Fig <- RTobsVRTpred_Fig+layer(geom="line") + facet_grid(rew_function ~ emo_condition)
  print(RTobsVRTpred_Fig)
  
  RTDiffVExp_Fig <- ggplot(DiffRTFitDf, aes(trialN,RT,colour=rt_type))
  RTDiffVExp_Fig <- RTDiffVExp_Fig+layer(geom="line") + facet_grid(rew_function ~ emo_condition)
  print(RTDiffVExp_Fig)
  
  #print(qplot(,data,data=D,color=type,geom="line", xlab="Trial Number", ylab="Magnitude", main=s)) 
  #dev.off()
}
