rm(list = ls()) # to clean the workspace

library(dplyr)    # to manipulate data
library(reshape2) # to transform data
library(ggplot2)  # for nice looking plots
library(tidyverse)
library(data.table)
library(formattable)
library(tidyr)
library(RColorBrewer)

# Call model setup functions
# To-do: Move into package eventually
source("R/input_parameter_functions.R")
source("R/model_setup_functions.R")
source("R/ICER_functions.R")

# Load parameters
source("Analysis/00_load_parameters.R")

# Load DSA parameters
################
### Overdose ###
################
# DSA data
df_dsa_overdose <- read.csv(file = "data/DSA/overdose.csv", row.names = 1, header = TRUE)
df_dsa_fentanyl <- read.csv(file = "data/DSA/fentanyl.csv", row.names = 1, header = TRUE)

# Load posterior
load(file = "outputs/Calibration/summary_posterior.RData")

## Fatal overdose ##
# Witnessed OD
v_dsa_witness_low <- unlist(df_posterior_summ["p_witness", "2.5%"])
v_dsa_witness_high <- unlist(df_posterior_summ["p_witness", "97.5%"])
names(v_dsa_witness_low) <- c("p_witness")
names(v_dsa_witness_high) <- c("p_witness")

# Naloxone prevalence
v_dsa_NX_prob_low <- unlist(df_dsa_overdose["low", "p_NX_used"])
v_dsa_NX_prob_high <- unlist(df_dsa_overdose["high", "p_NX_used"])
names(v_dsa_NX_prob_low) <- c("p_NX_used")
names(v_dsa_NX_prob_high) <- c("p_NX_used")

# Naloxone effectiveness
v_dsa_NX_success_low <- unlist(df_dsa_overdose["low", "p_NX_success"])
v_dsa_NX_success_high <- unlist(df_dsa_overdose["high", "p_NX_success"])
names(v_dsa_NX_success_low) <- c("p_NX_success")
names(v_dsa_NX_success_high) <- c("p_NX_success")

# Fatal overdose risk
v_dsa_fatal_OD_low <- unlist(df_posterior_summ["n_fatal_OD", "2.5%"])
v_dsa_fatal_OD_high <- unlist(df_posterior_summ["n_fatal_OD", "97.5%"])
names(v_dsa_fatal_OD_low) <- c("n_fatal_OD")
names(v_dsa_fatal_OD_high) <- c("n_fatal_OD")

## Non-fatal overdose ##
# Fentanyl prevalence
# SET FROM LOWEST AND HIGHEST % PROVINCES
v_dsa_fent_exp_2020_low <- unlist(df_dsa_fentanyl["low", "pe"])
v_dsa_fent_exp_2020_high <- unlist(df_dsa_fentanyl["high", "pe"])
names(v_dsa_fent_exp_2020_low) <- c("p_fent_exp_2020")
names(v_dsa_fent_exp_2020_high) <- c("p_fent_exp_2020")

# Fent OD multiplier
v_dsa_fent_OD_mult_low <- unlist(df_posterior_summ["n_fent_OD_mult", "2.5%"])
v_dsa_fent_OD_mult_high <- unlist(df_posterior_summ["n_fent_OD_mult", "97.5%"])
names(v_dsa_fent_OD_mult_low) <- c("n_fent_OD_mult")
names(v_dsa_fent_OD_mult_high) <- c("n_fent_OD_mult")

# Reduction in fentanyl exposure for non-injection v. injection
v_dsa_ni_fent_reduction_low <- unlist(df_dsa_overdose["low", "p_ni_fent_reduction"])
v_dsa_ni_fent_reduction_high <- unlist(df_dsa_overdose["high", "p_ni_fent_reduction"])
names(v_dsa_ni_fent_reduction_low) <- c("p_ni_fent_reduction")
names(v_dsa_ni_fent_reduction_high) <- c("p_ni_fent_reduction")

# BUP OD multiplier
v_dsa_BUP_OD_mult_low <- unlist(df_dsa_overdose["low", "n_BUP_OD_mult"])
v_dsa_BUP_OD_mult_high <- unlist(df_dsa_overdose["high", "n_BUP_OD_mult"])
names(v_dsa_BUP_OD_mult_low)  <- c("n_BUP_OD_mult")
names(v_dsa_BUP_OD_mult_high) <- c("n_BUP_OD_mult")

# MET OD multiplier
v_dsa_MET_OD_mult_low <- unlist(df_dsa_overdose["low", "n_MET_OD_mult"])
v_dsa_MET_OD_mult_high <- unlist(df_dsa_overdose["high", "n_MET_OD_mult"])
names(v_dsa_MET_OD_mult_low)  <- c("n_MET_OD_mult")
names(v_dsa_MET_OD_mult_high) <- c("n_MET_OD_mult")

# REL OD multiplier
v_dsa_REL_OD_mult_low <- unlist(df_dsa_overdose["low", "n_REL_OD_mult"])
v_dsa_REL_OD_mult_high <- unlist(df_dsa_overdose["high", "n_REL_OD_mult"])
names(v_dsa_REL_OD_mult_low)  <- c("n_REL_OD_mult")
names(v_dsa_REL_OD_mult_high) <- c("n_REL_OD_mult")

# INJ OD multiplier
v_dsa_INJ_OD_mult_low <- unlist(df_dsa_overdose["low", "n_INJ_OD_mult"])
v_dsa_INJ_OD_mult_high <- unlist(df_dsa_overdose["high", "n_INJ_OD_mult"])
names(v_dsa_INJ_OD_mult_low)  <- c("n_INJ_OD_mult")
names(v_dsa_INJ_OD_mult_high) <- c("n_INJ_OD_mult")

############################################
#### Deterministic sensitivity analysis ####
############################################
################
### Overdose ###
################
### Overdose fatality ###
#### Witnessed OD ####
# Low
l_outcomes_MET_witness_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_witness_low)
l_outcomes_BUP_witness_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_witness_low)
ICER_witness_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_witness_low_MMS, outcomes_int = l_outcomes_BUP_witness_low_MMS)

# High
l_outcomes_MET_witness_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_witness_high)
l_outcomes_BUP_witness_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_witness_high)
ICER_witness_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_witness_high_MMS, outcomes_int = l_outcomes_BUP_witness_high_MMS)

#### Naloxone prevalence ####
# Low
l_outcomes_MET_NX_prob_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_prob_low)
l_outcomes_BUP_NX_prob_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_prob_low)
ICER_NX_prob_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_NX_prob_low_MMS, outcomes_int = l_outcomes_BUP_NX_prob_low_MMS)

# High
l_outcomes_MET_NX_prob_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_prob_high)
l_outcomes_BUP_NX_prob_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_prob_high)
ICER_NX_prob_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_NX_prob_high_MMS, outcomes_int = l_outcomes_BUP_NX_prob_high_MMS)

#### Naloxone effectiveness ####
# Low
l_outcomes_MET_NX_success_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_success_low)
l_outcomes_BUP_NX_success_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_success_low)
ICER_NX_success_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_NX_success_low_MMS, outcomes_int = l_outcomes_BUP_NX_success_low_MMS)

# High
l_outcomes_MET_NX_success_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_success_high)
l_outcomes_BUP_NX_success_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_NX_success_high)
ICER_NX_success_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_NX_success_high_MMS, outcomes_int = l_outcomes_BUP_NX_success_high_MMS)

#### Fatal overdose risk ####
# Low
l_outcomes_MET_fatal_OD_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fatal_OD_low)
l_outcomes_BUP_fatal_OD_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fatal_OD_low)
ICER_fatal_OD_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_fatal_OD_low_MMS, outcomes_int = l_outcomes_BUP_fatal_OD_low_MMS)

# High
l_outcomes_MET_fatal_OD_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fatal_OD_high)
l_outcomes_BUP_fatal_OD_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fatal_OD_high)
ICER_fatal_OD_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_fatal_OD_high_MMS, outcomes_int = l_outcomes_BUP_fatal_OD_high_MMS)

### Non-fatal overdose ###
#### Fentanyl prevalence ####
# Low
l_outcomes_MET_fent_exp_2020_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_exp_2020_low)
l_outcomes_BUP_fent_exp_2020_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_exp_2020_low)
ICER_fent_exp_2020_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_fent_exp_2020_low_MMS, outcomes_int = l_outcomes_BUP_fent_exp_2020_low_MMS)

# High
l_outcomes_MET_fent_exp_2020_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_exp_2020_high)
l_outcomes_BUP_fent_exp_2020_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_exp_2020_high)
ICER_fent_exp_2020_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_fent_exp_2020_high_MMS, outcomes_int = l_outcomes_BUP_fent_exp_2020_high_MMS)

#### Reduction in fentanyl exposure for non-injection v. injection ####
# Low
l_outcomes_MET_ni_fent_reduction_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_ni_fent_reduction_low)
l_outcomes_BUP_ni_fent_reduction_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_ni_fent_reduction_low)
ICER_ni_fent_reduction_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_ni_fent_reduction_low_MMS, outcomes_int = l_outcomes_BUP_ni_fent_reduction_low_MMS)

# High
l_outcomes_MET_ni_fent_reduction_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_ni_fent_reduction_high)
l_outcomes_BUP_ni_fent_reduction_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_ni_fent_reduction_high)
ICER_ni_fent_reduction_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_ni_fent_reduction_high_MMS, outcomes_int = l_outcomes_BUP_ni_fent_reduction_high_MMS)

#### Fent OD multiplier ####
# Low
l_outcomes_MET_fent_OD_mult_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_OD_mult_low)
l_outcomes_BUP_fent_OD_mult_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_OD_mult_low)
ICER_fent_OD_mult_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_fent_OD_mult_low_MMS, outcomes_int = l_outcomes_BUP_fent_OD_mult_low_MMS)

# High
l_outcomes_MET_fent_OD_mult_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_OD_mult_high)
l_outcomes_BUP_fent_OD_mult_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_fent_OD_mult_high)
ICER_fent_OD_mult_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_fent_OD_mult_high_MMS, outcomes_int = l_outcomes_BUP_fent_OD_mult_high_MMS)

#### BUP OD multiplier ####
# Low
l_outcomes_MET_BUP_OD_mult_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_BUP_OD_mult_low)
l_outcomes_BUP_BUP_OD_mult_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_BUP_OD_mult_low)
ICER_BUP_OD_mult_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_BUP_OD_mult_low_MMS, outcomes_int = l_outcomes_BUP_BUP_OD_mult_low_MMS)

# High
l_outcomes_MET_BUP_OD_mult_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_BUP_OD_mult_high)
l_outcomes_BUP_BUP_OD_mult_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_BUP_OD_mult_high)
ICER_BUP_OD_mult_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_BUP_OD_mult_high_MMS, outcomes_int = l_outcomes_BUP_BUP_OD_mult_high_MMS)

#### MET OD multiplier ####
# Low
l_outcomes_MET_MET_OD_mult_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_MET_OD_mult_low)
l_outcomes_BUP_MET_OD_mult_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_MET_OD_mult_low)
ICER_MET_OD_mult_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_MET_OD_mult_low_MMS, outcomes_int = l_outcomes_BUP_MET_OD_mult_low_MMS)

# High
l_outcomes_MET_MET_OD_mult_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_MET_OD_mult_high)
l_outcomes_BUP_MET_OD_mult_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_MET_OD_mult_high)
ICER_MET_OD_mult_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_MET_OD_mult_high_MMS, outcomes_int = l_outcomes_BUP_MET_OD_mult_high_MMS)

#### REL OD multiplier ####
# Low
l_outcomes_MET_REL_OD_mult_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_REL_OD_mult_low)
l_outcomes_BUP_REL_OD_mult_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_REL_OD_mult_low)
ICER_REL_OD_mult_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_REL_OD_mult_low_MMS, outcomes_int = l_outcomes_BUP_REL_OD_mult_low_MMS)

# High
l_outcomes_MET_REL_OD_mult_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_REL_OD_mult_high)
l_outcomes_BUP_REL_OD_mult_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_REL_OD_mult_high)
ICER_REL_OD_mult_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_REL_OD_mult_high_MMS, outcomes_int = l_outcomes_BUP_REL_OD_mult_high_MMS)

#### INJ OD multiplier ####
# Low
l_outcomes_MET_INJ_OD_mult_low_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_INJ_OD_mult_low)
l_outcomes_BUP_INJ_OD_mult_low_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_INJ_OD_mult_low)
ICER_INJ_OD_mult_low_MMS <- ICER(outcomes_comp = l_outcomes_MET_INJ_OD_mult_low_MMS, outcomes_int = l_outcomes_BUP_INJ_OD_mult_low_MMS)

# High
l_outcomes_MET_INJ_OD_mult_high_MMS <- outcomes(l_params_all = l_params_MET_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_INJ_OD_mult_high)
l_outcomes_BUP_INJ_OD_mult_high_MMS <- outcomes(l_params_all = l_params_BUP_MMS, v_params_calib = v_calib_post_map, v_params_dsa = v_dsa_INJ_OD_mult_high)
ICER_INJ_OD_mult_high_MMS <- ICER(outcomes_comp = l_outcomes_MET_INJ_OD_mult_high_MMS, outcomes_int = l_outcomes_BUP_INJ_OD_mult_high_MMS)

################
### Overdose ###
################
# Costs
# Non-fatal OD
v_overdose_fent_exp_costs_MMS <- c(ICER_fent_exp_2020_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_fent_exp_2020_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_ni_fent_reduction_costs_MMS <- c(ICER_ni_fent_reduction_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_ni_fent_reduction_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_fent_OD_mult_costs_MMS <- c(ICER_fent_OD_mult_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_fent_OD_mult_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_BUP_OD_mult_costs_MMS <- c(ICER_BUP_OD_mult_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_BUP_OD_mult_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_MET_OD_mult_costs_MMS <- c(ICER_MET_OD_mult_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_MET_OD_mult_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_REL_OD_mult_costs_MMS <- c(ICER_REL_OD_mult_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_REL_OD_mult_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_INJ_OD_mult_costs_MMS <- c(ICER_INJ_OD_mult_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_INJ_OD_mult_high_MMS$df_incremental$n_inc_costs_TOTAL_life)

# Fatal OD
v_overdose_witness_costs_MMS <- c(ICER_witness_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_witness_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_NX_prob_costs_MMS <- c(ICER_NX_prob_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_NX_prob_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_NX_success_costs_MMS <- c(ICER_NX_success_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_NX_success_high_MMS$df_incremental$n_inc_costs_TOTAL_life)
v_overdose_fatal_OD_costs_MMS <- c(ICER_fatal_OD_low_MMS$df_incremental$n_inc_costs_TOTAL_life, ICER_fatal_OD_high_MMS$df_incremental$n_inc_costs_TOTAL_life)

m_overdose_costs_MMS <- rbind(v_overdose_fent_exp_costs_MMS, v_overdose_ni_fent_reduction_costs_MMS, v_overdose_fent_OD_mult_costs_MMS,
                              v_overdose_BUP_OD_mult_costs_MMS, v_overdose_MET_OD_mult_costs_MMS, v_overdose_REL_OD_mult_costs_MMS,
                              v_overdose_INJ_OD_mult_costs_MMS, v_overdose_witness_costs_MMS, v_overdose_NX_prob_costs_MMS, 
                              v_overdose_NX_success_costs_MMS, v_overdose_fatal_OD_costs_MMS)

df_overdose_costs_MMS <- as.data.frame(m_overdose_costs_MMS)
colnames(df_overdose_costs_MMS) <- c("Lower", "Upper")
df_overdose_costs_MMS <- as_data_frame(df_overdose_costs_MMS) %>%
  add_column(var_name = c("Fentanyl prevalence", "Fentanyl reduction for non-injection", "Fentanyl overdose multiplier", "First month overdose multiplier (BNX)", "First month overdose multiplier (MET)", 
                          "First month overdose multiplier (opioid use)", "Overdose multiplier (injection)", "Probability overdose witnessed", "Probability receive NX", "Probability NX success", "Fatal overdose rate"))

# Save outputs
## As .RData ##
save(df_overdose_costs_MMS, 
     file = "outputs/DSA/Modified Model Specification/df_overdose_costs_MMS.RData")

# QALYs
# Non-fatal OD
v_overdose_fent_exp_qalys_MMS <- c(ICER_fent_exp_2020_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_fent_exp_2020_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_ni_fent_reduction_qalys_MMS <- c(ICER_ni_fent_reduction_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_ni_fent_reduction_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_fent_OD_mult_qalys_MMS <- c(ICER_fent_OD_mult_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_fent_OD_mult_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_BUP_OD_mult_qalys_MMS <- c(ICER_BUP_OD_mult_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_BUP_OD_mult_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_MET_OD_mult_qalys_MMS <- c(ICER_MET_OD_mult_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_MET_OD_mult_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_REL_OD_mult_qalys_MMS <- c(ICER_REL_OD_mult_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_REL_OD_mult_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_INJ_OD_mult_qalys_MMS <- c(ICER_INJ_OD_mult_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_INJ_OD_mult_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)

# Fatal OD
v_overdose_witness_qalys_MMS <- c(ICER_witness_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_witness_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_NX_prob_qalys_MMS <- c(ICER_NX_prob_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_NX_prob_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_NX_success_qalys_MMS <- c(ICER_NX_success_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_NX_success_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)
v_overdose_fatal_OD_qalys_MMS <- c(ICER_fatal_OD_low_MMS$df_incremental$n_inc_qalys_TOTAL_life, ICER_fatal_OD_high_MMS$df_incremental$n_inc_qalys_TOTAL_life)

m_overdose_qalys_MMS <- rbind(v_overdose_fent_exp_qalys_MMS, v_overdose_ni_fent_reduction_qalys_MMS, v_overdose_fent_OD_mult_qalys_MMS,
                              v_overdose_BUP_OD_mult_qalys_MMS, v_overdose_MET_OD_mult_qalys_MMS, v_overdose_REL_OD_mult_qalys_MMS,
                              v_overdose_INJ_OD_mult_qalys_MMS, v_overdose_witness_qalys_MMS, v_overdose_NX_prob_qalys_MMS, 
                              v_overdose_NX_success_qalys_MMS, v_overdose_fatal_OD_qalys_MMS)

df_overdose_qalys_MMS <- as.data.frame(m_overdose_qalys_MMS)
colnames(df_overdose_qalys_MMS) <- c("Lower", "Upper")
df_overdose_qalys_MMS <- as_data_frame(df_overdose_qalys_MMS) %>% 
  add_column(var_name = c("Fentanyl prevalence", "Fentanyl reduction for non-injection", "Fentanyl overdose multiplier", "First month overdose multiplier (BNX)", "First month overdose multiplier (MET)", 
                          "First month overdose multiplier (opioid use)", "Overdose multiplier (injection)", "Probability overdose witnessed", "Probability receive NX", "Probability NX success", "Fatal overdose rate"))

# Save outputs
## As .RData ##
save(df_overdose_qalys_MMS, 
     file = "outputs/DSA/Modified Model Specification/df_overdose_qalys_MMS.RData")
