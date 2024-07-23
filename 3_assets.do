// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD 
// 			process asset module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear


/*
* productive assets (module 13)
rename Q13_3C12V tot_asset_value

egen temp = rowtotal(Q13_3A*)
recode temp (17/max = 17 "17+"), gen(n_assets)

*/
