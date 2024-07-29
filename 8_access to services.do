// date: 29/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: Silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD 
// 			process access to helth, education, childcare and information services

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear



//Health
*Dummy if child has seen a doctor when sick

gen med_treatment=(Q12_1_B1==1) | (Q12_1_B2==1) | (Q12_1_B3==1) | (Q12_1_B4==1) | (Q12_1_B5==1) | (Q12_1_B6==1) | (Q12_1_B7==1) | (Q12_1_B8==1) | (Q12_1_B9==1)

clonevar child_treat=med_treatment
replace child_treat=0 if age>=18

*at HH level
egen hh_treat_child=max(child_treat), by(hhid)

* how many HH have had a child sick

gen unwell=(Q12_1_A1==1) | (Q12_1_A2==1) | (Q12_1_A3==1) | (Q12_1_A4==1) | (Q12_1_A5==1) | (Q12_1_A6==1) | (Q12_1_A7==1) | (Q12_1_A8==1) | (Q12_1_A9==1)

clonevar child_ill=med_treatment
replace child_ill=0 if age>=18

egen hh_ill_child=max(child_ill), by(hhid)


*Dummy if pregnant mother has received services

preserve

use "FSP Baseline/FSP Baseline 2023 Section 18. Pregnant or new mom women (delivered over the past 24 months).dta", clear

duplicates report INTNO Q18
duplicates drop INTNO Q18, force
sort INTNO
rename INTNO hhid
tempfile pregnant
save `pregnant', replace

restore

merge m:1 hhid using `pregnant',nogenerate


gen received_service = 0

local service_vars Q18_G1 Q18_G2 Q18_G3 Q18_G4 Q18_G5 Q18_G6 Q18_G7 Q18_G8 Q18_G9 Q18_G10 Q18_G11 Q18_G12 Q18_G13 Q18_G14 Q18_G15 Q18_G16 Q18_G17 Q18_G18

foreach var of local service_vars {
    replace received_service = 1 if `var' != 95 & !missing(`var')
}

*variable to check how many pregnant women
gen is_pregnant = 0
replace is_pregnant = 1 if Q18_A!=.
count if is_pregnant == 1

*Combination of child and pregnant mother


*Access to child care



*Access to information (Dummy if has phone, radio, tv)
gen access_info = 0
replace access_info = 1 if Q13_3A2!= 0 | Q13_3A3 != 0 | Q13_3A4 != 0
label variable access_info "Access to info (radio, tv, phone)"
label define access_info_lbl 0 "No" 1 "Yes"
label values access_info access_info_lbl


*Number of school aged children attending school, school age  5-17
gen attend_school = (age >= 5 & age <= 17) &  (edu!=2)

*Proportion of school aged children attending school, school age  5-17
gen school_age = (age >= 5 & age <= 17)
egen total_school_age = total(school_age)
egen total_attend_school = total(attend_school)
gen prop_attend_school = total_attend_school / total_school_age
