// date: 21/10/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: regressions 
 
clear all
set more off
set maxvar 10000

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

* LATE endline - cs IV pooled
ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1, absorb(i.pair_rank) cluster(final_cluster)

* LATE twfe - panel IV pooled
ivreghdfe `var' (Dit_registered = Dit), absorb(i.hhid i.endline) cluster(final_cluster)

*/

 ****
xtset hhid round
 ****

*** more variables ***

 	replace hunger= any_hunger_3mo if missing(hunger) 
	recode hunger_freq (1/2=0) (3/4=1), gen(hunger_freq2)
	replace hunger_frequent = hunger_freq2 if missing(hunger_frequent)
	replace hunger_frequent = 0 if missing(hunger_frequent)

drop hhsize_2 	
su hhsize if round==0 , d
gen temp = (hhsize>r(p50)) if round==0
egen hhsize_2 = max(temp), by(hhid)
drop temp
cap label define hhsize_2 0 "Smaller (1-7)" 1 "Larger (8+)"
label values hhsize_2 hhsize_2

	gen hh_farm_base0 = hh_farming if round==0
	egen hh_farm_base = max(hh_farm_base0) , by(hhid)

su share_food if round==0 , d
gen temp = (share_food>r(p50)) if round==0
egen share_food_2 = max(temp), by(hhid)
drop temp
label define share_food_2 0 "Below median" 1 "Above median"
label values share_food_2 share_food_2

	gen any_climshock1 = any_climshock if round==1
	egen any_climshock_end = max(any_climshock1) , by(hhid)
gen any_r_climshock1 = any_r_climshock if round==1
egen any_r_climshock_end = max(any_r_climshock1) , by(hhid)

	gen gaemi = 0 if MUN==138060 & round==1
	replace gaemi = 1 if MUN==138060 & month_2==tm(2024m7)
	egen gaemi_0 = max(gaemi), by(hhid)

gen meal_planner_g0 = meal_planner_gender if round==0
egen meal_planner_g = max(meal_planner_g0) , by(hhid)

	gen fridge = (Q13_3A7==1|Q13_3A7==2) if round==0 
	egen fridge_2 = max(fridge), by(hhid)
	replace fridge = 1 if (Q13_3_A_7==1|Q13_3_A_7==2) & round==1
	replace fridge = 0 if (Q13_3_A_7==0) & round==1

winsor2 INCOMEALLSOURCES2, cuts(0 99)
gen income = INCOMEALLSOURCES2_w/6 if round==0
replace income = hh_income_1_mo if round==1
*
su income if round==0 , d
gen temp = (income>r(p50)) if round==0
egen income_2 = max(temp), by(hhid)
cap label define income_2 0 "Below median" 1 "Above median"
label values income_2 income_2
	
********************** 
 
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables/regressions"

global index abs_index_A abs_index_B abs_index_C hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access adapt_index_A adapt_index_B adapt_index_C n_sources n_asset_types good_debt no_negative_strat_climate crop_lives_fish hh_inclusion hh_emprate transf_index_2 exp_edu_pchild age_appr_edu_ratio 

global index_noshock abs_index_A abs_index_B abs_index_C hh_bop has_savings value_extra_asset FIES_8 share_food hh_network n_safetynet hh_healthins  health_access adapt_index_A adapt_index_B adapt_index_C n_sources n_asset_types good_debt crop_lives_fish hh_inclusion hh_emprate transf_index_2 exp_edu_pchild age_appr_edu_ratio 

global other access_info hh_socinsur any_debt bad_debt hunger hunger_frequent total_food_1mo_php total_food_1mo_php_pc tot_non_food_expenses tot_non_food_expenses_pc n_f_assets n_assets n_extra_assets n_jobs hh_farming

global shock loss_*_cl

global endline cantril_ladder resilience_climate_* locus_control_* jobs_pc consumed_self_produced


* LATE panel

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit), absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel.xls", append ctitle (`var')			
}

*  HETEROGENITY ANALYSIS

* study site 


foreach MUN of numlist 20313 50171 138060 160670  {
		foreach var of varlist $index $other { 
		display "`MUN'" " " "`var'"
		ivreghdfe `var' (Dit_registered = Dit) if MUN == `MUN' , absorb(i.hhid i.endline) cluster(final_cluster)
		outreg2 using "late_panel_byMUN.xls", append ctitle (`MUN'_`var')
	}
}

* vvv note hh_inclusion 190870 doesn't converge - manually skipped vvv *
		foreach var of varlist abs_index_A abs_index_B abs_index_C hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access adapt_index_A adapt_index_B adapt_index_C n_sources n_asset_types good_debt no_negative_strat_climate crop_lives_fish hh_emprate transf_index_2 exp_edu_pchild age_appr_edu_ratio $other { 
		display "190870" " " "`var'"
		ivreghdfe `var' (Dit_registered = Dit) if MUN == 190870 , absorb(i.hhid i.endline) cluster(final_cluster)
		outreg2 using "late_panel_byMUN.xls", append ctitle ("190870"_`var')
	}


* household size

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if hhsize_2 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bysize.xls", append ctitle (small_`var')
}

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if hhsize_2 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bysize.xls", append ctitle (large_`var')			
}

*mean $index $other if treatment==0 & hhsize_2==0
*mean $index $other if treatment==0 & hhsize_2==1

* income level

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if income_2 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byincome.xls", append ctitle (low_`var')
}

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if income_2 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byincome.xls", append ctitle (high_`var')			
}

* farming as main livelihood at baseline

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if hh_farm_base==0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_farming.xls", append ctitle (no_`var')	
}
foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if hh_farm_base==1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_farming.xls", append ctitle (yes_`var')			
}

*mean $index $other if treatment==0 & hh_farm_base==0
*mean $index $other if treatment==0 & hh_farm_base==1

* share of food consumption 

foreach var of varlist $index $other  { 
	ivreghdfe `var' (Dit_registered = Dit) if share_food_2 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byfoodshare.xls", append ctitle (low_`var')
}
foreach var of varlist $index $other  { 
	ivreghdfe `var' (Dit_registered = Dit) if share_food_2 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byfoodshare.xls", append ctitle (high_`var')			
}

*mean $index $other  if treatment==0 & share_food_2 == 0
*mean $index $other  if treatment==0 & share_food_2 == 1

* shock before endline

foreach var of varlist $index_noshock $other { 
	ivreghdfe `var' (Dit_registered = Dit) if any_climshock_end == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (no_shock_`var')
}
foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if any_climshock_end == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (shock_`var')			
}

*mean $index $other if treatment==0 & any_climshock_end == 0
*mean $index $other if treatment==0 & any_climshock_end == 1

* (shock in last 6 months = since feb)

foreach var of varlist $index_noshock $other { 
	ivreghdfe `var' (Dit_registered = Dit) if any_r_climshock_end == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (R_no_shock_`var')
}
foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if any_r_climshock_end == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (R_shock_`var')			
}

* only july shock in tondo 

foreach var of varlist $index_noshock $other { 
	ivreghdfe `var' (Dit_registered = Dit) if MUN==138060 & gaemi_0 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (TONDO_noshock_`var')
}
foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if MUN==138060 & gaemi_0 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_byshock.xls", append ctitle (TONDO_shock_`var')			
}

* gender of meal planner (at baseline)

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if meal_planner_g == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bygender.xls", append ctitle (male_`var')
}
foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if meal_planner_g == 2 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bygender.xls", append ctitle (female_`var')			
}

*mean $index $other if treatment==0 & meal_planner_g == 1
*mean $index $other if treatment==0 & meal_planner_g == 2

* presence of fridge (at baseline)

foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if fridge_2 == 0 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bfridge.xls", append ctitle (no_`var')
}
foreach var of varlist $index $other { 
	ivreghdfe `var' (Dit_registered = Dit) if fridge_2 == 1 , absorb(i.hhid i.endline) cluster(final_cluster)
	outreg2 using "late_panel_bfridge.xls", append ctitle (fridge_`var')			
}

*mean $index $other if treatment==0 & fridge_2 == 0
*mean $index $other if treatment==0 & fridge_2 == 1

* LATE endline
 
foreach var of varlist $index $other $endline loss_*_cl { 
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1, absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline.xls", append ctitle (`var')			
}

/*	
	* by subjective resilience 
	foreach var of varlist $index $other $endline loss_*_cl { 
		ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & subj_res_score_2 == 0 , absorb(i.pair_rank) cluster(final_cluster)
		outreg2 using "late_endline_bysubjres.xls", append ctitle (low_`var')
	}
	foreach var of varlist $index $other $endline loss_*_cl { 
		ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & subj_res_score_2 == 1 , absorb(i.pair_rank) cluster(final_cluster)
		outreg2 using "late_endline_bysubjres.xls", append ctitle (high_`var')			
	}

	*mean $index $other $endline loss_*_cl if endline == 1 & treatment==0 & subj_res_score_2 == 0 
	*mean $index $other $endline loss_*_cl if endline == 1 & treatment==0 & subj_res_score_2 == 1
*/
	
	* by municipality 
		foreach MUN of numlist 20313 50171 138060 160670 190870 {
		foreach var of varlist resilience_climate_* subj_res_score {
			ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & MUN == `MUN', absorb(i.pair_rank) cluster(final_cluster)
			outreg2 using "subjres_MUN.xls", append ctitle (total_`MUN')
		}
	}
	
/*	* by shock
		foreach var of varlist resilience_climate_* subj_res_score {
			ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & any_climshock==0 , absorb(i.pair_rank) cluster(final_cluster)
			outreg2 using "subjres_MUN.xls", append ctitle (totnoshock_`var')
		}

		foreach var of varlist resilience_climate_* subj_res_score {
			ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & any_climshock==1 , absorb(i.pair_rank) cluster(final_cluster)
			outreg2 using "subjres_MUN.xls", append ctitle (totshock_`var')
		}
*/

* Tondo only, by typhoon in July
		
foreach var of varlist $index_noshock $other $endline {
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & MUN==138060 & gaemi_0==0 , absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline_byshock.xls", append ctitle (tondo_noshock_`var')			
}

foreach var of varlist $index $other $endline {
	ivreghdfe `var' (registered_walang_gutom = treatment) if endline == 1 & MUN==138060 & gaemi_0==1 , absorb(i.pair_rank) cluster(final_cluster)
	outreg2 using "late_endline_byshock.xls", append ctitle (tondo_shock_`var')			
}
	
 
 