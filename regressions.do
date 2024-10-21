// date: 21/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: regressions 
 
clear all
set more off
set maxvar 10000

/*
* Install ftools (remove program if it existed previously)
 ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe 6.x
 ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

 ado uninstall ivreghdfe
 ssc install ivreg2 // Install ivreg2, the core package
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)
*/

use "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Endline Processed_HH.dta", clear

replace endline = 0 if missing(endline)
assert round==endline

******************
* balanced panel *
keep if balance==1
******************

gen Dit = treatment * endline

gen Dit_registered = registered_walang_gutom * endline
replace Dit_registered = 0 if missing(Dit_registered)

/* SPECIFICATIONS *

*did
reghdfe `var' endline##treatment, absorb(i.pair_rank) vce(cluster pair_rank)

*twfe
reghdfe `var' Dit, absorb(i.endline i.hhid) vce(cluster pair_rank)

*cs
reghdfe `var' treatment if endline == 1, absorb(i.pair_rank) vce(cluster pair_rank)

* LATE endline - cs IV pooled
ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1, absorb(i.pair_rank) cluster(final_cluster)
	* cs IV urban
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & urban ==1, absorb(i.pair_rank) cluster(final_cluster)
	* cs IV rural
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & urban ==0, absorb(i.pair_rank) cluster(final_cluster)

* LATE twfe - panel IV pooled
ivreghdfe `var' (Dit_registered = Dit), absorb(i.hhid i.endline) cluster(final_cluster)

*/

 ****
xtset hhid round
 ****
 
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables/regressions"

global index_comp hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access ///
n_sources n_asset_types access_info good_debt no_negative_strat_climate crop_lives_fish hh_inclusion hh_socinsur hh_emprate ///
exp_edu_pchild age_appr_edu_ratio 

global other_outcomes any_debt bad_debt cantril_ladder resilience_climate_* any_hunger_3mo hunger_frequent fies ///
total_food_1mo_php total_food_1mo_php_pc consumed_self_produced total2_food_1mo_php total2_food_1mo_php_pc tot_non_food_expenses tot_non_food_expenses_pc ///
n_f_assets n_assets n_extra_assets n_asset_types ///
n_jobs hh_farming /* jobs_pc */ 


/*

* endline cross-section (pair FE)
 
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* { 
	reghdfe `var' treatment if endline == 1, absorb(i.pair_rank) vce(cluster pair_rank)
	outreg2 using "itt_endline.xls", append ctitle (`var')			
}

*  two-way FE // too few obs
 
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 { 
	reghdfe `var' Dit, absorb(i.endline i.hhid) vce(cluster pair_rank)
	outreg2 using "itt_panel.xls", append ctitle (`var')			
}

* Difference in differences // it omits endline ans interaction (probs equivalent to cs then)

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes { 
	reghdfe `var' endline##treatment, absorb(i.pair_rank) vce(cluster pair_rank)
*	outreg2 using "did.xls", append ctitle (`var')			
}

*/

**# Bookmark #2
/*
* LATE endline
 
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* { 
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1, absorb(i.pair_rank) cluster(final_cluster)
	* reghdfe `var' registered_walang_gutom if endline == 1, absorb(i.pair_rank) vce(cluster pair_rank)
	outreg2 using "late_endline.xls", append ctitle (`var')			
}
*/
 
* LATE panel

/* 
	replace hunger= any_hunger_3mo if missing(hunger) 
	recode hunger_freq (1/2=0) (3/4=1), gen(hunger_freq2)
	replace hunger_frequent = hunger_freq2 if missing(hunger_frequent)
	replace hunger_frequent = 0 if missing(hunger_frequent)
	
 	ivreghdfe hunger_frequent (Dit_registered = Dit) if balance==1 , absorb(i.hhid i.endline) cluster(final_cluster)
*/

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt n_f_assets n_assets n_extra_assets n_asset_types n_jobs hh_farming { 
	ivreghdfe `var' (Dit_registered = Dit) if balance==1 , absorb(i.hhid i.endline) cluster(final_cluster)
	* reghdfe `var' endline##registered_walang_gutom, absorb(i.pair_rank) vce(cluster pair_rank)
	outreg2 using "late_panel.xls", append ctitle (`var')			
}

*  HETEROGENITY ANALYSIS

* study site 

/*
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* { 
	reghdfe `var' treatment if endline == 1 & MUN==138060, absorb(i.pair_rank) vce(cluster pair_rank)
	outreg2 using "itt_endline_by_site.xls", append ctitle (Tondo_`var')			
}

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* { 
	reghdfe `var' treatment if endline == 1 & MUN!=138060, absorb(i.pair_rank) vce(cluster pair_rank)
	outreg2 using "itt_endline_by_site.xls", append ctitle (Other_`var')			
}
*/

bysort MUN : su abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp if endline == 1

* vvv note hh_inclusion 190870 doesn't converge - manually skipped vvv *

foreach MUN of numlist /*20313 50171 138060 160670*/ 190870  {
		foreach var of varlist /*abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt no_negative_strat_climate crop_lives_fish hh_inclusion*/ hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio  { 
		display "`MUN'" " " "`var'"
		* ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & MUN == `MUN' , absorb(i.pair_rank) cluster(final_cluster)
		ivreghdfe `var' (Dit_registered = Dit) if MUN == `MUN' , absorb(i.hhid i.endline) cluster(final_cluster)
		outreg2 using "late_panel_byMUN.xls", append ctitle (`MUN'_`var')
	}
}

/*
                        1,634     20313  San Mariano
                          662     50171  Garchitorena
                        5,282    138060  Tondo
                        1,384    160670  Dapa
                          482    190870  Parang
*/

* household size

su hhsize if round==0 , d
gen temp = (hhsize>r(p50)) if round==0
egen hhsize_2 = max(temp), by(hhid)
drop temp
label define hhsize_2 0 "Smaller (1-7)" 1 "Larger (8+)"
label values hhsize_2 hhsize_2

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	*ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & hhsize_2 == 0 , absorb(i.pair_rank) cluster(final_cluster)
	ivreghdfe `var' (Dit_registered = Dit) if hhsize_2 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bysize.xls", append ctitle (small_`var')
}

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	*ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & hhsize_2 == 1 , absorb(i.pair_rank) cluster(final_cluster)
	ivreghdfe `var' (Dit_registered = Dit) if hhsize_2 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bysize.xls", append ctitle (large_`var')			
}

mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & hhsize_2==0
mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & hhsize_2==1

* farming as main livelihood at baseline

gen hh_farm_base0 = hh_farming if round==0
egen hh_farm_base = max(hh_farm_base0) , by(hhid)

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt no_negative_strat_climate hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt { 
	* reghdfe `var' treatment if endline == 1 & hh_farming==1, absorb(i.pair_rank) vce(cluster pair_rank)
	ivreghdfe `var' (Dit_registered = Dit) if hh_farm_base==0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_farming.xls", append ctitle (no_`var')	
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt no_negative_strat_climate hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt { 
	ivreghdfe `var' (Dit_registered = Dit) if hh_farm_base==1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_farming.xls", append ctitle (yes_`var')			
}

mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt no_negative_strat_climate hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt if treatment==0 & hh_farm_base==0
mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt no_negative_strat_climate hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt if treatment==0 & hh_farm_base==1

* share of food consumption 

su share_food if round==0 , d
gen temp = (share_food>r(p50)) if round==0
egen share_food_2 = max(temp), by(hhid)
label define share_food_2 0 "Below median" 1 "Above median"
label values share_food_2 share_food_2

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	*ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & share_food_2 == 0 , absorb(i.pair_rank) cluster(final_cluster)
	ivreghdfe `var' (Dit_registered = Dit) if share_food_2 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byfoodshare.xls", append ctitle (low_`var')
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	ivreghdfe `var' (Dit_registered = Dit) if share_food_2 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byfoodshare.xls", append ctitle (high_`var')			
}

mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & share_food_2 == 0
mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & share_food_2 == 1


* shock before endline

	replace hunger= any_hunger_3mo if missing(hunger) 
	recode hunger_freq (1/2=0) (3/4=1), gen(hunger_freq2)
	replace hunger_frequent = hunger_freq2 if missing(hunger_frequent)
	replace hunger_frequent = 0 if missing(hunger_frequent)

 
global resil_var hunger hunger_frequent FIES_8 total_food_1mo_php total_food_1mo_php_pc tot_non_food_expenses tot_non_food_expenses_pc
global shock_var negative_strat_climate /*cl_strategy2 cl_strategy4 cl_strategy9 cl_strategy10 cl_strategy11 cl_strategy14 cl_strategy15 cl_strategy16*/ loss_*_cl 

su abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* $resil_var if endline == 1 & any_climshock == 0

gen any_climshock1 = any_climshock if round==1
egen any_climshock_end = max(any_climshock1) , by(hhid)

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var { 
	*ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & any_climshock == 0 , absorb(i.pair_rank) cluster(final_cluster)
	ivreghdfe `var' (Dit_registered = Dit) if any_climshock_end == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (noshock_`var')
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var $shock_var { 
	*ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & any_climshock == 1 , absorb(i.pair_rank) cluster(final_cluster)
	ivreghdfe `var' (Dit_registered = Dit) if any_climshock_end == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (shock_`var')			
}

mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var if treatment==0 & any_climshock_end == 0
mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var if treatment==0 & any_climshock_end == 1

* (shock in last 6 months = since feb)
gen any_r_climshock1 = any_r_climshock if round==1
egen any_r_climshock_end = max(any_r_climshock1) , by(hhid)

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var { 
	ivreghdfe `var' (Dit_registered = Dit) if any_r_climshock_end == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (Rnoshock_`var')
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var $shock_var { 
	ivreghdfe `var' (Dit_registered = Dit) if any_r_climshock_end == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (Rshock_`var')			
}

* only july shock in tondo 

gen gaemi = 0 if MUN==138060 & round==1
replace gaemi = 1 if MUN==138060 & month_2==tm(2024m7)
egen gaemi_0 = max(gaemi), by(hhid)

su abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var $shock_var if MUN==138060 & gaemi_0 == 0

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var { 
	ivreghdfe `var' (Dit_registered = Dit) if MUN==138060 & gaemi_0 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (TONDO_noshock_`var')
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  n_safetynet hh_healthins  health_access n_sources n_asset_types access_info good_debt crop_lives_fish hh_inclusion hh_socinsur hh_emprate exp_edu_pchild age_appr_edu_ratio any_debt bad_debt $resil_var $shock_var { 
	ivreghdfe `var' (Dit_registered = Dit) if MUN==138060 & gaemi_0 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (TONDO_shock_`var')			
}


* subjective resilience

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* { 
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & subj_res_score_2 == 0 , absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline_bysubjres.xls", append ctitle (low_`var')
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* { 
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & subj_res_score_2 == 1 , absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline_bysubjres.xls", append ctitle (high_`var')			
}

mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* if endline == 1 & treatment==0 & subj_res_score_2 == 0 
mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp $other_outcomes locus_control_* if endline == 1 & treatment==0 & subj_res_score_2 == 1


foreach MUN of numlist 20313 50171 138060 160670 190870 {
	foreach var of varlist resilience_climate_* subj_res_score {
		ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & MUN == `MUN', absorb(i.pair_rank) cluster(final_cluster)
		outreg2 using "subjres_MUN.xls", append ctitle (total_`MUN')
	}
}

	foreach var of varlist resilience_climate_* subj_res_score {
		ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 /*& MUN == `MUN'*/ , absorb(i.pair_rank) cluster(final_cluster)
		outreg2 using "subjres_MUN.xls", append ctitle (tottotal_`var')
	}

*foreach MUN of numlist 20313 50171 160670 190870 138060 {
	foreach var of varlist resilience_climate_* subj_res_score {
		ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 /*& MUN == `MUN'*/ & any_climshock==0 , absorb(i.pair_rank) cluster(final_cluster)
		outreg2 using "subjres_MUN.xls", append ctitle (totnoshock_`var')
	}

*foreach MUN of numlist 20313 50171 160670 190870 138060 {
	foreach var of varlist resilience_climate_* subj_res_score {
		ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 /*& MUN == `MUN'*/ & any_climshock==1 , absorb(i.pair_rank) cluster(final_cluster)
		outreg2 using "subjres_MUN.xls", append ctitle (totshock_`var')
	}


* gender of meal planner (at baseline)

gen meal_planner_g0 = meal_planner_gender if round==0
egen meal_planner_g = max(meal_planner_g0) , by(hhid)

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	*ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & meal_planner_gender == 1 , absorb(i.pair_rank) cluster(final_cluster)
	ivreghdfe `var' (Dit_registered = Dit) if meal_planner_g == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bygender.xls", append ctitle (male_`var')
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	*ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & meal_planner_gender == 2 , absorb(i.pair_rank) cluster(final_cluster)
	ivreghdfe `var' (Dit_registered = Dit) if meal_planner_g == 2 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bygender.xls", append ctitle (female_`var')			
}

mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & meal_planner_g == 1
mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & meal_planner_g == 2

* presence of fridge (at baseline)

gen fridge = (Q13_3A7==1|Q13_3A7==2) if round==0 

egen fridge_2 = max(fridge), by(hhid)

replace fridge = 1 if (Q13_3_A_7==1|Q13_3_A_7==2) & round==1
replace fridge = 0 if (Q13_3_A_7==0) & round==1
xttrans fridge

foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	ivreghdfe `var' (Dit_registered = Dit) if fridge_2 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bfridge.xls", append ctitle (no_`var')
}
foreach var of varlist abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt { 
	ivreghdfe `var' (Dit_registered = Dit) if fridge_2 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bfridge.xls", append ctitle (yes_`var')			
}

mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & fridge_2 == 0
mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 $index_comp any_debt bad_debt if treatment==0 & fridge_2 == 1


* RESILIENCE ANALYSIS

*ivreghdfe negative_strat_climate (registered_walang_gutom = treatment) if endline==1 /*& MUN==138060*/ & any_climshock==1, absorb(i.pair_rank) cluster(pair_rank)
*	outreg2 using "late_endline_byshock.xls", append ctitle (negative_strat_climate)
	
* reghdfe negative_strat_climate##treatment if endline==1 /*& MUN==138060*/ & any_climshock==1, absorb(i.pair_rank) vce(cluster pair_rank)
*	outreg2 using "itt_endline_tondo.xls"			

	
* reghdfe total_food_1mo_php any_climshock##treatment if endline==1 & MUN==138060, absorb(i.pair_rank) vce(cluster pair_rank)

*reghdfe fies any_climshock##treatment if endline==1 & MUN==138060, absorb(i.pair_rank) vce(cluster pair_rank)

***
 

global resil_var hunger hunger_frequent FIES_8 total_food_1mo_php total_food_1mo_php_pc consumed_self_produced total2_food_1mo_php total2_food_1mo_php_pc tot_non_food_expenses tot_non_food_expenses_pc self_poverty cantril_ladder resilience_climate_* negative_strat_climate cl_strategy2 cl_strategy4 cl_strategy9 cl_strategy10 cl_strategy11 cl_strategy14 cl_strategy15 cl_strategy16 loss_*_cl 

su $resil_var if round==1

**# Bookmark #3
/*

foreach var of varlist $resil_var {
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 , absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline_resilience.xls", append ctitle (`var')			
}
foreach var of varlist any_hunger_3mo hunger_frequent FIES_8 fies total_food_1mo_php total_food_1mo_php_pc consumed_self_produced total2_food_1mo_php total2_food_1mo_php_pc tot_non_food_expenses tot_non_food_expenses_pc self_poverty cantril_ladder resilience_climate_* {
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & any_climshock==0 , absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline_resilience.xls", append ctitle (no_shock_`var')			
}
foreach var of varlist $resil_var {
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & any_climshock==1 , absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline_resilience.xls", append ctitle (shock_`var')			
}
	
*/	
 
/*
* outcome variables used for regressions
cantril_ladder self_poverty harvest_php_rice harvest_php_corn harvest_php_veg crop_harvest_php total_nb_nonfarm_assets farm_asset_spend_1y_php total_nb_farm_assets ///
any_hunger_3mo hunger_frequent fies fies_raw hh_average_fcs_score hh_average_fcs_poor hh_average_fcs_borderline hh_average_fcs_acceptable adult_average_fcs_score adult_average_fcs_poor adult_average_fcs_borderline adult_average_fcs_acceptable male_adult_fcs_score male_adult_fcs_poor male_adult_fcs_borderline male_adult_fcs_acceptable female_adult_fcs_score female_adult_fcs_poor female_adult_fcs_borderline female_adult_fcs_acceptable adult_avg_fcs_cereal adult_avg_fcs_pulses adult_avg_fcs_vegetable adult_avg_fcs_fruit adult_avg_fcs_oil_fats adult_avg_fcs_meat adult_avg_fcs_milk adult_avg_fcs_sugar child_average_fcs_score child_average_fcs_poor child_average_fcs_borderline child_average_fcs_acceptable fcs_grain_little fcs_tubers_little fcs_pulses_little fcs_green_veg_little fcs_vit_a_little fcs_other_veg_little fcs_fruit_little fcs_meat_little fcs_fish_little fcs_milk_little fcs_eggs_little fcs_sugar_little fcs_oil_little fcs_nuts_little fcs_condiments_little ///
received_train_nutrition quiz_index_correct quiz_share_correct total_food_1mo_php total_food_1mo_php_ln total_food_spend_1mo total_food_inkind_1mo  total_food_gift_1mo total_food_1mo_php_pc total_food_1mo_php_ln_pc expenses_1 expenses_2 expenses_3 expenses_4 expenses_5 expenses_6 expenses_7 expenses_8 expenses_9 expenses_10 expenses_11 expenses_12 expenses_13 expenses_14 expenses_15 expenses_16 tot_nonfood_exp any_borrowing_6mo any_borrowing_food_6mo current_out_bal largest_debt_6mo savings_php wages_1_mo_total hh_income_1_mo hh_income_1_mo_pc ln_hh_income_1_mo ln_hh_income_1_mo_pc purchased_1 purchased_2 purchased_3 purchased_4 purchased_5 purchased_6 purchased_7 purchased_8 purchased_9 purchase_1_kadiwa tot_transport_duration_1 q10_4_4_1 tot_transport_cost_1 q10_4_5_1 resilience_climate_1 resilience_climate_2 resilience_climate_3 resilience_climate_4 

* other variables used for regression
 treatment // explanatory var
 endline // endline only 
 pair_rank // fixed effects
 final_cluster // cluster 
 farming_rice_at_baseline farming_corn_at_baseline farming_veg_at_baseline farming_at_baseline purchased_1_baseline /// condition on baseline characteristic
 hhid // household level fixed effects
 larger_households max_presence_child_05 // condition on hh characteristics 
 meal_planner_respond // condition on respondent 
 MUN // condition on location 
 dummy_4p_any // condition on 4P receipt (either base or end)
 cshock_since_baseline // condition on experience of shocks
 offered_wg // didn't receive treatment but was offered, didn't receive treatment and wasn't offered ?
*/ 
 