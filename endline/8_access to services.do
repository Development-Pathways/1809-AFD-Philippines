// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: Silvia
// purpose: clean data from Walang Gutom RCT endline survey, provided by ADB through AFD 
// 			process access to helth, education, childcare and information services

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Endline Processed.dta", clear

//Health

*Dummy if child (0-5) has seen a doctor when sick

destring Q12_1_B*, replace

gen child_treat=(Q12_1_B1==1) | (Q12_1_B2==1) | (Q12_1_B3==1) | (Q12_1_B4==1) | (Q12_1_B5==1) | (Q12_1_B6==1) | (Q12_1_B7==1) | (Q12_1_B8==1) | (Q12_1_B9==1)

replace child_treat=. if age>=5

*at HH level
egen hh_treat_child=max(child_treat), by(hhid)

* how many HH have had a child sick

gen child_ill=(Q12_1_A1==1) | (Q12_1_A2==1) | (Q12_1_A3==1) | (Q12_1_A4==1) | (Q12_1_A5==1) | (Q12_1_A6==1) | (Q12_1_A7==1) | (Q12_1_A8==1) | (Q12_1_A9==1)

replace child_ill=. if age>=5

egen hh_ill_child=max(child_ill), by(hhid)

*Combination of child and pregnant mother

egen has_preg_or_child = rowmax(has_pregnant has_child05)

gen health_access = (pregnant_health==1 | hh_treat_child==1)
replace health_access = . if has_preg_or_child==0

save "Processed/FSP Endline Processed.dta", replace
