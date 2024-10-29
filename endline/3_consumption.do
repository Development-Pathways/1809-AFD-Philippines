// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT endline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Endline Processed.dta", clear

* consumption (module 9)

/*
consumed_self_produced

total_food_1mo_php 
total_food_1mo_php_pc 

total2_food_1mo_php 
total2_food_1mo_php_pc 

tot_non_food_expenses
tot_non_food_expenses_pc

expenses_*
*/

*gen nonfood_consumption = tot_non_food_expenses

egen neces_consumption = rowtotal(total_food_1mo_php expenses_1 expenses_2 expenses_3 expenses_4) // schooling, health, utilities, rent

egen total_consumption = rowtotal (total_food_1mo_php tot_non_food_expenses)

gen share_food = total_food_1mo_php/total_consumption

gen share_necess = neces_consumption/total_consumption

*

winsor2 expenses_1 , cuts(0 99)

clonevar exp_edu = expenses_1_w

gen exp_edu_pchild = exp_edu/n_school_age


save "Processed/FSP Endline Processed.dta", replace
