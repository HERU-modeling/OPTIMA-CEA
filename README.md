# OPTIMA-CEA

[`OPTIMA-CEA`](https://github.com/HERU-modeling/OPTIMA-CEA) provides the necessary code and data to run a semi-Markov cohort model
to evaluate the cost-effectiveness of BNX versus methadone alongside the OPTIMA trial.

# Preliminaries

-   Install
    [RStudio](https://www.rstudio.com/products/rstudio/download/)
-   Install `devtools`

``` r
install.packages("devtools")
```

# R code modules

The R scripts to run the model and conduct the analysis are organized
into two sections:

1.  [R](https://github.com/HERU-modeling/OPTIMA-CEA/tree/main/R)
    contains R functions for core modules.

2.  [Analysis](https://github.com/HERU-modeling/OPTIMA-CEA/tree/main/Analysis)
    contains R scripts to run the primary analyses.
    
# Analysis

All code needed to run analyses from the manuscript is located in:

1.  Main analysis (all results derived from PSA simulations) and manuscript figure 2 code located in '04_PSA.R' 

2.  Deterministic and two-way sensitivity analyses are located in '05_DSA' modules