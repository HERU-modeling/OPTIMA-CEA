#' Load mortality data
#'
#' \code{load_mort_data} is used to load age-specific mortality from .csv file 
#' into vector.
#'
#' @param file String with the location and name of the file with mortality 
#' data.
#' @return 
#' A vector with mortality by age.
#' @export
load_mort_params <- function(file.mort = NULL, n_male){
  df_lt_can_2018 <- read.csv(file = file.mort)
  v_r_mort_by_age_male <- df_lt_can_2018 %>% select(Male) %>% as.matrix()
  v_r_mort_by_age_female <- df_lt_can_2018 %>% select(Female) %>% as.matrix()
  v_r_mort_by_age <- (v_r_mort_by_age_male * n_male) + (v_r_mort_by_age_female * (1 - n_male)) # weighted mortality
  return(v_r_mort_by_age)
}

#' Load all parameters
#'
#' \code{load_all_params} loads all parameters for the decision model from multiple sources and creates a list.
#'
#' @param file.init String with the location and name of the file with initial set of parameters
#' @param file.init_dist String with the location and name of the file with initial distributions
#' @param file.mort String with the location and name of the file with mortality data
#' @param file.death_hr String with the location and name of death hazard ratios
#' @param file.frailty String with the location and name of the file with frailty estimates for subsequent episodes in health states
#' @param file.weibull_scale String with the location and name of the file with weibull scale
#' @param file.weibull_shape String with the location and name of the file with weibull shape
#' @param file.unconditional String with the location and name of the file with empirical destination states
#' @param file.overdose String with the location and name of the file with overdose/fentanyl-related parameters
#' @param file.fentanyl String with the location and name of the file with fentanyl exposure parameters
#' @param file.naloxone String with the location and name of the file with naloxone parameters
#' @param file.hiv String with the location and name of the file with HIV seroconversion probabilities
#' @param file.hcv String with the location and name of the file with HCV seroconversion probabilities
#' @param file.costs String with the location and name of the file with costs (excluding crime costs)
#' @param file.crime_costs String with the location and name of the file with age-specific crime costs
#' @param file.qalys String with the location and name of the file with HRQoL weights
#' 
#' @return 
#' A list of all parameters used for the decision model.
#' @export
load_all_params <- function(file.init = NULL,
                            file.init_dist = NULL,
                            file.mort = NULL,
                            file.death_hr = NULL,
                            file.frailty = NULL,
                            file.weibull = NULL,
                            file.unconditional = NULL,
                            file.overdose = NULL,
                            file.fentanyl = NULL,
                            file.naloxone = NULL,
                            file.hiv = NULL,
                            file.hcv = NULL,
                            file.costs = NULL,
                            file.crime_costs = NULL,
                            file.qalys = NULL){ # User defined
    
  #Load files of all baseline model parameters
  df_init_params <- read.csv(file = file.init, row.names = 1, header = TRUE) # Initial parameter values
  df_init_dist <- read.csv(file = file.init_dist, row.names = 1, header = TRUE) # Initial parameter values
  df_death_hr <- read.csv(file = file.death_hr, row.names = 1, header = TRUE) # Mortality hazard ratios
  df_frailty <- read.csv(file = file.frailty, row.names = 1, header = TRUE) # Episode frailty params
  df_weibull <- read.csv(file = file.weibull, row.names = 1, header = TRUE) # Weibull params
  df_UP <- read.csv(file = file.unconditional, row.names = 1, header = TRUE) # Unconditional transition probs
  df_overdose <- read.csv(file = file.overdose, row.names = 1, header = TRUE) # Overdose-fentanyl parameters
  df_fentanyl <- read.csv(file = file.fentanyl, row.names = 1, header = TRUE) # Fentanyl exposure parameters
  df_naloxone <- read.csv(file = file.naloxone, row.names = 1, header = TRUE) # Time-varying naloxone parameters for calibration
  df_hiv <- read.csv(file = file.hiv, row.names = 1, header = TRUE) # HIV seroconversion probs
  df_hcv <- read.csv(file = file.hcv, row.names = 1, header = TRUE) # HCV seroconversion probs
  df_costs <- read.csv(file = file.costs, row.names = 1, header = TRUE) # All costs excluding crime
  df_crime_costs <- read.csv(file = file.crime_costs, row.names = 1, header = TRUE) # Crime costs
  df_qalys <- read.csv(file = file.qalys, row.names = 1, header = TRUE) # QALYs
  
  l_params_all <- list(
    
    #### Initial parameters ####
    
    n_age_init = df_init_params["pe", "age_init"], # age at baseline
    n_age_max = df_init_params["pe", "age_max"], # maximum age of follow up
    n_per = df_init_params["pe", "period_yr"], # periods per year (e.g. 12-months)
    n_discount = df_init_params["pe", "discount"], # discount rate
    n_cali_per = df_init_params["pe", "cali_per"], # number of calibration periods
    n_male = df_init_params["pe", "male_prop"], # % male
    n_INJ = df_init_params["pe", "INJ_prop"], # % injection
    #Injection
    n_HIV_INJ = df_init_params["pe", "HIV_prop_INJ"], # % of HIV-positive individuals
    n_HCV_INJ = df_init_params["pe", "HCV_prop_INJ"], # % of HCV-positive individuals
    n_COI_INJ = df_init_params["pe", "COI_prop_INJ"], # % of co-infected individuals
    # Non-injection
    n_HIV_NI = df_init_params["pe", "HIV_prop_NI"], # % of HIV-positive individuals
    n_HCV_NI = df_init_params["pe", "HCV_prop_NI"], # % of HCV-positive individuals
    n_COI_NI = df_init_params["pe", "COI_prop_NI"], # % of co-infected individuals
    
    n_HIV_ART = df_init_params["pe", "ART_prop"], # % of HIV-positive on-ART (used to calculate costs)
    n_HCV_DAA = df_init_params["pe", "DAA_prop"], # % of HIV-positive on-ART (used to calculate costs)
    
    #### Initial state distribution ####
    
    v_init_dist = as.vector(df_init_dist["pe", ]),
    
    #### Mortality ####
    
    v_r_mort_by_age = load_mort_params(file = file.mort, n_male = df_init_params["pe", "male_prop"]), # vector of age-specific mortality
    
    #### Hazard ratios for death probability ####
    # Non-injection
    hr_BUP_NI  = df_death_hr["pe", "TX"],
    hr_BUPC_NI = df_death_hr["pe", "TX"],
    hr_MET_NI  = df_death_hr["pe", "TX"],
    hr_METC_NI = df_death_hr["pe", "TX"],
    hr_REL_NI  = df_death_hr["pe", "REL"],
    hr_ODN_NI  = df_death_hr["pe", "REL"],
    hr_ABS_NI  = df_death_hr["pe", "ABS"],
    hr_HIV_NI  = df_death_hr["pe", "HIV"],
    hr_HCV_NI  = df_death_hr["pe", "HCV"],
    hr_COI_NI  = df_death_hr["pe", "COI"],
    
    # Injection
    hr_BUP_INJ  = df_death_hr["pe", "TX"], 
    hr_BUPC_INJ = df_death_hr["pe", "TX"], 
    hr_MET_INJ  = df_death_hr["pe", "TX"], 
    hr_METC_INJ = df_death_hr["pe", "TX"], 
    hr_REL_INJ  = df_death_hr["pe", "REL"],
    hr_ODN_INJ  = df_death_hr["pe", "REL"],
    hr_ABS_INJ  = df_death_hr["pe", "ABS"],
    hr_HIV_INJ  = df_death_hr["pe", "HIV"],
    hr_HCV_INJ  = df_death_hr["pe", "HCV"],
    hr_COI_INJ  = df_death_hr["pe", "COI"],
    
    #### Frailty estimates for successive episodes, injection vs. non-injection, concurrent opioid use ####
    # ***NEW ESTIMATES*** #
    # Episodes
    p_frailty_BUP_1 = 1,
    p_frailty_BUP_2 = df_frailty["pe", "BUP_2"],
    p_frailty_BUP_3 = df_frailty["pe", "BUP_3"],
    p_frailty_MET_1 = 1,
    p_frailty_MET_2 = df_frailty["pe", "MET_2"],
    p_frailty_MET_3 = df_frailty["pe", "MET_3"],
    p_frailty_REL_1 = 1,
    p_frailty_REL_2 = df_frailty["pe", "REL_2"],
    p_frailty_REL_3 = df_frailty["pe", "REL_3"],
    p_frailty_ABS_1 = 1,
    p_frailty_ABS_2 = df_frailty["pe", "ABS_2"],
    p_frailty_ABS_3 = df_frailty["pe", "ABS_3"],
    
    # Injection vs. non-injection
    p_frailty_BUP_INJ = df_frailty["pe", "BUP_INJ"],
    p_frailty_MET_INJ = df_frailty["pe", "MET_INJ"],
    p_frailty_REL_INJ = df_frailty["pe", "REL_INJ"],
    p_frailty_ABS_INJ = df_frailty["pe", "ABS_INJ"],
    
    # Concurrent opioid use
    p_frailty_BUPC = df_frailty["pe", "BUPC"],
    p_frailty_METC = df_frailty["pe", "METC"],
    
    #### Load weibull parameters ####
    # From OPTIMA trial
    # Shape
    p_weibull_shape_BUP = df_weibull["pe", "BUP_shape_1"],
    p_weibull_shape_MET = df_weibull["pe", "MET_shape_1"],
    p_weibull_shape_REL = df_weibull["pe", "REL_shape_1"],
    p_weibull_shape_ABS = df_weibull["pe", "ABS_shape_1"],
    
    # scale
    p_weibull_scale_BUP = df_weibull["pe", "BUP_scale_1"],
    p_weibull_scale_MET = df_weibull["pe", "MET_scale_1"],
    p_weibull_scale_REL = df_weibull["pe", "REL_scale_1"],
    p_weibull_scale_ABS = df_weibull["pe", "ABS_scale_1"],

    #### Unconditional transition probabilities ####
    # Non-Injection
    # From BUP
    p_BUP_BUPC_NI  = df_UP["BUP_NI", "BUPC_NI"],
    p_BUP_MET_NI  = df_UP["BUP_NI", "MET_NI"],
    p_BUP_METC_NI  = df_UP["BUP_NI", "METC_NI"],
    p_BUP_ABS_NI   = df_UP["BUP_NI", "ABS_NI"],
    p_BUP_REL_NI  = df_UP["BUP_NI", "REL_NI"],
    # From BUPC
    p_BUPC_BUP_NI  = df_UP["BUPC_NI", "BUP_NI"],
    p_BUPC_MET_NI  = df_UP["BUPC_NI", "MET_NI"],
    p_BUPC_METC_NI  = df_UP["BUPC_NI", "METC_NI"],
    p_BUPC_ABS_NI   = df_UP["BUPC_NI", "ABS_NI"],
    p_BUPC_REL_NI  = df_UP["BUPC_NI", "REL_NI"],
    # From MET
    p_MET_METC_NI  = df_UP["MET_NI", "METC_NI"],
    p_MET_BUP_NI  = df_UP["MET_NI", "BUP_NI"],
    p_MET_BUPC_NI  = df_UP["MET_NI", "BUPC_NI"],
    p_MET_ABS_NI   = df_UP["MET_NI", "ABS_NI"],
    p_MET_REL_NI  = df_UP["MET_NI", "REL_NI"],
    # From METC
    p_METC_MET_NI  = df_UP["METC_NI", "MET_NI"],
    p_METC_BUP_NI  = df_UP["METC_NI", "BUP_NI"],
    p_METC_BUPC_NI  = df_UP["METC_NI", "BUPC_NI"],
    p_METC_ABS_NI   = df_UP["METC_NI", "ABS_NI"],
    p_METC_REL_NI  = df_UP["METC_NI", "REL_NI"],
    # From ABS
    p_ABS_REL_NI = df_UP["ABS_NI", "REL_NI"],
    p_ABS_MET_NI = df_UP["ABS_NI", "MET_NI"],
    p_ABS_METC_NI = df_UP["ABS_NI", "METC_NI"],
    p_ABS_BUP_NI = df_UP["ABS_NI", "BUP_NI"],
    p_ABS_BUPC_NI = df_UP["ABS_NI", "BUPC_NI"],
    # From REL
    p_REL_MET_NI  = df_UP["REL_NI", "MET_NI"],
    p_REL_METC_NI  = df_UP["REL_NI", "METC_NI"],
    p_REL_BUP_NI  = df_UP["REL_NI", "BUP_NI"],
    p_REL_BUPC_NI  = df_UP["REL_NI", "BUPC_NI"],
    p_REL_ABS_NI   = df_UP["REL_NI", "ABS_NI"],
    # From OD
    p_ODN_MET_NI  = df_UP["ODN_NI", "MET_NI"],
    p_ODN_METC_NI  = df_UP["ODN_NI", "METC_NI"],
    p_ODN_BUP_NI  = df_UP["ODN_NI", "BUP_NI"],
    p_ODN_BUPC_NI  = df_UP["ODN_NI", "BUPC_NI"],
    p_ODN_ABS_NI  = df_UP["ODN_NI", "ABS_NI"],
    p_ODN_REL_NI  = df_UP["ODN_NI", "REL_NI"],

    # Inj
    # From BUP & BUPC
    p_BUP_BUPC_INJ  = df_UP["BUP_INJ", "BUPC_INJ"],
    p_BUP_MET_INJ  = df_UP["BUP_INJ", "MET_INJ"],
    p_BUP_METC_INJ  = df_UP["BUP_INJ", "METC_INJ"],
    p_BUP_ABS_INJ   = df_UP["BUP_INJ", "ABS_INJ"],
    p_BUP_REL_INJ  = df_UP["BUP_INJ", "REL_INJ"],
    p_BUPC_BUP_INJ  = df_UP["BUPC_INJ", "BUP_INJ"],
    p_BUPC_MET_INJ  = df_UP["BUPC_INJ", "MET_INJ"],
    p_BUPC_METC_INJ  = df_UP["BUPC_INJ", "METC_INJ"],
    p_BUPC_ABS_INJ   = df_UP["BUPC_INJ", "ABS_INJ"],
    p_BUPC_REL_INJ  = df_UP["BUPC_INJ", "REL_INJ"],
    # From MET & METC
    p_MET_METC_INJ  = df_UP["MET_INJ", "METC_INJ"],
    p_MET_BUP_INJ  = df_UP["MET_INJ", "BUP_INJ"],
    p_MET_BUPC_INJ  = df_UP["MET_INJ", "BUPC_INJ"],
    p_MET_ABS_INJ   = df_UP["MET_INJ", "ABS_INJ"],
    p_MET_REL_INJ  = df_UP["MET_INJ", "REL_INJ"],
    p_METC_MET_INJ  = df_UP["METC_INJ", "MET_INJ"],
    p_METC_BUP_INJ  = df_UP["METC_INJ", "BUP_INJ"],
    p_METC_BUPC_INJ  = df_UP["METC_INJ", "BUPC_INJ"],
    p_METC_ABS_INJ   = df_UP["METC_INJ", "ABS_INJ"],
    p_METC_REL_INJ  = df_UP["METC_INJ", "REL_INJ"],
    # From ABS
    p_ABS_REL_INJ = df_UP["ABS_INJ", "REL_INJ"],
    p_ABS_MET_INJ = df_UP["ABS_INJ", "MET_INJ"],
    p_ABS_METC_INJ = df_UP["ABS_INJ", "METC_INJ"],
    p_ABS_BUP_INJ = df_UP["ABS_INJ", "BUP_INJ"],
    p_ABS_BUPC_INJ = df_UP["ABS_INJ", "BUPC_INJ"],
    # From REL
    p_REL_MET_INJ  = df_UP["REL_INJ", "MET_INJ"],
    p_REL_METC_INJ  = df_UP["REL_INJ", "METC_INJ"],
    p_REL_BUP_INJ  = df_UP["REL_INJ", "BUP_INJ"],
    p_REL_BUPC_INJ  = df_UP["REL_INJ", "BUPC_INJ"],
    p_REL_ABS_INJ   = df_UP["REL_INJ", "ABS_INJ"],
    # From OD
    p_ODN_MET_INJ  = df_UP["ODN_INJ", "MET_INJ"],
    p_ODN_METC_INJ  = df_UP["ODN_INJ", "METC_INJ"],
    p_ODN_BUP_INJ  = df_UP["ODN_INJ", "BUP_INJ"],
    p_ODN_BUPC_INJ  = df_UP["ODN_INJ", "BUPC_INJ"],
    p_ODN_ABS_INJ  = df_UP["ODN_INJ", "ABS_INJ"],
    p_ODN_REL_INJ  = df_UP["ODN_INJ", "REL_INJ"],
    
    #### Overdose ####
    # Overdose parameters loaded as rates and converted to probabilities in model
    # Includes additional calibration related parameters
    # Base overdose params
    n_TX_OD = df_overdose["pe", "TX_OD"],
    n_TXC_OD = df_overdose["pe", "TXC_OD"],
    n_REL_OD = df_overdose["pe", "REL_OD"],
    n_ABS_OD = df_overdose["pe", "ABS_OD"],
    
    # Gamma shape parameter (prior)
    n_TX_OD_shape  = df_overdose["shape", "TX_OD"],
    n_TXC_OD_shape = df_overdose["shape", "TXC_OD"],
    n_REL_OD_shape = df_overdose["shape", "REL_OD"],
    n_ABS_OD_shape = df_overdose["shape", "ABS_OD"],
    
    # Gamma scale parameter (prior)
    n_TX_OD_scale  = df_overdose["scale", "TX_OD"],
    n_TXC_OD_scale = df_overdose["scale", "TXC_OD"],
    n_REL_OD_scale = df_overdose["scale", "REL_OD"],
    n_ABS_OD_scale = df_overdose["scale", "ABS_OD"],
    
    # BUP
    n_BUP_OD_mult = df_overdose["pe", "BUP_OD_mult"],
    n_BUP_OD_mult_shape = df_overdose["shape", "BUP_OD_mult"],
    n_BUP_OD_mult_scale = df_overdose["scale", "BUP_OD_mult"],
    
    # MET
    n_MET_OD_mult = df_overdose["pe", "MET_OD_mult"],
    n_MET_OD_mult_shape = df_overdose["shape", "MET_OD_mult"],
    n_MET_OD_mult_scale = df_overdose["scale", "MET_OD_mult"],
    
    # Treatment + concurrent opioid
    n_TXC_OD_mult = df_overdose["pe", "TXC_OD_mult"],
    n_TXC_OD_mult_shape = df_overdose["shape", "TXC_OD_mult"],
    n_TXC_OD_mult_scale = df_overdose["scale", "TXC_OD_mult"],
    
    # Relapse
    n_REL_OD_mult  = df_overdose["pe", "REL_OD_mult"],
    n_REL_OD_mult_shape  = df_overdose["shape", "REL_OD_mult"],
    n_REL_OD_mult_scale  = df_overdose["scale", "REL_OD_mult"],
    
    # Abstinence
    n_ABS_OD_mult  = df_overdose["pe", "ABS_OD_mult"],
    n_ABS_OD_mult_shape  = df_overdose["shape", "ABS_OD_mult"],
    n_ABS_OD_mult_scale  = df_overdose["scale", "ABS_OD_mult"],
    
    # Injection (vs. non-injection)
    n_INJ_OD_mult = df_overdose["pe", "INJ_OD_mult"],
    n_INJ_OD_mult_shape = df_overdose["shape", "INJ_OD_mult"],
    n_INJ_OD_mult_scale = df_overdose["scale", "INJ_OD_mult"],
    
    # Fatal overdose (conditional on overdose)
    n_fatal_OD = df_overdose["pe", "fatal_OD"],
    n_fatal_OD_shape = df_overdose["shape", "fatal_OD"],
    n_fatal_OD_scale = df_overdose["scale", "fatal_OD"],
    
    # Fentanyl
    # Fentanyl rate multiplier
    n_fent_OD_mult = df_overdose["pe", "fent_OD_mult"],
    n_fent_OD_mult_shape = df_overdose["shape", "fent_OD_mult"],
    n_fent_OD_mult_scale = df_overdose["scale", "fent_OD_mult"],
    n_fent_OD_mult_low = df_overdose["low", "fent_OD_mult"],
    n_fent_OD_mult_high = df_overdose["high", "fent_OD_mult"],
    
    # Probability of fentanyl exposure
    p_ni_fent_reduction = df_overdose["pe", "ni_fent_reduction"],
    
    # Overall - Fentanyl prevalence
    p_fent_exp_2017 = df_fentanyl["2017", "pe"],
    p_fent_exp_2018 = df_fentanyl["2018", "pe"],
    p_fent_exp_2019 = df_fentanyl["2019", "pe"],
    p_fent_exp_2020 = df_fentanyl["2020", "pe"],
    
    # Naloxone
    p_witness = df_overdose["pe", "witness_prob"],
    p_witness_low = df_overdose["low", "witness_prob"],
    p_witness_high = df_overdose["high", "witness_prob"],
    
    # Only for 2020 calibration year
    p_witness_covid_adj = df_overdose["pe", "witness_covid_adj"],
    p_witness_covid_adj_low = df_overdose["low", "witness_covid_adj"],
    p_witness_covid_adj_high = df_overdose["high", "witness_covid_adj"],
    
    p_attended = df_overdose["pe", "attended_prob"],
    p_NX_success = df_overdose["pe", "NX_success_prob"],
    
    ### R&R MODIFICATION ###
    p_NX_2017 = df_naloxone["2017", "pe"],
    p_NX_2018 = df_naloxone["2018", "pe"],
    p_NX_2019 = df_naloxone["2019", "pe"],
    p_NX_2020 = df_naloxone["2020", "pe"],
    
    #### Seroconversion ####
    # HIV Seroconversion
    # From negative
    # Non-injection
    p_HIV_NI = df_hiv["pe", "HIV_NI"],
    p_HIV_BUP_NI = df_hiv["pe", "HIV_NI"],
    p_HIV_BUPC_NI = df_hiv["pe", "HIV_NI"],
    p_HIV_MET_NI = df_hiv["pe", "HIV_NI"],
    p_HIV_METC_NI = df_hiv["pe", "HIV_NI"],
    p_HIV_REL_NI = df_hiv["pe", "HIV_NI"],
    p_HIV_ODN_NI = df_hiv["pe", "HIV_NI"],
    p_HIV_ABS_NI = df_hiv["pe", "HIV_NI"],
    
    # Injection
    p_HIV_BUP_INJ = df_hiv["pe", "HIV_TX_INJ"],
    p_HIV_MET_INJ = df_hiv["pe", "HIV_TX_INJ"],
    p_HIV_BUPC_INJ = df_hiv["pe", "HIV_TXC_INJ"],
    p_HIV_METC_INJ = df_hiv["pe", "HIV_TXC_INJ"],
    p_HIV_REL_INJ = df_hiv["pe", "HIV_REL_INJ"],
    p_HIV_ODN_INJ = df_hiv["pe", "HIV_REL_INJ"],
    p_HIV_ABS_INJ = df_hiv["pe", "HIV_NI"],
    
    # Co-infection conditional on HCV
    # Non-injection
    p_HCV_HIV_BUP_NI = df_hiv["pe", "COI_HIV_NI"],
    p_HCV_HIV_BUPC_NI = df_hiv["pe", "COI_HIV_NI"],
    p_HCV_HIV_MET_NI = df_hiv["pe", "COI_HIV_NI"],
    p_HCV_HIV_METC_NI = df_hiv["pe", "COI_HIV_NI"],
    p_HCV_HIV_REL_NI = df_hiv["pe", "COI_HIV_NI"],
    p_HCV_HIV_ODN_NI = df_hiv["pe", "COI_HIV_NI"],
    p_HCV_HIV_ABS_NI = df_hiv["pe", "COI_HIV_NI"],
    
    # Injection
    p_HCV_HIV_BUP_INJ = df_hiv["pe", "COI_HIV_TX_INJ"],
    p_HCV_HIV_MET_INJ = df_hiv["pe", "COI_HIV_TX_INJ"],
    p_HCV_HIV_BUPC_INJ = df_hiv["pe", "COI_HIV_TXC_INJ"],
    p_HCV_HIV_METC_INJ = df_hiv["pe", "COI_HIV_TXC_INJ"],
    p_HCV_HIV_REL_INJ = df_hiv["pe", "COI_HIV_REL_INJ"],
    p_HCV_HIV_ODN_INJ = df_hiv["pe", "COI_HIV_REL_INJ"],
    p_HCV_HIV_ABS_INJ  = df_hiv["pe", "COI_HIV_NI"], # ABS same as non-injection

    # HCV Seroconversion
    # From negative
    # Non-injection
    p_HCV_BUP_NI = df_hcv["pe", "HCV_NI"],
    p_HCV_BUPC_NI = df_hcv["pe", "HCV_NI"],
    p_HCV_MET_NI = df_hcv["pe", "HCV_NI"],
    p_HCV_METC_NI = df_hcv["pe", "HCV_NI"],
    p_HCV_REL_NI = df_hcv["pe", "HCV_NI"],
    p_HCV_ODN_NI = df_hcv["pe", "HCV_NI"],
    p_HCV_ABS_NI = df_hcv["pe", "HCV_NI"],
    
    # Injection
    p_HCV_BUP_INJ = df_hcv["pe", "HCV_TX_INJ"],
    p_HCV_MET_INJ = df_hcv["pe", "HCV_TX_INJ"],
    p_HCV_BUPC_INJ = df_hcv["pe", "HCV_TXC_INJ"],
    p_HCV_METC_INJ = df_hcv["pe", "HCV_TXC_INJ"],
    p_HCV_REL_INJ = df_hcv["pe", "HCV_REL_INJ"],
    p_HCV_ODN_INJ = df_hcv["pe", "HCV_REL_INJ"],
    p_HCV_ABS_INJ = df_hcv["pe", "HCV_NI"], # ABS same as non-injection

    # Co-infection conditional on HIV
    # Non-injection
    p_HIV_HCV_BUP_NI = df_hcv["pe", "COI_HCV_NI"],
    p_HIV_HCV_BUPC_NI = df_hcv["pe", "COI_HCV_NI"],
    p_HIV_HCV_MET_NI = df_hcv["pe", "COI_HCV_NI"],
    p_HIV_HCV_METC_NI = df_hcv["pe", "COI_HCV_NI"],
    p_HIV_HCV_REL_NI = df_hcv["pe", "COI_HCV_NI"],
    p_HIV_HCV_ODN_NI = df_hcv["pe", "COI_HCV_NI"],
    p_HIV_HCV_ABS_NI = df_hcv["pe", "COI_HCV_NI"],
    
    # Injection
    p_HIV_HCV_BUP_INJ = df_hcv["pe", "COI_HCV_TX_INJ"],
    p_HIV_HCV_MET_INJ = df_hcv["pe", "COI_HCV_TX_INJ"],
    p_HIV_HCV_BUPC_INJ = df_hcv["pe", "COI_HCV_TXC_INJ"],
    p_HIV_HCV_METC_INJ = df_hcv["pe", "COI_HCV_TXC_INJ"],
    p_HIV_HCV_REL_INJ = df_hcv["pe", "COI_HCV_REL_INJ"],
    p_HIV_HCV_ODN_INJ = df_hcv["pe", "COI_HCV_REL_INJ"],
    p_HIV_HCV_ABS_INJ = df_hcv["pe", "COI_HCV_NI"],

    #### Costs ####
    # Treatment Costs
    c_BUP_TX  = df_costs["pe", "BUP_TX"],
    c_MET_TX  = df_costs["pe", "MET_TX"],
    c_OD_TX  = df_costs["pe", "OD_TX"],
    
    # HRU Costs
    # Modify if age-specific
    c_BUP_NI_HRU   = df_costs["pe", "BUP_NI_HRU"],
    c_BUPC_NI_HRU  = df_costs["pe", "BUPC_NI_HRU"],
    c_MET_NI_HRU   = df_costs["pe", "MET_NI_HRU"],
    c_METC_NI_HRU  = df_costs["pe", "METC_NI_HRU"],
    c_REL_NI_HRU   = df_costs["pe", "REL_NI_HRU"],
    c_ODN_NI_HRU   = df_costs["pe", "ODN_NI_HRU"],
    c_ODF_NI_HRU   = df_costs["pe", "ODF_NI_HRU"],
    c_ABS_NI_HRU   = df_costs["pe", "ABS_NI_HRU"],
    c_BUP_INJ_HRU  = df_costs["pe", "BUP_INJ_HRU"], 
    c_BUPC_INJ_HRU = df_costs["pe", "BUPC_INJ_HRU"], 
    c_MET_INJ_HRU  = df_costs["pe", "MET_INJ_HRU"],
    c_METC_INJ_HRU = df_costs["pe", "METC_INJ_HRU"],
    c_REL_INJ_HRU  = df_costs["pe", "REL_INJ_HRU"],
    c_ODN_INJ_HRU  = df_costs["pe", "ODN_INJ_HRU"],
    c_ODF_INJ_HRU  = df_costs["pe", "ODF_INJ_HRU"],
    c_ABS_INJ_HRU  = df_costs["pe", "ABS_INJ_HRU"], 

    # HIV/HCV Costs
    c_HIV_HRU = df_costs["pe", "HIV_HRU"],
    c_HIV_ART = df_costs["pe", "HIV_ART"],
    c_HCV_HRU = df_costs["pe", "HCV_HRU"],
    c_HCV_DAA = df_costs["pe", "HCV_DAA"],
    
    # Overdose Costs
    c_OD_NX = df_costs["pe", "OD_NX"],
    c_OD_AMB = df_costs["pe", "OD_AMB"],
    
    # Crime Costs
    c_BUP_NI_crime  = df_crime_costs["pe", "BUP"],
    c_BUPC_NI_crime = df_crime_costs["pe", "BUPC"],
    c_MET_NI_crime  = df_crime_costs["pe", "MET"],
    c_METC_NI_crime = df_crime_costs["pe", "METC"],
    c_REL_NI_crime  = df_crime_costs["pe", "REL"],
    c_ODN_NI_crime  = df_crime_costs["pe", "REL"],
    c_ODF_NI_crime  = 0,
    c_ABS_NI_crime  = df_crime_costs["pe", "ABS"],
      
    c_BUP_INJ_crime  = df_crime_costs["pe", "BUP"],
    c_BUPC_INJ_crime = df_crime_costs["pe", "BUPC"],
    c_MET_INJ_crime  = df_crime_costs["pe", "MET"],
    c_METC_INJ_crime = df_crime_costs["pe", "METC"],
    c_REL_INJ_crime  = df_crime_costs["pe", "REL"],
    c_ODN_INJ_crime  = df_crime_costs["pe", "REL"],
    c_ODF_INJ_crime  = 0,
    c_ABS_INJ_crime  = df_crime_costs["pe", "ABS"],
    
    #### QALYs ####
    # HIV/HCV negative
    u_BUP_NI_NEG  = df_qalys["pe", "BUP"],
    u_BUPC_NI_NEG = df_qalys["pe", "BUPC"],
    u_MET_NI_NEG  = df_qalys["pe", "MET"],
    u_METC_NI_NEG = df_qalys["pe", "METC"],
    u_REL_NI_NEG  = df_qalys["pe", "REL"],
    u_ODN_NI_NEG  = df_qalys["pe", "ODN"],
    u_ODF_NI_NEG  = df_qalys["pe", "ODF"],
    u_ABS_NI_NEG  = df_qalys["pe", "ABS"],
    
    u_BUP_INJ_NEG  = df_qalys["pe", "BUP"],
    u_BUPC_INJ_NEG = df_qalys["pe", "BUPC"],
    u_MET_INJ_NEG  = df_qalys["pe", "MET"],
    u_METC_INJ_NEG = df_qalys["pe", "METC"],
    u_REL_INJ_NEG  = df_qalys["pe", "REL"],
    u_ODN_INJ_NEG  = df_qalys["pe", "ODN"],
    u_ODF_INJ_NEG  = df_qalys["pe", "ODF"],
    u_ABS_INJ_NEG  = df_qalys["pe", "ABS"],

    u_HIV_mult = df_qalys["pe", "HIV_mult"], # HIV multiplier for negative states
    u_HCV_mult = df_qalys["pe", "HCV_mult"], # HCV multiplier for negative states
    u_COI_mult = df_qalys["pe", "COI_mult"]

    ) # Close list
  return(l_params_all) # Return full parameter list
}

#' Update parameters
#'
#' \code{update_param_list} is used to update list of all parameters with new 
#' values for specific parameters.
#'
#' @param l_params_all List with all parameters of decision model
#' @param params_updated Parameters for which values need to be updated
#' @return 
#' A modifed list with all parameters updated.
#' @export

update_param_list <- function(l_params_all, params_updated){
  
  if (typeof(params_updated)!="list"){
    params_updated <- split(unname(params_updated),names(params_updated)) #convert the named vector to a list
  }
  l_params_all <- modifyList(l_params_all, params_updated) #update the values
  return(l_params_all)
}