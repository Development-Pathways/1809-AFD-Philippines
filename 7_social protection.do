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

* individual beneficiaries

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

save "Processed/FSP Baseline Processed.dta", replace
