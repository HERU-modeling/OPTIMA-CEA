# OPTIMA-CEA

[`OPTIMA-CEA`](https://github.com/HERU-modeling/OPTIMA-CEA) provides the necessary code and data to run a semi-Markov cohort model
to evaluate the cost-effectiveness of BNX versus methadone alongside the OPTIMA trial, published in [Enns, Benjamin et al. “Cost-effectiveness of flexible take-home buprenorphine-naloxone versus methadone for treatment of prescription-type opioid use disorder.” Drug and alcohol dependence vol. 247 (2023): 109893.](https://www.sciencedirect.com/science/article/abs/pii/S037687162300131X)

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

1.  [04_PSA.R](https://github.com/HERU-modeling/OPTIMA-CEA/blob/main/Analysis/04_PSA.R) Main analysis (all results derived from PSA simulations) and manuscript Figure 2 code 

2.  Deterministic and two-way sensitivity analyses are located in '05_DSA' modules
