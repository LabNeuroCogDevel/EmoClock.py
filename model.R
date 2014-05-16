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
Subj <- c(10997, 11243, 11246, 11255, 11258, 11262, 11263)

#loop through subjects and fit
for (s in Subj) 
	{ 
	subjdata <- adply(Sys.glob(paste("/Volumes/T800/Multimodal/Clock",s,"MEG/*csv",sep="/")),1,.fun=function(x){read.csv(x,header=T)})
	#setup subject
	subData <- clockdata_subject(subject_ID=as.character(s), dataset=subjdata)
	

	#setup model to fit RT
	RT_model <- clock_model()

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
	expDiff_model$set_data(subData)

	#fit full model, using 5 random starts and choosing the best fit
	fitRT <- RT_model$fit(random_starts=5)
	fitDiffRT <- expDiff_model$fit(random_starts=5)
	
	#save data
	save(file=paste("subjs/",s,"_fitdata.Rdata",sep=""),fitRT,fitDiffRT,s)

}
