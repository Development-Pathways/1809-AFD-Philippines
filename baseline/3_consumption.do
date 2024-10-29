// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

* consumption (module 9)

/* food groups consumed

forvalues i = 1/45 {
	replace Q9_1_`i' = Q9_1_`i'- 1  // recode 1-2 to 0-1
}

egen any_breadandcereal = rowmax(Q9_1_1 Q9_1_2 Q9_1_3 Q9_1_4)
// etc

*/

/* not actually the same
assert TOTAL_1 == TOTALBREADANDCEREALS
assert TOTAL_2 == TOTALMEAT
assert TOTAL_3 == TOTALFISHANDSEAFOOD
assert TOTAL_4 == TOTALMILKDAIRYANDEGGS
assert TOTAL_5 == TOTALOILDANDFATS
assert TOTAL_6 == TOTALFRUITSANDNUTS
assert TOTAL_7 == TOTALVEGETABLES
assert TOTAL_8 == TOTALSUGARPROD
assert TOTAL_9 == TOTALFOODNEC
assert TOTAL_10 == TOTALNONALCOHOL
assert TOTAL_11  == TOTALCOOKED
*/

egen food_consumption = rowtotal(TOTALBREADANDCEREALS TOTALMEAT TOTALFISHANDSEAFOOD TOTALMILKDAIRYANDEGGS TOTALOILDANDFATS TOTALFRUITSANDNUTS TOTALVEGETABLES TOTALSUGARPROD TOTALFOODNEC TOTALNONALCOHOL TOTALCOOKED)

assert round(food_consumption) == round(TOTALCONSUMPTION) 

replace food_consumption = food_consumption/6 // monthly 

/* convert from "monthly average over past 6 months" to "6 months"
forvalues i = 1/16 {				// item 17 = other is missing
 replace Q9_2_`i' = Q9_2_`i'* 6 
}
*/

egen nonfood_consumption = rowtotal(Q9_2_*) // monthly

egen neces_consumption = rowtotal(food_consumption Q9_2_1 Q9_2_2 Q9_2_3 Q9_2_4) // schooling, health, utilities, rent

egen total_consumption = rowtotal(food_consumption nonfood_consumption) // monthly 

gen share_food = food_consumption/total_consumption
gen share_necess = neces_consumption/total_consumption

* check outliers
* graph box food_consumption , over(MUN)
* graph box nonfood_consumption , over(MUN)

* winsorise 
winsor2 food_consumption, cuts(0 99)
drop food_consumption
rename food_consumption_w food_consumption

foreach var of varlist food_consumption nonfood_consumption total_consumption {
	gen `var'_pc = `var'/hhsize
}

clonevar total_food_1mo_php = food_consumption
clonevar total_food_1mo_php_pc = food_consumption_pc
clonevar tot_non_food_expenses = nonfood_consumption
clonevar tot_non_food_expenses_pc = nonfood_consumption_pc


winsor2 Q9_2_1, cuts(0 99)

clonevar exp_edu = Q9_2_1_w

gen exp_edu_pchild = exp_edu/n_school_age

save "Processed/FSP Baseline Processed.dta", replace
