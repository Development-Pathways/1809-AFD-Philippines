// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: export tables of descriptive statistics

* load data
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"
* use "Processed/FSP Endline Processed.dta", clear // individual 
use "Processed/FSP Endline Processed_HH.dta", clear // household

table () (round), statistic(mean $index_comp )

* progs

su n_safetynet hh_healthins hh_inclusion hh_socinsur

forval n = 1/8 {
	replace prog_`n' = health_subsidy_`n' if round==1
}
replace prog_9 = health_subsidy_99 if round==1
replace prog_10 = other_subsidy_1 if round==1
replace prog_11 = other_subsidy_2 if round==1
replace prog_12 = other_subsidy_3 if round==1
replace prog_13 = other_subsidy_4 if round==1
replace prog_14 = other_subsidy_5 if round==1
replace prog_15 = other_subsidy_6 if round==1
replace prog_16 = other_subsidy_7 if round==1
replace prog_17 = other_subsidy_8 if round==1

mean prog_*, over(round)

reg prog_8 treatment if round==1


*** shocks *** 

table () (MUN round), statistic(mean Q16_*A) nototals

table () (MUN) if round==0, statistic(mean Q16_*A)

table () (MUN treatment) if round==0, statistic(mean $index_comp ) nototals



tabstat recent_shock_2 recent_shock_3 recent_shock_5 recent_shock_6 recent_shock_7 recent_shock_8 , statistics( mean ) by(MUN)

foreach var of varlist any_climshock shock_2 shock_3 shock_5 shock_6 shock_7 shock_8 {
	tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 if round==1 & `var'==1, statistics(mean)
}

tabstat any_r_climshock , statistics( mean ) by(MUN)

**************

tab resilience_climate_1 MUN, col nofreq
tab resilience_climate_2 MUN, col nofreq
tab resilience_climate_3 MUN, col nofreq
tab resilience_climate_4 MUN, col nofreq

tabstat subj_res2v* , statistics( mean ) by(MUN)

reg subj_res3v_1 i.MUN##treatment

reg subj_res3v_1 treatment##any_climshock i.MUN 

**************

global darkblue 	"0 57 114"
global darkorange 	"239 93 59"
global lightgrey 	"242 242 242"
global teal 		"41 139 156"
global yellow 		"250 180 31"
global purple 		"112 48 160"

// plot

twoway scatter hh_livelihood n_sources

tab hhsize_bin MUN, col nofreq

graph box food_consumption_pc if round==0 /*& food_consumption_pc<100000*/, over(MUN) box(1, fcolor($teal ) lcolor($darkblue )) medtype(cline) medline(lcolor($darkblue )) cwhisker lines(lcolor($darkblue )) marker(1, mcolor($darkblue )) ytitle("Food consumption per capita") graphregion(fcolor($lightgrey ) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey )) plotregion(fcolor($lightgrey) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey ))

graph box share_food if round==0 /*& food_consumption_pc<100000*/, over(MUN) box(1, fcolor($teal ) lcolor($darkblue )) medtype(cline) medline(lcolor($darkblue )) cwhisker lines(lcolor($darkblue )) marker(1, mcolor($darkblue )) ytitle("Food consumption share") graphregion(fcolor($lightgrey ) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey )) plotregion(fcolor($lightgrey) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey ))

graph box hhsize , over(MUN)

graph box hhsize if round==0, over(MUN) box(1, fcolor($teal ) lcolor($darkblue )) medtype(cline) medline(lcolor($darkblue )) cwhisker lines(lcolor($darkblue )) marker(1, mcolor($darkblue )) ytitle("Household size") graphregion(fcolor($lightgrey ) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey )) plotregion(fcolor($lightgrey) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey ))

mean prog_8, over(MUN)
mean hh_safetynet_no4p, over(MUN)

tab n_safetynet MUN, col nofreq
graph hbox n_safetynet , over(MUN)

recode n_sources (6/max = 6 "6 or more"), gen (n_sources_bin)
tab n_sources_bin MUN, col nofreq

mean any_climshock //, over(MUN)

mean crop livestock fishing foodservice wholesale manufacturing trasportation other_activ other_sources //, over (MUN)

tab main_livelihood MUN, col nofreq

tabstat hh_farming hh_foodservice hh_wholesale hh_manufacturing hh_transportation hh_other_activ, statistics( mean ) by(MUN)

tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 if round==0 , statistics( mean ) by(MUN)

reg abs_index_A i.MUN if round==0
mvtest means abs_index_A, by(MUN) 

table (MUN) (round), statistic(mean abs_index_A_01  adapt_index_A_01 transf_index_2_01) nototals

table (MUN) (hhsize_2) if refgroup==1 , statistic(mean abs_index_A_01  adapt_index_A_01 transf_index_2_01) nototals

use "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Endline Processed_HH.dta", clear

keep if round==0 

tabstat abs_index_A_01 abs_index_B_01 abs_index_C_01 adapt_index_A_01 adapt_index_B_01 adapt_index_C_01 transf_index_2_01 if refgroup==1 , by(MUN) statistics(mean) 

tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 if refgroup==1 , by(MUN) statistics(mean) format(%9.3f)
tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 if refgroup==1 & hhsize_2==1, by(MUN) statistics(mean) format(%9.3f)

tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 if refgroup==1, by(hhsize_2) statistics(mean sd) 

tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2, by(main_natural) statistics(mean sd) // 8% main_natural=1

tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2, by(hh_farming) statistics(mean sd) // 32%

*** 

* less resilient households *

twoway scatter abs_index_A adapt_index_A if round==0, mcolor("$darkblue") msize(tiny) msymbol(smcircle) ytitle("Absorptive resilience") xtitle("Adaptive resilience") graphregion(fcolor($lightgrey ) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey )) plotregion(fcolor($lightgrey) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey ))

twoway scatter adapt_index_A transf_index_2 if round==0
twoway scatter abs_index_A transf_index_2 if round==0

gen low_abs_A_base = abs_index_A<0 if round==0
egen low_abs_A = max(low_abs_A_base), by(hhid)

gen low_adapt_A_base = adapt_index_A<0 if round==0
egen low_adapt_A = max(low_adapt_A_base), by(hhid)

gen low_transf_A_base = transf_index_2<0 if round==0
egen low_transf_A = max(low_transf_A_base), by(hhid)


table () (MUN low_abs_A) if round==0, statistic(mean hhsize sex n_child05 n_school_age hh_maxedu hh_depratio hh_n_jobs any_debt $index_comp) nototals

table () (MUN low_adapt_A) if round==0, statistic(mean hhsize sex n_child05 n_school_age hh_maxedu hh_depratio hh_n_jobs any_debt $index_comp) nototals

table () (MUN low_transf_A) if round==0, statistic(mean  $index_comp ) nototals

global non_index_vars hhsize sex n_child05 n_school_age hh_maxedu hh_depratio hh_n_jobs hh_farming share_food_2 any_debt any_climshock /*subj_res_score_2*/ fridge_2 

cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables/endline"

asdoc pwcorr abs_index_A adapt_index_A transf_index_2 $non_index_vars if round==0 , bonferroni star(all) save(other_corr.doc) replace

table () (MUN) if round==0, statistic(prop hhsize_2 hh_farm_base fridge_2 share_food_2 income_2)
table () (MUN) if round==1, statistic(prop meal_planner_g any_climshock_end subj_res_score_2)

foreach var of varlist hhsize_2 hh_farm_base fridge_2 share_food_2 income_2 meal_planner_g {
	tab `var' MUN if round==0, row nofreq
}
foreach var of varlist any_climshock_end subj_res_score_2 {
	tab `var' MUN if round==1, row nofreq
}

* correlation between resilience indices and subjective resilience

/*
foreach var of varlist abs_index_A_01  adapt_index_A_01 transf_index_2_01 {
	pwcorr `var' resilience_climate_* subj_res_score, star(0.1) bonferroni
}
*/

foreach MUN of numlist 20313 50171 138060 160670 190870 {
	asdoc pwcorr abs_index_A  adapt_index_A transf_index_2 resilience_climate_* subj_res_score if MUN==`MUN' , bonferroni star(all) save(resilience_corr_`MUN'.doc) replace
}
	asdoc pwcorr abs_index_A  adapt_index_A transf_index_2 resilience_climate_* subj_res_score, bonferroni star(all) save(resilience_corr.doc) replace

table () (MUN), statistic(mean subj_res2v_*) nototals
mean subj_res2v_*

table () (round), statistic(mean $index ) nototals
