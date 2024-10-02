// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT endline survey, provided by ADB through AFD 
// 			process social protection module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Endline Processed.dta", clear

* multiple programme dummies
	
gen hh_inclusion = (other_subsidy_5==1 | other_subsidy_6==1 | other_subsidy_7==1) // livelihood

gen hh_socinsur = (health_subsidy_1==1 | health_subsidy_2==1 | health_subsidy_6==1)

gen hh_healthins = (health_subsidy_3==1 | health_subsidy_4==1 | health_subsidy_5==1)

* number of schemes (0-11)

egen n_safetynet = rowtotal(health_subsidy_7 health_subsidy_8 health_subsidy_99 other_subsidy_1 other_subsidy_2 other_subsidy_3 other_subsidy_4 other_subsidy_8)

egen n_prog = rowtotal(health_subsidy_* other_subsidy_*)

/*
foreach var of varlist prog_* pension hh_safetynet* hh_inclusion hh_socinsur n_prog  {
	tab MUN `var' if rel==1, row nofreq
*	reg `var' ib3.provmun if rel==1, robust
}
*/

save "Processed/FSP Endline Processed.dta", replace
