// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT endline survey, provided by ADB through AFD 
// 			process savings and credit module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Endline Processed.dta", clear

* savings and banking (module 14) 

//amount

gen savings_pc = savings_php/hhsize

//presence 

gen has_savings = (savings_banks==1 | savings_coop==1 | savings_home==1 | savings_other==1 )

* borrowing (module 15)

	* borrowing_total_php

* Debt from "good sources" for "good uses" vs debt from "bad sources" for "bad uses"

gen any_debt = (Q15_1A ==1 | ///
				Q15_2A ==1 | ///
				Q15_3A ==1 | ///
				Q15_4A ==1 | /// 
				Q15_5A ==1 | ///
				Q15_6A ==1 | ///
				Q15_7A ==1)

 gen good_source = (Q15_1A ==1 | ///
					Q15_2A ==1 | ///
					Q15_4A ==1 | /// 
					Q15_6A ==1 | ///
					Q15_7A ==1)

gen bad_source = (Q15_3A==1 | Q15_5A==1) // bad source = pawnshop or loan shark					
	
destring Q15_*D*, replace	
	
gen bad_reason = 0 // bad reason = education or health
gen good_reason = 0 // any other reason
foreach var of varlist Q15_1D1 Q15_1D2 Q15_1D3 Q15_2D1 Q15_2D2 Q15_2D3 Q15_3D1 Q15_3D2 Q15_3D3 Q15_4D1 Q15_4D2 Q15_4D3 Q15_5D1 Q15_5D2 Q15_5D3 Q15_6D1 Q15_6D2 Q15_6D3 Q15_7D1 Q15_7D2 Q15_7D3 {
	replace bad_reason = 1 if `var'==1 | `var'==3
	replace good_reason = 1 if `var'==2 | `var'==4 | `var'==5 | `var'==6
}

gen bad_debt = (bad_source==1 | bad_reason==1)

gen good_debt = (good_source==1 & good_reason==1)

/*
foreach var of varlist tot_savings tot_borrow any_debt good_source bad_source bad_reason good_reason bad_debt good_debt {
	reg `var' i.MUN, robust
}
*/

save "Processed/FSP Endline Processed.dta", replace
