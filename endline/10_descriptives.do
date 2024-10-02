// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: export tables of descriptive statistics

* load data
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"
* use "Processed/FSP Endline Processed.dta", clear // individual 
use "Processed/FSP Endline Processed_HH.dta", clear // household

*** shocks *** 

table () (MUN round), statistic(mean Q16_*A) nototals

table () (MUN) if round==0, statistic(mean Q16_*A)


tabstat recent_shock_2 recent_shock_3 recent_shock_5 recent_shock_6 recent_shock_7 recent_shock_8 , statistics( mean ) by(MUN)

foreach n of numlist 1/20 22/28 {
	tabstat abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2 if round==1 & recent_shock_`n'==1, statistics(mean)
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

table (MUN) (round), statistic(mean abs_index_A abs_index_B abs_index_C adapt_index_A adapt_index_B adapt_index_C transf_index_2) nototals
