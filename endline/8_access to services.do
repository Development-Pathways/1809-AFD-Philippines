// date: 29/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: Silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD 
// 			process access to helth, education, childcare and information services

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

//Health

*Dummy if child (0-5) has seen a doctor when sick

gen child_treat=(Q12_1_B1==1) | (Q12_1_B2==1) | (Q12_1_B3==1) | (Q12_1_B4==1) | (Q12_1_B5==1) | (Q12_1_B6==1) | (Q12_1_B7==1) | (Q12_1_B8==1) | (Q12_1_B9==1)

replace child_treat=. if age>=5

*at HH level
egen hh_treat_child=max(child_treat), by(hhid)

* how many HH have had a child sick

gen child_ill=(Q12_1_A1==1) | (Q12_1_A2==1) | (Q12_1_A3==1) | (Q12_1_A4==1) | (Q12_1_A5==1) | (Q12_1_A6==1) | (Q12_1_A7==1) | (Q12_1_A8==1) | (Q12_1_A9==1)

replace child_ill=. if age>=5

egen hh_ill_child=max(child_ill), by(hhid)


*Dummy if pregnant mother has received services

preserve

use "FSP Baseline/FSP Baseline 2023 Section 18. Pregnant or new mom women (delivered over the past 24 months).dta", clear

rename INTNO hhid

gen health_check = (Q18_D==1)
egen pregnant_health = max(health_check), by(hhid)

duplicates drop hhid, force
keep hhid pregnant_health 

tempfile pregnant
save `pregnant', replace

restore

merge m:1 hhid using `pregnant'

recode _merge (1=0 "No") (3=1 "Yes"), gen(has_pregnant)
drop _merge

/*
gen received_service = 0

local service_vars Q18_G1 Q18_G2 Q18_G3 Q18_G4 Q18_G5 Q18_G6 Q18_G7 Q18_G8 Q18_G9 Q18_G10 Q18_G11 Q18_G12 Q18_G13 Q18_G14 Q18_G15 Q18_G16 Q18_G17 Q18_G18

foreach var of local service_vars {
    replace received_service = 1 if `var' != 95 & !missing(`var')
}

*variable to check how many pregnant women at household level
gen has_pregnant = 0
replace has_pregnant = 1 if Q18_A!=.
count if has_pregnant == 1

*/

*Combination of child and pregnant mother

egen has_preg_or_child = rowmax(has_pregnant has_child05)

gen health_access = (pregnant_health==1 | hh_treat_child==1)
replace health_access = . if has_preg_or_child==0

*Access to child care

recode Q5_11C (2=0 "No") (1=1 "Yes") (8/9=.), gen(day_care)

*Access to information (Dummy if has phone, radio, tv)
gen access_info = (Q13_3A2!= 0 | Q13_3A3 != 0 | Q13_3A4 != 0)
label variable access_info "Access to info (radio, tv, phone)"


save "Processed/FSP Baseline Processed.dta", replace
