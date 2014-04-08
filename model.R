# install if not installed
if (!require(fitclock)) { 
  install.packages(c("devtools",'doMC','survival','Hmisc'));
  install_github("fitclock", "LabNeuroCogDevel", args="--byte-compile");
  require(fitclock)
}

#subjdata <- read.csv('11243_20140213_1.csv',header=T)
subjdata <- adply(Sys.glob('11243_20140213*csv'),1,.fun=function(x){read.csv(x,header=T)})
#setup subject
subj11243_20140213 <- clockdata_subject(subject_ID="11243_20140213", dataset=subjdata)

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
expDiff_model$set_data(subj11243_20140213)

# #test the incremental contribution of each parameter to AIC (fit)
# incr_fit <- expDiff_model$incremental_fit(njobs=6)
# 
# #vector of AIC values
# AICs<-sapply(incr_fit$incremental_fits, "[[", "AIC")

#fit full model, using 5 random starts and choosing the best fit
f <- expDiff_model$fit(random_starts=5)


