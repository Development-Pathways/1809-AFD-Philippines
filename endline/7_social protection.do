// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD 
// 			process social protection module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

* identify programme beneficiaries

* household indicator
* Q5_nA for programme n = 1/9
* Q5_mC for programme m = 10/16 20
* Q6_2_1A for pension

* amount received - 12 months
* Q5_nB for programme n = 1/9
* Q6_2_1B for pension

foreach var of varlist Q5_*B {
	su `var' if `var'>0
}


* access to safety nets 
	* cash for work / food for work
	* Pantawid Pamilya
	* Other cash transfer
	* Scholarship
	* Social Pension

* single programme dummies
forval i = 1/9 {
	gen prog_`i' = (Q5_`i'A==1)	
}
forval i = 10/16 {
	gen prog_`i' = (Q5_`i'C==1)	
}

label variable prog_8 "Pantawid Pamilya 4Ps"

gen prog_17 = (Q5_20C_OTH==1)

gen pension = (Q6_2_1A==1)

* multiple programme dummies
	
gen hh_safetynet = (Q5_7A==1 | Q5_8A==1 | Q5_9A==1 | Q5_10C==1 | Q5_13C==1)	

gen hh_safetynet2 = (Q5_7A==1 | Q5_8A==1 | Q5_9A==1 | Q5_10C==1 | Q5_13C==1 | Q5_12C==1)	

gen hh_safetynet_no4p = (Q5_7A==1 | Q5_9A==1 | Q5_10C==1 | Q5_13C==1)	

gen hh_inclusion = (Q5_14C==1 | Q5_15C==1 | Q5_16C==1) // livelihood

*gen hh_socinsur = (Q5_1A==1 | Q5_2A==1 | Q5_3A==1 | Q5_4A==1 | Q5_5A==1| Q5_6A==1)

gen hh_socinsur = (Q5_1A==1 | Q5_2A==1 | Q5_6A==1)

gen hh_healthins = (Q5_3A==1 | Q5_4A==1 | Q5_5A==1)

gen hh_SLP = (Q5_16C==1)

* number of schemes (0-11)

egen n_safetynet = rowtotal(prog_7-prog_13 prog_17)

egen n_prog = rowtotal(prog_1-prog_17)

* individual beneficiaries

/*

foreach j in 10 11 12 13 14 15 16 20 {
	
	forval i = 1/25 {
		
		preserve 

		duplicates drop hhid Q5_`j'_D`i', force
		keep hhid Q5_`j'_D`i'
		rename Q5_`j'_D`i' pid
		gen Q5_`j'_D`i'_ = 1
		tempfile Q5_`j'_D`i'
		save `Q5_`j'_D`i''

		restore 

		merge 1:1 hhid pid using `Q5_`j'_D`i'', keep(1 3) nogen	
	}
}

foreach j in 10 11 12 13 14 15 16 20 {
	egen Q5_`j' = rowtotal (Q5_`j'_D*_)
	drop Q5_`j'_D*
}

*/

foreach var of varlist prog_* pension hh_safetynet* hh_inclusion hh_socinsur n_prog  {
	tab MUN `var' if rel==1, row nofreq
*	reg `var' ib3.provmun if rel==1, robust
}

save "Processed/FSP Baseline Processed.dta", replace
