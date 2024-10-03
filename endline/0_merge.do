
// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: merge datafiles from Walang Gutom RCT endline survey, provided by ADB through AFD


clear
clear matrix
clear mata
set maxvar 32000

global ADB "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/ADB Dropbox/endline"

global processed "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed"

* INDIVIDUAL LEVEL
import delimited "$ADB/FSP ENDLINE 2024_Section 2-3.5_LONG VALUES (17Aug24).csv", case(preserve) clear // INTNO COUNT 37,147

*import delimited "$path/FSP ENDLINE 2024_Section 2-3.5_Long LABELS (17Aug24).csv", case(preserve) clear // INTNO COUNT 37,147

/* identify and drop non-numeric
list INTNO if missing(real(INTNO))
drop if missing(real(INTNO)) 
*/

tostring INTNO, replace

save "$processed/FSP Endline_ind.dta" , replace

* HOUSEHOLD LEVEL

* extract shock months from label version 

import delimited "$ADB/FSP Endline 2024 Main Questionnaire_LABEL (21Aug24).csv", case(preserve) clear 

* identify and drop non-numeric
list INTNO if missing(real(INTNO))
drop if missing(real(INTNO)) 

keep INTNO Q16_B_*

/* 

forval n = 1/8 {
	tab Q16_B_`n' MUN
}

*/

tempfile Q16_B
save `Q16_B', replace

import delimited "$ADB/FSP Endline 2024 Main Questionnaire_VALUE (21Aug24).csv", case(preserve) clear // INTNO 4,941

* identify and drop non-numeric
list INTNO if missing(real(INTNO))
drop if missing(real(INTNO)) 

drop Q16_B*

merge 1:1 INTNO using `Q16_B', nogenerate

destring PROVINCE MUN, replace

merge 1:m INTNO using "$processed/FSP Endline_ind.dta" , nogenerate keep(3)

destring INTNO, replace

merge m:1 INTNO using "$ADB/endline_household_data.dta", keep(3) nogenerate

drop fcs* raw* spending_1mo_baby_food-kg_price_water one_way* child_*

/*
keep INTNO urban urban_tondo hours_worked_1day ///
wages_1_mo_total crop_sold_php_1mo livestock_sold_php_1mo fish_sold_php_1mo enterprise_food_rev_1mo enterprise_retail_rev_1mo enterprise_manufacturing_rev_1mo enterprise_transport_rev_1mo enterprise_other_rev_1mo other_income_php_1mo health_subsidy_php_1mo cash_assistance_php_1mo pension_income_php_1mo rental_income_php_1mo interest_income_php_1mo hh_income_1_mo hh_income_1_mo_pc ///
enterprise_crop_farming enterprise_livestock enterprise_fish enterprise_food enterprise_retail enterprise_manufacturing enterprise_transport enterprise_other ///
health_subsidy_* other_subsidy_* cash_assistance_* receives_pension pension_income_php receives_rental_income rental_income_php receives_interest_income interest_income_php receives_other_income other_income_php receives_interest_relatives interest_relatives_php ///
consumed_self_produced total_food_1mo_php total_food_1mo_php_pc total2_food_1mo_php total2_food_1mo_php_pc tot_non_food_expenses tot_non_food_expenses_pc expenses_* ///
borrow_* savings_* land_* farm_asset_* non_farm_asset_* ///
shock_* cantril_ladder self_poverty any_hunger_3mo hunger_frequent fies fies_raw resilience_climate_* ///
program_invited program_joined program_times_used program_num_vendors registered_walang_gutom control_spillover_* received_train_nutrition self_reported_training_* 
*/

* save "$processed/FSP Endline Merged.dta" , replace

*** child module

preserve 

import delimited "$ADB/FSP ENDLINE 2024_Section_12. Child Health LONG VALUES (17Aug24).csv", case(preserve) clear 

rename Q12_CHILDNAME COUNT

* keep INTNO COUNT Q12*

tempfile children
save `children', replace

restore

merge 1:1 INTNO COUNT using `children', nogenerate

* save "$processed/FSP Endline Merged.dta" , replace

*** mother module

preserve

import delimited "$ADB/FSP ENDLINE 2024_Section_18. Pregnant or New mom women_LONG VALUES (17Aug24).csv", case(preserve) clear 

gen health_check = (Q18_D==1)
egen pregnant_health = max(health_check), by(INTNO)

duplicates drop INTNO, force
keep INTNO pregnant_health 

tempfile pregnant
save `pregnant', replace

restore

merge m:1 INTNO using `pregnant'

recode _merge (1=0 "No") (3=1 "Yes"), gen(has_pregnant)
drop _merge

save "$processed/FSP Endline Merged.dta" , replace
