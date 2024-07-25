// date: 24/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: nayha
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD 
// 			process savings and credit module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

* savings and banking (module 14) 
rename Q_575 tot_savings

* borrowing (module 15)
rename Q15_1_CT tot_borrow

*Net savings

gen net_savings=.
replace net_savings=tot_savings-tot_borrow if tot_savings!=. & tot_savings!=0
replace net_savings=tot_savings if tot_borrow==-8


* Credit from "good sources" for "good uses"






* Debt for bad uses or from bad source


save "Processed/FSP Baseline Processed.dta", replace
