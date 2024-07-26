// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

* consumption (module 9)

* food groups consumed

forvalues i = 1/45 {
	replace Q9_1_`i' = Q9_1_`i'- 1  // recode 1-2 to 0-1
}

egen any_breadandcereal = rowmax(Q9_1_1 Q9_1_2 Q9_1_3 Q9_1_4)
// etc



* TOTAL[food group] = food consumption 
assert TOTAL_11  == TOTALCOOKED // and so on 

	egen food_consumption = rowtotal(TOTALRICE-TOTALCOOKED) // wrong: exceeds TOTALCONSUMPTION
	replace food_consumption = food_consumption/2 // similar not identical to TOTALCONSUMPTION

	egen check = rowtotal(Q9_1_6A_CASH_T Q9_1_6A_PAID_T Q9_1_6A_KIND_T Q9_1_6B_CASH_T Q9_1_6B_PAID_T Q9_1_6B_KIND_T Q9_1_6C_CASH_T Q9_1_6C_PAID_T Q9_1_6C_KIND_T Q9_1_6D_CASH_T Q9_1_6D_PAID_T Q9_1_6D_KIND_T)

* Q9_2_* = non-food consumption (monthly average over past 6 months)
* TOTALCONSUMPTION 

save "Processed/FSP Baseline Processed.dta", replace
