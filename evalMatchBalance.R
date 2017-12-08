require(MatchIt)
require(dplyr)


calcPercentDiff <- function(matchit_obj, treatment, col_names, dta) {
  ## Takes a `matchit` object and evalutes balance using Percent Difference.
  ## - treatment is the name of the column for treatment var
  ## - orig_data is the data frame that was used in matchit
  ## - column names is a vector of strings giving names of variables to balance.

  treatment <- get_matches(matchit_obj, dta)[ , treatment] == 1
  conf <- get_matches(matchit_obj, dta)[ , col_names]
  wts <- get_matches(matchit_obj, dta)[ , "weight"]
  tot <- sum(wts)

  ## Removing NAs
  treatment <- na.omit(treatment)
  conf <- na.omit(conf)

  treated_pcts <- apply(conf[treatment,]*wts[treatment],2,sum)/tot
  untreated_pcts <- apply(conf[!treatment,]*wts[!treatment],2,sum)/tot

  return(treated_pcts - untreated_pcts)
}

calcSDRatio <- function(matchit_obj, trtname, col_names, dta) {
  ## Takes a `matchit` object and evalutes balance using SD Ratio
  ## - treatment is the name of the column for treatment var
  ## - dta is the data frame that was used in matchit
  ## - column names is a vector of strings giving names of variables to balance.

  matchit_obj$call$data <- dta # Necessary, but I don't get why

  treatment <- match.data(matchit_obj)[ , trtname] == 1
  conf <- match.data(matchit_obj)[ , col_names]
  stdmd <- summary(matchit_obj, standardize=T,
                   addlvariables = dta[,col_names])$sum.matched['Std. Mean Diff.']

  std <- summary(matchit_obj,
                 addlvariables = dta[,col_names])$sum.matched['Mean Diff']

  sdtreat <- std/stdmd
  sdcont <-summary(matchit_obj,
                   addlvariables = dta[,col_names])$sum.matched['SD Control']

  return(sdtreat/sdcont)
}


evalMatchBalance <- function(form, dta, cont_vars, cat_vars,
                             digits = 3, debug=F, ...) {
  ## Given a formula, data frame, and a list of which confounding vars are
  ## categorical or continuous (later could be made automatic), will give a
  ## report on the propensity matching balance.

  if (debug) browser()

  ## Get Matchit Object
  mtch <- matchit(form, data=dta, replace=T, ...)
  trt_char <- as.character(form[2]) # Pulls name of outcome from formula

  ## Standardized mean difference
  stdmd <- summary(mtch, standardize=T,
                   addlvariables = dta[,cont_vars])$sum.matched['Std. Mean Diff.']
  stdmd_vec <- stdmd[,1]
  names(stdmd_vec) <- rownames(stdmd)
  stdmd_imp <- stdmd_vec[(nrow(stdmd)-5):(nrow(stdmd))]

  ## SD Ratio
  sdrat <- calcSDRatio(mtch, trt_char, cont_vars, dta=dta)

  ## We need to pull out just the continuous variables
  sdrat_cont <- sdrat[cont_vars,'Mean Diff']
  names(sdrat_cont) <- cont_vars

  ## Difference in Percentages
  pctdiff <- calcPercentDiff(mtch, treatment = trt_char,
                             col_names = cat_vars, dta=dta)

  return(list("StdMeanDiff" = round(stdmd_imp, digits),
              "SDRatio" = round(sdrat_cont, digits),
              "PercentDiff" = round(pctdiff, digits)))
}
