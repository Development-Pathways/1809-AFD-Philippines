// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: export tables of descriptive statistics

global data_folder "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "$data_folder/Processed/FSP Baseline Processed.dta", clear

cd "$data_folder/Tables"

* IND LEVEL

foreach var of varlist age10yrs ethnicity marital edu work nowork_reason work_type* sector* agri_work wage_work unfit_work {
	table (provmun) (`var'), statistic(percent, across(`var')) nformat(%5.1f)
	collect export "baseline-stats.xlsx", as(xlsx) sheet("`var'", replace) cell(B5) modify
	putexcel set "baseline-stats.xlsx", sheet("`var'") modify
	putexcel B2 = "Percentage distribution of individuals by `var' and location",  font("calibri" , 14)
	putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

/*
foreach var of varlist age10yrs ethnicity marital edu work nowork_reason work_type* sector* agri_work wage_work unfit_work {
	table (`var') (tondo), statistic(frequency) statistic(percent)
	collect label dim tondo "Location", modify
	collect label dim `var' "`vars'", modify
	collect recode result frequency = column1
	collect recode result percent = column2
	collect layout (`var') (tondo#result[column1 column2])	
	collect style cell result[column2], nformat (%4.0f)
	collect label levels result column1 "Freq"
	collect label levels result column2 "Perc"
	collect preview
	collect export urban_rural_ind.xlsx, sheet(`var') modify
}		
*/

* HH LEVEL
keep if rel==1

* differences between tondo (urban) and other study areas (rural) 

global general /*cluster_size*/ hhsize sex edu hh_maxedu hh_totedu hh_eduratio /*km_to_fixed_vendor*/
global income hh_active hh_work hh_wawork crop livestock fishing foodservice wholesale manufacturing trasportation other_activ hh_farm_income s_hh_vuln_income n_sources HHI 
global consumption fsec_score fooddivindex pcfoodcons
global assets tot_asset_value assetindex n_assets liquid_assetindex

iebaltab $general $income $assets , grpvar(tondo) /*vce(cluster location) balmiss(groupmean)*/ total replace save("urban_rural.xlsx")
		
reg tondo $general $income $assets , robust
outreg2 using "urban_rural_reg.xlsx.xls", replace



* mean sd min max freq by location and treatment
gen treatment = 1 // change to treatment var

foreach var of varlist $varlist{
	table (provmun) (treatment), statistic(mean $varlist) statistic(sd $varlist) statistic(min $varlist) statistic(max $varlist)  statistic(frequency) 
	collect recode result mean = column1
	collect recode result sd = column2
	collect recode result min = column3
	collect recode result max = column4
	collect recode result frequency = column5
	collect layout (provmun) (treatment#result[column1 column2 column3 column4 column5])
	collect style cell result[column1], nformat (%5.1f)
	collect style cell result[column2], nformat (%5.1f)
	collect style cell result[column3], nformat (%5.0f)
	collect style cell result[column4], nformat (%5.0f)
	collect style cell result[column5], nformat (%5.0f)
	collect label levels result column1 "Mean"
	collect label levels result column2 "SD"
	collect label levels result column3 "Min"
	collect label levels result column4 "Max"
	collect label levels result column5 "Obs"
	collect export "baseline-stats.xlsx", as(xlsx) sheet("_`var'", replace) cell(B5) modify
	putexcel set "baseline-stats.xlsx", sheet("_`var'") modify
	putexcel B2 = "Mean, standard deviation, minimum, maximum amd number of observations `var' by location",  font("calibri" , 14)
	putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

