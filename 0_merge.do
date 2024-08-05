// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: merge datafiles from Walang Gutom RCT baseline survey, provided by ADB through AFD

clear all
set maxvar 32767 

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

*	import delimited "FSP Baseline/FSP BASELINE 2023 CAPI_2024_01_08_15_30.csv", clear

*	keep INTNO q13_1_a1-q13_2_c5

* individual level data
use "FSP Baseline/FSP Baseline 2023 Section 2. Household members information and Employment.dta", clear // ID 38,687
merge 1:1 ID using "FSP Baseline/FSP Baseline 2023 Section 12. Child Health.dta", nogen // ID 3,188
*merge 1:1 ID using "FSP Baseline/FSP Baseline 2023 Section 11. Child Nutrition.dta", nogen // ID 1,033
merge 1:1 ID using "FSP Baseline/FSP Baseline 2023 Section 17. Children Born in the Last 12 Months.dta", nogen // ID 456
*merge 1:1 ID using "FSP Baseline/FSP Baseline 2023 Section 18. Pregnant or new mom women (delivered over the past 24 months).dta" // no ID 957

* household level data
merge m:1 INTNO using "FSP Baseline/FSP Baseline 2023 Main Questionnaire Dataset.dta", nogen // INTNO 5,655

* variables provided by ADB : km_to_fixed_vendor treatment final_cluster cluster_size
merge m:1 INTNO using "FSP Baseline/AFD_request_Aug1.dta" // 335 households not matched 

order INTNO PROVINCE MUN BRGY CLUSTER final_cluster cluster_size treatment, first

* export summary
//estpost sum _all
//esttab using "FSP Baseline/descr.csv", cells("count mean sd min max") replace

rename INTNO hhid
rename HH_ROSTER pid

save "Processed/FSP Baseline Merged.dta", replace
