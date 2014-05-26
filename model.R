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
}

#code for plotting
#open pdf
pdf("MEG_Behav_output.pdf", width=8, height=11)

for (s in Subj) 
{
  file=paste("subjs/",s,"_fitdata.Rdata",sep="")
  
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
  
  #transform exploration parameter and RT swing
  epsilon_beta <- as.vector(t(laply(fitDiffRT$pred_contrib[1:nrow(fitDiffRT$RTobs)],"[","p_epsilonBeta",1:ncol(fitRT$RTobs))))  
  epsilon_beta[is.na(epsilon_beta)] <- 0 #take out nans
  epsilon_beta <- (epsilon_beta-mean(epsilon_beta))/sd(epsilon_beta);
  rt_swing <- as.vector(t(fitDiffRT$RTobs));
  rt_swing[is.na(rt_swing)] <- 0
  rt_swing <- (rt_swing-mean(rt_swing))/sd(rt_swing);
  corr <- cor(epsilon_beta,rt_swing,use='complete.obs')
  
  DiffRTFitDf <- data.frame(
    run=rep(1:nrow(fitDiffRT$RTobs), each=ncol(fitDiffRT$RTobs)),
    trialN=1:ncol(fitRT$RTobs),
    emo_condition=rep(fitDiffRT$run_condition, each=ncol(fitDiffRT$RTobs)),
    rew_function=rep(fitDiffRT$rew_function, each=ncol(fitDiffRT$RTobs)),
    RT=c(as.vector(t(fitDiffRT$RTobs)),as.vector(t(laply(fitDiffRT$pred_contrib[1:nrow(fitDiffRT$RTobs)],"[","p_epsilonBeta",1:ncol(fitRT$RTobs))))),
    RT_z=c(as.vector(rt_swing),as.vector(epsilon_beta)),
    rt_type=rep(c("RT Diff", "Exploration"), each=length(fitRT$RTobs))
  )  
  
  #plot PE and reward
  RewardPE_Fig <- ggplot(RTFitDf, aes(trialN,magnitude,colour=mag_type))
  RewardPE_Fig <- RewardPE_Fig+layer(geom="line") + facet_grid(rew_function ~ emo_condition)
  title = paste(s,' Reward vs. PE')
  RewardPE_Fig <- RewardPE_Fig + ggtitle (title) + theme (legend.title = element_blank()) + 
    xlab("Trial Number") +ylab("Magnitude")
  print(RewardPE_Fig)
  
  #plot RT
  RTobsVRTpred_Fig <- ggplot(RTFitDf, aes(trialN,rt,colour=rt_type))
  RTobsVRTpred_Fig <- RTobsVRTpred_Fig+layer(geom="line") + facet_grid(rew_function ~ emo_condition)
  title = paste(s,' Predicted RT vs. Observed RT')
  RTobsVRTpred_Fig <- RTobsVRTpred_Fig + ggtitle (title) + theme (legend.title = element_blank()) +
    xlab("Trial Number") +ylab("RT (ms)")
  print(RTobsVRTpred_Fig)
  
  #plot exploration
  RTDiffVExp_Fig <- ggplot(DiffRTFitDf, aes(trialN,RT_z,colour=rt_type))
  RTDiffVExp_Fig <- RTDiffVExp_Fig+layer(geom="line") + facet_grid(rew_function ~ emo_condition)
  title = paste(s,' RT Swing vs. Exploration Parameter','  ','Correlation = ', sprintf("%.4f",corr))
  RTDiffVExp_Fig <- RTDiffVExp_Fig + ggtitle (title) + theme (legend.title = element_blank()) + 
    xlab("Trial Number") +ylab("z score")
  print(RTDiffVExp_Fig)
  
}
dev.off()


