# install if not installed
if (!require(fitclock)) { 
  install.packages(c("devtools",'doMC','survival','Hmisc','colorspace','ggplot2'));
  library(devtools)

  install_github("fitclock", "LabNeuroCogDevel", args="--byte-compile");
  require(fitclock)
}

library(ggplot2)
library(plyr)

#subjdata <- read.csv('11243_20140213_1.csv',header=T)
subjdata <- adply(Sys.glob('subjs/10637_20140312/*csv'),1,.fun=function(x){read.csv(x,header=T)})
#setup subject
subj10637 <- clockdata_subject(subject_ID="10637", dataset=subjdata)

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
RT_model$set_data(subj10637)
expDiff_model$set_data(subj10637)

# #test the incremental contribution of each parameter to AIC (fit)
# incr_fit <- expDiff_model$incremental_fit(njobs=6)
# 
# #vector of AIC values
# AICs<-sapply(incr_fit$incremental_fits, "[[", "AIC")

#fit full model, using 5 random starts and choosing the best fit
fitRT <- RT_model$fit(random_starts=5)
fitDiffRT <- expDiff_model$fit(random_starts=5)


