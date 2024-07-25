// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD 
// 			process savings and credit module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

//total savings: tot_savings
//total borrowing: tot_borrow


gen net_savings=.
replace net_savings=tot_savings-tot_borrow if tot_savings!=. & tot_savings!=0
replace net_savings=tot_savings if tot_borrow==-8


