// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

* food security (module 7)

rename Q7_1_A hunger // past 3 months
rename Q7_1_B hunger_freq // frequency in past 3 months
* Q7_2A* = food security (module 7)


save "Processed/FSP Baseline Processed.dta", replace
