// date: 31/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: run scripts for the baseline analysis of Walang Gutom RCT 

global github "~/Documents/GitHub/1809-AFD-Philippines/endline"

do "$github/0_merge.do"
do "$github/1_clean.do"
do "$github/2_livelihoods.do"
do "$github/3_consumption.do"
do "$github/4_assets.do"
do "$github/5_savings and credit.do"
do "$github/6_food sec and shocks.do"
do "$github/7_social protection.do"
do "$github/8_access to services.do"
do "$github/9_resilience.do"
*do "$github/10_descriptives"
