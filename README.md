# Function for Evaluating MatchIt Object Balance

Running this function will report back balance in the form of:

1. The **difference in means** for continuous variables.
2. The **ratio of standard deviations** for continuous variables.
3. The **difference in percentages across groups** for categorical variables.

## How to Use

For this example the data is in a data frame called `nlsy`.

### Define which variables are categorical and continuous

(Maybe a future version can do this automatically)

```{r}
cont_vars <- c("afqt", "age", "lnfinc_a0", "brthwt", "momage", "preterm")
cat_vars <- c("pr0", "college", "ltcoll", "hs", "female","hispanic", "white",
              "black", "b_marr", "rmomwk", "brorddum")
```

### Run the function

Giving the formula that you want to use to match, the original data frame, and the variable lists.

```{r}
evalMatchBalance(first ~ pr0 + lnfinc_a0 + afqt + I(as.integer(momed)>2) + 
                  rmomwk + age + brorddum + hispanic + black +
                  preterm + brthwt + momage, dta = nlsy,
          cont_vars = cont_vars, cat_vars = cat_vars)
```

Will provide the following result:

```
$StdMeanDiff
     afqt.1       age.1 lnfinc_a0.1    brthwt.1    momage.1   preterm.1 
      0.049       0.047       0.044      -0.010      -0.013       0.067 

$SDRatio
     afqt       age lnfinc_a0    brthwt    momage   preterm 
    1.049     0.972     1.006     0.993     0.942     1.119 

$PercentDiff
     pr0  college   ltcoll       hs   female hispanic    white    black 
  -0.006    0.011   -0.019    0.023    0.010    0.006   -0.003   -0.002 
  b_marr   rmomwk brorddum 
  -0.017    0.020   -0.001 
```
