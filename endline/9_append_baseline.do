// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: append baseline and endline

* load endline data
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"
use "Processed/FSP Endline Processed.dta", clear

drop if missing(treatment)
duplicates drop hhid, force
* keep if rel==1 // 4,772 obs 

gen endline = 1

/* check if it matches baseline

merge 1:1 hhid using "Processed/FSP Baseline Processed_HH.dta", force

    Result                      Number of obs
    -----------------------------------------
    Not matched                           385
        from master                         0  (_merge==1)
        from using                        385  (_merge==2)

    Matched                             4,935  (_merge==3)
    -----------------------------------------
*/
	
* append baseline data

append using "Processed/FSP Baseline Processed_HH.dta", force

recode endline (.=0 "Baseline") (1=1 "Endline"), gen(round) 
replace endline = 0 if missing(endline)

* balanced panel 
duplicates tag hhid, gen(balance)

/*
tab treatment round, miss
 
 results |  Baseline    Endline |     Total
-----------+----------------------+----------
   Control |     2,618      2,407 |     5,025 
 Treatment |     2,702      2,528 |     5,230 
-----------+----------------------+----------
     Total |     5,320      4,935 |    10,255 

*/

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/Panel_unbalanced.dta", replace

*** merge ADB processed panel *** 

keep if balance == 1 

rename hhid INTNO

keep INTNO MUN endline round treatment pair_rank final_cluster ///
hh_bop has_savings value_extra_asset FIES_8 hh_network negative_strat_climate n_safetynet hh_healthins health_access ///
n_sources n_asset_types access_info good_debt no_negative_strat_climate crop_lives_fish hh_inclusion hh_socinsur hh_emprate ///
exp_edu_pchild age_appr_edu_ratio ///
any_debt bad_debt cantril_ladder resilience_climate_* subj_res_score* n_f_assets n_assets n_extra_assets n_asset_types n_jobs hh_farming ///
any_climshock any_r_climshock month_2 Q13_3A7 Q13_3_A_7 loss_*_cl subj_res2v_* *cl_strategy* Rnegative_strat_climate strat_gaemi negative_strat_gaemi

missings report 

merge 1:1 INTNO endline using "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/ADB Dropbox/panel_household_data.dta"

drop *_fcs_* no_school* kg_price* inkind* gift* consumed* sold* disposed* *price* one_way* spending_1mo_* tot_rec_kg_1mo_*

missings report total2_food_1mo_php tot_non_food_expenses hh_income_1_mo hhsize

** update variables ** 

egen check = rowtotal(total2_food_1mo_php tot_non_food_expenses)
assert tot_expenses == check  

gen share_food = total2_food_1mo_php/tot_expenses



save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/Panel_ADBvars.dta", replace
